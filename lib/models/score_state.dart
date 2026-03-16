/// Estado completo do placar: pontos no game, games no set, sets, sacador, histórico para undo.
class ScoreState {
  const ScoreState({
    this.pointsA = 0,
    this.pointsB = 0,
    this.gamesA = 0,
    this.gamesB = 0,
    this.setsA = 0,
    this.setsB = 0,
    this.previousSetsGamesA = const [], // NOVO: Caderninho de sets do Jogador A
    this.previousSetsGamesB = const [], // NOVO: Caderninho de sets do Jogador B
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
  final List<int> previousSetsGamesA; // NOVO
  final List<int> previousSetsGamesB; // NOVO
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
    List<int>? previousSetsGamesA, // NOVO
    List<int>? previousSetsGamesB, // NOVO
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
      previousSetsGamesA: previousSetsGamesA ?? this.previousSetsGamesA, // NOVO
      previousSetsGamesB: previousSetsGamesB ?? this.previousSetsGamesB, // NOVO
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
}