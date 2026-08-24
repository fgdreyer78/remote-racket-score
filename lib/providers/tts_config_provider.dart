import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/tts_dictionary.dart';

const _ttsLanguageKey = 'tts_language';
const _ttsCustomPhrasesKey = 'tts_custom_phrases';
const _ttsVoiceKey = 'tts_voice';

/// Estado da configuração de locução.
class TtsConfig {
  final String languageCode;
  final String? voiceName;
  final Map<String, String> customPhrases;

  const TtsConfig({
    this.languageCode = 'pt-BR',
    this.voiceName,
    this.customPhrases = const {},
  });

  TtsConfig copyWith({
    String? languageCode,
    String? voiceName,
    bool clearVoice = false,
    Map<String, String>? customPhrases,
  }) {
    return TtsConfig(
      languageCode: languageCode ?? this.languageCode,
      voiceName: clearVoice ? null : (voiceName ?? this.voiceName),
      customPhrases: customPhrases ?? this.customPhrases,
    );
  }

  /// Busca uma frase do dicionário, verificando customizações primeiro.
  String phrase(String key) {
    return TtsDictionary.get(key, languageCode, custom: customPhrases);
  }

  /// Busca ordinal do set.
  String ordinal(int setNumber) {
    return TtsDictionary.ordinal(setNumber, languageCode,
        custom: customPhrases);
  }

  /// Busca palavra da pontuação.
  String pointWord(int points) {
    return TtsDictionary.pointWord(points, languageCode, custom: customPhrases);
  }
}

class TtsConfigNotifier extends StateNotifier<TtsConfig> {
  TtsConfigNotifier() : super(const TtsConfig()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_ttsLanguageKey) ?? 'pt-BR';
    final voiceName = prefs.getString(_ttsVoiceKey);
    final customJson = prefs.getString(_ttsCustomPhrasesKey);
    Map<String, String> custom = {};
    if (customJson != null) {
      try {
        final map = jsonDecode(customJson) as Map<String, dynamic>;
        custom = map.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {}
    }
    state = TtsConfig(
      languageCode: langCode,
      voiceName: voiceName,
      customPhrases: custom,
    );
  }

  Future<void> setLanguage(String languageCode) async {
    // Ao mudar idioma, limpar a voz salva para auto-selecionar
    state = state.copyWith(languageCode: languageCode, clearVoice: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ttsLanguageKey, languageCode);
    await prefs.remove(_ttsVoiceKey);
  }

  Future<void> setVoice(String? voiceName) async {
    state = state.copyWith(voiceName: voiceName);
    final prefs = await SharedPreferences.getInstance();
    if (voiceName == null) {
      await prefs.remove(_ttsVoiceKey);
    } else {
      await prefs.setString(_ttsVoiceKey, voiceName);
    }
  }

  Future<void> setCustomPhrase(String key, String value) async {
    final newCustom = Map<String, String>.from(state.customPhrases);
    if (value.isEmpty) {
      newCustom.remove(key);
    } else {
      newCustom[key] = value;
    }
    state = state.copyWith(customPhrases: newCustom);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ttsCustomPhrasesKey, jsonEncode(newCustom));
  }

  Future<void> resetPhrases() async {
    state = state.copyWith(customPhrases: {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ttsCustomPhrasesKey);
  }
}

final ttsConfigProvider =
    StateNotifierProvider<TtsConfigNotifier, TtsConfig>((ref) {
  return TtsConfigNotifier();
});
