import 'package:flutter/services.dart';

import '../models/button_mapping.dart';

/// Callback ao receber uma ação mapeada (ponto A, ponto B, desfazer).
typedef OnMappedAction = void Function(MappedAction action);

/// Escuta KeyEvents do hardware (incl. controle Bluetooth) e dispara ações conforme [ButtonMapping].
class KeyEventService {
  KeyEventService({required this.mapping});

  ButtonMapping mapping;
  OnMappedAction? onMappedAction;

  bool _handler(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final keyId = event.physicalKey.usbHidUsage;
    if (mapping.pointAKeyId != null && keyId == mapping.pointAKeyId) {
      onMappedAction?.call(MappedAction.pointA);
      return true;
    }
    if (mapping.pointBKeyId != null && keyId == mapping.pointBKeyId) {
      onMappedAction?.call(MappedAction.pointB);
      return true;
    }
    if (mapping.undoKeyId != null && keyId == mapping.undoKeyId) {
      onMappedAction?.call(MappedAction.undo);
      return true;
    }
    return false;
  }

  void startListening() {
    HardwareKeyboard.instance.addHandler(_handler);
  }

  void stopListening() {
    HardwareKeyboard.instance.removeHandler(_handler);
  }

  /// Atualiza o mapeamento em tempo real (ex.: após usuário configurar novo botão).
  void updateMapping(ButtonMapping newMapping) {
    mapping = newMapping;
  }
}
