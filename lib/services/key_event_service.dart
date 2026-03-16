import 'dart:async';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import '../models/button_mapping.dart';

typedef OnMappedAction = void Function(MappedAction action);

class KeyEventService {
  KeyEventService({
    required this.mapping,
    this.lockVolume = true,
  });

  ButtonMapping mapping;
  bool lockVolume;
  OnMappedAction? onMappedAction;

  Timer? _clickTimer;
  int _clickCount = 0;
  MappedAction? _pendingAction;
  StreamSubscription<double>? _volumeSub;
  double _baseVol = 0.5;

  Future<void> startListening() async {
    HardwareKeyboard.instance.addHandler(_handler);
    
    if (lockVolume) {
      try {
        PerfectVolumeControl.hideUI = true;
        _baseVol = await PerfectVolumeControl.getVolume();
        _volumeSub = PerfectVolumeControl.stream.listen((v) {
          if (v != _baseVol) {
            // Se o Android roubou o botão e alterou o volume, nós geramos o clique falso!
            final keyId = v > _baseVol 
                ? LogicalKeyboardKey.audioVolumeUp.keyId 
                : LogicalKeyboardKey.audioVolumeDown.keyId;
                
            _processKeyId(keyId);
            PerfectVolumeControl.setVolume(_baseVol); // Trava o volume de volta no lugar
          }
        });
      } catch (e) {}
    }
  }

  void stopListening() {
    HardwareKeyboard.instance.removeHandler(_handler);
    _clickTimer?.cancel();
    
    if (lockVolume) {
      try {
        PerfectVolumeControl.hideUI = false;
        _volumeSub?.cancel();
      } catch (e) {}
    }
  }

  void updateMapping(ButtonMapping newMapping) {
    mapping = newMapping;
  }

  bool _handler(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyUpEvent) return false;
    if (event is KeyUpEvent) return false; // Ignoramos a soltura aqui para não contar duplo

    return _processKeyId(event.logicalKey.keyId);
  }

  // Lógica principal isolada para poder ser chamada pelo teclado OU pelo volume
  bool _processKeyId(int keyId) {
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
      // Temporizador de 900ms ajustado por você!
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