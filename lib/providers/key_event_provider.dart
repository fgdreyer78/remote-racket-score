import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/button_mapping.dart';
import '../services/key_event_service.dart';
import 'button_mapping_provider.dart';
import 'score_provider.dart'; // Importamos o cérebro da partida aqui!

final keyEventServiceProvider = Provider<KeyEventService>((ref) {
  final mapping = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();

  final service = KeyEventService(
    mapping: mapping,
  );

  // A SOLDAGEM DO FIO!
  // O motor manda os pontos direto para a memória. A tela pode até estar apagada no seu bolso!
  service.onMappedAction = (action) {
    final notifier = ref.read(scoreStateProvider.notifier);
    switch (action) {
      case MappedAction.pointA:
        notifier.addPointA();
        break;
      case MappedAction.pointB:
        notifier.addPointB();
        break;
      case MappedAction.undo:
        notifier.undo();
        break;
      case MappedAction.none:
        // A CORREÇÃO MÁGICA: Se for "Nenhum", apenas cruza os braços e não faz nada!
        break;
    }
  };

  // Liga a ignição
  service.startListening();

  ref.listen(buttonMappingProvider, (previous, next) {
    final newMapping = next.valueOrNull;
    if (newMapping != null) {
      service.updateMapping(newMapping);
    }
  });

  ref.onDispose(() {
    service.stopListening();
  });

  return service;
});