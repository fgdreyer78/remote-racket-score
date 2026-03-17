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
  
  int? _lastProcessedKeyId;
  int _lastProcessedTime = 0;

  Future<void> startListening() async {
    HardwareKeyboard.instance.addHandler(_handler);
    
    if (lockVolume) {
      try {
        PerfectVolumeControl.hideUI = true;
        
        _currentVol = await PerfectVolumeControl.getVolume();
        // Se estiver muito baixo, garante que o juiz será ouvido
        if (_currentVol < 0.2) {
          _currentVol = 0.5;
          PerfectVolumeControl.setVolume(_currentVol);
        }
        
        _volumeSub = PerfectVolumeControl.stream.listen((v) {
          if ((v - _currentVol).abs() < 0.001) return; 
          
          if (v > _currentVol) {
            _processKeyId(LogicalKeyboardKey.audioVolumeUp.keyId);
          } else if (v < _currentVol) {
            _processKeyId(LogicalKeyboardKey.audioVolumeDown.keyId);
          }
          
          _currentVol = v; 
          
          // ÂNCORA SUAVE: Só interfere se bater nos extremos! 
          // O fone agora tem liberdade total no meio.
          if (_currentVol <= 0.1 || _currentVol >= 0.9) {
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
    // Escudo reduzido para 50ms para garantir que não vai engolir cliques rápidos do fone
    final now = DateTime.now().millisecondsSinceEpoch;
    if (keyId == _lastProcessedKeyId && (now - _lastProcessedTime) < 50) {
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