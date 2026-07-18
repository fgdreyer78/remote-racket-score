// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Remote Racket Score';

  @override
  String get home => 'Menu Principal';

  @override
  String get newGame => 'NOVO JOGO';

  @override
  String get presets => 'PRESETS';

  @override
  String get history => 'HISTÓRICO';

  @override
  String get settings => 'CONFIGURAÇÕES';

  @override
  String get version => 'v1.0';

  @override
  String get playerA => 'Jogador / Dupla A';

  @override
  String get playerB => 'Jogador / Dupla B';

  @override
  String get playerANameHint => 'Nome do jogador ou dupla A';

  @override
  String get playerBNameHint => 'Nome do jogador ou dupla B';

  @override
  String get presetLabel => 'Preset de Jogo';

  @override
  String get presetDefault => 'Padrão (última configuração)';

  @override
  String get presetNone => 'Nenhum preset salvo. Será usado o padrão (Tênis).';

  @override
  String get play => 'JOGAR';

  @override
  String get fillBothNames => 'Preencha os nomes dos dois jogadores/duplas.';

  @override
  String get differentNames => 'Os nomes dos jogadores devem ser diferentes.';

  @override
  String get startMatch => 'Iniciar partida?';

  @override
  String get presetLabelShort => 'Preset';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String get coinToss => 'Coin Toss';

  @override
  String coinTossWinner(String winner) {
    return '$winner ganhou o sorteio!\nEscolha:';
  }

  @override
  String get receive => 'Receber';

  @override
  String get serve => 'Sacar';

  @override
  String get skip => 'Pular';

  @override
  String get score => 'Placar';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get noMatches => 'Nenhuma partida registrada';

  @override
  String get noMatchesHint => 'Finalize uma partida para vê-la aqui';

  @override
  String get clearHistory => 'Limpar histórico';

  @override
  String get clearHistoryConfirm =>
      'Deseja apagar todo o histórico de partidas?';

  @override
  String get delete => 'Apagar';

  @override
  String get deleteMatch => 'Apagar partida?';

  @override
  String get share => 'Compartilhar';

  @override
  String get matchDetail => 'Detalhes da Partida';

  @override
  String get duration => 'Duração';

  @override
  String get matchStats => 'Estatísticas Gerais';

  @override
  String get games => 'Games';

  @override
  String get totalPoints => 'Total de Pontos';

  @override
  String get pointPercentage => 'Aproveitamento de Pontos';

  @override
  String get scoreBySet => 'Placar por Set';

  @override
  String get breakPoints => 'Break Points';

  @override
  String get breakPointsFaced => 'Break Points Enfrentados';

  @override
  String get breakGames => 'Jogos de Break';

  @override
  String get gameSequence => 'Sequência de Games';

  @override
  String winner(String name) {
    return 'Vencedor';
  }

  @override
  String winnerLabel(String name) {
    return 'Vencedor: $name';
  }

  @override
  String get settingsTitle => 'Configurações da partida';

  @override
  String get sportName => 'Nome do esporte / configuração';

  @override
  String get gamesAndSets => 'Games e Sets';

  @override
  String get gamesToWinSet => 'Games para ganhar o set';

  @override
  String get minGameDifference => 'Diferença mínima de games';

  @override
  String get numberOfSets => 'Número de sets (melhor de)';

  @override
  String get tiebreak => 'Tiebreak';

  @override
  String get tiebreakAt => 'Tiebreak ao empatar em';

  @override
  String get tiebreakPoints => 'Pontos para ganhar tiebreak';

  @override
  String get tiebreakDifference => 'Diferença no tiebreak';

  @override
  String get finalSetTiebreak => 'Tiebreak como set decisivo';

  @override
  String get timerAndBreaks => 'Cronômetro e Tempos';

  @override
  String get serveClock => 'Relógio de saque (segundos)';

  @override
  String get oddGamesBreak => 'Intervalo entre games ímpares (segundos)';

  @override
  String get evenGamesBreak => 'Intervalo entre games pares (segundos)';

  @override
  String get setsBreak => 'Intervalo entre sets (segundos)';

  @override
  String get timeWarning => 'Aviso sonoro \"Tempo\" (games ímpares e sets)';

  @override
  String get pointFlash => 'Flash Visual ao Marcar Ponto';

  @override
  String get enableFlash => 'Ativar flash visual';

  @override
  String get flashFrequency => 'Frequência (vezes/seg)';

  @override
  String get flashDuration => 'Duração total (ms)';

  @override
  String get speechLanguage => 'Idioma de Fala';

  @override
  String get saveToHistory => 'Salvar no Histórico';

  @override
  String get autoSave => 'Salvar automaticamente ao fim da partida';

  @override
  String get autoSaveDelay => 'Aguardar antes de salvar (segundos)';

  @override
  String get saveSettings => 'Salvar configurações';

  @override
  String get layout => 'Layout do Placar';

  @override
  String get layoutDefault => 'Padrão (retrato / paisagem)';

  @override
  String get layoutSplit => 'Paisagem dividido (lado a lado)';

  @override
  String get newMatch => 'Nova partida';

  @override
  String get resetMatchConfirm =>
      'Tem certeza que deseja resetar o placar e iniciar uma nova partida?';

  @override
  String get mapButtons => 'Mapear botões';

  @override
  String get configurations => 'Configurações';

  @override
  String get sportSettings => 'Dispositivos de Pontuação';

  @override
  String get sportSettingsHint => 'Botões de volume, mídia e teclado';

  @override
  String get scoreLayout => 'Layout do Placar';

  @override
  String get scoreLayoutHint => 'Em breve';

  @override
  String get language => 'Idioma';

  @override
  String get languageHint => 'Em breve';

  @override
  String get portuguese => 'Português (Brasil)';

  @override
  String get english => 'English (US)';
}
