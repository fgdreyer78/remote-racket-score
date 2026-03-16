import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../models/button_mapping.dart';
import '../../providers/button_mapping_provider.dart';

class ButtonMappingScreen extends ConsumerStatefulWidget {
  const ButtonMappingScreen({super.key});

  @override
  ConsumerState<ButtonMappingScreen> createState() => _ButtonMappingScreenState();
}

class _ButtonMappingScreenState extends ConsumerState<ButtonMappingScreen> {
  MappedAction? _waitingFor;
  int? _lastKeyId;

  bool _handler(KeyEvent event) {
    if (event is! KeyDownEvent || _waitingFor == null) return false;
    final keyId = event.physicalKey.usbHidUsage;
    setState(() {
      _lastKeyId = keyId;
      _assignKey(keyId, _waitingFor!);
      _waitingFor = null;
    });
    return true;
  }

  void _assignKey(int keyId, MappedAction action) {
    final current = ref.read(buttonMappingProvider).valueOrNull ?? const ButtonMapping();
    ButtonMapping next;
    switch (action) {
      case MappedAction.pointA:
        next = current.copyWith(pointAKeyId: keyId);
        break;
      case MappedAction.pointB:
        next = current.copyWith(pointBKeyId: keyId);
        break;
      case MappedAction.undo:
        next = current.copyWith(undoKeyId: keyId);
        break;
    }
    ref.read(buttonMappingProvider.notifier).updateMapping(next);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HardwareKeyboard.instance.addHandler(_handler);
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mappingAsync = ref.watch(buttonMappingProvider);
    final mapping = mappingAsync.valueOrNull ?? const ButtonMapping();

    return Focus(
      autofocus: true,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          title: const Text(
            'Mapeamento de botões',
            style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pressione o botão físico que deseja usar para cada ação. '
                'Use um controle Bluetooth (ex.: volante ou anel).',
                style: TextStyle(color: AppTheme.onSurface, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _MappingTile(
                label: 'Ponto Jogador/Dupla A',
                keyId: mapping.pointAKeyId,
                isWaiting: _waitingFor == MappedAction.pointA,
                onTap: () => setState(() => _waitingFor = MappedAction.pointA),
              ),
              const SizedBox(height: 16),
              _MappingTile(
                label: 'Ponto Jogador/Dupla B',
                keyId: mapping.pointBKeyId,
                isWaiting: _waitingFor == MappedAction.pointB,
                onTap: () => setState(() => _waitingFor = MappedAction.pointB),
              ),
              const SizedBox(height: 16),
              _MappingTile(
                label: 'Desfazer última ação',
                keyId: mapping.undoKeyId,
                isWaiting: _waitingFor == MappedAction.undo,
                onTap: () => setState(() => _waitingFor = MappedAction.undo),
              ),
              if (_waitingFor != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Aguardando botão para "${_actionLabel(_waitingFor!)}"...',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _actionLabel(MappedAction a) {
    switch (a) {
      case MappedAction.pointA:
        return 'Ponto A';
      case MappedAction.pointB:
        return 'Ponto B';
      case MappedAction.undo:
        return 'Desfazer';
    }
  }
}

class _MappingTile extends StatelessWidget {
  const _MappingTile({
    required this.label,
    required this.keyId,
    required this.isWaiting,
    required this.onTap,
  });

  final String label;
  final int? keyId;
  final bool isWaiting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surfaceVariant,
      child: ListTile(
        title: Text(label, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
        subtitle: Text(
          keyId != null ? 'KeyCode: $keyId' : 'Não mapeado',
          style: TextStyle(color: AppTheme.onSurface.withOpacity(0.7)),
        ),
        trailing: isWaiting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
              )
            : IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.primary),
                onPressed: onTap,
              ),
        onTap: isWaiting ? null : onTap,
      ),
    );
  }
}