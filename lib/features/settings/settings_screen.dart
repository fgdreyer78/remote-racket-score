import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late TextEditingController _playerAController;
  late TextEditingController _playerBController;
  late int _gamesToWinSet;
  late int _minGameDifference;
  late int _maxSets;
  late int _tiebreakAt;
  late int _tiebreakPoints;
  late int _tiebreakDifference;
  late int _finalSetTiebreakPoints;
  late bool _useFinalSetTiebreak;
  late bool _withAdvantage;
  late String _ttsLanguage;
  late int _serveClockSeconds;
  late int _breakBetweenGamesSeconds;
  late int _breakBetweenSetsSeconds;
  late bool _timeWarningSound;
  late String _audioOutput;

  @override
  void initState() {
    super.initState();
    _sportController = TextEditingController();
    _playerAController = TextEditingController();
    _playerBController = TextEditingController();
    _gamesToWinSet = 6;
    _minGameDifference = 2;
    _maxSets = 3;
    _tiebreakAt = 6;
    _tiebreakPoints = 7;
    _tiebreakDifference = 2;
    _finalSetTiebreakPoints = 7;
    _useFinalSetTiebreak = true;
    _withAdvantage = true;
    _ttsLanguage = 'pt-BR';
    _serveClockSeconds = 0;
    _breakBetweenGamesSeconds = 0;
    _breakBetweenSetsSeconds = 0;
    _timeWarningSound = true;
    _audioOutput = 'speaker';
  }

  bool _formInitialized = false;
  int _formKey = 0;

  void _initFromConfig(GameConfig? config) {
    if (config == null || _formInitialized) return;
    _formInitialized = true;
    _sportController.text = config.sportName;
    _playerAController.text = config.playerAName;
    _playerBController.text = config.playerBName;
    setState(() {
      _gamesToWinSet = config.gamesToWinSet;
      _minGameDifference = config.minGameDifference;
      _maxSets = config.maxSets;
      _tiebreakAt = config.tiebreakAt;
      _tiebreakPoints = config.tiebreakPoints;
      _tiebreakDifference = config.tiebreakDifference;
      _finalSetTiebreakPoints = config.finalSetTiebreakPoints;
      _useFinalSetTiebreak = config.useFinalSetTiebreak;
      _withAdvantage = config.withAdvantage;
      _ttsLanguage = config.ttsLanguage;
      _serveClockSeconds = config.serveClockSeconds;
      _breakBetweenGamesSeconds = config.breakBetweenGamesSeconds;
      _breakBetweenSetsSeconds = config.breakBetweenSetsSeconds;
      _timeWarningSound = config.timeWarningSound;
      _audioOutput = config.audioOutput;
    });
  }

  @override
  void dispose() {
    _sportController.dispose();
    _playerAController.dispose();
    _playerBController.dispose();
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
          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
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
      body: SafeArea( // Protege contra barras do sistema
        child: ListView(
          key: ValueKey(_formKey),
          // O "bottom: 64" garante que o final da lista (o botão) nunca fique colado no rodapé
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 64),
          children: [
            TextField(
              controller: _sportController,
              decoration: const InputDecoration(
                labelText: 'Configuração da partida',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: AppTheme.onSurface),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _playerAController,
              decoration: const InputDecoration(
                labelText: 'Jogador / Dupla A',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: AppTheme.onSurface),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _playerBController,
              decoration: const InputDecoration(
                labelText: 'Jogador / Dupla B',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: AppTheme.onSurface),
            ),
            const SizedBox(height: 24),
            const Text('Games e Sets', style: TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            _numberField('Games para ganhar o set', _gamesToWinSet, (v) => _gamesToWinSet = v),
            _numberField('Diferença mínima de games', _minGameDifference, (v) => _minGameDifference = v),
            _numberField('Número de sets (melhor de)', _maxSets, (v) => _maxSets = v),
            const SizedBox(height: 16),
            const Text('Tiebreak', style: TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            _numberField('Tiebreak ao empatar em', _tiebreakAt, (v) => _tiebreakAt = v),
            _numberField('Pontos para ganhar tiebreak', _tiebreakPoints, (v) => _tiebreakPoints = v),
            _numberField('Diferença no tiebreak', _tiebreakDifference, (v) => _tiebreakDifference = v),
            SwitchListTile(
              title: const Text('Tiebreak no set decisivo', style: TextStyle(color: AppTheme.onSurface)),
              value: _useFinalSetTiebreak,
              onChanged: (v) => setState(() => _useFinalSetTiebreak = v),
              activeColor: AppTheme.primary,
            ),
            const SizedBox(height: 24),

            const Text('Cronômetro e Tempos', style: TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            _numberField('Relógio de saque (segundos)', _serveClockSeconds, (v) => _serveClockSeconds = v, min: 0),
            _numberField('Intervalo entre games (segundos)', _breakBetweenGamesSeconds, (v) => _breakBetweenGamesSeconds = v, min: 0),
            _numberField('Intervalo entre sets (segundos)', _breakBetweenSetsSeconds, (v) => _breakBetweenSetsSeconds = v, min: 0),
            SwitchListTile(
              title: const Text('Aviso sonoro de tempo esgotado', style: TextStyle(color: AppTheme.onSurface)),
              value: _timeWarningSound,
              onChanged: (v) => setState(() => _timeWarningSound = v),
              activeColor: AppTheme.primary,
            ),
            const SizedBox(height: 24),

            const Text('Saída de áudio do TTS', style: TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _audioOutput,
              dropdownColor: AppTheme.surfaceVariant,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'speaker',
                  child: Text('Alto-falante do aparelho'),
                ),
                DropdownMenuItem(
                  value: 'bluetooth',
                  child: Text('Dispositivo Bluetooth (fone/caixa)'),
                ),
                DropdownMenuItem(
                  value: 'headphones',
                  child: Text('Fone de ouvido (cabo)'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _audioOutput = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Idioma', style: TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _ttsLanguage,
              dropdownColor: AppTheme.surfaceVariant,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'pt-BR',
                  child: Text('Português (Brasil)'),
                ),
                DropdownMenuItem(
                  value: 'en-US',
                  child: Text('English (US)'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _ttsLanguage = value;
                });
              },
            ),
            
            const SizedBox(height: 48), // Empurra o botão bem pra baixo
            
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Salvar configurações", style: TextStyle(fontWeight: FontWeight.bold)),
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
            style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
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
    _loadPresetIntoForm(preset.config);
  }

  void _loadPresetIntoForm(GameConfig config) {
    _sportController.text = config.sportName;
    _playerAController.text = config.playerAName;
    _playerBController.text = config.playerBName;
    setState(() {
      _gamesToWinSet = config.gamesToWinSet;
      _minGameDifference = config.minGameDifference;
      _maxSets = config.maxSets;
      _tiebreakAt = config.tiebreakAt;
      _tiebreakPoints = config.tiebreakPoints;
      _tiebreakDifference = config.tiebreakDifference;
      _finalSetTiebreakPoints = config.finalSetTiebreakPoints;
      _useFinalSetTiebreak = config.useFinalSetTiebreak;
      _withAdvantage = config.withAdvantage;
      _ttsLanguage = config.ttsLanguage;
      _serveClockSeconds = config.serveClockSeconds;
      _breakBetweenGamesSeconds = config.breakBetweenGamesSeconds;
      _breakBetweenSetsSeconds = config.breakBetweenSetsSeconds;
      _timeWarningSound = config.timeWarningSound;
      _audioOutput = config.audioOutput;
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
            }
          },
        ),
      ),
    );
  }

  void _save() {
    final name =
        _sportController.text.trim().isEmpty ? 'Configuração da partida' : _sportController.text.trim();
    final config = GameConfig(
      sportName: name,
      playerAName: _playerAController.text.trim().isEmpty ? 'Time A' : _playerAController.text.trim(),
      playerBName: _playerBController.text.trim().isEmpty ? 'Time B' : _playerBController.text.trim(),
      gamesToWinSet: _gamesToWinSet,
      minGameDifference: _minGameDifference,
      maxSets: _maxSets,
      tiebreakAt: _tiebreakAt,
      tiebreakPoints: _tiebreakPoints,
      tiebreakDifference: _tiebreakDifference,
      finalSetTiebreakPoints: _finalSetTiebreakPoints,
      useFinalSetTiebreak: _useFinalSetTiebreak,
      withAdvantage: _withAdvantage,
      miniMatchGames: false,
      miniMatchGamesCount: 0,
      ttsLanguage: _ttsLanguage,
      serveClockSeconds: _serveClockSeconds,
      breakBetweenGamesSeconds: _breakBetweenGamesSeconds,
      breakBetweenSetsSeconds: _breakBetweenSetsSeconds,
      timeWarningSound: _timeWarningSound,
      audioOutput: _audioOutput,
    );
    ref.read(gameConfigProvider.notifier).updateConfig(config);
    ref.read(gamePresetsProvider.notifier).savePreset(name, config);
    if (mounted) Navigator.of(context).pop();
  }
}