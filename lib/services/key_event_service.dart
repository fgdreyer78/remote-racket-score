import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/button_mapping.dart';
import 'match_audio_handler.dart';

typedef OnMappedAction = void Function(MappedAction action);

class KeyEventService with WidgetsBindingObserver {
  KeyEventService({
    required this.mapping,
  }) {
    WidgetsBinding.instance.addObserver(this);
    _setupMethodChannel();
  }

  ButtonMapping mapping;
  OnMappedAction? onMappedAction;
  Function(int keyId)? onKeyboardKeyCaptured;

  StreamSubscription<MediaCommand>? _mediaSub;
  bool _isGameMode = false;

  // A LINHA DE TELEFONE COM O KOTLIN
  static const platform = MethodChannel('com.remoteracketscore/volume');

  String? _pendingSource; 
  MappedAction? _pendingAction;
  MappedAction? _pendingDouble;
  MappedAction? _pendingTriple;
  int _clickCount = 0;
  Timer? _clickTimer;

  // O Dart atende o telefone do Kotlin aqui!
  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (!_isGameMode || !mapping.enableVolume) return;
      
      if (call.method == 'volumeUp') {
        _registerClick('volUp', mapping.volUpAction, mapping.volUpDouble, mapping.volUpTriple, mapping.volumeDelayMs);
      } else if (call.method == 'volumeDown') {
        _registerClick('volDown', mapping.volDownAction, mapping.volDownDouble, mapping.volDownTriple, mapping.volumeDelayMs);
      }
    });
  }

  void _registerClick(String source, MappedAction action, MappedAction dbl, MappedAction trpl, int delayMs) {
    if (action == MappedAction.none) return;
    
    if (_pendingSource != null && _pendingSource != source) _executePending();
    
    _pendingSource = source; _pendingAction = action; _pendingDouble = dbl; _pendingTriple = trpl; _clickCount++;
    
    _clickTimer?.cancel();
    _clickTimer = Timer(Duration(milliseconds: delayMs), _executePending);
  }

  void _executePending() {
    if (_clickCount == 1) {
       _fire(_pendingAction);
    } else if (_clickCount == 2) {
       if (_pendingDouble != null && _pendingDouble != MappedAction.none) _fire(_pendingDouble);
       else { _fire(_pendingAction); _fire(_pendingAction); }
    } else if (_clickCount >= 3) {
       if (_pendingTriple != null && _pendingTriple != MappedAction.none) _fire(_pendingTriple);
       else if (_pendingDouble != null && _pendingDouble != MappedAction.none) { _fire(_pendingDouble); _fire(_pendingAction); }
       else { _fire(_pendingAction); _fire(_pendingAction); _fire(_pendingAction); }
    }
    _clickCount = 0; _pendingSource = null;
  }

  void _fire(MappedAction? action) {
     if (action != null && action != MappedAction.none) onMappedAction?.call(action);
  }

  @override
  void didChangeMetrics() {
    if (_isGameMode) SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void setGameMode(bool isGame) {
    _isGameMode = isGame;
    if (isGame) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      // Avisa o Kotlin: LIGA O BURACO NEGRO!
      platform.invokeMethod('setGameMode', true);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // Avisa o Kotlin: DESLIGA O BURACO NEGRO! (Volume volta ao normal nos menus)
      platform.invokeMethod('setGameMode', false);
    }
  }

  Future<void> startListening() async {
    stopListening();
    HardwareKeyboard.instance.addHandler(_keyboardHandler);
    
    // Mídia continua funcionando linda e bela
    if (mapping.enableMedia) {
      _mediaSub = globalAudioHandler.commandStream.listen((command) {
        if (command == MediaCommand.next && mapping.mediaNextAction != MappedAction.none) onMappedAction?.call(mapping.mediaNextAction);
        else if (command == MediaCommand.previous && mapping.mediaPrevAction != MappedAction.none) onMappedAction?.call(mapping.mediaPrevAction);
        else if ((command == MediaCommand.play || command == MediaCommand.pause) && mapping.mediaPlayAction != MappedAction.none) onMappedAction?.call(mapping.mediaPlayAction);
      });
    }
  }

  void stopListening() {
    HardwareKeyboard.instance.removeHandler(_keyboardHandler);
    _clickTimer?.cancel(); _mediaSub?.cancel();
    platform.invokeMethod('setGameMode', false); // Segurança extra
  }

  void updateMapping(ButtonMapping newMapping) {
    mapping = newMapping; startListening(); 
  }

  int? _lastProcessedKeyId;
  int _lastProcessedTime = 0;

  bool _keyboardHandler(KeyEvent event) {
    final keyId = event.logicalKey.keyId;
    if (keyId == 0) return false;

    if (event is! KeyDownEvent) return false; 
    
    // Mapeamento manual e uso normal do Teclado USB/Bluetooth
    if (onKeyboardKeyCaptured != null) {
      onKeyboardKeyCaptured!(keyId);
      return true; 
    }

    if (!mapping.enableKeyboard) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (keyId == _lastProcessedKeyId && (now - _lastProcessedTime) < 150) return false; 
    _lastProcessedKeyId = keyId; _lastProcessedTime = now;

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