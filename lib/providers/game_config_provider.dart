import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_config.dart';

const _key = 'game_config';

Future<GameConfig> _loadConfig() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_key);
  if (json == null) return const GameConfig();
  try {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return GameConfig.fromJson(map);
  } catch (_) {
    return const GameConfig();
  }
}

Future<void> _saveConfig(GameConfig config) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, jsonEncode(config.toJson()));
}

final gameConfigProvider =
    StateNotifierProvider<GameConfigNotifier, AsyncValue<GameConfig>>((ref) {
  return GameConfigNotifier();
});

class GameConfigNotifier extends StateNotifier<AsyncValue<GameConfig>> {
  GameConfigNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final config = await _loadConfig();
      state = AsyncValue.data(config);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateConfig(GameConfig config) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(config);
    await _saveConfig(config);
  }
}
