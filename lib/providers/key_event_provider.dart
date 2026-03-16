import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/button_mapping.dart';
import '../models/game_config.dart';
import '../services/key_event_service.dart';
import 'button_mapping_provider.dart';
import 'game_config_provider.dart';

final keyEventServiceProvider = Provider<KeyEventService>((ref) {
  // 1. Cria o motor uma única vez com os valores iniciais
  final initialMapping = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();
  final initialConfig = ref.read(gameConfigProvider).valueOrNull ?? const GameConfig(); 
  
  final service = KeyEventService(
    mapping: initialMapping, 
    lockVolume: initialConfig.lockVolumeButtons
  );

  // 2. O Segredo: Escuta as mudanças e atualiza a memória SEM destruir o motor
  ref.listen(buttonMappingProvider, (previous, next) {
    final newMapping = next.valueOrNull;
    if (newMapping != null) {
      service.updateMapping(newMapping);
    }
  });

  ref.listen(gameConfigProvider, (previous, next) {
    final newConfig = next.valueOrNull;
    if (newConfig != null) {
      service.lockVolume = newConfig.lockVolumeButtons;
    }
  });

  // 3. Segurança para desligar caso o app seja fechado
  ref.onDispose(() {
    service.stopListening();
  });

  return service;
});