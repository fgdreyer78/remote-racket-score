import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_config.dart';
import '../models/match_preset.dart';
import 'game_config_provider.dart';

const _presetsKey = 'game_presets';

Future<List<MatchPreset>> _loadPresets() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_presetsKey);
  if (raw == null) return <MatchPreset>[];
  try {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map(
          (e) => MatchPreset.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  } catch (_) {
    return <MatchPreset>[];
  }
}

Future<void> _savePresets(List<MatchPreset> presets) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _presetsKey,
    jsonEncode(presets.map((e) => e.toJson()).toList()),
  );
}

final gamePresetsProvider =
    StateNotifierProvider<GamePresetsNotifier, AsyncValue<List<MatchPreset>>>(
        (ref) {
  return GamePresetsNotifier(ref);
});

class GamePresetsNotifier extends StateNotifier<AsyncValue<List<MatchPreset>>> {
  GamePresetsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final presets = await _loadPresets();
      state = AsyncValue.data(presets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> savePreset(String name, GameConfig config) async {
    final current = state.valueOrNull ?? <MatchPreset>[];
    final id = name.trim().toLowerCase();
    final existingIndex = current.indexWhere((p) => p.id == id);
    final preset = MatchPreset(
        id: id,
        name: name.trim().isEmpty ? 'Configuração' : name.trim(),
        config: config);

    List<MatchPreset> updated;
    if (existingIndex >= 0) {
      updated = List<MatchPreset>.from(current)
        ..removeAt(existingIndex)
        ..insert(existingIndex, preset);
    } else {
      updated = <MatchPreset>[preset, ...current];
    }

    state = AsyncValue.data(updated);
    await _savePresets(updated);
  }

  Future<void> deletePreset(int index) async {
    final current = state.valueOrNull ?? <MatchPreset>[];
    if (index < 0 || index >= current.length) return;
    final updated = List<MatchPreset>.from(current)..removeAt(index);
    state = AsyncValue.data(updated);
    await _savePresets(updated);
  }

  Future<void> applyPreset(MatchPreset preset) async {
    _ref.read(gameConfigProvider.notifier).updateConfig(preset.config);
  }
}
