import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';

import '../../core/app_theme.dart';
import '../../models/button_mapping.dart';
import '../../providers/button_mapping_provider.dart';
import '../../providers/key_event_provider.dart';

class ButtonMappingScreen extends ConsumerStatefulWidget {
  const ButtonMappingScreen({super.key});

  @override
  ConsumerState<ButtonMappingScreen> createState() => _ButtonMappingScreenState();
}

class _ButtonMappingScreenState extends ConsumerState<ButtonMappingScreen> {
  MappedAction? _waitingFor;
  final FocusNode _focusNode = FocusNode();
  
  StreamSubscription<double>? _volSub;
  double _currentVol = 0.5;

  void _assignKey(int keyId, MappedAction action) {
    final current = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();
    ButtonMapping next;
    switch (action) {
      case MappedAction.pointA: next = current.copyWith(pointAKeyId: keyId); break;
      case MappedAction.pointB: next = current.copyWith(pointBKeyId: keyId); break;
      case MappedAction.undo: next = current.copyWith(undoKeyId: keyId); break;
    }
    ref.read(buttonMappingProvider.notifier).updateMapping(next);
  }

  void _clearKey(MappedAction action) {
    final current = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();
    ButtonMapping next;
    switch (action) {
      case MappedAction.pointA:
        next = ButtonMapping(pointAKeyId: null, pointBKeyId: current.pointBKeyId, undoKeyId: current.undoKeyId, doubleClickActionA: current.doubleClickActionA, doubleClickActionB: current.doubleClickActionB, doubleClickActionUndo: current.doubleClickActionUndo, tripleClickActionA: current.tripleClickActionA, tripleClickActionB: current.tripleClickActionB, tripleClickActionUndo: current.tripleClickActionUndo);
        break;
      case MappedAction.pointB:
        next = ButtonMapping(pointAKeyId: current.pointAKeyId, pointBKeyId: null, undoKeyId: current.undoKeyId, doubleClickActionA: current.doubleClickActionA, doubleClickActionB: current.doubleClickActionB, doubleClickActionUndo: current.doubleClickActionUndo, tripleClickActionA: current.tripleClickActionA, tripleClickActionB: current.tripleClickActionB, tripleClickActionUndo: current.tripleClickActionUndo);
        break;
      case MappedAction.undo:
        next = ButtonMapping(pointAKeyId: current.pointAKeyId, pointBKeyId: current.pointBKeyId, undoKeyId: null, doubleClickActionA: current.doubleClickActionA, doubleClickActionB: current.doubleClickActionB, doubleClickActionUndo: current.doubleClickActionUndo, tripleClickActionA: current.tripleClickActionA, tripleClickActionB: current.tripleClickActionB, tripleClickActionUndo: null);
        break;
    }
    ref.read(buttonMappingProvider.notifier).updateMapping(next);
  }

  void _updateDoubleClick(MappedAction targetButton, MappedAction? actionToExecute) {
    final current = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();
    ButtonMapping next;
    if (actionToExecute == null) {
      switch (targetButton) {
        case MappedAction.pointA: next = ButtonMapping(pointAKeyId: current.pointAKeyId, pointBKeyId: current.pointBKeyId, undoKeyId: current.undoKeyId, doubleClickActionA: null, doubleClickActionB: current.doubleClickActionB, doubleClickActionUndo: current.doubleClickActionUndo, tripleClickActionA: current.tripleClickActionA, tripleClickActionB: current.tripleClickActionB, tripleClickActionUndo: current.tripleClickActionUndo); break;
        case MappedAction.pointB: next = ButtonMapping(pointAKeyId: current.pointAKeyId, pointBKeyId: current.pointBKeyId, undoKeyId: current.undoKeyId, doubleClickActionA: current.doubleClickActionA, doubleClickActionB: null, doubleClickActionUndo: current.doubleClickActionUndo, tripleClickActionA: current.tripleClickActionA, tripleClickActionB: current.tripleClickActionB, tripleClickActionUndo: current.tripleClickActionUndo); break;
        case MappedAction.undo: next = ButtonMapping(pointAKeyId: current.pointAKeyId, pointBKeyId: current.pointBKeyId, undoKeyId: current.undoKeyId, doubleClickActionA: current.doubleClickActionA, doubleClickActionB: current.doubleClickActionB, doubleClickActionUndo: null, tripleClickActionA: current.tripleClickActionA, tripleClickActionB: current.tripleClickActionB, tripleClickActionUndo: current.tripleClickActionUndo); break;
      }
    } else {
      switch (targetButton) {
        case MappedAction.pointA: next = current.copyWith(doubleClickActionA: actionToExecute); break;
        case MappedAction.pointB: next = current.copyWith(doubleClickActionB: actionToExecute); break;
        case MappedAction.undo: next = current.copyWith(doubleClickActionUndo: actionToExecute); break;
      }
    }
    ref.read(buttonMappingProvider.notifier).updateMapping(next);
  }

  void _updateTripleClick(MappedAction targetButton, MappedAction? actionToExecute) {
    final current = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();
    ButtonMapping next;
    if (actionToExecute == null) {
      switch (targetButton) {
        case MappedAction.pointA: next = ButtonMapping(pointAKeyId: current.pointAKeyId, pointBKeyId: current.pointBKeyId, undoKeyId: current.undoKeyId, doubleClickActionA: current.doubleClickActionA, doubleClickActionB: current.doubleClickActionB, doubleClickActionUndo: current.doubleClickActionUndo, tripleClickActionA: null, tripleClickActionB: current.tripleClickActionB, tripleClickActionUndo: current.tripleClickActionUndo); break;
        case MappedAction.pointB: next = ButtonMapping(pointAKeyId: current.pointAKeyId, pointBKeyId: current.pointBKeyId, undoKeyId: current.undoKeyId, doubleClickActionA: current.doubleClickActionA, doubleClickActionB: current.doubleClickActionB, doubleClickActionUndo: current.doubleClickActionUndo, tripleClickActionA: current.tripleClickActionA, tripleClickActionB: null, tripleClickActionUndo: current.tripleClickActionUndo); break;
        case MappedAction.undo: next = ButtonMapping(pointAKeyId: current.pointAKeyId, pointBKeyId: current.pointBKeyId, undoKeyId: current.undoKeyId, doubleClickActionA: current.doubleClickActionA, doubleClickActionB: current.doubleClickActionB, doubleClickActionUndo: current.doubleClickActionUndo, tripleClickActionA: current.tripleClickActionA, tripleClickActionB: current.tripleClickActionB, tripleClickActionUndo: null); break;
      }
    } else {
      switch (targetButton) {
        case MappedAction.pointA: next = current.copyWith(tripleClickActionA: actionToExecute); break;
        case MappedAction.pointB: next = current.copyWith(tripleClickActionB: actionToExecute); break;
        case MappedAction.undo: next = current.copyWith(tripleClickActionUndo: actionToExecute); break;
      }
    }
    ref.read(buttonMappingProvider.notifier).updateMapping(next);
  }

  @override
  void initState() {
    super.initState();
    ref.read(keyEventServiceProvider).stopListening(); 
    
    // ARMADILHA DE VOLUME: Se o Android roubar o botão, a gente pega ele pela mudança de volume!
    PerfectVolumeControl.getVolume().then((v) => _currentVol = v);
    _volSub = PerfectVolumeControl.stream.listen((v) {
      if (_waitingFor != null) {
        if (v > _currentVol) { // Aumentou
          _assignKey(LogicalKeyboardKey.audioVolumeUp.keyId, _waitingFor!);
          setState(() => _waitingFor = null);
        } else if (v < _currentVol) { // Diminuiu
          _assignKey(LogicalKeyboardKey.audioVolumeDown.keyId, _waitingFor!);
          setState(() => _waitingFor = null);
        }
      }
      _currentVol = v;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus(); 
    });
  }

  @override
  void dispose() {
    _volSub?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mappingAsync = ref.watch(buttonMappingProvider);
    final mapping = mappingAsync.valueOrNull ?? const ButtonMapping();

    return Focus( // Focus é mais agressivo que o RawKeyboardListener para botões de mídia
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (_waitingFor != null && (event is KeyDownEvent || event is KeyUpEvent)) {
          final keyId = event.logicalKey.keyId;
          if (keyId != 0) { // Ignora sinais vazios do Android
            _assignKey(keyId, _waitingFor!);
            setState(() => _waitingFor = null);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          title: const Text('Mapeamento de botões', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.primary), onPressed: () => Navigator.of(context).pop()),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Pressione o botão físico que deseja usar para cada ação. Use um controle Bluetooth (ex.: fones de ouvido, volante ou anel).', style: TextStyle(color: AppTheme.onSurface, fontSize: 16)),
            const SizedBox(height: 32),

            _MappingTile(
              label: 'Ponto Jogador/Dupla A', keyId: mapping.pointAKeyId,
              isWaiting: _waitingFor == MappedAction.pointA,
              onTap: () => setState(() { _waitingFor = MappedAction.pointA; _focusNode.requestFocus(); }),
              onClear: () => _clearKey(MappedAction.pointA),
              options: [_Option(label: 'Nenhum', value: null), _Option(label: 'Ponto B', value: MappedAction.pointB), _Option(label: 'Desfazer', value: MappedAction.undo)],
              currentDoubleClick: mapping.doubleClickActionA,
              onDoubleClickChanged: (val) => _updateDoubleClick(MappedAction.pointA, val),
              currentTripleClick: mapping.tripleClickActionA,
              onTripleClickChanged: (val) => _updateTripleClick(MappedAction.pointA, val),
            ),
            const SizedBox(height: 16),
            
            _MappingTile(
              label: 'Ponto Jogador/Dupla B', keyId: mapping.pointBKeyId,
              isWaiting: _waitingFor == MappedAction.pointB,
              onTap: () => setState(() { _waitingFor = MappedAction.pointB; _focusNode.requestFocus(); }),
              onClear: () => _clearKey(MappedAction.pointB),
              options: [_Option(label: 'Nenhum', value: null), _Option(label: 'Ponto A', value: MappedAction.pointA), _Option(label: 'Desfazer', value: MappedAction.undo)],
              currentDoubleClick: mapping.doubleClickActionB,
              onDoubleClickChanged: (val) => _updateDoubleClick(MappedAction.pointB, val),
              currentTripleClick: mapping.tripleClickActionB,
              onTripleClickChanged: (val) => _updateTripleClick(MappedAction.pointB, val),
            ),
            const SizedBox(height: 16),

            _MappingTile(
              label: 'Desfazer última ação', keyId: mapping.undoKeyId,
              isWaiting: _waitingFor == MappedAction.undo,
              onTap: () => setState(() { _waitingFor = MappedAction.undo; _focusNode.requestFocus(); }),
              onClear: () => _clearKey(MappedAction.undo),
              options: [_Option(label: 'Nenhum', value: null), _Option(label: 'Ponto A', value: MappedAction.pointA), _Option(label: 'Ponto B', value: MappedAction.pointB)],
              currentDoubleClick: mapping.doubleClickActionUndo,
              onDoubleClickChanged: (val) => _updateDoubleClick(MappedAction.undo, val),
              currentTripleClick: mapping.tripleClickActionUndo,
              onTripleClickChanged: (val) => _updateTripleClick(MappedAction.undo, val),
            ),
            
            if (_waitingFor != null) ...[
              const SizedBox(height: 24),
              Text('Aguardando botão para "${_actionLabel(_waitingFor!)}"...', style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  String _actionLabel(MappedAction a) {
    switch (a) {
      case MappedAction.pointA: return 'Ponto A';
      case MappedAction.pointB: return 'Ponto B';
      case MappedAction.undo: return 'Desfazer';
    }
  }
}

class _Option {
  final String label;
  final MappedAction? value;
  _Option({required this.label, required this.value});
}

class _MappingTile extends StatelessWidget {
  const _MappingTile({required this.label, required this.keyId, required this.isWaiting, required this.onTap, required this.onClear, required this.options, required this.currentDoubleClick, required this.onDoubleClickChanged, required this.currentTripleClick, required this.onTripleClickChanged});

  final String label;
  final int? keyId;
  final bool isWaiting;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final List<_Option> options;
  final MappedAction? currentDoubleClick;
  final ValueChanged<MappedAction?> onDoubleClickChanged;
  final MappedAction? currentTripleClick;
  final ValueChanged<MappedAction?> onTripleClickChanged;

  @override
  Widget build(BuildContext context) {
    const neonColor = Color(0xFFCCFF00);
    return Card(
      color: AppTheme.surfaceVariant,
      child: Column(
        children: [
          ListTile(
            title: Text(label, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
            subtitle: Text(keyId != null ? 'Código gravado: $keyId' : 'Não mapeado', style: TextStyle(color: AppTheme.onSurface.withOpacity(0.7))),
            trailing: isWaiting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: neonColor))
                : keyId != null
                    ? Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.delete, color: neonColor), onPressed: onClear), IconButton(icon: const Icon(Icons.edit, color: neonColor), onPressed: onTap)])
                    : IconButton(icon: const Icon(Icons.edit, color: neonColor), onPressed: onTap),
            onTap: isWaiting ? null : onTap,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ação ao fazer Duplo Clique:', style: TextStyle(color: neonColor.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: options.map((option) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<MappedAction?>(
                            value: option.value, groupValue: currentDoubleClick, onChanged: onDoubleClickChanged, activeColor: neonColor,
                            fillColor: MaterialStateProperty.resolveWith<Color>((states) => states.contains(MaterialState.selected) ? neonColor : AppTheme.onSurface.withOpacity(0.5)),
                          ),
                          Text(option.label, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13)),
                          const SizedBox(width: 8),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Ação ao fazer Triplo Clique:', style: TextStyle(color: neonColor.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: options.map((option) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<MappedAction?>(
                            value: option.value, groupValue: currentTripleClick, onChanged: onTripleClickChanged, activeColor: neonColor,
                            fillColor: MaterialStateProperty.resolveWith<Color>((states) => states.contains(MaterialState.selected) ? neonColor : AppTheme.onSurface.withOpacity(0.5)),
                          ),
                          Text(option.label, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13)),
                          const SizedBox(width: 8),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}