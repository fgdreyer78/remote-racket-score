import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/score/scoring_engine.dart';
import '../models/game_config.dart';
import '../models/match_record.dart';
import '../models/score_state.dart';
import 'game_config_provider.dart';
import 'match_history_provider.dart';
import 'tts_config_provider.dart';
import 'tts_provider.dart';

final scoreStateProvider =
    StateNotifierProvider<ScoreNotifier, ScoreState>((ref) {
  return ScoreNotifier(ref);
});

class ScoreNotifier extends StateNotifier<ScoreState> {
  ScoreNotifier(this._ref)
      : _matchStart = DateTime.now(),
        _events = <PointEvent>[],
        _lastScorerIsA = false,
        super(const ScoreState());

  final Ref _ref;
  DateTime _matchStart;
  final List<PointEvent> _events;

  /// Último jogador que fez ponto — usado para o flash visual
  bool _lastScorerIsA;
  bool get lastScorerIsA => _lastScorerIsA;

  /// Flag para saber se a partida já foi salva no histórico.
  bool _matchSaved = false;
  bool get matchSaved => _matchSaved;

  /// Timer para salvar a partida com delay (autoSaveDelaySeconds).
  Timer? _pendingSaveTimer;
  Timer? get pendingSaveTimer => _pendingSaveTimer;

  GameConfig get _config =>
      _ref.read(gameConfigProvider).valueOrNull ?? const GameConfig();

  void addPointA() {
    _addPoint(forTeamA: true);
  }

  void addPointB() {
    _addPoint(forTeamA: false);
  }

  void _addPoint({required bool forTeamA}) {
    // Não aceitar novos pontos após o término da partida.
    if (state.matchOver) return;

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

    _lastScorerIsA = forTeamA;
    state = ScoringEngine(config).addPoint(prev, forTeamA);
    final ttsConfig = _ref.read(ttsConfigProvider);
    _ref
        .read(ttsServiceProvider)
        .announceTransition(prev, state, config, ttsConfig);

    if (!prev.matchOver && state.matchOver) {
      _startPendingSave(config);
    }
  }

  /// Inicia o timer de save atrasado (autoSaveDelaySeconds).
  /// Durante essa janela, o utilizador pode desfazer pontos.
  void _startPendingSave(GameConfig config) {
    _pendingSaveTimer?.cancel();
    final delay = config.autoSaveDelaySeconds;
    if (delay > 0) {
      _pendingSaveTimer = Timer(Duration(seconds: delay), () {
        _pendingSaveTimer = null;
        if (mounted && state.matchOver && !_matchSaved) {
          _saveMatch(config);
        }
      });
    } else {
      // Sem delay — salvar imediatamente.
      _saveMatch(config);
    }
  }

  /// Cancela o save pendente (usado quando o utilizador desfaz o ponto vencedor).
  void _cancelPendingSave() {
    _pendingSaveTimer?.cancel();
    _pendingSaveTimer = null;
  }

  void _saveMatch(GameConfig config) {
    if (_matchSaved) return;
    _matchSaved = true;
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

    // Se a partida acabou mas ainda não foi salva, permitir undo
    // (o utilizador pode ter se enganado no último ponto).
    if (state.matchOver && _matchSaved) return;

    // Se a partida acabou e há save pendente, cancelar o save
    // e reverter o estado.
    if (state.matchOver && _pendingSaveTimer != null) {
      _cancelPendingSave();
    }

    if (_events.isNotEmpty) {
      _events.removeLast();
    }
    state = ScoringEngine(_config).undo(state);
  }

  void reset() {
    _cancelPendingSave();
    _matchSaved = false;
    state = const ScoreState();
    _events.clear();
    _matchStart = DateTime.now();
  }

  void setServer(bool isA) {
    state = state.copyWith(serverIsA: isA);
  }
}
