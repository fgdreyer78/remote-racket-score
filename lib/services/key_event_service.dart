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

  // Controle de intervalo mínimo entre pontos (anti-duplicata) por método
  int _volumeLastFiredMs = 0;
  int _mediaLastFiredMs = 0;
  int _keyboardLastFiredMs = 0;

  // O Dart atende o telefone do Kotlin aqui!
  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (!_isGameMode || !mapping.enableVolume) return;

      if (call.method == 'volumeUp') {
        _registerClick(
          'volUp',
          mapping.volUpAction,
          mapping.volUpDouble,
          mapping.volUpTriple,
          mapping.volumeDelayMs,
          _MethodType.volume,
        );
      } else if (call.method == 'volumeDown') {
        _registerClick(
          'volDown',
          mapping.volDownAction,
          mapping.volDownDouble,
          mapping.volDownTriple,
          mapping.volumeDelayMs,
          _MethodType.volume,
        );
      }
    });
  }

  void _registerClick(
    String source,
    MappedAction action,
    MappedAction dbl,
    MappedAction trpl,
    int delayMs,
    _MethodType methodType,
  ) {
    if (action == MappedAction.none) return;

    if (_pendingSource != null && _pendingSource != source) _executePending();

    _pendingSource = source;
    _pendingAction = action;
    _pendingDouble = dbl;
    _pendingTriple = trpl;
    _pendingMethodType = methodType;
    _clickCount++;

    _clickTimer?.cancel();
    _clickTimer = Timer(Duration(milliseconds: delayMs), _executePending);
  }

  _MethodType _pendingMethodType = _MethodType.volume;

  void _executePending() {
    if (_clickCount == 1) {
      _fire(_pendingAction, _pendingMethodType);
    } else if (_clickCount == 2) {
      if (_pendingDouble != null && _pendingDouble != MappedAction.none) {
        _fire(_pendingDouble, _pendingMethodType);
      } else {
        _fire(_pendingAction, _pendingMethodType);
        _fire(_pendingAction, _pendingMethodType);
      }
    } else if (_clickCount >= 3) {
      if (_pendingTriple != null && _pendingTriple != MappedAction.none) {
        _fire(_pendingTriple, _pendingMethodType);
      } else if (_pendingDouble != null && _pendingDouble != MappedAction.none) {
        _fire(_pendingDouble, _pendingMethodType);
        _fire(_pendingAction, _pendingMethodType);
      } else {
        _fire(_pendingAction, _pendingMethodType);
        _fire(_pendingAction, _pendingMethodType);
        _fire(_pendingAction, _pendingMethodType);
      }
    }
    _clickCount = 0;
    _pendingSource = null;
  }

  void _fire(MappedAction? action, _MethodType methodType) {
    if (action == null || action == MappedAction.none) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // Verifica o intervalo mínimo entre pontos para o método correspondente
    switch (methodType) {
      case _MethodType.volume:
        if (mapping.volumeMinIntervalMs > 0 &&
            (now - _volumeLastFiredMs) < mapping.volumeMinIntervalMs) {
          return; // Bloqueado pelo intervalo mínimo
        }
        _volumeLastFiredMs = now;
        break;
      case _MethodType.media:
        if (mapping.mediaMinIntervalMs > 0 &&
            (now - _mediaLastFiredMs) < mapping.mediaMinIntervalMs) {
          return; // Bloqueado pelo intervalo mínimo
        }
        _mediaLastFiredMs = now;
        break;
      case _MethodType.keyboard:
        if (mapping.keyboardMinIntervalMs > 0 &&
            (now - _keyboardLastFiredMs) < mapping.keyboardMinIntervalMs) {
          return; // Bloqueado pelo intervalo mínimo
        }
        _keyboardLastFiredMs = now;
        break;
    }

    onMappedAction?.call(action);
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
        if (command == MediaCommand.next && mapping.mediaNextAction != MappedAction.none) {
          _fire(mapping.mediaNextAction, _MethodType.media);
        } else if (command == MediaCommand.previous && mapping.mediaPrevAction != MappedAction.none) {
          _fire(mapping.mediaPrevAction, _MethodType.media);
        } else if ((command == MediaCommand.play || command == MediaCommand.pause) &&
            mapping.mediaPlayAction != MappedAction.none) {
          _fire(mapping.mediaPlayAction, _MethodType.media);
        }
      });
    }
  }

  void stopListening() {
    HardwareKeyboard.instance.removeHandler(_keyboardHandler);
    _clickTimer?.cancel();
    _mediaSub?.cancel();
    platform.invokeMethod('setGameMode', false); // Segurança extra
  }

  void updateMapping(ButtonMapping newMapping) {
    mapping = newMapping;
    startListening();
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
    _lastProcessedKeyId = keyId;
    _lastProcessedTime = now;

    if (mapping.keyA != null && keyId == mapping.keyA) {
      _registerClick('keyA', MappedAction.pointA, mapping.keyDoubleA, mapping.keyTripleA, mapping.keyboardDelayMs, _MethodType.keyboard);
      return true;
    } else if (mapping.keyB != null && keyId == mapping.keyB) {
      _registerClick('keyB', MappedAction.pointB, mapping.keyDoubleB, mapping.keyTripleB, mapping.keyboardDelayMs, _MethodType.keyboard);
      return true;
    } else if (mapping.keyUndo != null && keyId == mapping.keyUndo) {
      _registerClick('keyUndo', MappedAction.undo, mapping.keyDoubleUndo, mapping.keyTripleUndo, mapping.keyboardDelayMs, _MethodType.keyboard);
      return true;
    }

    return false;
  }
}

/// Identifica qual método de entrada originou o evento, para aplicar o intervalo mínimo correto
enum _MethodType { volume, media, keyboard }
