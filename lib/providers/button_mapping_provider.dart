import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/button_mapping.dart';

const _key = 'button_mapping';

Future<ButtonMapping> _loadMapping() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_key);
  if (json == null) return const ButtonMapping();
  try {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return ButtonMapping.fromJson(map);
  } catch (_) {
    return const ButtonMapping();
  }
}

Future<void> _saveMapping(ButtonMapping mapping) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, jsonEncode(mapping.toJson()));
}

final buttonMappingProvider =
    StateNotifierProvider<ButtonMappingNotifier, AsyncValue<ButtonMapping>>((ref) {
  return ButtonMappingNotifier();
});

class ButtonMappingNotifier extends StateNotifier<AsyncValue<ButtonMapping>> {
  ButtonMappingNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final mapping = await _loadMapping();
      state = AsyncValue.data(mapping);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateMapping(ButtonMapping mapping) async {
    state = AsyncValue.data(mapping);
    await _saveMapping(mapping);
  }
}
