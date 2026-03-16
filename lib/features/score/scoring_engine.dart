import '../../models/game_config.dart';
import '../../models/score_state.dart';

/// Motor de regras: aplica GameConfig e calcula próximo estado ao marcar ponto ou desfazer.
class ScoringEngine {
  ScoringEngine(this.config);

  final GameConfig config;

  static const int _love = 0;
  static const int _fifteen = 1;
  static const int _thirty = 2;
  static const int _forty = 3;

  /// Converte índice de ponto (0..4) para anúncio: "0", "15", "30", "40", "vantagem".
  static String pointToDisplay(int pointIndex, {bool isAdvantage = false}) {
    if (isAdvantage) return 'AD';
    switch (pointIndex) {
      case _love:
        return '0';
      case _fifteen:
        return '15';
      case _thirty:
        return '30';
      case _forty:
        return '40';
      default:
        return '$pointIndex';
    }
  }

  /// Retorna o próximo ScoreState ao marcar ponto para [forTeamA].
  ScoreState addPoint(ScoreState state, bool forTeamA) {
    if (state.matchOver) return state;

    final nextHistory = List<ScoreState>.from(state.history)..add(state);

    if (state.isTiebreak) {
      return _addTiebreakPoint(state, forTeamA, nextHistory);
    }

    return _addGamePoint(state, forTeamA, nextHistory);
  }

  ScoreState _addGamePoint(
      ScoreState state, bool forTeamA, List<ScoreState> nextHistory) {
    int pa = state.pointsA;
    int pb = state.pointsB;

    if (forTeamA) {
      pa++;
    } else {
      pb++;
    }

    final withAdv = config.withAdvantage;
    final gameOver = _isGameOver(pa, pb, withAdv);
    if (!gameOver) {
      return state.copyWith(
        pointsA: pa,
        pointsB: pb,
        history: nextHistory,
      );
    }

    int ga = state.gamesA;
    int gb = state.gamesB;
    if (forTeamA) {
      ga++;
    } else {
      gb++;
    }

    final setOver = _isSetOver(ga, gb);
    final goTiebreak = _shouldGoTiebreakFor(ga, gb, state.currentSet);

    if (setOver && !goTiebreak) {
      return _finishSet(state, ga, gb, forTeamA, nextHistory);
    }

    if (goTiebreak) {
      return state.copyWith(
        pointsA: 0,
        pointsB: 0,
        gamesA: ga,
        gamesB: gb,
        isTiebreak: true,
        tiebreakPointsA: 0,
        tiebreakPointsB: 0,
        serverIsA: !state.serverIsA,
        history: nextHistory,
      );
    }

    return state.copyWith(
      pointsA: 0,
      pointsB: 0,
      gamesA: ga,
      gamesB: gb,
      serverIsA: !state.serverIsA,
      history: nextHistory,
    );
  }

  bool _isGameOver(int pa, int pb, bool withAdvantage) {
    if (withAdvantage) {
      if (pa >= 4 && pa - pb >= 2) return true;
      if (pb >= 4 && pb - pa >= 2) return true;
      return false;
    }
    if (pa >= 4 || pb >= 4) return true;
    return false;
  }

  bool _isSetOver(int ga, int gb) {
    if (config.miniMatchGames) {
      return ga >= config.miniMatchGamesCount || gb >= config.miniMatchGamesCount;
    }
    if (ga >= config.gamesToWinSet && ga - gb >= config.minGameDifference) {
      return true;
    }
    if (gb >= config.gamesToWinSet && gb - ga >= config.minGameDifference) {
      return true;
    }
    return false;
  }

  bool _shouldGoTiebreakFor(int ga, int gb, int currentSet) {
    if (config.miniMatchGames) return false;
    return ga == config.tiebreakAt && gb == config.tiebreakAt;
  }

  ScoreState _addTiebreakPoint(
      ScoreState state, bool forTeamA, List<ScoreState> nextHistory) {
    int ta = state.tiebreakPointsA;
    int tb = state.tiebreakPointsB;
    if (forTeamA) {
      ta++;
    } else {
      tb++;
    }

    final pointsToWin = _getTiebreakPointsToWin(state);
    final diff = config.tiebreakDifference;
    final tiebreakOver =
        (ta >= pointsToWin && ta - tb >= diff) || (tb >= pointsToWin && tb - ta >= diff);

    int ptsBefore = state.tiebreakPointsA + state.tiebreakPointsB;
    bool firstServerIsA = ((ptsBefore % 4 == 1) || (ptsBefore % 4 == 2)) ? !state.serverIsA : state.serverIsA;

    if (!tiebreakOver) {
      bool swapServer = ((ta + tb) % 2 != 0);
      return state.copyWith(
        tiebreakPointsA: ta,
        tiebreakPointsB: tb,
        serverIsA: swapServer ? !state.serverIsA : state.serverIsA,
        history: nextHistory,
      );
    }

    int ga = state.gamesA;
    int gb = state.gamesB;
    if (forTeamA) {
      ga++;
    } else {
      gb++;
    }
    
    // Passamos os pontos exatos do tiebreak (ta e tb) para o motor salvar caso seja Super Tiebreak
    return _finishSet(state, ga, gb, forTeamA, nextHistory, nextServerIsA: !firstServerIsA, tiebreakPointsA: ta, tiebreakPointsB: tb);
  }

  int _getTiebreakPointsToWin(ScoreState state) {
    final isFinalSet = state.currentSet == config.maxSets;
    return isFinalSet ? config.finalSetTiebreakPoints : config.tiebreakPoints;
  }

  ScoreState _finishSet(ScoreState state, int ga, int gb, bool setWinnerIsA,
      List<ScoreState> nextHistory, {bool? nextServerIsA, int? tiebreakPointsA, int? tiebreakPointsB}) {
    int sa = state.setsA;
    int sb = state.setsB;
    
    // Identifica se estamos encerrando um Super Tiebreak (Match Tiebreak)
    bool isMatchTiebreak = state.isTiebreak && state.gamesA == 0 && state.gamesB == 0;
    
    // Se for Super Tiebreak, anota os pontos reais (ex: 11 a 9). Se for normal, anota os games (ex: 6 a 4)
    int recordedGamesA = isMatchTiebreak ? (tiebreakPointsA ?? 0) : ga;
    int recordedGamesB = isMatchTiebreak ? (tiebreakPointsB ?? 0) : gb;

    final newPreviousSetsGamesA = List<int>.from(state.previousSetsGamesA)..add(recordedGamesA);
    final newPreviousSetsGamesB = List<int>.from(state.previousSetsGamesB)..add(recordedGamesB);

    if (setWinnerIsA) {
      sa++;
    } else {
      sb++;
    }

    final matchOver = _isMatchOver(sa, sb);
    
    int nextSet = state.currentSet + 1;
    bool nextSetIsMatchTiebreak = (!matchOver && nextSet == config.maxSets && config.useFinalSetTiebreak);

    return state.copyWith(
      pointsA: 0,
      pointsB: 0,
      gamesA: 0,
      gamesB: 0,
      setsA: sa,
      setsB: sb,
      previousSetsGamesA: newPreviousSetsGamesA,
      previousSetsGamesB: newPreviousSetsGamesB,
      currentSet: nextSet,
      isTiebreak: nextSetIsMatchTiebreak,
      tiebreakPointsA: 0,
      tiebreakPointsB: 0,
      serverIsA: nextServerIsA ?? !state.serverIsA,
      history: nextHistory,
      matchOver: matchOver,
      winnerIsA: matchOver ? setWinnerIsA : null,
    );
  }

  bool _isMatchOver(int setsA, int setsB) {
    final setsToWin = (config.maxSets / 2).ceil();
    return setsA >= setsToWin || setsB >= setsToWin;
  }

  ScoreState undo(ScoreState state) {
    if (state.history.isEmpty) return state;
    final prev = state.history.last;
    final newHistory = List<ScoreState>.from(state.history)..removeLast();
    return prev.copyWith(history: newHistory);
  }
}