import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
import '../home/home_screen.dart';

class ScoreScreen extends ConsumerStatefulWidget {
  const ScoreScreen({super.key});

  @override
  ConsumerState<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends ConsumerState<ScoreScreen> {
  int? _clockRemaining;
  String _clockLabel = '';
  Timer? _clockTimer;

  bool _isMenuVisible = true;

  // Flash visual: qual jogador está piscando (null = nenhum)
  bool? _flashingIsA;
  bool _flashState = false; // true = invertido, false = normal
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    // ACORDA O MOTOR: Entrou no placar, liga o Buraco Negro NATIVO do Kotlin!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(keyEventServiceProvider).setGameMode(true);
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _flashTimer?.cancel();
    // Saiu do placar de vez, solta o volume do celular!
    ref.read(keyEventServiceProvider).setGameMode(false);
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

  /// Inicia o flash visual para o jogador que marcou ponto
  void _startFlash(bool isA, GameConfig config) {
    if (!config.pointFlashEnabled) return;
    _flashTimer?.cancel();
    final intervalMs = (1000 / config.pointFlashFrequencyHz).round();
    final totalMs = config.pointFlashDurationMs;
    int elapsed = 0;

    setState(() {
      _flashingIsA = isA;
      _flashState = true;
    });

    _flashTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      elapsed += intervalMs;
      if (elapsed >= totalMs) {
        timer.cancel();
        setState(() {
          _flashingIsA = null;
          _flashState = false;
        });
        return;
      }
      setState(() => _flashState = !_flashState);
    });
  }

  @override
  Widget build(BuildContext context) {
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

      if (_isMenuVisible) {
        setState(() => _isMenuVisible = false);
      }

      final setEnded = (next.setsA != prev.setsA) || (next.setsB != prev.setsB);
      final gameEnded = (next.gamesA + next.gamesB) > (prev.gamesA + prev.gamesB) && !next.isTiebreak;
      final pointAdded = next.pointsA != prev.pointsA || next.pointsB != prev.pointsB ||
          next.tiebreakPointsA != prev.tiebreakPointsA || next.tiebreakPointsB != prev.tiebreakPointsB;

      // Detecta quem marcou o ponto para o flash
      if (pointAdded) {
        final scorerIsA = (next.pointsA != prev.pointsA) ||
            (next.tiebreakPointsA != prev.tiebreakPointsA) ||
            (next.gamesA != prev.gamesA && next.pointsA == 0) ||
            (next.setsA != prev.setsA);
        _startFlash(scorerIsA, config);
      }

      final totalGames = next.gamesA + next.gamesB;
      final isOddGame = totalGames % 2 != 0;
      final isFirstGame = totalGames == 1;
      final shouldRest = gameEnded && isOddGame && !isFirstGame;

      if (setEnded && config.breakBetweenSetsSeconds > 0) {
        _startClock(config.breakBetweenSetsSeconds, 'Intervalo', config);
      } else if (shouldRest && config.breakBetweenGamesSeconds > 0) {
        _startClock(config.breakBetweenGamesSeconds, 'Intervalo', config);
      } else if (pointAdded && config.serveClockSeconds > 0) {
        _startClock(config.serveClockSeconds, 'Saque', config);
      }
    });

    const neonColor = Color(0xFFCCFF00);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 2 && !_isMenuVisible) {
            setState(() => _isMenuVisible = true);
          } else if (details.primaryDelta! < -2 && _isMenuVisible) {
            setState(() => _isMenuVisible = false);
          }
        },
        child: config == null
            ? const Center(child: CircularProgressIndicator(color: neonColor))
            : Stack(
                children: [
                  SafeArea(
                    child: _ScoreContent(
                      score: score,
                      playerAName: config.playerAName,
                      playerBName: config.playerBName,
                      ttsLanguage: config.ttsLanguage,
                      clockLabel: _clockLabel,
                      clockRemaining: _clockRemaining,
                      flashingIsA: _flashingIsA,
                      flashState: _flashState,
                      onPointA: () {
                        if (!score.matchOver) ref.read(scoreStateProvider.notifier).addPointA();
                      },
                      onPointB: () {
                        if (!score.matchOver) ref.read(scoreStateProvider.notifier).addPointB();
                      },
                      onUndo: () => ref.read(scoreStateProvider.notifier).undo(),
                    ),
                  ),

                  AnimatedSlide(
                    offset: _isMenuVisible ? Offset.zero : const Offset(0, -1.2),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOutCubic,
                    child: Container(
                      color: AppTheme.surface.withOpacity(0.95),
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              config.sportName.isNotEmpty ? config.sportName : 'Placar',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.history, color: neonColor), tooltip: 'Histórico', onPressed: () => _openHistory(context)),
                                IconButton(icon: const Icon(Icons.casino, color: neonColor), tooltip: 'Coin toss', onPressed: () => _coinToss(context)),
                                IconButton(icon: const Icon(Icons.refresh, color: neonColor), tooltip: 'Nova partida', onPressed: () => _confirmReset(context)),
                                IconButton(icon: const Icon(Icons.sports_tennis, color: neonColor), tooltip: 'Configurações', onPressed: () => _openSettings(context)),
                                IconButton(icon: const Icon(Icons.settings_input_antenna, color: neonColor), tooltip: 'Mapear botões', onPressed: () => _openButtonMapping(context)),
                                IconButton(icon: const Icon(Icons.home, color: neonColor), tooltip: 'Menu principal', onPressed: () => _goHome(context)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // --- NAVEGAÇÃO BLINDADA ---
  void _openSettings(BuildContext context) async {
    ref.read(keyEventServiceProvider).setGameMode(false);
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    ref.read(keyEventServiceProvider).setGameMode(true);
  }

  void _openButtonMapping(BuildContext context) async {
    ref.read(keyEventServiceProvider).setGameMode(false);
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ButtonMappingScreen()));
    ref.read(keyEventServiceProvider).setGameMode(true);
  }

  void _openHistory(BuildContext context) async {
    ref.read(keyEventServiceProvider).setGameMode(false);
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
    ref.read(keyEventServiceProvider).setGameMode(true);
  }

  void _goHome(BuildContext context) {
    ref.read(keyEventServiceProvider).setGameMode(false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }
  // -------------------------------------------------------------------------

  Future<void> _confirmReset(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceVariant,
              title: const Text('Nova partida', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              content: const Text('Tem certeza que deseja resetar o placar e iniciar uma nova partida?', style: TextStyle(color: AppTheme.onSurface)),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurface))),
                TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Nova partida', style: TextStyle(color: AppTheme.primary))),
              ],
            );
          },
        ) ?? false;
    if (shouldReset) {
      ref.read(scoreStateProvider.notifier).reset();
      setState(() => _isMenuVisible = true);
    }
  }

  Future<void> _coinToss(BuildContext context) async {
    final config = ref.read(gameConfigProvider).valueOrNull;
    if (config == null) return;
    final random = Random();
    final tossWinnerIsA = random.nextBool();
    final winnerName = tossWinnerIsA ? config.playerAName : config.playerBName;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceVariant,
          title: const Text('Coin toss', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          content: Text('$winnerName ganhou o sorteio.\nEscolha se vai sacar ou receber primeiro.', style: const TextStyle(color: AppTheme.onSurface)),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop('receive'), child: const Text('Receber', style: TextStyle(color: AppTheme.onSurface))),
            TextButton(onPressed: () => Navigator.of(context).pop('serve'), child: const Text('Sacar', style: TextStyle(color: AppTheme.primary))),
          ],
        );
      },
    );

    if (choice == null) return;

    final serveIsA = (choice == 'serve') ? tossWinnerIsA : !tossWinnerIsA;
    ref.read(scoreStateProvider.notifier).setServer(serveIsA);

    final tts = ref.read(ttsServiceProvider);
    final language = config.ttsLanguage;
    if (language == 'pt-BR') {
      final choiceText = choice == 'serve' ? 'sacar' : 'receber';
      await tts.speakCoinToss('$winnerName ganhou o sorteio e escolheu $choiceText primeiro.', config);
    } else {
      final choiceText = choice == 'serve' ? 'serve' : 'receive';
      await tts.speakCoinToss('$winnerName won the coin toss and chose to $choiceText first.', config);
    }
  }
}

class _ScoreContent extends StatelessWidget {
  const _ScoreContent({
    required this.score,
    required this.playerAName,
    required this.playerBName,
    required this.ttsLanguage,
    required this.clockLabel,
    required this.clockRemaining,
    required this.flashingIsA,
    required this.flashState,
    required this.onPointA,
    required this.onPointB,
    required this.onUndo,
  });

  final ScoreState score;
  final String playerAName;
  final String playerBName;
  final String ttsLanguage;
  final String clockLabel;
  final int? clockRemaining;
  final bool? flashingIsA;
  final bool flashState;
  final VoidCallback onPointA;
  final VoidCallback onPointB;
  final VoidCallback onUndo;

  Widget _buildBigClockPortrait(Color neonColor) {
    if (clockRemaining == null) return const SizedBox.shrink();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(clockLabel.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w500)),
        Text('$clockRemaining', style: TextStyle(color: neonColor, fontWeight: FontWeight.bold, fontSize: 80, height: 1.1)),
      ],
    );
  }

  Widget _buildBigClockLandscape(Color neonColor) {
    if (clockRemaining == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(clockLabel.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w500)),
        const SizedBox(width: 24),
        Text('$clockRemaining', style: TextStyle(color: neonColor, fontWeight: FontWeight.bold, fontSize: 80, height: 1.1)),
      ],
    );
  }

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

    // Determina cores de flash para cada jogador
    Color bgA = Colors.transparent;
    Color bgB = Colors.transparent;
    Color pointColorA = neonColor;
    Color pointColorB = neonColor;

    if (flashingIsA != null && flashState) {
      if (flashingIsA == true) {
        bgA = neonColor;
        pointColorA = AppTheme.surface;
      } else {
        bgB = neonColor;
        pointColorB = AppTheme.surface;
      }
    }

    Widget content;
    if (isPortrait) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 160,
            child: clockRemaining != null ? _buildBigClockPortrait(neonColor) : null,
          ),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPointA,
            onLongPress: onUndo,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              decoration: BoxDecoration(
                color: bgA,
                borderRadius: BorderRadius.circular(8),
              ),
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
                neonColor: pointColorA,
                whiteColor: flashingIsA == true && flashState ? AppTheme.surface : whiteColor,
                grayColor: flashingIsA == true && flashState ? AppTheme.surface : grayColor,
              ),
            ),
          ),

          const SizedBox(height: 32),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPointB,
            onLongPress: onUndo,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              decoration: BoxDecoration(
                color: bgB,
                borderRadius: BorderRadius.circular(8),
              ),
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
                neonColor: pointColorB,
                whiteColor: flashingIsA == false && flashState ? AppTheme.surface : whiteColor,
                grayColor: flashingIsA == false && flashState ? AppTheme.surface : grayColor,
              ),
            ),
          ),
        ],
      );
    } else {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPointA,
                onLongPress: onUndo,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 60),
                  decoration: BoxDecoration(
                    color: bgA,
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                    neonColor: pointColorA,
                    whiteColor: flashingIsA == true && flashState ? AppTheme.surface : whiteColor,
                    grayColor: flashingIsA == true && flashState ? AppTheme.surface : grayColor,
                  ),
                ),
              ),

              const SizedBox(height: 80),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPointB,
                onLongPress: onUndo,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 60),
                  decoration: BoxDecoration(
                    color: bgB,
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                    neonColor: pointColorB,
                    whiteColor: flashingIsA == false && flashState ? AppTheme.surface : whiteColor,
                    grayColor: flashingIsA == false && flashState ? AppTheme.surface : grayColor,
                  ),
                ),
              ),
            ],
          ),

          if (clockRemaining != null)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: _buildBigClockLandscape(neonColor),
                ),
              ),
            ),
        ],
      );
    }

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
                  child: content,
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
        Text(name, style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: whiteColor)),
      ],
    );

    final scoresRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSets) ...[
          for (int pastGameScore in previousSetsGames) ...[
            SizedBox(width: 160, child: Center(child: Text('$pastGameScore', style: TextStyle(fontSize: 150, color: grayColor, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 24),
          ],
        ],
        if (hasGames) ...[
          SizedBox(width: 160, child: Center(child: Text('$games', style: TextStyle(fontSize: 150, color: whiteColor, fontWeight: FontWeight.bold)))),
          if (hasPoints) const SizedBox(width: 24),
        ],
        if (hasPoints)
          SizedBox(width: 220, child: Center(child: Text(points, style: TextStyle(fontSize: 150, color: neonColor, fontWeight: FontWeight.bold)))),
      ],
    );

    if (isPortrait) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          nameRow,
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.only(left: 64), child: scoresRow),
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
