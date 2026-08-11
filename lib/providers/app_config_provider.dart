import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_dictionary.dart';
import 'locale_provider.dart';

/// Helper para acessar textos do dicionário a partir do contexto.
/// Substitui AppLocalizations.of(context) por AppConfig.of(context).
class AppConfig {
  final String languageCode;

  const AppConfig({required this.languageCode});

  /// Busca um texto do dicionário.
  String text(String key) {
    return AppDictionary.text(key, languageCode);
  }

  /// Helper estático para usar em widgets.
  static AppConfig of(BuildContext context) {
    // Obtém o idioma do ProviderScope
    final container = ProviderScope.containerOf(context);
    final locale = container.read(localeProvider);
    final langCode = locale.languageCode == 'en' ? 'en-US' : 'pt-BR';
    return AppConfig(languageCode: langCode);
  }
}

/// Provider que expõe o AppConfig baseado no locale atual.
final appConfigProvider = Provider<AppConfig>((ref) {
  final locale = ref.watch(localeProvider);
  final langCode = locale.languageCode == 'en' ? 'en-US' : 'pt-BR';
  return AppConfig(languageCode: langCode);
});
