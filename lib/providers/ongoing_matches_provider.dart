import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ongoing_match.dart';
import 'game_config_provider.dart';
import 'score_provider.dart';

const _ongoingKey = 'ongoing_matches';

Future<List<OngoingMatch>> _loadOngoing() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_ongoingKey);
  if (raw == null) return <OngoingMatch>[];
  try {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => OngoingMatch.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return <OngoingMatch>[];
  }
}

Future<void> _saveOngoing(List<OngoingMatch> matches) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _ongoingKey,
    jsonEncode(matches.map((e) => e.toJson()).toList()),
  );
}

final ongoingMatchesProvider = StateNotifierProvider<OngoingMatchesNotifier,
    AsyncValue<List<OngoingMatch>>>((ref) {
  return OngoingMatchesNotifier(ref);
});

class OngoingMatchesNotifier
    extends StateNotifier<AsyncValue<List<OngoingMatch>>> {
  OngoingMatchesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final matches = await _loadOngoing();
      state = AsyncValue.data(matches);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Salva a partida atual como em andamento.
  Future<void> saveCurrentMatch() async {
    final score = _ref.read(scoreStateProvider);
    final config = _ref.read(gameConfigProvider).valueOrNull;
    if (config == null) return;

    // Não salva se a partida já terminou ou não foi iniciada
    if (score.matchOver) return;
    final hasProgress = score.matchStarted ||
        score.setsA > 0 ||
        score.setsB > 0 ||
        score.gamesA > 0 ||
        score.gamesB > 0 ||
        score.pointsA > 0 ||
        score.pointsB > 0 ||
        score.tiebreakPointsA > 0 ||
        score.tiebreakPointsB > 0;
    if (!hasProgress) return;

    final id = DateTime.now().toIso8601String();
    final match = OngoingMatch(
      id: id,
      playerAName: config.playerAName,
      playerBName: config.playerBName,
      configSnapshot: config,
      scoreState: score,
      startedAt: DateTime.now(),
      lastPointAt: DateTime.now(),
    );

    final current = state.valueOrNull ?? <OngoingMatch>[];
    final updated = [match, ...current];
    state = AsyncValue.data(updated);
    await _saveOngoing(updated);
  }

  /// Restaura uma partida em andamento como partida ativa.
  Future<void> restoreMatch(OngoingMatch match) async {
    // Restaura config
    await _ref
        .read(gameConfigProvider.notifier)
        .updateConfig(match.configSnapshot);

    // Restaura estado do placar
    _ref.read(scoreStateProvider.notifier).loadFromState(match.scoreState);

    // Remove da lista de ongoing
    await deleteMatch(match.id);
  }

  /// Deleta uma partida em andamento.
  Future<void> deleteMatch(String id) async {
    final current = state.valueOrNull ?? <OngoingMatch>[];
    final updated = current.where((m) => m.id != id).toList();
    state = AsyncValue.data(updated);
    await _saveOngoing(updated);
  }

  /// Remove a partida atual da lista quando ela termina.
  /// Chamado quando matchOver = true.
  Future<void> onMatchFinished() async {
    // Não precisamos fazer nada especial aqui — quando a partida termina,
    // ela vai para o histórico automaticamente via ScoreNotifier.
    // Mas se por algum motivo ainda estiver na lista, removemos.
    final current = state.valueOrNull ?? <OngoingMatch>[];
    if (current.isNotEmpty) {
      // Mantém apenas partidas que ainda não terminaram
      final score = _ref.read(scoreStateProvider);
      if (score.matchOver) {
        state = const AsyncValue.data([]);
        await _saveOngoing([]);
      }
    }
  }
}
