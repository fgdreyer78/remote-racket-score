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
    this.pointFlashEnabled = false,
    this.pointFlashDurationMs = 600,
    this.pointFlashFrequencyHz = 4,
    this.layoutMode = 0,
    this.lockSettingsDuringMatch = false,
    this.autoSaveToHistory = true,
    this.autoSaveDelaySeconds = 10,
  });

  final String sportName;
  final String playerAName;
  final String playerBName;
  final int gamesToWinSet;
  final int minGameDifference;
  final int maxSets;
  final int tiebreakAt;
  final int tiebreakPoints;
  final int tiebreakDifference;
  final int finalSetTiebreakPoints;
  final bool useFinalSetTiebreak;
  final bool withAdvantage;
  final bool miniMatchGames;
  final int miniMatchGamesCount;
  final String ttsLanguage;
  final int serveClockSeconds;
  final int breakBetweenOddGamesSeconds;
  final int breakBetweenEvenGamesSeconds;
  final int breakBetweenSetsSeconds;
  final bool timeWarningSound;
  final bool pointFlashEnabled;
  final int pointFlashDurationMs;
  final int pointFlashFrequencyHz;
  final int layoutMode;

  /// Travar configurações durante a partida.
  final bool lockSettingsDuringMatch;
  final bool autoSaveToHistory;
  final int autoSaveDelaySeconds;

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
    int? layoutMode,
    bool? lockSettingsDuringMatch,
    bool? autoSaveToHistory,
    int? autoSaveDelaySeconds,
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
      layoutMode: layoutMode ?? this.layoutMode,
      lockSettingsDuringMatch:
          lockSettingsDuringMatch ?? this.lockSettingsDuringMatch,
      autoSaveToHistory: autoSaveToHistory ?? this.autoSaveToHistory,
      autoSaveDelaySeconds: autoSaveDelaySeconds ?? this.autoSaveDelaySeconds,
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
        'layoutMode': layoutMode,
        'lockSettingsDuringMatch': lockSettingsDuringMatch,
        'autoSaveToHistory': autoSaveToHistory,
        'autoSaveDelaySeconds': autoSaveDelaySeconds,
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
      layoutMode: json['layoutMode'] as int? ?? 0,
      lockSettingsDuringMatch:
          json['lockSettingsDuringMatch'] as bool? ?? false,
      autoSaveToHistory: json['autoSaveToHistory'] as bool? ?? true,
      autoSaveDelaySeconds: json['autoSaveDelaySeconds'] as int? ?? 10,
    );
  }
}
