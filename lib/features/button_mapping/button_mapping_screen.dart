import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../models/button_mapping.dart';
import '../../providers/button_mapping_provider.dart';
import '../../providers/key_event_provider.dart';
import '../../services/key_event_service.dart';

class ButtonMappingScreen extends ConsumerStatefulWidget {
  const ButtonMappingScreen({super.key});

  @override
  ConsumerState<ButtonMappingScreen> createState() => _ButtonMappingScreenState();
}

class _ButtonMappingScreenState extends ConsumerState<ButtonMappingScreen> {
  MappedAction? _waitingFor;
  late final KeyEventService _keyService;

  @override
  void initState() {
    super.initState();
    _keyService = ref.read(keyEventServiceProvider);
    _keyService.onKeyboardKeyCaptured = (keyId) {
      if (_waitingFor != null) {
        final current = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();
        ButtonMapping next;
        switch (_waitingFor!) {
          case MappedAction.pointA: next = current.copyWith(keyA: keyId); break;
          case MappedAction.pointB: next = current.copyWith(keyB: keyId); break;
          case MappedAction.undo: next = current.copyWith(keyUndo: keyId); break;
        }
        ref.read(buttonMappingProvider.notifier).updateMapping(next);
        setState(() => _waitingFor = null);
      }
    };
  }

  @override
  void dispose() {
    _keyService.onKeyboardKeyCaptured = null;
    super.dispose();
  }

  void _clearKeyboardKey(MappedAction action) {
    final current = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();
    ButtonMapping next;
    switch (action) {
      case MappedAction.pointA: next = current.copyWith(keyA: null); break;
      case MappedAction.pointB: next = current.copyWith(keyB: null); break;
      case MappedAction.undo: next = current.copyWith(keyUndo: null); break;
    }
    // Força bruta para deletar
    if (action == MappedAction.pointA) next = ButtonMapping(keyA: null, keyB: current.keyB, keyUndo: current.keyUndo, enableVolume: current.enableVolume, volUpAction: current.volUpAction, volUpDouble: current.volUpDouble, volUpTriple: current.volUpTriple, volDownAction: current.volDownAction, volDownDouble: current.volDownDouble, volDownTriple: current.volDownTriple, volumeDelayMs: current.volumeDelayMs, enableMedia: current.enableMedia, mediaNextAction: current.mediaNextAction, mediaPrevAction: current.mediaPrevAction, mediaPlayAction: current.mediaPlayAction, enableKeyboard: current.enableKeyboard, keyDoubleA: current.keyDoubleA, keyDoubleB: current.keyDoubleB, keyDoubleUndo: current.keyDoubleUndo, keyTripleA: current.keyTripleA, keyTripleB: current.keyTripleB, keyTripleUndo: current.keyTripleUndo, keyboardDelayMs: current.keyboardDelayMs);
    if (action == MappedAction.pointB) next = ButtonMapping(keyA: current.keyA, keyB: null, keyUndo: current.keyUndo, enableVolume: current.enableVolume, volUpAction: current.volUpAction, volUpDouble: current.volUpDouble, volUpTriple: current.volUpTriple, volDownAction: current.volDownAction, volDownDouble: current.volDownDouble, volDownTriple: current.volDownTriple, volumeDelayMs: current.volumeDelayMs, enableMedia: current.enableMedia, mediaNextAction: current.mediaNextAction, mediaPrevAction: current.mediaPrevAction, mediaPlayAction: current.mediaPlayAction, enableKeyboard: current.enableKeyboard, keyDoubleA: current.keyDoubleA, keyDoubleB: current.keyDoubleB, keyDoubleUndo: current.keyDoubleUndo, keyTripleA: current.keyTripleA, keyTripleB: current.keyTripleB, keyTripleUndo: current.keyTripleUndo, keyboardDelayMs: current.keyboardDelayMs);
    if (action == MappedAction.undo) next = ButtonMapping(keyA: current.keyA, keyB: current.keyB, keyUndo: null, enableVolume: current.enableVolume, volUpAction: current.volUpAction, volUpDouble: current.volUpDouble, volUpTriple: current.volUpTriple, volDownAction: current.volDownAction, volDownDouble: current.volDownDouble, volDownTriple: current.volDownTriple, volumeDelayMs: current.volumeDelayMs, enableMedia: current.enableMedia, mediaNextAction: current.mediaNextAction, mediaPrevAction: current.mediaPrevAction, mediaPlayAction: current.mediaPlayAction, enableKeyboard: current.enableKeyboard, keyDoubleA: current.keyDoubleA, keyDoubleB: current.keyDoubleB, keyDoubleUndo: current.keyDoubleUndo, keyTripleA: current.keyTripleA, keyTripleB: current.keyTripleB, keyTripleUndo: current.keyTripleUndo, keyboardDelayMs: current.keyboardDelayMs);
    ref.read(buttonMappingProvider.notifier).updateMapping(next);
  }

  @override
  Widget build(BuildContext context) {
    const neonColor = Color(0xFFCCFF00);
    final mappingAsync = ref.watch(buttonMappingProvider);
    final mapping = mappingAsync.valueOrNull ?? const ButtonMapping();
    final options = [_Option(label: 'Nenhum', value: null), _Option(label: 'Ponto A', value: MappedAction.pointA), _Option(label: 'Ponto B', value: MappedAction.pointB), _Option(label: 'Desfazer', value: MappedAction.undo)];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Dispositivos de Pontuação', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ================= SESSÃO 1: VOLUME =================
          _buildHeader('Botões de Volume / Shutter', 'Utiliza os botões de volume do celular ou Shutter Bluetooth', mapping.enableVolume, (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(enableVolume: val))),
          if (mapping.enableVolume) ...[
            _StaticMappingTile(
              label: 'Ação do Botão AUMENTAR Volume',
              currentSingle: mapping.volUpAction, onSingleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(volUpAction: val)),
              currentDouble: mapping.volUpDouble, onDoubleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(volUpDouble: val)),
              currentTriple: mapping.volUpTriple, onTripleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(volUpTriple: val)),
              options: options,
            ),
            _StaticMappingTile(
              label: 'Ação do Botão DIMINUIR Volume',
              currentSingle: mapping.volDownAction, onSingleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(volDownAction: val)),
              currentDouble: mapping.volDownDouble, onDoubleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(volDownDouble: val)),
              currentTriple: mapping.volDownTriple, onTripleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(volDownTriple: val)),
              options: options,
            ),
            _buildDelaySlider('Intervalo Máximo Entre Cliques', mapping.volumeDelayMs, (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(volumeDelayMs: val))),
          ],
          const Divider(color: Colors.white24, height: 1),

          // ================= SESSÃO 2: MÍDIA =================
          _buildHeader('Controles de Mídia', 'Utiliza os comandos do fone de ouvido ou smartwatch', mapping.enableMedia, (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(enableMedia: val))),
          if (mapping.enableMedia) ...[
            _SimpleDropdownTile(label: 'Ação para AVANÇAR (>>)', currentValue: mapping.mediaNextAction, options: options, onChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(mediaNextAction: val))),
            _SimpleDropdownTile(label: 'Ação para VOLTAR (<<)', currentValue: mapping.mediaPrevAction, options: options, onChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(mediaPrevAction: val))),
            _SimpleDropdownTile(label: 'Ação para PLAY / PAUSE', currentValue: mapping.mediaPlayAction, options: options, onChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(mediaPlayAction: val))),
            const SizedBox(height: 16),
          ],
          const Divider(color: Colors.white24, height: 1),

          // ================= SESSÃO 3: TECLADO =================
          _buildHeader('Teclado USB / Bluetooth', 'Utiliza teclas mapeadas manualmente', mapping.enableKeyboard, (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(enableKeyboard: val))),
          if (mapping.enableKeyboard) ...[
             _ManualMappingTile(
              label: 'Ponto Jogador/Dupla A', keyId: mapping.keyA, isWaiting: _waitingFor == MappedAction.pointA,
              onTap: () => setState(() { _waitingFor = MappedAction.pointA; }), onClear: () => _clearKeyboardKey(MappedAction.pointA),
              options: options, currentDouble: mapping.keyDoubleA, onDoubleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(keyDoubleA: val)),
              currentTriple: mapping.keyTripleA, onTripleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(keyTripleA: val)),
            ),
            _ManualMappingTile(
              label: 'Ponto Jogador/Dupla B', keyId: mapping.keyB, isWaiting: _waitingFor == MappedAction.pointB,
              onTap: () => setState(() { _waitingFor = MappedAction.pointB; }), onClear: () => _clearKeyboardKey(MappedAction.pointB),
              options: options, currentDouble: mapping.keyDoubleB, onDoubleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(keyDoubleB: val)),
              currentTriple: mapping.keyTripleB, onTripleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(keyTripleB: val)),
            ),
            _ManualMappingTile(
              label: 'Desfazer última ação', keyId: mapping.keyUndo, isWaiting: _waitingFor == MappedAction.undo,
              onTap: () => setState(() { _waitingFor = MappedAction.undo; }), onClear: () => _clearKeyboardKey(MappedAction.undo),
              options: options, currentDouble: mapping.keyDoubleUndo, onDoubleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(keyDoubleUndo: val)),
              currentTriple: mapping.keyTripleUndo, onTripleChanged: (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(keyTripleUndo: val)),
            ),
            if (_waitingFor != null) Padding(padding: const EdgeInsets.all(16), child: Text('Aguardando botão para o Teclado...', style: const TextStyle(color: neonColor, fontWeight: FontWeight.bold))),
            _buildDelaySlider('Intervalo Máximo Entre Cliques', mapping.keyboardDelayMs, (val) => ref.read(buttonMappingProvider.notifier).updateMapping(mapping.copyWith(keyboardDelayMs: val))),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      color: Colors.black12,
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Color(0xFFCCFF00), fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        value: value, activeColor: const Color(0xFFCCFF00), onChanged: onChanged,
      ),
    );
  }

  Widget _buildDelaySlider(String title, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(child: Slider(value: value.toDouble(), min: 200, max: 1000, divisions: 8, activeColor: const Color(0xFFCCFF00), onChanged: (v) => onChanged(v.toInt()))),
              Text('${value}ms', style: const TextStyle(color: Color(0xFFCCFF00), fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Option { final String label; final MappedAction? value; _Option({required this.label, required this.value}); }

class _StaticMappingTile extends StatelessWidget {
  const _StaticMappingTile({required this.label, required this.currentSingle, required this.onSingleChanged, required this.currentDouble, required this.onDoubleChanged, required this.currentTriple, required this.onTripleChanged, required this.options});
  final String label; final MappedAction? currentSingle; final ValueChanged<MappedAction?> onSingleChanged; final MappedAction? currentDouble; final ValueChanged<MappedAction?> onDoubleChanged; final MappedAction? currentTriple; final ValueChanged<MappedAction?> onTripleChanged; final List<_Option> options;
  @override Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: AppTheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildRadioRow('Ação de 1 Clique:', currentSingle, onSingleChanged, options),
            _buildRadioRow('Ação de 2 Cliques:', currentDouble, onDoubleChanged, options),
            _buildRadioRow('Ação de 3 Cliques:', currentTriple, onTripleChanged, options),
          ],
        ),
      ),
    );
  }
  Widget _buildRadioRow(String title, MappedAction? current, ValueChanged<MappedAction?> onChanged, List<_Option> options) {
    const neon = Color(0xFFCCFF00);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: neon.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((opt) => Row(mainAxisSize: MainAxisSize.min, children: [
              Radio<MappedAction?>(value: opt.value, groupValue: current, onChanged: onChanged, activeColor: neon, fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? neon : Colors.white54)),
              Text(opt.label, style: const TextStyle(color: Colors.white, fontSize: 13)), const SizedBox(width: 8)
            ])).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SimpleDropdownTile extends StatelessWidget {
  const _SimpleDropdownTile({required this.label, required this.currentValue, required this.options, required this.onChanged});
  final String label; final MappedAction? currentValue; final List<_Option> options; final ValueChanged<MappedAction?> onChanged;
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold))),
          DropdownButton<MappedAction?>(
            value: currentValue, dropdownColor: AppTheme.surfaceVariant,
            items: options.map((opt) => DropdownMenuItem(value: opt.value, child: Text(opt.label, style: const TextStyle(color: Colors.white)))).toList(),
            onChanged: onChanged,
          )
        ],
      ),
    );
  }
}

class _ManualMappingTile extends StatelessWidget {
  const _ManualMappingTile({required this.label, required this.keyId, required this.isWaiting, required this.onTap, required this.onClear, required this.options, required this.currentDouble, required this.onDoubleChanged, required this.currentTriple, required this.onTripleChanged});
  final String label; final int? keyId; final bool isWaiting; final VoidCallback onTap; final VoidCallback onClear; final List<_Option> options; final MappedAction? currentDouble; final ValueChanged<MappedAction?> onDoubleChanged; final MappedAction? currentTriple; final ValueChanged<MappedAction?> onTripleChanged;
  @override Widget build(BuildContext context) {
    const neon = Color(0xFFCCFF00);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: AppTheme.surfaceVariant,
      child: Column(
        children: [
          ListTile(
            title: Text(label, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
            subtitle: Text(keyId != null ? 'Código gravado: $keyId' : 'Não mapeado', style: TextStyle(color: Colors.white70)),
            trailing: isWaiting ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: neon)) : keyId != null ? Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.delete, color: neon), onPressed: onClear), IconButton(icon: const Icon(Icons.edit, color: neon), onPressed: onTap)]) : IconButton(icon: const Icon(Icons.edit, color: neon), onPressed: onTap),
            onTap: isWaiting ? null : onTap,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ação de 2 Cliques:', style: TextStyle(color: neon.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: options.map((opt) => Row(mainAxisSize: MainAxisSize.min, children: [Radio<MappedAction?>(value: opt.value, groupValue: currentDouble, onChanged: onDoubleChanged, activeColor: neon, fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? neon : Colors.white54)), Text(opt.label, style: const TextStyle(color: Colors.white, fontSize: 13)), const SizedBox(width: 8)])).toList())),
                const SizedBox(height: 8),
                Text('Ação de 3 Cliques:', style: TextStyle(color: neon.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: options.map((opt) => Row(mainAxisSize: MainAxisSize.min, children: [Radio<MappedAction?>(value: opt.value, groupValue: currentTriple, onChanged: onTripleChanged, activeColor: neon, fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? neon : Colors.white54)), Text(opt.label, style: const TextStyle(color: Colors.white, fontSize: 13)), const SizedBox(width: 8)])).toList())),
              ],
            ),
          )
        ],
      ),
    );
  }
}