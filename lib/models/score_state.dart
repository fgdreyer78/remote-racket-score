/// Estado completo do placar: pontos no game, games no set, sets, sacador, histórico para undo.

class ScoreState {
  const ScoreState({
    this.pointsA = 0,
    this.pointsB = 0,
    this.gamesA = 0,
    this.gamesB = 0,
    this.setsA = 0,
    this.setsB = 0,
    this.previousSetsGamesA = const [],
    this.previousSetsGamesB = const [],
    this.previousSetsTiebreakPointsA = const [],
    this.previousSetsTiebreakPointsB = const [],
    this.currentSet = 1,
    this.isTiebreak = false,
    this.tiebreakPointsA = 0,
    this.tiebreakPointsB = 0,
    this.serverIsA = true,
    this.history = const [],
    this.matchOver = false,
    this.winnerIsA,
  });

  final int pointsA;
  final int pointsB;
  final int gamesA;
  final int gamesB;
  final int setsA;
  final int setsB;
  final List<int> previousSetsGamesA;
  final List<int> previousSetsGamesB;

  /// Pontos de tiebreak de cada set anterior (0 se não houve tiebreak).
  final List<int> previousSetsTiebreakPointsA;
  final List<int> previousSetsTiebreakPointsB;
  final int currentSet;
  final bool isTiebreak;
  final int tiebreakPointsA;
  final int tiebreakPointsB;
  final bool serverIsA;
  final List<ScoreState> history;
  final bool matchOver;
  final bool? winnerIsA;

  ScoreState copyWith({
    int? pointsA,
    int? pointsB,
    int? gamesA,
    int? gamesB,
    int? setsA,
    int? setsB,
    List<int>? previousSetsGamesA,
    List<int>? previousSetsGamesB,
    List<int>? previousSetsTiebreakPointsA,
    List<int>? previousSetsTiebreakPointsB,
    int? currentSet,
    bool? isTiebreak,
    int? tiebreakPointsA,
    int? tiebreakPointsB,
    bool? serverIsA,
    List<ScoreState>? history,
    bool? matchOver,
    bool? winnerIsA,
  }) {
    return ScoreState(
      pointsA: pointsA ?? this.pointsA,
      pointsB: pointsB ?? this.pointsB,
      gamesA: gamesA ?? this.gamesA,
      gamesB: gamesB ?? this.gamesB,
      setsA: setsA ?? this.setsA,
      setsB: setsB ?? this.setsB,
      previousSetsGamesA: previousSetsGamesA ?? this.previousSetsGamesA,
      previousSetsGamesB: previousSetsGamesB ?? this.previousSetsGamesB,
      previousSetsTiebreakPointsA:
          previousSetsTiebreakPointsA ?? this.previousSetsTiebreakPointsA,
      previousSetsTiebreakPointsB:
          previousSetsTiebreakPointsB ?? this.previousSetsTiebreakPointsB,
      currentSet: currentSet ?? this.currentSet,
      isTiebreak: isTiebreak ?? this.isTiebreak,
      tiebreakPointsA: tiebreakPointsA ?? this.tiebreakPointsA,
      tiebreakPointsB: tiebreakPointsB ?? this.tiebreakPointsB,
      serverIsA: serverIsA ?? this.serverIsA,
      history: history ?? this.history,
      matchOver: matchOver ?? this.matchOver,
      winnerIsA: winnerIsA ?? this.winnerIsA,
    );
  }

  Map<String, dynamic> toJson() => {
        'pointsA': pointsA,
        'pointsB': pointsB,
        'gamesA': gamesA,
        'gamesB': gamesB,
        'setsA': setsA,
        'setsB': setsB,
        'previousSetsGamesA': previousSetsGamesA,
        'previousSetsGamesB': previousSetsGamesB,
        'previousSetsTiebreakPointsA': previousSetsTiebreakPointsA,
        'previousSetsTiebreakPointsB': previousSetsTiebreakPointsB,
        'currentSet': currentSet,
        'isTiebreak': isTiebreak,
        'tiebreakPointsA': tiebreakPointsA,
        'tiebreakPointsB': tiebreakPointsB,
        'serverIsA': serverIsA,
        'matchOver': matchOver,
        'winnerIsA': winnerIsA,
      };

  factory ScoreState.fromJson(Map<String, dynamic> json) {
    return ScoreState(
      pointsA: json['pointsA'] as int? ?? 0,
      pointsB: json['pointsB'] as int? ?? 0,
      gamesA: json['gamesA'] as int? ?? 0,
      gamesB: json['gamesB'] as int? ?? 0,
      setsA: json['setsA'] as int? ?? 0,
      setsB: json['setsB'] as int? ?? 0,
      previousSetsGamesA:
          (json['previousSetsGamesA'] as List<dynamic>?)?.cast<int>() ?? [],
      previousSetsGamesB:
          (json['previousSetsGamesB'] as List<dynamic>?)?.cast<int>() ?? [],
      previousSetsTiebreakPointsA:
          (json['previousSetsTiebreakPointsA'] as List<dynamic>?)
                  ?.cast<int>() ??
              [],
      previousSetsTiebreakPointsB:
          (json['previousSetsTiebreakPointsB'] as List<dynamic>?)
                  ?.cast<int>() ??
              [],
      currentSet: json['currentSet'] as int? ?? 1,
      isTiebreak: json['isTiebreak'] as bool? ?? false,
      tiebreakPointsA: json['tiebreakPointsA'] as int? ?? 0,
      tiebreakPointsB: json['tiebreakPointsB'] as int? ?? 0,
      serverIsA: json['serverIsA'] as bool? ?? true,
      matchOver: json['matchOver'] as bool? ?? false,
      winnerIsA: json['winnerIsA'] as bool?,
    );
  }
}
