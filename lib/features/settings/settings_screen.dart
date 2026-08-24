import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_theme.dart';
import '../../models/game_config.dart';
import '../../providers/game_config_provider.dart';
import '../../providers/game_presets_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _sportController;
  late int _gamesToWinSet;
  late int _minGameDifference;
  late int _maxSets;
  late int _tiebreakAt;
  late int _tiebreakPoints;
  late int _tiebreakDifference;
  late int _finalSetTiebreakPoints;
  late int _finalSetTiebreakDifference;
  late bool _useFinalSetTiebreak;
  late bool _withAdvantage;
  late int _serveClockSeconds;
  late int _breakBetweenOddGamesSeconds;
  late int _breakBetweenEvenGamesSeconds;
  late int _breakBetweenSetsSeconds;
  late bool _timeWarningSound;
  // Flash visual
  late bool _pointFlashEnabled;
  late int _pointFlashDurationMs;
  late int _pointFlashFrequencyHz;
  // Auto-save
  late bool _autoSaveToHistory;
  late int _autoSaveDelaySeconds;
  // Layout
  late int _layoutMode;
  // Lock settings during match
  late bool _lockSettingsDuringMatch;

  // Preset overrides (-1 = usar padrão, >= 0 = valor específico)
  late int _presetTtsLanguageIndex;
  late int _presetLayoutModeIndex;

  @override
  void initState() {
    super.initState();
    _sportController = TextEditingController();
    _gamesToWinSet = 6;
    _minGameDifference = 2;
    _maxSets = 3;
    _tiebreakAt = 6;
    _tiebreakPoints = 7;
    _tiebreakDifference = 2;
    _finalSetTiebreakPoints = 10;
    _finalSetTiebreakDifference = 2;
    _useFinalSetTiebreak = true;
    _withAdvantage = true;
    _serveClockSeconds = 0;
    _breakBetweenOddGamesSeconds = 0;
    _breakBetweenEvenGamesSeconds = 0;
    _breakBetweenSetsSeconds = 0;
    _timeWarningSound = true;
    _pointFlashEnabled = false;
    _pointFlashDurationMs = 600;
    _pointFlashFrequencyHz = 4;
    _autoSaveToHistory = true;
    _autoSaveDelaySeconds = 10;
    _layoutMode = 0;
    _lockSettingsDuringMatch = false;
    _presetTtsLanguageIndex = -1;
    _presetLayoutModeIndex = -1;
  }

  int _formKey = 0;
  String? _lastConfigName;

  void _initFromConfig(GameConfig? config) {
    if (config == null) return;
    // Reinicializa se a config mudou (ex: preset aplicado externamente)
    if (_lastConfigName == config.sportName && _formKey > 0) return;
    _lastConfigName = config.sportName;

    _sportController.text = config.sportName;
    setState(() {
      _gamesToWinSet = config.gamesToWinSet;
      _minGameDifference = config.minGameDifference;
      _maxSets = config.maxSets;
      _tiebreakAt = config.tiebreakAt;
      _tiebreakPoints = config.tiebreakPoints;
      _tiebreakDifference = config.tiebreakDifference;
      _finalSetTiebreakPoints = config.finalSetTiebreakPoints;
      _finalSetTiebreakDifference = config.finalSetTiebreakDifference;
      _useFinalSetTiebreak = config.useFinalSetTiebreak;
      _withAdvantage = config.withAdvantage;
      _serveClockSeconds = config.serveClockSeconds;
      _breakBetweenOddGamesSeconds = config.breakBetweenOddGamesSeconds;
      _breakBetweenEvenGamesSeconds = config.breakBetweenEvenGamesSeconds;
      _breakBetweenSetsSeconds = config.breakBetweenSetsSeconds;
      _timeWarningSound = config.timeWarningSound;
      _pointFlashEnabled = config.pointFlashEnabled;
      _pointFlashDurationMs = config.pointFlashDurationMs;
      _pointFlashFrequencyHz = config.pointFlashFrequencyHz;
      _autoSaveToHistory = config.autoSaveToHistory;
      _autoSaveDelaySeconds = config.autoSaveDelaySeconds;
      _layoutMode = config.layoutMode;
      _lockSettingsDuringMatch = config.lockSettingsDuringMatch;
    });
  }

  @override
  void dispose() {
    _sportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(gameConfigProvider).valueOrNull;
    _initFromConfig(config);
    final presetsAsync = ref.watch(gamePresetsProvider);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(
          'Configurações da partida',
          style:
              TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: AppTheme.primary),
            tooltip: 'Carregar configuração salva',
            onPressed: presetsAsync.valueOrNull == null ||
                    presetsAsync.valueOrNull!.isEmpty
                ? null
                : () => _showPresetPicker(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          key: ValueKey(_formKey),
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 64),
          children: [
            TextField(
              controller: _sportController,
              decoration: const InputDecoration(
                labelText: 'Nome do esporte / configuração',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: AppTheme.onSurface),
            ),
            const SizedBox(height: 24),

            // --- GAMES E SETS ---
            const Text('Games e Sets',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            _numberField('Games para ganhar o set', _gamesToWinSet,
                (v) => _gamesToWinSet = v),
            _numberField('Diferença mínima de games', _minGameDifference,
                (v) => _minGameDifference = v),
            _numberField(
                'Número de sets (melhor de)', _maxSets, (v) => _maxSets = v),
            SwitchListTile(
              title: const Text('Sem vantagem (No-AD)',
                  style: TextStyle(color: AppTheme.onSurface)),
              subtitle: const Text(
                  'Game termina em 40-40 sem vantagem — próximo ponto fecha',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              value: !_withAdvantage,
              onChanged: (v) {
                setState(() => _withAdvantage = !v);
                _autoSave();
              },
              activeColor: AppTheme.primary,
            ),
            const SizedBox(height: 16),

            // --- TIEBREAK ---
            const Text('Tiebreak',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            _numberField(
                'Tiebreak ao empatar em', _tiebreakAt, (v) => _tiebreakAt = v),
            _numberField('Pontos para ganhar tiebreak', _tiebreakPoints,
                (v) => _tiebreakPoints = v),
            _numberField('Diferença no tiebreak', _tiebreakDifference,
                (v) => _tiebreakDifference = v),
            SwitchListTile(
              title: const Text('Tiebreak como set decisivo',
                  style: TextStyle(color: AppTheme.onSurface)),
              value: _useFinalSetTiebreak,
              onChanged: (v) {
                setState(() => _useFinalSetTiebreak = v);
                _autoSave();
              },
              activeColor: AppTheme.primary,
            ),
            if (_useFinalSetTiebreak) ...[
              _numberField('Pontos para ganhar tiebreak decisivo',
                  _finalSetTiebreakPoints, (v) => _finalSetTiebreakPoints = v),
              _numberField(
                  'Diferença para fechar tiebreak decisivo',
                  _finalSetTiebreakDifference,
                  (v) => _finalSetTiebreakDifference = v),
            ],
            const SizedBox(height: 24),

            // --- CRONÔMETRO E TEMPOS ---
            const Text('Cronômetro e Tempos',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            _numberField('Relógio de saque (segundos)', _serveClockSeconds,
                (v) => _serveClockSeconds = v,
                min: 0),
            _numberField(
                'Intervalo entre games ímpares (segundos)',
                _breakBetweenOddGamesSeconds,
                (v) => _breakBetweenOddGamesSeconds = v,
                min: 0),
            _numberField(
                'Intervalo entre games pares (segundos)',
                _breakBetweenEvenGamesSeconds,
                (v) => _breakBetweenEvenGamesSeconds = v,
                min: 0),
            _numberField('Intervalo entre sets (segundos)',
                _breakBetweenSetsSeconds, (v) => _breakBetweenSetsSeconds = v,
                min: 0),
            SwitchListTile(
              title: const Text('Aviso sonoro "Tempo" (games ímpares e sets)',
                  style: TextStyle(color: AppTheme.onSurface)),
              value: _timeWarningSound,
              onChanged: (v) {
                setState(() => _timeWarningSound = v);
                _autoSave();
              },
              activeColor: AppTheme.primary,
            ),
            const SizedBox(height: 24),

            // --- FLASH VISUAL ---
            const Text('Flash Visual ao Marcar Ponto',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Ativar flash visual',
                  style: TextStyle(color: AppTheme.onSurface)),
              value: _pointFlashEnabled,
              onChanged: (v) {
                setState(() => _pointFlashEnabled = v);
                _autoSave();
              },
              activeColor: AppTheme.primary,
            ),
            if (_pointFlashEnabled) ...[
              _numberField('Frequência (vezes/seg)', _pointFlashFrequencyHz,
                  (v) => _pointFlashFrequencyHz = v,
                  min: 1),
              _numberField('Duração total (ms)', _pointFlashDurationMs,
                  (v) => _pointFlashDurationMs = v,
                  min: 100),
            ],
            const SizedBox(height: 24),

            // --- AUTO-SAVE ---
            const Text('Salvar no Histórico',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Salvar automaticamente ao fim da partida',
                  style: TextStyle(color: AppTheme.onSurface)),
              value: _autoSaveToHistory,
              onChanged: (v) {
                setState(() => _autoSaveToHistory = v);
                _autoSave();
              },
              activeColor: AppTheme.primary,
            ),
            if (_autoSaveToHistory)
              _numberField('Aguardar antes de salvar (segundos)',
                  _autoSaveDelaySeconds, (v) => _autoSaveDelaySeconds = v,
                  min: 0),

            const SizedBox(height: 24),

            // --- LAYOUT ---
            const Text('Layout do Placar',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _layoutMode,
              dropdownColor: AppTheme.surfaceVariant,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 0, child: Text('Padrão (retrato / paisagem)')),
                DropdownMenuItem(
                    value: 1, child: Text('Paisagem dividido (lado a lado)')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _layoutMode = value);
                _autoSave();
              },
            ),

            const SizedBox(height: 24),

            // --- SEGURANÇA ---
            SwitchListTile(
              title: const Text('Travar configurações durante a partida',
                  style: TextStyle(color: AppTheme.onSurface)),
              subtitle: const Text(
                  'Impedir alterações nas configurações enquanto a partida está em andamento',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              value: _lockSettingsDuringMatch,
              onChanged: (v) {
                setState(() => _lockSettingsDuringMatch = v);
                _autoSave();
              },
              activeColor: AppTheme.primary,
            ),

            const SizedBox(height: 24),

            // --- OPÇÕES DO PRESET ---
            const Text('Opções do Preset',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Se definido no preset, sobrescreve a configuração global.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            ListTile(
              title: const Text('Idioma de Fala no Preset',
                  style: TextStyle(color: AppTheme.onSurface)),
              trailing: DropdownButton<int>(
                value: _presetTtsLanguageIndex,
                dropdownColor: AppTheme.surfaceVariant,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                      value: -1,
                      child: Text('Usar padrão',
                          style: TextStyle(color: AppTheme.onSurface))),
                  DropdownMenuItem(
                      value: 0,
                      child: Text('Português',
                          style: TextStyle(color: AppTheme.onSurface))),
                  DropdownMenuItem(
                      value: 1,
                      child: Text('English',
                          style: TextStyle(color: AppTheme.onSurface))),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _presetTtsLanguageIndex = v);
                },
              ),
            ),
            ListTile(
              title: const Text('Layout do Placar no Preset',
                  style: TextStyle(color: AppTheme.onSurface)),
              trailing: DropdownButton<int>(
                value: _presetLayoutModeIndex,
                dropdownColor: AppTheme.surfaceVariant,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                      value: -1,
                      child: Text('Usar padrão',
                          style: TextStyle(color: AppTheme.onSurface))),
                  DropdownMenuItem(
                      value: 0,
                      child: Text('Padrão',
                          style: TextStyle(color: AppTheme.onSurface))),
                  DropdownMenuItem(
                      value: 1,
                      child: Text('Paisagem dividido',
                          style: TextStyle(color: AppTheme.onSurface))),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _presetLayoutModeIndex = v);
                },
              ),
            ),

            const SizedBox(height: 48),

            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Salvar configurações",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPresetPicker(BuildContext context) async {
    final presets = ref.read(gamePresetsProvider).valueOrNull ?? [];
    if (presets.isEmpty) return;
    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceVariant,
          title: const Text(
            'Escolher configuração',
            style:
                TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final preset = presets[index];
                return ListTile(
                  title: Text(
                    preset.name,
                    style: const TextStyle(color: AppTheme.onSurface),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share,
                            color: AppTheme.primary, size: 20),
                        onPressed: () {
                          final c = preset.config;
                          Share.share(
                            'Preset: ${preset.name}\n'
                            'Games: ${c.gamesToWinSet} | Sets: melhor de ${c.maxSets}\n'
                            'Tiebreak: ${c.tiebreakAt} games, ${c.tiebreakPoints} pontos\n'
                            'Vantagem: ${c.withAdvantage ? "Sim" : "Não"}\n'
                            'Saque: ${c.serveClockSeconds}s | Intervalo ímpar: ${c.breakBetweenOddGamesSeconds}s | Par: ${c.breakBetweenEvenGamesSeconds}s',
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: AppTheme.error, size: 20),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dctx) => AlertDialog(
                              backgroundColor: AppTheme.surfaceVariant,
                              title: const Text(
                                'Confirmar exclusão',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                'Deseja deletar o preset "${preset.name}"?',
                                style:
                                    const TextStyle(color: AppTheme.onSurface),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dctx).pop(false),
                                  child: const Text('Cancelar',
                                      style:
                                          TextStyle(color: AppTheme.onSurface)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(dctx).pop(true),
                                  child: const Text('Deletar',
                                      style: TextStyle(color: AppTheme.error)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await ref
                                .read(gamePresetsProvider.notifier)
                                .deletePreset(index);
                            if (context.mounted) Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => Navigator.of(context).pop(index),
                );
              },
            ),
          ),
        );
      },
    );
    if (selected == null) return;
    final preset = presets[selected];
    await ref.read(gamePresetsProvider.notifier).applyPreset(preset);
    _loadPresetIntoForm(preset);
  }

  void _loadPresetIntoForm(dynamic preset) {
    final config = preset.config;
    _sportController.text = config.sportName;
    setState(() {
      _gamesToWinSet = config.gamesToWinSet;
      _minGameDifference = config.minGameDifference;
      _maxSets = config.maxSets;
      _tiebreakAt = config.tiebreakAt;
      _tiebreakPoints = config.tiebreakPoints;
      _tiebreakDifference = config.tiebreakDifference;
      _finalSetTiebreakPoints = config.finalSetTiebreakPoints;
      _finalSetTiebreakDifference = config.finalSetTiebreakDifference;
      _useFinalSetTiebreak = config.useFinalSetTiebreak;
      _withAdvantage = config.withAdvantage;
      _serveClockSeconds = config.serveClockSeconds;
      _breakBetweenOddGamesSeconds = config.breakBetweenOddGamesSeconds;
      _breakBetweenEvenGamesSeconds = config.breakBetweenEvenGamesSeconds;
      _breakBetweenSetsSeconds = config.breakBetweenSetsSeconds;
      _timeWarningSound = config.timeWarningSound;
      _pointFlashEnabled = config.pointFlashEnabled;
      _pointFlashDurationMs = config.pointFlashDurationMs;
      _pointFlashFrequencyHz = config.pointFlashFrequencyHz;
      _autoSaveToHistory = config.autoSaveToHistory;
      _autoSaveDelaySeconds = config.autoSaveDelaySeconds;
      _layoutMode = config.layoutMode;
      _lockSettingsDuringMatch = config.lockSettingsDuringMatch;
      // Preset overrides
      _presetTtsLanguageIndex = preset.overrideTtsLanguageIndex ?? -1;
      _presetLayoutModeIndex = preset.overrideLayoutModeIndex ?? -1;
      _formKey++;
    });
  }

  Widget _numberField(
    String label,
    int value,
    void Function(int) onSet, {
    int min = 1,
  }) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: AppTheme.onSurface)),
      trailing: SizedBox(
        width: 80,
        child: TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.onSurface),
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged: (text) {
            final parsed = int.tryParse(text);
            if (parsed != null && parsed >= min) {
              setState(() => onSet(parsed));
              _autoSave();
            }
          },
        ),
      ),
    );
  }

  /// Converte índice do dropdown de idioma TTS para código de idioma.
  String? _ttsLanguageCodeFromIndex(int index) {
    switch (index) {
      case 0:
        return 'pt-BR';
      case 1:
        return 'en-US';
      default:
        return null;
    }
  }

  /// Salva a configuração atual no provider (auto-aplica).
  void _autoSave() {
    final name = _sportController.text.trim().isEmpty
        ? 'Configuração da partida'
        : _sportController.text.trim();
    final currentConfig = ref.read(gameConfigProvider).valueOrNull;
    if (currentConfig == null) return;
    final config = currentConfig.copyWith(
      sportName: name,
      gamesToWinSet: _gamesToWinSet,
      minGameDifference: _minGameDifference,
      maxSets: _maxSets,
      tiebreakAt: _tiebreakAt,
      tiebreakPoints: _tiebreakPoints,
      tiebreakDifference: _tiebreakDifference,
      finalSetTiebreakPoints: _finalSetTiebreakPoints,
      finalSetTiebreakDifference: _finalSetTiebreakDifference,
      useFinalSetTiebreak: _useFinalSetTiebreak,
      withAdvantage: _withAdvantage,
      serveClockSeconds: _serveClockSeconds,
      breakBetweenOddGamesSeconds: _breakBetweenOddGamesSeconds,
      breakBetweenEvenGamesSeconds: _breakBetweenEvenGamesSeconds,
      breakBetweenSetsSeconds: _breakBetweenSetsSeconds,
      timeWarningSound: _timeWarningSound,
      pointFlashEnabled: _pointFlashEnabled,
      pointFlashDurationMs: _pointFlashDurationMs,
      pointFlashFrequencyHz: _pointFlashFrequencyHz,
      autoSaveToHistory: _autoSaveToHistory,
      autoSaveDelaySeconds: _autoSaveDelaySeconds,
      layoutMode: _layoutMode,
      lockSettingsDuringMatch: _lockSettingsDuringMatch,
    );
    ref.read(gameConfigProvider.notifier).updateConfig(config);
  }

  void _save() {
    _autoSave();

    // Preset overrides
    final name = _sportController.text.trim().isEmpty
        ? 'Configuração da partida'
        : _sportController.text.trim();
    final config = ref.read(gameConfigProvider).valueOrNull;
    if (config == null) return;

    final overrideTtsCode = _ttsLanguageCodeFromIndex(_presetTtsLanguageIndex);
    final overrideLayout =
        _presetLayoutModeIndex >= 0 ? _presetLayoutModeIndex : null;

    ref.read(gamePresetsProvider.notifier).savePreset(
          name,
          config,
          overrideTtsLanguage: overrideTtsCode,
          overrideLayoutMode: overrideLayout,
        );
    if (mounted) Navigator.of(context).pop();
  }
}
