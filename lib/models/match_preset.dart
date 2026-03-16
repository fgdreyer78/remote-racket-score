import 'game_config.dart';

/// Preset de configuração de partida, identificado por nome.
class MatchPreset {
  const MatchPreset({
    required this.id,
    required this.name,
    required this.config,
  });

  final String id;
  final String name;
  final GameConfig config;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'config': config.toJson(),
      };

  factory MatchPreset.fromJson(Map<String, dynamic> json) {
    return MatchPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      config: GameConfig.fromJson(json['config'] as Map<String, dynamic>),
    );
  }
}

