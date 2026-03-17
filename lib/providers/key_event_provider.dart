import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/button_mapping.dart';
import '../services/key_event_service.dart';
import 'button_mapping_provider.dart';

final keyEventServiceProvider = Provider<KeyEventService>((ref) {
  final mapping = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();

  final service = KeyEventService(
    mapping: mapping,
  );

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