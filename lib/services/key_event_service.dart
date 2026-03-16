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
  
  double _currentVol = 0.5;
  
  // VARIÁVEIS DO ESCUDO ANTI-DUPLICIDADE
  int? _lastProcessedKeyId;
  int _lastProcessedTime = 0;

  Future<void> startListening() async {
    HardwareKeyboard.instance.addHandler(_handler);
    
    if (lockVolume) {
      try {
        PerfectVolumeControl.hideUI = true;
        _currentVol = await PerfectVolumeControl.getVolume();
        
        _volumeSub = PerfectVolumeControl.stream.listen((v) {
          // Só processa se o volume realmente tiver mudado
          if (v > _currentVol) {
            _processKeyId(LogicalKeyboardKey.audioVolumeUp.keyId);
          } else if (v < _currentVol) {
            _processKeyId(LogicalKeyboardKey.audioVolumeDown.keyId);
          } else {
            return; // Ignora se o som for igual
          }
          
          _currentVol = v; // Atualiza a memória
          
          // PROTEÇÃO DE BORDA: Deixa o fone trabalhar livremente, 
          // só puxa pro meio se bater nas pontas (< 15% ou > 85%)
          if (_currentVol <= 0.15 || _currentVol >= 0.85) {
            Future.delayed(const Duration(milliseconds: 300), () {
              PerfectVolumeControl.setVolume(0.5);
              _currentVol = 0.5;
            });
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
    if (event is KeyUpEvent) return false; 
    return _processKeyId(event.logicalKey.keyId);
  }

  bool _processKeyId(int keyId) {
    // ESCUDO ANTI-DUPLICIDADE (150ms)
    // Se o teclado e o som dispararem a mesma tecla juntos, ignora o clone.
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