import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/button_mapping.dart';
import '../services/key_event_service.dart';
import 'button_mapping_provider.dart';

final keyEventServiceProvider = Provider<KeyEventService>((ref) {
  final mapping = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();
  return KeyEventService(mapping: mapping);
});
