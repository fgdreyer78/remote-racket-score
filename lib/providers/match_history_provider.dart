import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_record.dart';

const _matchHistoryKey = 'match_history';

Future<List<MatchRecord>> _loadHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_matchHistoryKey);
  if (raw == null) return <MatchRecord>[];
  try {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map(
          (e) => MatchRecord.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  } catch (_) {
    return <MatchRecord>[];
  }
}

Future<void> _saveHistory(List<MatchRecord> records) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _matchHistoryKey,
    jsonEncode(records.map((e) => e.toJson()).toList()),
  );
}

final matchHistoryProvider =
    StateNotifierProvider<MatchHistoryNotifier, AsyncValue<List<MatchRecord>>>(
        (ref) {
  return MatchHistoryNotifier();
});

class MatchHistoryNotifier
    extends StateNotifier<AsyncValue<List<MatchRecord>>> {
  MatchHistoryNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final history = await _loadHistory();
      state = AsyncValue.data(history);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRecord(MatchRecord record) async {
    final current = state.valueOrNull ?? <MatchRecord>[];
    final updated = <MatchRecord>[record, ...current];
    state = AsyncValue.data(updated);
    await _saveHistory(updated);
  }

  Future<void> clear() async {
    state = const AsyncValue.data(<MatchRecord>[]);
    await _saveHistory(<MatchRecord>[]);
  }
}

