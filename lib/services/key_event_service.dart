import 'dart:async';
import 'package:flutter/services.dart';
import '../models/button_mapping.dart';
import 'match_audio_handler.dart'; // Importa o nosso novo interceptador de mídia!

typedef OnMappedAction = void Function(MappedAction action);

class KeyEventService {
  KeyEventService({
    required this.mapping,
  });

  ButtonMapping mapping;
  OnMappedAction? onMappedAction;

  Timer? _clickTimer;
  int _clickCount = 0;
  MappedAction? _pendingAction;
  
  int? _lastProcessedKeyId;
  int _lastProcessedTime = 0;

  StreamSubscription<MediaCommand>? _mediaSub;

  Future<void> startListening() async {
    stopListening();
    
    // 1. Ouve os teclados Bluetooth (ex: Cam Shutter)
    HardwareKeyboard.instance.addHandler(_handler);
    
    // 2. Ouve o Relógio e o Fone de Ouvido!
    _mediaSub = globalAudioHandler.commandStream.listen((command) {
      if (command == MediaCommand.next) {
        // Relógio mandou "Avançar Trilha" = Ponto A
        onMappedAction?.call(MappedAction.pointA);
      } else if (command == MediaCommand.previous) {
        // Relógio mandou "Voltar Trilha" = Ponto B
        onMappedAction?.call(MappedAction.pointB);
      } else if (command == MediaCommand.play || command == MediaCommand.pause) {
        // Relógio mandou Play/Pause = Desfazer
        onMappedAction?.call(MappedAction.undo);
      }
    });
  }

  void stopListening() {
    HardwareKeyboard.instance.removeHandler(_handler);
    _clickTimer?.cancel();
    _mediaSub?.cancel();
  }

  void updateMapping(ButtonMapping newMapping) {
    mapping = newMapping;
  }

  bool _handler(KeyEvent event) {
    if (event is! KeyDownEvent) return false; 
    
    final keyId = event.logicalKey.keyId;
    if (keyId == 0) return false;

    return _processKeyId(keyId);
  }

  bool _processKeyId(int keyId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (keyId == _lastProcessedKeyId && (now - _lastProcessedTime) < 150) {
      return false; 
    }
    _lastProcessedKeyId = keyId;
    _lastProcessedTime = now;

    MappedAction? action;
    MappedAction? dcTarget;
    MappedAction? tcTarget;

    if (mapping.pointAKeyId != null && keyId == mapping.pointAKeyId) {
      action = MappedAction.pointA;
      dcTarget = mapping.doubleClickActionA;
      tcTarget = mapping.tripleClickActionA;
    } else if (mapping.pointBKeyId != null && keyId == mapping.pointBKeyId) {
      action = MappedAction.pointB;
      dcTarget = mapping.doubleClickActionB;
      tcTarget = mapping.tripleClickActionB;
    } else if (mapping.undoKeyId != null && keyId == mapping.undoKeyId) {
      action = MappedAction.undo;
      dcTarget = mapping.doubleClickActionUndo;
      tcTarget = mapping.tripleClickActionUndo;
    }

    if (action != null) {
      if (dcTarget == null && tcTarget == null) {
        onMappedAction?.call(action);
        return true;
      }

      if (_pendingAction != null && _pendingAction != action) {
        onMappedAction?.call(_pendingAction!);
        _clickCount = 0;
      }

      _clickCount++;
      _pendingAction = action;

      _clickTimer?.cancel();
      _clickTimer = Timer(const Duration(milliseconds: 900), () {
        if (_clickCount == 1) {
          onMappedAction?.call(_pendingAction!);
        } else if (_clickCount == 2) {
          onMappedAction?.call(dcTarget ?? _pendingAction!);
        } else if (_clickCount >= 3) {
          onMappedAction?.call(tcTarget ?? dcTarget ?? _pendingAction!);
        }
        _clickCount = 0;
        _pendingAction = null;
      });
      return true;
    }
    return false;
  }
}