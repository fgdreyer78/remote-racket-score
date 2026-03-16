import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/button_mapping.dart';
import '../models/game_config.dart'; // Importa GameConfig
import '../services/key_event_service.dart';
import 'button_mapping_provider.dart';
import 'game_config_provider.dart'; // Importa gameConfigProvider

final keyEventServiceProvider = Provider<KeyEventService>((ref) {
  final mapping = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();
  final gameConfig = ref.read(gameConfigProvider).valueOrNull ?? const GameConfig(); // Obtém gameConfig
  return KeyEventService(mapping: mapping, lockVolume: gameConfig.lockVolumeButtons);
});
