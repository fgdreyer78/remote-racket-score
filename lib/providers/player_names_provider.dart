import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'player_names_history';

final playerNamesProvider =
    StateNotifierProvider<PlayerNamesNotifier, List<String>>((ref) {
  return PlayerNamesNotifier();
});

class PlayerNamesNotifier extends StateNotifier<List<String>> {
  PlayerNamesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      state = list.cast<String>();
    } catch (_) {
      state = [];
    }
  }

  Future<void> addName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    // Evita duplicatas (case-insensitive), move para o topo se já existe
    final updated = [
      trimmed,
      ...state.where((n) => n.toLowerCase() != trimmed.toLowerCase()),
    ];
    // Limita a 50 nomes
    state = updated.take(50).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }

  /// Retorna nomes que contêm [query] (case-insensitive), excluindo [exclude]
  List<String> suggest(String query, {String? exclude}) {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    return state
        .where((n) =>
            n.toLowerCase().contains(q) &&
            (exclude == null || n.toLowerCase() != exclude.toLowerCase()))
        .toList();
  }
}
