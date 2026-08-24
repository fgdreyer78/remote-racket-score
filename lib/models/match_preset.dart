import 'game_config.dart';

/// Preset de configuração de partida, identificado por nome.
/// Pode conter overrides opcionais para idioma de fala e layout do placar.
class MatchPreset {
  const MatchPreset({
    required this.id,
    required this.name,
    required this.config,
    this.overrideTtsLanguage,
    this.overrideLayoutMode,
  });

  final String id;
  final String name;
  final GameConfig config;

  /// Código do idioma TTS para sobrescrever o global (null = usar padrão).
  final String? overrideTtsLanguage;

  /// Índice do layout para sobrescrever o global (null = usar padrão).
  final int? overrideLayoutMode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'config': config.toJson(),
        if (overrideTtsLanguage != null)
          'overrideTtsLanguage': overrideTtsLanguage,
        if (overrideLayoutMode != null)
          'overrideLayoutMode': overrideLayoutMode,
      };

  factory MatchPreset.fromJson(Map<String, dynamic> json) {
    return MatchPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      config: GameConfig.fromJson(json['config'] as Map<String, dynamic>),
      overrideTtsLanguage: json['overrideTtsLanguage'] as String?,
      overrideLayoutMode: json['overrideLayoutMode'] as int?,
    );
  }

  /// Retrocompatibilidade: alias para overrideTtsLanguageIndex baseado no código.
  int? get overrideTtsLanguageIndex {
    if (overrideTtsLanguage == null) return -1;
    switch (overrideTtsLanguage) {
      case 'pt-BR':
        return 0;
      case 'en-US':
        return 1;
      default:
        return -1;
    }
  }

  /// Retrocompatibilidade: alias para overrideLayoutModeIndex.
  int? get overrideLayoutModeIndex => overrideLayoutMode;
}
