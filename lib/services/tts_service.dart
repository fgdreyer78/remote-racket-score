import 'package:flutter_tts/flutter_tts.dart';

import '../features/score/scoring_engine.dart';
import '../models/game_config.dart';
import '../models/score_state.dart';

/// Serviço de Text-to-Speech para narrar o placar.
/// Regras: sempre anuncia pontuação do sacador primeiro; ao fim do game anuncia "Game [vencedor]" e depois o placar do set.
class TtsService {
  TtsService() {
    _tts = FlutterTts();
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(0.9); // Tom mais neutro/grave, estilo chair umpire.
  }

  late final FlutterTts _tts;
  String _currentLanguage = 'pt-BR';
  final List<String> _numberWords = [
    'zero', 'um', 'dois', 'três', 'quatro', 'cinco', 'seis', 'sete', 'oito', 'nove', 'dez'
  ];

  String _n(int i) => i < _numberWords.length ? _numberWords[i] : '$i';

  Future<void> _ensureLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;
    _currentLanguage = languageCode;
    await _tts.setLanguage(languageCode);
    await _trySetMaleVoice(languageCode);
  }

  /// Preferência por voz masculina/neutra (chair umpire). Busca vozes do idioma e usa a primeira que pareça masculina.
  Future<void> _trySetMaleVoice(String languageCode) async {
    try {
      final voices = await _tts.getVoices;
      if (voices == null || voices.isEmpty) return;
      final langPrefix = languageCode.toLowerCase().split('-').first;
      for (final v in voices) {
        final map = v is Map ? Map<String, dynamic>.from(v as Map) : null;
        if (map == null) continue;
        final locale = map['locale']?.toString().toLowerCase() ?? '';
        if (!locale.startsWith(langPrefix)) continue;
        final name = (map['name'] ?? map['id'] ?? '').toString().toLowerCase();
        if (name.contains('male') || name.contains('homem') || name.contains('masculin')) {
          await _tts.setVoice({'name': map['name']?.toString() ?? '', 'locale': map['locale']?.toString() ?? languageCode});
          return;
        }
      }
      for (final v in voices) {
        final map = v is Map ? Map<String, dynamic>.from(v as Map) : null;
        if (map == null) continue;
        final locale = map['locale']?.toString().toLowerCase() ?? '';
        if (!locale.startsWith(langPrefix)) continue;
        final gender = (map['gender'] ?? map['voice'] ?? '').toString().toLowerCase();
        if (gender.contains('male') || gender.contains('homem')) {
          await _tts.setVoice({'name': map['name']?.toString() ?? '', 'locale': map['locale']?.toString() ?? languageCode});
          return;
        }
      }
    } catch (_) {}
  }

  /// Anuncia o placar atual (sacar primeiro). Sem "a": "15 30", "30 40". Iguais: "15 iguais" / "15 all". EN: 0 = love.
  Future<void> speakCurrentScore(
    ScoreState state,
    GameConfig config,
  ) async {
    await _ensureLanguage(config.ttsLanguage);
    if (state.isTiebreak) {
      final sa = state.tiebreakPointsA;
      final sb = state.tiebreakPointsB;
      if (sa == 0 && sb == 0) return; // Não fala 0 a 0 no tiebreak; anúncio de entrada é em outro lugar.
      final first = state.serverIsA ? sa : sb;
      final second = state.serverIsA ? sb : sa;
      if (config.ttsLanguage == 'pt-BR') {
        await _speak('$first a $second no taibrêik');
      } else {
        await _speak('$first to $second in the tiebreak');
      }
      return;
    }
    final serverPoints = state.serverIsA ? state.pointsA : state.pointsB;
    final receiverPoints = state.serverIsA ? state.pointsB : state.pointsA;
    final other = state.serverIsA ? state.pointsB : state.pointsA;
    final isEqual = serverPoints == receiverPoints && serverPoints <= 3;
    final equalWord = config.ttsLanguage == 'pt-BR' ? 'iguais' : 'all';
    if (config.ttsLanguage == 'en-US') {
      final s = _pointWordEn(serverPoints);
      final r = _pointWordEn(receiverPoints);
      if (isEqual) {
        await _speak('$s $equalWord');
      } else {
        await _speak('$s $r');
      }
    } else {
      final s = _pointWordPt(serverPoints);
      final r = _pointWordPt(receiverPoints);
      if (isEqual) {
        await _speak('$s $equalWord');
      } else {
        await _speak('$s $r');
      }
    }
  }

  String _pointWordPt(int points) {
    switch (points) {
      case 0: return 'zero';
      case 1: return '15';
      case 2: return '30';
      case 3: return '40';
      default: return '40';
    }
  }

  String _pointWordEn(int points) {
    switch (points) {
      case 0: return 'love';
      case 1: return 'fifteen';
      case 2: return 'thirty';
      case 3: return 'forty';
      default: return 'forty';
    }
  }

  /// Após o game: "(Nome do vencedor) lidera por X games a Y" / "(Name) leads X games to Y".
  Future<void> speakGameAndSetScore(ScoreState newState, ScoreState previousState, GameConfig config) async {
    await _ensureLanguage(config.ttsLanguage);
    final newGa = newState.gamesA;
    final newGb = newState.gamesB;
    final aWonGame = newGa > previousState.gamesA;
    final name = aWonGame ? config.playerAName : config.playerBName;
    final winnerGames = aWonGame ? newGa : newGb;
    final otherGames = aWonGame ? newGb : newGa;
    if (config.ttsLanguage == 'pt-BR') {
      await _speak('$name lidera por $winnerGames games a $otherGames');
    } else {
      await _speak('$name leads $winnerGames games to $otherGames');
    }
  }

  /// Após tiebreak (fim do set): mesmo formato "(Name) leads X games to Y".
  Future<void> speakTiebreakAndSet(ScoreState newState, ScoreState previousState, GameConfig config) async {
    await _ensureLanguage(config.ttsLanguage);
    final aWon = newState.setsA > previousState.setsA;
    final name = aWon ? config.playerAName : config.playerBName;
    final ga = newState.gamesA;
    final gb = newState.gamesB;
    final winnerGames = aWon ? ga : gb;
    final otherGames = aWon ? gb : ga;
    if (config.ttsLanguage == 'pt-BR') {
      await _speak('$name lidera por $winnerGames games a $otherGames');
    } else {
      await _speak('$name leads $winnerGames games to $otherGames');
    }
  }

  /// Fim da partida: "Game, set, match (NOME)" PT / "Game, set and match (NAME)" EN.
  Future<void> speakMatchWinner(ScoreState state, GameConfig config) async {
    await _ensureLanguage(config.ttsLanguage);
    final name = state.winnerIsA == true ? config.playerAName : config.playerBName;
    if (config.ttsLanguage == 'pt-BR') {
      await _speak('Game, set, match $name');
    } else {
      await _speak('Game, set and match $name');
    }
  }

  /// Vantagem: só "Vantagem (Nome)" / "Advantage (Name)".
  Future<void> speakAdvantage(String playerName, GameConfig config) async {
    await _ensureLanguage(config.ttsLanguage);
    if (config.ttsLanguage == 'pt-BR') {
      await _speak('Vantagem $playerName');
    } else {
      await _speak('Advantage $playerName');
    }
  }

  /// Entrada no tiebreak: "Tiebreak" PT / "X set tiebreak" EN.
  Future<void> speakTiebreakStart(ScoreState newState, GameConfig config) async {
    await _ensureLanguage(config.ttsLanguage);
    if (config.ttsLanguage == 'pt-BR') {
      await _speak('Taibrêik');
    } else {
      final setNumber = newState.currentSet;
      final ord = _ordinalSetName(setNumber, config.ttsLanguage);
      await _speak('$ord set tiebreak');
    }
  }

  /// Fim de set: "Game e primeiro/segundo/terceiro set [Nome]".
  Future<void> speakSetWinner(
    ScoreState previousState,
    ScoreState newState,
    GameConfig config,
  ) async {
    await _ensureLanguage(config.ttsLanguage);
    final setsBeforeA = previousState.setsA;
    final setsBeforeB = previousState.setsB;
    final setsAfterA = newState.setsA;
    final setsAfterB = newState.setsB;
    final aWonSet = setsAfterA > setsBeforeA;
    final name = aWonSet ? config.playerAName : config.playerBName;
    final setNumber = setsAfterA + setsAfterB; // 1,2,3...
    final ordinal = _ordinalSetName(setNumber, config.ttsLanguage);
    if (config.ttsLanguage == 'pt-BR') {
      await _speak('Game e $ordinal set $name');
    } else {
      await _speak('Game and $ordinal set $name');
    }
  }

  String _ordinalSetName(int setNumber, String languageCode) {
    if (languageCode == 'pt-BR') {
      switch (setNumber) {
        case 1:
          return 'primeiro';
        case 2:
          return 'segundo';
        case 3:
          return 'terceiro';
        case 4:
          return 'quarto';
        case 5:
          return 'quinto';
        default:
          return '$setNumberº';
      }
    } else {
      switch (setNumber) {
        case 1:
          return 'first';
        case 2:
          return 'second';
        case 3:
          return 'third';
        case 4:
          return 'fourth';
        case 5:
          return 'fifth';
        default:
          return '${setNumber}th';
      }
    }
  }

  /// Aviso de tempo (entre pontos/games/sets). PT: "Táim" para pronúncia; EN: "Time".
  Future<void> speakTimeWarning(GameConfig config) async {
    await _ensureLanguage(config.ttsLanguage);
    if (config.ttsLanguage == 'pt-BR') {
      await _speak('Táim');
    } else {
      await _speak('Time');
    }
  }

  /// Resultado do coin toss.
  Future<void> speakCoinToss(String text, GameConfig config) async {
    await _ensureLanguage(config.ttsLanguage);
    await _speak(text);
  }

  /// Anuncia a transição de [previousState] para [newState]: ponto atual, ou game/set/partida se aplicável.
  Future<void> announceTransition(
    ScoreState previousState,
    ScoreState newState,
    GameConfig config,
  ) async {
    if (newState.matchOver) {
      await speakMatchWinner(newState, config);
      return;
    }
    // Entrada no tiebreak: não fala 0 a 0, fala "Tiebreak" / "X set tiebreak".
    if (newState.isTiebreak && !previousState.isTiebreak) {
      await speakTiebreakStart(newState, config);
      return;
    }
    final setJustEnded =
        (newState.setsA != previousState.setsA) || (newState.setsB != previousState.setsB);
    if (setJustEnded) {
      await speakSetWinner(previousState, newState, config);
      return;
    }
    final gameJustEnded = (newState.gamesA != previousState.gamesA ||
            newState.gamesB != previousState.gamesB) &&
        !newState.isTiebreak;
    if (gameJustEnded) {
      await speakGameAndSetScore(newState, previousState, config);
      return;
    }
    // Vantagem: só "Vantagem (Nome)" / "Advantage (Name)".
    if (config.withAdvantage) {
      if (newState.pointsA == 4 && newState.pointsB == 3) {
        await speakAdvantage(config.playerAName, config);
        return;
      }
      if (newState.pointsB == 4 && newState.pointsA == 3) {
        await speakAdvantage(config.playerBName, config);
        return;
      }
    }
    await speakCurrentScore(newState, config);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
