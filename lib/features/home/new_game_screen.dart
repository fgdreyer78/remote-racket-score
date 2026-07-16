import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../models/game_config.dart';
import '../../models/match_preset.dart';
import '../../providers/game_config_provider.dart';
import '../../providers/game_presets_provider.dart';
import '../../providers/player_names_provider.dart';
import '../../providers/score_provider.dart';
import '../score/score_screen.dart';

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  final _playerAController = TextEditingController();
  final _playerBController = TextEditingController();
  final _playerAFocus = FocusNode();
  final _playerBFocus = FocusNode();

  MatchPreset? _selectedPreset;
  List<String> _suggestionsA = [];
  List<String> _suggestionsB = [];

  @override
  void initState() {
    super.initState();
    _playerAController.addListener(_onPlayerAChanged);
    _playerBController.addListener(_onPlayerBChanged);
  }

  @override
  void dispose() {
    _playerAController.removeListener(_onPlayerAChanged);
    _playerBController.removeListener(_onPlayerBChanged);
    _playerAController.dispose();
    _playerBController.dispose();
    _playerAFocus.dispose();
    _playerBFocus.dispose();
    super.dispose();
  }

  void _onPlayerAChanged() {
    final notifier = ref.read(playerNamesProvider.notifier);
    final q = _playerAController.text;
    final other = _playerBController.text.trim();
    setState(() {
      _suggestionsA = notifier.suggest(q, exclude: other.isEmpty ? null : other);
    });
  }

  void _onPlayerBChanged() {
    final notifier = ref.read(playerNamesProvider.notifier);
    final q = _playerBController.text;
    final other = _playerAController.text.trim();
    setState(() {
      _suggestionsB = notifier.suggest(q, exclude: other.isEmpty ? null : other);
    });
  }

  void _selectSuggestionA(String name) {
    _playerAController.text = name;
    _playerAController.selection = TextSelection.fromPosition(
      TextPosition(offset: name.length),
    );
    setState(() => _suggestionsA = []);
    _playerAFocus.unfocus();
  }

  void _selectSuggestionB(String name) {
    _playerBController.text = name;
    _playerBController.selection = TextSelection.fromPosition(
      TextPosition(offset: name.length),
    );
    setState(() => _suggestionsB = []);
    _playerBFocus.unfocus();
  }

  Future<void> _onPlay() async {
    final nameA = _playerAController.text.trim();
    final nameB = _playerBController.text.trim();

    if (nameA.isEmpty || nameB.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os nomes dos dois jogadores/duplas.')),
      );
      return;
    }

    if (nameA.toLowerCase() == nameB.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Os nomes dos jogadores devem ser diferentes.')),
      );
      return;
    }

    // Confirmação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: const Text(
          'Iniciar partida?',
          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '$nameA  vs  $nameB\n'
          'Preset: ${_selectedPreset?.name ?? 'Padrão'}',
          style: const TextStyle(color: AppTheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurface)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('OK', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Aplica preset ou config atual com os nomes escolhidos
    final baseConfig = _selectedPreset?.config ?? ref.read(gameConfigProvider).valueOrNull ?? const GameConfig();
    final config = baseConfig.copyWith(playerAName: nameA, playerBName: nameB);
    await ref.read(gameConfigProvider.notifier).updateConfig(config);

    // Salva os nomes no histórico de autocomplete
    await ref.read(playerNamesProvider.notifier).addName(nameA);
    await ref.read(playerNamesProvider.notifier).addName(nameB);

    // Reseta o placar
    ref.read(scoreStateProvider.notifier).reset();

    if (!mounted) return;

    // Coin toss / definir sacador
    await _showCoinTossDialog(config);
  }

  Future<void> _showCoinTossDialog(GameConfig config) async {
    if (!mounted) return;

    final random = Random();
    final tossWinnerIsA = random.nextBool();
    final winnerName = tossWinnerIsA ? config.playerAName : config.playerBName;

    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: const Text(
          'Coin Toss',
          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on, color: Color(0xFFCCFF00), size: 48),
            const SizedBox(height: 12),
            Text(
              '$winnerName ganhou o sorteio!\nEscolha:',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.onSurface, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('receive'),
            child: const Text('Receber', style: TextStyle(color: AppTheme.onSurface)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('serve'),
            child: const Text('Sacar', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('skip'),
            child: const Text('Pular', style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (choice != null && choice != 'skip') {
      final serveIsA = (choice == 'serve') ? tossWinnerIsA : !tossWinnerIsA;
      ref.read(scoreStateProvider.notifier).setServer(serveIsA);
    }

    // Navega para o placar, removendo todas as telas anteriores
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ScoreScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const neonColor = Color(0xFFCCFF00);
    final presetsAsync = ref.watch(gamePresetsProvider);
    final presets = presetsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(
          'Novo Jogo',
          style: TextStyle(color: neonColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: neonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            _suggestionsA = [];
            _suggestionsB = [];
          });
        },
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // ---- JOGADOR A ----
              const Text(
                'Jogador / Dupla A',
                style: TextStyle(color: neonColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _playerAController,
                focusNode: _playerAFocus,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Nome do jogador ou dupla A',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: const OutlineInputBorder(),
                  suffixIcon: _playerAController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white38),
                          onPressed: () {
                            _playerAController.clear();
                            setState(() => _suggestionsA = []);
                          },
                        )
                      : null,
                ),
              ),
              if (_suggestionsA.isNotEmpty)
                _SuggestionList(
                  suggestions: _suggestionsA,
                  onSelect: _selectSuggestionA,
                ),

              const SizedBox(height: 20),

              // ---- JOGADOR B ----
              const Text(
                'Jogador / Dupla B',
                style: TextStyle(color: neonColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _playerBController,
                focusNode: _playerBFocus,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Nome do jogador ou dupla B',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: const OutlineInputBorder(),
                  suffixIcon: _playerBController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white38),
                          onPressed: () {
                            _playerBController.clear();
                            setState(() => _suggestionsB = []);
                          },
                        )
                      : null,
                ),
              ),
              if (_suggestionsB.isNotEmpty)
                _SuggestionList(
                  suggestions: _suggestionsB,
                  onSelect: _selectSuggestionB,
                ),

              const SizedBox(height: 28),

              // ---- PRESET ----
              const Text(
                'Preset de Jogo',
                style: TextStyle(color: neonColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),

              if (presets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Nenhum preset salvo. Será usado o padrão (Tênis).',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      // Opção "Padrão"
                      RadioListTile<MatchPreset?>(
                        value: null,
                        groupValue: _selectedPreset,
                        onChanged: (v) => setState(() => _selectedPreset = v),
                        activeColor: neonColor,
                        title: const Text(
                          'Padrão (última configuração)',
                          style: TextStyle(color: AppTheme.onSurface),
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      ...presets.map((preset) => Column(
                            children: [
                              RadioListTile<MatchPreset?>(
                                value: preset,
                                groupValue: _selectedPreset,
                                onChanged: (v) => setState(() => _selectedPreset = v),
                                activeColor: neonColor,
                                title: Text(
                                  preset.name,
                                  style: const TextStyle(color: AppTheme.onSurface),
                                ),
                                subtitle: Text(
                                  '${preset.config.gamesToWinSet} games · melhor de ${preset.config.maxSets} sets',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ),
                              if (preset != presets.last)
                                const Divider(color: Colors.white12, height: 1),
                            ],
                          )),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // ---- BOTÃO JOGAR ----
              FilledButton.icon(
                onPressed: _onPlay,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'JOGAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: neonColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lista de sugestões de autocomplete
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.suggestions, required this.onSelect});

  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: suggestions
            .map(
              (name) => InkWell(
                onTap: () => onSelect(name),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white38, size: 18),
                      const SizedBox(width: 10),
                      Text(name, style: const TextStyle(color: AppTheme.onSurface)),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
