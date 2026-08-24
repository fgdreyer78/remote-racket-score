import 'package:flutter_tts/flutter_tts.dart';
import 'package:audio_session/audio_session.dart';

import '../models/game_config.dart';
import '../models/score_state.dart';
import '../providers/tts_config_provider.dart';

class TtsService {
  TtsService() {
    _tts = FlutterTts();
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(0.9);
  }

  late final FlutterTts _tts;
  String _currentLanguage = 'pt-BR';

  Future<void> _ensureLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;
    _currentLanguage = languageCode;
    await _tts.setLanguage(languageCode);
    await _trySetMaleVoice(languageCode);
  }

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
        if (name.contains('male') ||
            name.contains('homem') ||
            name.contains('masculin')) {
          await _tts.setVoice({
            'name': map['name']?.toString() ?? '',
            'locale': map['locale']?.toString() ?? languageCode
          });
          return;
        }
      }
      for (final v in voices) {
        final map = v is Map ? Map<String, dynamic>.from(v as Map) : null;
        if (map == null) continue;
        final locale = map['locale']?.toString().toLowerCase() ?? '';
        if (!locale.startsWith(langPrefix)) continue;
        final gender =
            (map['gender'] ?? map['voice'] ?? '').toString().toLowerCase();
        if (gender.contains('male') || gender.contains('homem')) {
          await _tts.setVoice({
            'name': map['name']?.toString() ?? '',
            'locale': map['locale']?.toString() ?? languageCode
          });
          return;
        }
      }
    } catch (_) {}
  }

  Future<void> _configureAudioRoute() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.alarm,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
      ));
    } catch (e) {
      // Ignora falhas de sessão
    }
  }

  // ─── Locuções usando TtsConfig ───────────────────────────────

  Future<void> speakCurrentScore(
      ScoreState state, GameConfig config, TtsConfig ttsConfig) async {
    await _ensureLanguage(ttsConfig.languageCode);
    if (state.isTiebreak) {
      final sa = state.tiebreakPointsA;
      final sb = state.tiebreakPointsB;
      if (sa == 0 && sb == 0) return;
      final first = state.serverIsA ? sa : sb;
      final second = state.serverIsA ? sb : sa;
      await _speak(
          '$first ${ttsConfig.phrase('tiebreakScore')} $second ${ttsConfig.phrase('tiebreakSuffix')}',
          config);
      return;
    }
    final pa = state.pointsA;
    final pb = state.pointsB;

    // Vantagem: ambos com ≥3 pontos e um à frente por 1 ponto
    if (pa >= 3 && pb >= 3 && (pa - pb).abs() == 1) {
      final advantagePlayer = pa > pb ? config.playerAName : config.playerBName;
      await speakAdvantage(advantagePlayer, config, ttsConfig);
      return;
    }

    // Placar empatado: ambos com o mesmo número de pontos → "X iguais"
    if (pa == pb) {
      final s = ttsConfig.pointWord(pa);
      await _speak('$s ${ttsConfig.phrase('deuce')}', config);
      return;
    }

    final serverPoints = state.serverIsA ? pa : pb;
    final receiverPoints = state.serverIsA ? pb : pa;

    final s = ttsConfig.pointWord(serverPoints);
    final r = ttsConfig.pointWord(receiverPoints);

    await _speak('$s $r', config);
  }

  Future<void> speakGameAndSetScore(ScoreState newState,
      ScoreState previousState, GameConfig config, TtsConfig ttsConfig) async {
    await _ensureLanguage(ttsConfig.languageCode);
    final newGa = newState.gamesA;
    final newGb = newState.gamesB;
    final aWonGame = newGa > previousState.gamesA;
    final gameWinnerName = aWonGame ? config.playerAName : config.playerBName;
    final setNumber = newState.currentSet;
    final ordinal = ttsConfig.ordinal(setNumber);

    // 1. SEMPRE diz "Game [JOGADOR]"
    await _speak('${ttsConfig.phrase('game')} $gameWinnerName', config);

    // 2. Placar do set
    if (newGa == newGb) {
      // Empate — usar singular/game quando 1 a 1, plural/games caso contrário
      final gameUnit = newGa == 1
          ? ttsConfig.phrase('gameUnitSingular')
          : ttsConfig.phrase('gamesUnit');
      await _speak(
          '$ordinal ${ttsConfig.phrase('setTied')} $newGa $gameUnit a $newGb',
          config);
    } else {
      // Quem lidera (baseado no placar REAL de games)
      final leaderName =
          newGa > newGb ? config.playerAName : config.playerBName;
      final leaderGames = newGa > newGb ? newGa : newGb;
      final otherGames = newGa > newGb ? newGb : newGa;
      final unit = leaderGames == 1
          ? ttsConfig.phrase('gameUnitSingular')
          : ttsConfig.phrase('gamesUnit');
      await _speak(
          '$leaderName ${ttsConfig.phrase('leads')} $leaderGames $unit $otherGames',
          config);
    }
  }

  Future<void> speakTiebreakAndSet(ScoreState newState,
      ScoreState previousState, GameConfig config, TtsConfig ttsConfig) async {
    await _ensureLanguage(ttsConfig.languageCode);
    final aWon = newState.setsA > previousState.setsA;
    final name = aWon ? config.playerAName : config.playerBName;
    final ga = newState.gamesA;
    final gb = newState.gamesB;
    final winnerGames = aWon ? ga : gb;
    final otherGames = aWon ? gb : ga;
    await _speak(
        '$name ${ttsConfig.phrase('leads')} $winnerGames ${ttsConfig.phrase('gamesUnit')} $otherGames',
        config);
  }

  Future<void> speakMatchWinner(
      ScoreState state, GameConfig config, TtsConfig ttsConfig) async {
    await _ensureLanguage(ttsConfig.languageCode);
    final name =
        state.winnerIsA == true ? config.playerAName : config.playerBName;
    await _speak('${ttsConfig.phrase('matchWinner')} $name', config);
  }

  Future<void> speakAdvantage(
      String playerName, GameConfig config, TtsConfig ttsConfig) async {
    await _ensureLanguage(ttsConfig.languageCode);
    await _speak('${ttsConfig.phrase('advantage')} $playerName', config);
  }

  Future<void> speakTiebreakStart(
      ScoreState newState, GameConfig config, TtsConfig ttsConfig) async {
    await _ensureLanguage(ttsConfig.languageCode);
    final setNumber = newState.currentSet;
    final ordinal = ttsConfig.ordinal(setNumber);
    await _speak('$ordinal ${ttsConfig.phrase('tiebreak')}', config);
  }

  Future<void> speakSetWinner(ScoreState previousState, ScoreState newState,
      GameConfig config, TtsConfig ttsConfig) async {
    await _ensureLanguage(ttsConfig.languageCode);
    final aWonSet = newState.setsA > previousState.setsA;
    final name = aWonSet ? config.playerAName : config.playerBName;
    final setNumber = newState.setsA + newState.setsB;
    final ordinal = ttsConfig.ordinal(setNumber);
    await _speak(
        '${ttsConfig.phrase('setWinnerPrefix')} $ordinal set $name', config);
  }

  Future<void> speakTimeWarning(GameConfig config, TtsConfig ttsConfig) async {
    await _ensureLanguage(ttsConfig.languageCode);
    await _speak(ttsConfig.phrase('timeWarning'), config);
  }

  Future<void> speakCoinToss(
      String text, GameConfig config, TtsConfig ttsConfig) async {
    await _ensureLanguage(ttsConfig.languageCode);
    await _speak(text, config);
  }

  // ─── Ponto de entrada principal ──────────────────────────────

  Future<void> announceTransition(ScoreState previousState, ScoreState newState,
      GameConfig config, TtsConfig ttsConfig) async {
    if (newState.matchOver) {
      await speakMatchWinner(newState, config, ttsConfig);
      return;
    }
    if (newState.isTiebreak && !previousState.isTiebreak) {
      await speakTiebreakStart(newState, config, ttsConfig);
      return;
    }
    final setJustEnded = (newState.setsA != previousState.setsA) ||
        (newState.setsB != previousState.setsB);
    if (setJustEnded) {
      await speakSetWinner(previousState, newState, config, ttsConfig);
      return;
    }
    final gameJustEnded = (newState.gamesA != previousState.gamesA ||
            newState.gamesB != previousState.gamesB) &&
        !newState.isTiebreak;
    if (gameJustEnded) {
      await speakGameAndSetScore(newState, previousState, config, ttsConfig);
      return;
    }
    // Vantagem: ambos com ≥3 pontos e um à frente por 1 ponto
    if (newState.pointsA >= 3 &&
        newState.pointsB >= 3 &&
        (newState.pointsA - newState.pointsB).abs() == 1) {
      final advantagePlayer = newState.pointsA > newState.pointsB
          ? config.playerAName
          : config.playerBName;
      await speakAdvantage(advantagePlayer, config, ttsConfig);
      return;
    }
    await speakCurrentScore(newState, config, ttsConfig);
  }

  Future<void> _speak(String text, GameConfig config) async {
    await _configureAudioRoute();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
