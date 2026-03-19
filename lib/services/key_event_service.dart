import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';

import '../models/button_mapping.dart';
import 'match_audio_handler.dart';

typedef OnMappedAction = void Function(MappedAction action);

class KeyEventService with WidgetsBindingObserver {
  KeyEventService({
    required this.mapping,
  }) {
    WidgetsBinding.instance.addObserver(this);
  }

  ButtonMapping mapping;
  OnMappedAction? onMappedAction;
  Function(int keyId)? onKeyboardKeyCaptured; // Apenas o teclado manual precisa disso agora!

  StreamSubscription<MediaCommand>? _mediaSub;
  StreamSubscription<double>? _volumeSub;

  bool _isGameMode = false;
  bool _isRestoringVolume = false;
  double _baseVolume = 0.5;

  // ROTEADOR GENÉRICO DE CLIQUES (Serve para Volume e Teclado perfeitamente)
  String? _pendingSource; 
  MappedAction? _pendingAction;
  MappedAction? _pendingDouble;
  MappedAction? _pendingTriple;
  int _clickCount = 0;
  Timer? _clickTimer;

  void _registerClick(String source, MappedAction? action, MappedAction? dbl, MappedAction? trpl, int delayMs) {
    if (action == null) return;
    
    // Se clicou em outro botão antes do tempo acabar, executa o anterior na hora
    if (_pendingSource != null && _pendingSource != source) {
      _executePending();
    }
    
    _pendingSource = source;
    _pendingAction = action;
    _pendingDouble = dbl;
    _pendingTriple = trpl;
    _clickCount++;
    
    _clickTimer?.cancel();
    _clickTimer = Timer(Duration(milliseconds: delayMs), _executePending);
  }

  void _executePending() {
    if (_clickCount == 1) onMappedAction?.call(_pendingAction!);
    else if (_clickCount == 2) onMappedAction?.call(_pendingDouble ?? _pendingAction!);
    else if (_clickCount >= 3) onMappedAction?.call(_pendingTriple ?? _pendingDouble ?? _pendingAction!);
    
    _clickCount = 0;
    _pendingSource = null;
  }

  @override
  void didChangeMetrics() {
    if (_isGameMode) SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void setGameMode(bool isGame) async {
    _isGameMode = isGame;
    if (isGame) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      if (mapping.enableVolume) {
        _baseVolume = await PerfectVolumeControl.getVolume();
        // Margem de segurança para o botão físico sempre ter espaço para atuar
        if (_baseVolume >= 0.95) _baseVolume = 0.90;
        if (_baseVolume <= 0.05) _baseVolume = 0.10;
        PerfectVolumeControl.setVolume(_baseVolume);
        PerfectVolumeControl.hideUI = true;
      }
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      try { PerfectVolumeControl.hideUI = false; } catch(e){}
    }
  }

  Future<void> startListening() async {
    stopListening();
    
    if (mapping.enableKeyboard) {
      HardwareKeyboard.instance.addHandler(_keyboardHandler);
    }
    
    // MÍDIA (Executa na hora, sem delay de cliques múltiplos pois os botões já são fixos)
    if (mapping.enableMedia) {
      _mediaSub = globalAudioHandler.commandStream.listen((command) {
        if (command == MediaCommand.next && mapping.mediaNextAction != null) onMappedAction?.call(mapping.mediaNextAction!);
        else if (command == MediaCommand.previous && mapping.mediaPrevAction != null) onMappedAction?.call(mapping.mediaPrevAction!);
        else if ((command == MediaCommand.play || command == MediaCommand.pause) && mapping.mediaPlayAction != null) onMappedAction?.call(mapping.mediaPlayAction!);
      });
    }

    // VOLUME (Usa o stream nativo para driblar a confusão de Toque/Mídia do Android)
    if (mapping.enableVolume) {
      try {
        _baseVolume = await PerfectVolumeControl.getVolume();
        _volumeSub = PerfectVolumeControl.stream.listen((newVolume) {
          if (!_isGameMode) {
            _baseVolume = newVolume;
            return;
          }
          if (_isRestoringVolume) return;

          // Detecta a intenção e roteia para o contador de cliques de Volume
          if (newVolume > _baseVolume + 0.01) {
            _registerClick('volUp', mapping.volUpAction, mapping.volUpDouble, mapping.volUpTriple, mapping.volumeDelayMs);
            _forceVolumeBack();
          } else if (newVolume < _baseVolume - 0.01) {
            _registerClick('volDown', mapping.volDownAction, mapping.volDownDouble, mapping.volDownTriple, mapping.volumeDelayMs);
            _forceVolumeBack();
          }
        });
      } catch (e) {}
    }
  }

  void _forceVolumeBack() {
    _isRestoringVolume = true;
    PerfectVolumeControl.setVolume(_baseVolume);
    Future.delayed(const Duration(milliseconds: 300), () {
      _isRestoringVolume = false;
    });
  }

  void stopListening() {
    HardwareKeyboard.instance.removeHandler(_keyboardHandler);
    _clickTimer?.cancel();
    _mediaSub?.cancel();
    _volumeSub?.cancel();
  }

  void updateMapping(ButtonMapping newMapping) {
    mapping = newMapping;
    startListening(); 
  }

  int? _lastProcessedKeyId;
  int _lastProcessedTime = 0;

  bool _keyboardHandler(KeyEvent event) {
    if (event is! KeyDownEvent) return false; 
    final keyId = event.logicalKey.keyId;
    if (keyId == 0) return false;

    if (onKeyboardKeyCaptured != null) {
      onKeyboardKeyCaptured!(keyId);
      return true; // Consome para o mapeamento
    }

    if (!mapping.enableKeyboard) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (keyId == _lastProcessedKeyId && (now - _lastProcessedTime) < 150) return false; 
    _lastProcessedKeyId = keyId;
    _lastProcessedTime = now;

    // Roteia para o contador de cliques de Teclado
    if (mapping.keyA != null && keyId == mapping.keyA) {
      _registerClick('keyA', MappedAction.pointA, mapping.keyDoubleA, mapping.keyTripleA, mapping.keyboardDelayMs);
      return true;
    } else if (mapping.keyB != null && keyId == mapping.keyB) {
      _registerClick('keyB', MappedAction.pointB, mapping.keyDoubleB, mapping.keyTripleB, mapping.keyboardDelayMs);
      return true;
    } else if (mapping.keyUndo != null && keyId == mapping.keyUndo) {
      _registerClick('keyUndo', MappedAction.undo, mapping.keyDoubleUndo, mapping.keyTripleUndo, mapping.keyboardDelayMs);
      return true;
    }
    return false;
  }
}