/// Configuração completa da partida (tênis, padel, etc.).
class GameConfig {
  const GameConfig({
    this.sportName = 'Tênis',
    this.playerAName = 'Time A',
    this.playerBName = 'Time B',
    this.gamesToWinSet = 6,
    this.minGameDifference = 2,
    this.maxSets = 3,
    this.tiebreakAt = 6,
    this.tiebreakPoints = 7,
    this.tiebreakDifference = 2,
    this.finalSetTiebreakPoints = 7,
    this.useFinalSetTiebreak = true,
    this.withAdvantage = true,
    this.miniMatchGames = false,
    this.miniMatchGamesCount = 3,
    this.ttsLanguage = 'pt-BR',
    this.serveClockSeconds = 0,
    this.breakBetweenOddGamesSeconds = 0,
    this.breakBetweenEvenGamesSeconds = 0,
    this.breakBetweenSetsSeconds = 0,
    this.timeWarningSound = true,
    // Flash visual ao registrar ponto
    this.pointFlashEnabled = false,
    this.pointFlashDurationMs = 600,
    this.pointFlashFrequencyHz = 4,
    // Layout do placar: 0 = padrão, 1 = landscape dividido
    this.layoutMode = 0,
    // Auto-save no histórico
    this.autoSaveToHistory = true,
    this.autoSaveDelaySeconds = 10,
  });

  final String sportName;

  /// Nomes dos jogadores (não salvos em presets, apenas na sessão atual).
  final String playerAName;
  final String playerBName;

  /// Games para ganhar o set (ex.: 6 no tênis).
  final int gamesToWinSet;

  /// Diferença mínima de games (ex.: 2 = 6-4, 7-5).
  final int minGameDifference;

  /// Melhor de N sets (1, 3 ou 5).
  final int maxSets;

  /// Empatar em X games ativa o tiebreak (ex.: 6).
  final int tiebreakAt;

  /// Pontos para ganhar o tiebreak (7 ou 10).
  final int tiebreakPoints;
  final int tiebreakDifference;

  /// Set decisivo: tiebreak até quantos pontos (ex.: 7 ou 10).
  final int finalSetTiebreakPoints;
  final bool useFinalSetTiebreak;

  /// true = jogo com vantagem (40-40 → vantagem → game).
  final bool withAdvantage;

  /// true = mini partida até [miniMatchGamesCount] games (sem sets).
  final bool miniMatchGames;
  final int miniMatchGamesCount;

  /// Idioma da locução TTS (por exemplo: 'pt-BR' ou 'en-US').
  final String ttsLanguage;

  /// Tempo de saque após o ponto (segundos). 0 = desativado.
  final int serveClockSeconds;

  /// Intervalo entre games ímpares (soma de games do set é ímpar). 0 = desativado.
  final int breakBetweenOddGamesSeconds;

  /// Intervalo entre games pares (soma de games do set é par). 0 = desativado.
  final int breakBetweenEvenGamesSeconds;

  /// Tempo entre sets (segundos). 0 = desativado.
  final int breakBetweenSetsSeconds;

  /// Ao fim do tempo, aviso sonoro "Tempo" (apenas em games ímpares e sets).
  final bool timeWarningSound;

  /// Ativa o flash visual ao registrar um ponto.
  final bool pointFlashEnabled;

  /// Duração total do flash em milissegundos.
  final int pointFlashDurationMs;

  /// Frequência de alternância do flash (vezes por segundo).
  final int pointFlashFrequencyHz;

  /// Salvar automaticamente no histórico ao fim da partida.
  final bool autoSaveToHistory;

  /// Segundos de espera após último ponto antes de salvar (para desfazer). 0 = salvar imediatamente.
  final int autoSaveDelaySeconds;

  /// Modo de layout: 0 = padrão, 1 = landscape dividido (lado a lado).
  final int layoutMode;

  GameConfig copyWith({
    String? sportName,
    String? playerAName,
    String? playerBName,
    int? gamesToWinSet,
    int? minGameDifference,
    int? maxSets,
    int? tiebreakAt,
    int? tiebreakPoints,
    int? tiebreakDifference,
    int? finalSetTiebreakPoints,
    bool? useFinalSetTiebreak,
    bool? withAdvantage,
    bool? miniMatchGames,
    int? miniMatchGamesCount,
    String? ttsLanguage,
    int? serveClockSeconds,
    int? breakBetweenOddGamesSeconds,
    int? breakBetweenEvenGamesSeconds,
    int? breakBetweenSetsSeconds,
    bool? timeWarningSound,
    bool? pointFlashEnabled,
    int? pointFlashDurationMs,
    int? pointFlashFrequencyHz,
    bool? autoSaveToHistory,
    int? autoSaveDelaySeconds,
    int? layoutMode,
  }) {
    return GameConfig(
      sportName: sportName ?? this.sportName,
      playerAName: playerAName ?? this.playerAName,
      playerBName: playerBName ?? this.playerBName,
      gamesToWinSet: gamesToWinSet ?? this.gamesToWinSet,
      minGameDifference: minGameDifference ?? this.minGameDifference,
      maxSets: maxSets ?? this.maxSets,
      tiebreakAt: tiebreakAt ?? this.tiebreakAt,
      tiebreakPoints: tiebreakPoints ?? this.tiebreakPoints,
      tiebreakDifference: tiebreakDifference ?? this.tiebreakDifference,
      finalSetTiebreakPoints:
          finalSetTiebreakPoints ?? this.finalSetTiebreakPoints,
      useFinalSetTiebreak: useFinalSetTiebreak ?? this.useFinalSetTiebreak,
      withAdvantage: withAdvantage ?? this.withAdvantage,
      miniMatchGames: miniMatchGames ?? this.miniMatchGames,
      miniMatchGamesCount: miniMatchGamesCount ?? this.miniMatchGamesCount,
      ttsLanguage: ttsLanguage ?? this.ttsLanguage,
      serveClockSeconds: serveClockSeconds ?? this.serveClockSeconds,
      breakBetweenOddGamesSeconds:
          breakBetweenOddGamesSeconds ?? this.breakBetweenOddGamesSeconds,
      breakBetweenEvenGamesSeconds:
          breakBetweenEvenGamesSeconds ?? this.breakBetweenEvenGamesSeconds,
      breakBetweenSetsSeconds:
          breakBetweenSetsSeconds ?? this.breakBetweenSetsSeconds,
      timeWarningSound: timeWarningSound ?? this.timeWarningSound,
      pointFlashEnabled: pointFlashEnabled ?? this.pointFlashEnabled,
      pointFlashDurationMs: pointFlashDurationMs ?? this.pointFlashDurationMs,
      pointFlashFrequencyHz:
          pointFlashFrequencyHz ?? this.pointFlashFrequencyHz,
      autoSaveToHistory: autoSaveToHistory ?? this.autoSaveToHistory,
      autoSaveDelaySeconds: autoSaveDelaySeconds ?? this.autoSaveDelaySeconds,
      layoutMode: layoutMode ?? this.layoutMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'sportName': sportName,
        'gamesToWinSet': gamesToWinSet,
        'minGameDifference': minGameDifference,
        'maxSets': maxSets,
        'tiebreakAt': tiebreakAt,
        'tiebreakPoints': tiebreakPoints,
        'tiebreakDifference': tiebreakDifference,
        'finalSetTiebreakPoints': finalSetTiebreakPoints,
        'useFinalSetTiebreak': useFinalSetTiebreak,
        'withAdvantage': withAdvantage,
        'miniMatchGames': miniMatchGames,
        'miniMatchGamesCount': miniMatchGamesCount,
        'ttsLanguage': ttsLanguage,
        'serveClockSeconds': serveClockSeconds,
        'breakBetweenOddGamesSeconds': breakBetweenOddGamesSeconds,
        'breakBetweenEvenGamesSeconds': breakBetweenEvenGamesSeconds,
        'breakBetweenSetsSeconds': breakBetweenSetsSeconds,
        'timeWarningSound': timeWarningSound,
        'pointFlashEnabled': pointFlashEnabled,
        'pointFlashDurationMs': pointFlashDurationMs,
        'pointFlashFrequencyHz': pointFlashFrequencyHz,
        'autoSaveToHistory': autoSaveToHistory,
        'autoSaveDelaySeconds': autoSaveDelaySeconds,
        'layoutMode': layoutMode,
      };

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      sportName: json['sportName'] as String? ?? 'Tênis',
      playerAName: json['playerAName'] as String? ?? 'Time A',
      playerBName: json['playerBName'] as String? ?? 'Time B',
      gamesToWinSet: json['gamesToWinSet'] as int? ?? 6,
      minGameDifference: json['minGameDifference'] as int? ?? 2,
      maxSets: json['maxSets'] as int? ?? 3,
      tiebreakAt: json['tiebreakAt'] as int? ?? 6,
      tiebreakPoints: json['tiebreakPoints'] as int? ?? 7,
      tiebreakDifference: json['tiebreakDifference'] as int? ?? 2,
      finalSetTiebreakPoints: json['finalSetTiebreakPoints'] as int? ?? 7,
      useFinalSetTiebreak: json['useFinalSetTiebreak'] as bool? ?? true,
      withAdvantage: json['withAdvantage'] as bool? ?? true,
      miniMatchGames: json['miniMatchGames'] as bool? ?? false,
      miniMatchGamesCount: json['miniMatchGamesCount'] as int? ?? 3,
      ttsLanguage: json['ttsLanguage'] as String? ?? 'pt-BR',
      serveClockSeconds: json['serveClockSeconds'] as int? ?? 0,
      breakBetweenOddGamesSeconds:
          json['breakBetweenOddGamesSeconds'] as int? ??
              json['breakBetweenGamesSeconds'] as int? ??
              0,
      breakBetweenEvenGamesSeconds:
          json['breakBetweenEvenGamesSeconds'] as int? ?? 0,
      breakBetweenSetsSeconds: json['breakBetweenSetsSeconds'] as int? ?? 0,
      timeWarningSound: json['timeWarningSound'] as bool? ?? true,
      pointFlashEnabled: json['pointFlashEnabled'] as bool? ?? false,
      pointFlashDurationMs: json['pointFlashDurationMs'] as int? ?? 600,
      pointFlashFrequencyHz: json['pointFlashFrequencyHz'] as int? ?? 4,
      autoSaveToHistory: json['autoSaveToHistory'] as bool? ?? true,
      autoSaveDelaySeconds: json['autoSaveDelaySeconds'] as int? ?? 10,
      layoutMode: json['layoutMode'] as int? ?? 0,
    );
  }
}
