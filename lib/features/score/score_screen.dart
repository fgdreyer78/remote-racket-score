import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../models/button_mapping.dart';
import '../../models/game_config.dart';
import '../../models/score_state.dart';
import '../../providers/button_mapping_provider.dart';
import '../../providers/game_config_provider.dart';
import '../../providers/key_event_provider.dart';
import '../../providers/score_provider.dart';
import '../../providers/tts_provider.dart';
import '../history/history_screen.dart';
import '../button_mapping/button_mapping_screen.dart';
import '../settings/settings_screen.dart';

class ScoreScreen extends ConsumerStatefulWidget {
  const ScoreScreen({super.key});

  @override
  ConsumerState<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends ConsumerState<ScoreScreen> {
  int? _clockRemaining;
  String _clockLabel = '';
  Timer? _clockTimer;

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock(int seconds, String label, GameConfig config) {
    _clockTimer?.cancel();
    setState(() {
      _clockRemaining = seconds;
      _clockLabel = label;
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_clockRemaining == null) return;
      final next = _clockRemaining! - 1;
      if (next <= 0) {
        _clockTimer?.cancel();
        _clockTimer = null;
        if (config.timeWarningSound) {
          ref.read(ttsServiceProvider).speakTimeWarning(config);
        }
      }
      if (mounted) {
        setState(() {
          _clockRemaining = next <= 0 ? null : next;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Garante que o nosso motor em segundo plano está vivo e rodando!
    ref.watch(keyEventServiceProvider);
    
    ref.listen<AsyncValue<ButtonMapping>>(buttonMappingProvider, (prev, next) {
      next.whenData((mapping) {
        ref.read(keyEventServiceProvider).updateMapping(mapping);
      });
    });
    
    final score = ref.watch(scoreStateProvider);
    final configAsync = ref.watch(gameConfigProvider);
    final config = configAsync.valueOrNull;

    ref.listen<ScoreState>(scoreStateProvider, (prev, next) {
      if (config == null || prev == null || next == prev) return;
      final setEnded = (next.setsA != prev.setsA) || (next.setsB != prev.setsB);
      final gameEnded = (next.gamesA + next.gamesB) > (prev.gamesA + prev.gamesB) && !next.isTiebreak;
      final pointAdded = next.pointsA != prev.pointsA || next.pointsB != prev.pointsB ||
          next.tiebreakPointsA != prev.tiebreakPointsA || next.tiebreakPointsB != prev.tiebreakPointsB;
      
      final totalGames = next.gamesA + next.gamesB;
      final isOddGame = totalGames % 2 != 0;
      final isFirstGame = totalGames == 1;
      final shouldRest = gameEnded && isOddGame && !isFirstGame;

      if (setEnded && config.breakBetweenSetsSeconds > 0) {
        _startClock(config.breakBetweenSetsSeconds, 'Intervalo (set)', config);
      } else if (shouldRest && config.breakBetweenGamesSeconds > 0) {
        _startClock(config.breakBetweenGamesSeconds, 'Intervalo (game)', config);
      } else if (pointAdded && config.serveClockSeconds > 0) {
        _startClock(config.serveClockSeconds, 'Saque', config);
      }
    });

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    const neonColor = Color(0xFFCCFF00); 

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          config?.sportName ?? 'Placar',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          if (!isPortrait && _clockRemaining != null && config != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.onSurface),
                    children: [
                      TextSpan(text: '$_clockLabel: '),
                      TextSpan(
                        text: '$_clockRemaining',
                        style: const TextStyle(color: neonColor, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.history, color: neonColor),
            tooltip: 'Histórico',
            onPressed: () => _openHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.casino, color: neonColor),
            tooltip: 'Coin toss',
            onPressed: _isMatchNotStarted(score) ? () => _coinToss(context) : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: neonColor),
            tooltip: 'Nova partida',
            onPressed: () => _confirmReset(context),
          ),
          IconButton(
            icon: const Icon(Icons.sports_tennis, color: neonColor),
            tooltip: 'Configurações',
            onPressed: () => _openSettings(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_input_antenna, color: neonColor),
            tooltip: 'Mapear botões',
            onPressed: () => _openButtonMapping(context),
          ),
        ],
      ),
      body: config == null
          ? const Center(child: CircularProgressIndicator(color: neonColor))
          : SafeArea(
              child: Column(
                children: [
                  if (isPortrait && _clockRemaining != null && config != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_clockLabel: ',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.onSurface),
                          ),
                          Text(
                            '$_clockRemaining',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: neonColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: _ScoreContent(
                      score: score,
                      playerAName: config.playerAName,
                      playerBName: config.playerBName,
                      ttsLanguage: config.ttsLanguage,
                      onPointA: () {
                        if (!score.matchOver) ref.read(scoreStateProvider.notifier).addPointA();
                      },
                      onPointB: () {
                        if (!score.matchOver) ref.read(scoreStateProvider.notifier).addPointB();
                      },
                      onUndo: () => ref.read(scoreStateProvider.notifier).undo(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openButtonMapping(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ButtonMappingScreen()),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceVariant,
              title: const Text(
                'Nova partida',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold), 
              ),
              content: const Text(
                'Tem certeza que deseja resetar o placar e iniciar uma nova partida?',
                style: TextStyle(color: AppTheme.onSurface),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurface)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Nova partida', style: TextStyle(color: AppTheme.primary)),
                ),
              ],
            );
          },
        ) ??
        false;
    if (shouldReset) {
      ref.read(scoreStateProvider.notifier).reset();
    }
  }

  bool _isMatchNotStarted(ScoreState score) {
    return score.pointsA == 0 &&
        score.pointsB == 0 &&
        score.gamesA == 0 &&
        score.gamesB == 0 &&
        score.setsA == 0 &&
        score.setsB == 0 &&
        !score.isTiebreak &&
        score.history.isEmpty;
  }

  Future<void> _coinToss(BuildContext context) async {
    final config = ref.read(gameConfigProvider).valueOrNull;
    if (config == null) return;
    final random = Random();
    final tossWinnerIsA = random.nextBool();
    final winnerName =
        tossWinnerIsA ? config.playerAName : config.playerBName;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceVariant,
          title: const Text(
            'Coin toss',
            style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold), 
          ),
          content: Text(
            '$winnerName ganhou o sorteio.\nEscolha se vai sacar ou receber primeiro.',
            style: const TextStyle(color: AppTheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('receive'),
              child: const Text('Receber', style: TextStyle(color: AppTheme.onSurface)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('serve'),
              child: const Text('Sacar', style: TextStyle(color: AppTheme.primary)),
            ),
          ],
        );
      },
    );

    if (choice == null) return;

    final serveIsA =
        (choice == 'serve') ? tossWinnerIsA : !tossWinnerIsA;
    ref.read(scoreStateProvider.notifier).setServer(serveIsA);

    final tts = ref.read(ttsServiceProvider);
    final language = config.ttsLanguage;
    if (language == 'pt-BR') {
      final choiceText = choice == 'serve' ? 'sacar' : 'receber';
      await tts.speakCoinToss(
        '$winnerName ganhou o sorteio e escolheu $choiceText primeiro.',
        config,
      );
    } else {
      final choiceText = choice == 'serve' ? 'serve' : 'receive';
      await tts.speakCoinToss(
        '$winnerName won the coin toss and chose to $choiceText first.',
        config,
      );
    }
  }
}

class _ScoreContent extends StatelessWidget {
  const _ScoreContent({
    required this.score,
    required this.playerAName,
    required this.playerBName,
    required this.ttsLanguage,
    required this.onPointA,
    required this.onPointB,
    required this.onUndo,
  });

  final ScoreState score;
  final String playerAName;
  final String playerBName;
  final String ttsLanguage;
  final VoidCallback onPointA;
  final VoidCallback onPointB;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    String pA = '';
    String pB = '';

    if (score.isTiebreak) {
      pA = '${score.tiebreakPointsA}';
      pB = '${score.tiebreakPointsB}';
    } else {
      if (score.pointsA >= 3 && score.pointsB >= 3) {
        if (score.pointsA == score.pointsB) {
          pA = '40';
          pB = '40';
        } else if (score.pointsA > score.pointsB) {
          pA = 'AD';
          pB = '40';
        } else {
          pA = '40';
          pB = 'AD';
        }
      } else {
        const pts = ['0', '15', '30', '40'];
        pA = score.pointsA < pts.length ? pts[score.pointsA] : '${score.pointsA}';
        pB = score.pointsB < pts.length ? pts[score.pointsB] : '${score.pointsB}';
      }
    }

    bool isMatchTiebreak = score.isTiebreak && score.gamesA == 0 && score.gamesB == 0;
    final bool hasGames = !score.matchOver && !isMatchTiebreak && (score.gamesA > 0 || score.gamesB > 0 || score.setsA > 0 || score.setsB > 0);
    final bool hasPoints = !score.matchOver && (pA != '0' || pB != '0');
    final bool hasSets = score.setsA > 0 || score.setsB > 0;

    const neonColor = Color(0xFFCCFF00); 
    const whiteColor = Colors.white; 
    const grayColor = Color(0xFF9E9E9E); 

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque, 
                        onTap: onPointA,
                        onLongPress: onUndo,
                        child: _buildPlayer(
                          isPortrait: isPortrait,
                          name: playerAName,
                          isServer: score.serverIsA,
                          previousSetsGames: score.previousSetsGamesA,
                          games: score.gamesA,
                          points: pA,
                          hasSets: hasSets,
                          hasGames: hasGames,
                          hasPoints: hasPoints,
                          neonColor: neonColor,
                          whiteColor: whiteColor,
                          grayColor: grayColor,
                        ),
                      ),
                      
                      SizedBox(height: isPortrait ? 64 : 32),
                      
                      GestureDetector(
                        behavior: HitTestBehavior.opaque, 
                        onTap: onPointB,
                        onLongPress: onUndo,
                        child: _buildPlayer(
                          isPortrait: isPortrait,
                          name: playerBName,
                          isServer: !score.serverIsA,
                          previousSetsGames: score.previousSetsGamesB,
                          games: score.gamesB,
                          points: pB,
                          hasSets: hasSets,
                          hasGames: hasGames,
                          hasPoints: hasPoints,
                          neonColor: neonColor,
                          whiteColor: whiteColor,
                          grayColor: grayColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          if (score.matchOver && score.winnerIsA != null) ...[
            const SizedBox(height: 24),
            Text(
              ttsLanguage == 'pt-BR'
                  ? 'Vencedor: ${score.winnerIsA! ? playerAName : playerBName}'
                  : 'Winner: ${score.winnerIsA! ? playerAName : playerBName}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: neonColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayer({
    required bool isPortrait,
    required String name,
    required bool isServer,
    required List<int> previousSetsGames,
    required int games,
    required String points,
    required bool hasSets,
    required bool hasGames,
    required bool hasPoints,
    required Color neonColor,
    required Color whiteColor,
    required Color grayColor,
  }) {
    final nameRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: isServer ? 1.0 : 0.0,
          child: Icon(Icons.circle, color: neonColor, size: 48),
        ),
        const SizedBox(width: 16),
        Text(
          name,
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
        ),
      ],
    );

    final scoresRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSets) ...[
          for (int pastGameScore in previousSetsGames) ...[
            SizedBox(
              width: 160,
              child: Center(child: Text('$pastGameScore', style: TextStyle(fontSize: 150, color: grayColor, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 24),
          ],
        ],
        if (hasGames) ...[
          SizedBox(
            width: 160,
            child: Center(child: Text('$games', style: TextStyle(fontSize: 150, color: whiteColor, fontWeight: FontWeight.bold))),
          ),
          if (hasPoints) const SizedBox(width: 24),
        ],
        if (hasPoints)
          SizedBox(
            width: 220, 
            child: Center(child: Text(points, style: TextStyle(fontSize: 150, color: neonColor, fontWeight: FontWeight.bold))),
          ),
      ],
    );

    if (isPortrait) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          nameRow,
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: scoresRow,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 500, child: nameRow),
          const SizedBox(width: 48),
          scoresRow,
        ],
      );
    }
  }
}