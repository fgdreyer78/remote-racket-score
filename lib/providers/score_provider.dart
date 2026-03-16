import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/score/scoring_engine.dart';
import '../models/game_config.dart';
import '../models/match_record.dart';
import '../models/score_state.dart';
import 'game_config_provider.dart';
import 'match_history_provider.dart';
import 'tts_provider.dart';

final scoreStateProvider =
    StateNotifierProvider<ScoreNotifier, ScoreState>((ref) {
  return ScoreNotifier(ref);
});

class ScoreNotifier extends StateNotifier<ScoreState> {
  ScoreNotifier(this._ref)
      : _matchStart = DateTime.now(),
        _events = <PointEvent>[],
        super(const ScoreState());

  final Ref _ref;
  DateTime _matchStart;
  final List<PointEvent> _events;

  GameConfig get _config =>
      _ref.read(gameConfigProvider).valueOrNull ?? const GameConfig();

  void addPointA() {
    _addPoint(forTeamA: true);
  }

  void addPointB() {
    _addPoint(forTeamA: false);
  }

  void _addPoint({required bool forTeamA}) {
    final config = _config;
    final prev = state;

    // Registra evento de ponto para reconstruir depois.
    final currentSet = prev.currentSet;
    final currentGame = prev.gamesA + prev.gamesB + 1;
    final isTiebreak = prev.isTiebreak;
    _events.add(
      PointEvent(
        setNumber: currentSet,
        gameNumber: currentGame,
        scorerIsA: forTeamA,
        isTiebreak: isTiebreak,
      ),
    );

    state = ScoringEngine(config).addPoint(prev, forTeamA);
    _ref.read(ttsServiceProvider).announceTransition(prev, state, config);

    if (!prev.matchOver && state.matchOver) {
      _saveMatch(config);
    }
  }

  void _saveMatch(GameConfig config) {
    final finishedAt = DateTime.now();
    final record = MatchRecord(
      id: finishedAt.toIso8601String(),
      startedAt: _matchStart,
      finishedAt: finishedAt,
      configName: config.sportName,
      playerAName: config.playerAName,
      playerBName: config.playerBName,
      configSnapshot: config,
      points: List<PointEvent>.from(_events),
    );
    _ref.read(matchHistoryProvider.notifier).addRecord(record);
    _events.clear();
    _matchStart = DateTime.now();
  }

  void undo() {
    if (state.history.isEmpty) return;
    if (_events.isNotEmpty) {
      _events.removeLast();
    }
    state = ScoringEngine(_config).undo(state);
  }

  void reset() {
    state = const ScoreState();
    _events.clear();
    _matchStart = DateTime.now();
  }

  void setServer(bool isA) {
    state = state.copyWith(serverIsA: isA);
  }
}
