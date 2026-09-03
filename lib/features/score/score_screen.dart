import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/ad_mob_service.dart';
import '../../widgets/bottom_banner_ad.dart';

import '../../core/app_theme.dart';
import '../../models/button_mapping.dart';
import '../../models/game_config.dart';
import '../../models/score_state.dart';
import '../../providers/button_mapping_provider.dart';
import '../../providers/game_config_provider.dart';
import '../../providers/key_event_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/ongoing_matches_provider.dart';
import '../../providers/score_provider.dart';
import '../../providers/tts_config_provider.dart';
import '../../providers/tts_provider.dart';
import '../history/history_screen.dart';
import '../button_mapping/button_mapping_screen.dart';
import '../settings/settings_screen.dart';
import '../home/home_screen.dart';
import 'landscape_score_layout.dart';

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

  bool? _flashingIsA;
  bool _flashState = false;
  Timer? _flashTimer;
  bool _undoFlashActive = false;

  bool _lastClockPlayWarning = false;

  bool _gameJustEnded = false;
  bool _setJustEnded = false;
  int _preGameEndPointsA = 0;
  int _preGameEndPointsB = 0;
  int _preGameEndTbPointsA = 0;
  int _preGameEndTbPointsB = 0;

  @override
  void initState() {
    super.initState();
    AdMobService.instance.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(keyEventServiceProvider).setGameMode(true);
      final config = ref.read(gameConfigProvider).valueOrNull;
      if (config != null && config.layoutMode == 1) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _flashTimer?.cancel();
    AdMobService.instance.dispose();
    ref.read(keyEventServiceProvider).setGameMode(false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  VoidCallback? _onClockComplete;

  void _startClock(int seconds, String label, GameConfig config,
      {bool playWarningSound = false, VoidCallback? onComplete}) {
    _clockTimer?.cancel();
    _lastClockPlayWarning = playWarningSound;
    _onClockComplete = onComplete;
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
        if (config.timeWarningSound && _lastClockPlayWarning) {
          final ttsConfig = ref.read(ttsConfigProvider);
          ref.read(ttsServiceProvider).speakTimeWarning(config, ttsConfig);
        }
        if (_onClockComplete != null) {
          final callback = _onClockComplete;
          _onClockComplete = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && callback != null) callback();
          });
        }
      }
      if (mounted) {
        setState(() {
          _clockRemaining = next <= 0 ? null : next;
        });
      }
    });
  }

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
          _undoFlashActive = false;
          _gameJustEnded = false;
          _setJustEnded = false;
        });
        return;
      }
      setState(() => _flashState = !_flashState);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(keyEventServiceProvider);
    ref.watch(localeProvider);
    final loc = AppConfig.of(context);

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
      final gameEnded =
          (next.gamesA + next.gamesB) > (prev.gamesA + prev.gamesB) &&
              !next.isTiebreak;
      final pointAdded = next.pointsA != prev.pointsA ||
          next.pointsB != prev.pointsB ||
          next.tiebreakPointsA != prev.tiebreakPointsA ||
          next.tiebreakPointsB != prev.tiebreakPointsB;

      final isUndo = next.history.length < prev.history.length;

      if (next.matchOver) {
        _clockTimer?.cancel();
        _clockTimer = null;
        if (mounted) {
          setState(() {
            _clockRemaining = null;
            _clockLabel = '';
          });
        }
        return;
      }

      if (isUndo) {
        setState(() => _undoFlashActive = true);
        final undoScorerIsA =
            ref.read(scoreStateProvider.notifier).lastScorerIsA;
        _startFlash(undoScorerIsA, config);
      } else if (pointAdded) {
        final scorerIsA = ref.read(scoreStateProvider.notifier).lastScorerIsA;
        final gameEnded =
            (next.gamesA + next.gamesB) > (prev.gamesA + prev.gamesB) &&
                !next.isTiebreak;
        final setEnded = (next.setsA + next.setsB) > (prev.setsA + prev.setsB);
        setState(() {
          _gameJustEnded = gameEnded;
          _setJustEnded = setEnded;
          if (gameEnded || setEnded) {
            _preGameEndPointsA = prev.pointsA;
            _preGameEndPointsB = prev.pointsB;
            _preGameEndTbPointsA = prev.tiebreakPointsA;
            _preGameEndTbPointsB = prev.tiebreakPointsB;
          }
        });
        _startFlash(scorerIsA, config);
      }

      final totalGames = next.gamesA + next.gamesB;
      final isOddGame = totalGames % 2 != 0;
      final isFirstGame = totalGames == 1;
      final shouldRestOdd = gameEnded && isOddGame && !isFirstGame;
      final shouldRestEven = gameEnded && !isOddGame && !isFirstGame;

      VoidCallback? serveClockAfterBreak;
      if (config.serveClockSeconds > 0) {
        serveClockAfterBreak = () {
          if (mounted) {
            _startClock(config.serveClockSeconds, 'Saque', config,
                playWarningSound: false);
          }
        };
      }

      if (setEnded) {
        AdMobService.instance.showAdIfAvailable();
      }

      if (setEnded && config.breakBetweenSetsSeconds > 0) {
        _startClock(config.breakBetweenSetsSeconds, 'Intervalo', config,
            playWarningSound: true, onComplete: serveClockAfterBreak);
      } else if (shouldRestOdd && config.breakBetweenOddGamesSeconds > 0) {
        _startClock(config.breakBetweenOddGamesSeconds, 'Intervalo', config,
            playWarningSound: true, onComplete: serveClockAfterBreak);
      } else if (shouldRestEven && config.breakBetweenEvenGamesSeconds > 0) {
        _startClock(config.breakBetweenEvenGamesSeconds, 'Intervalo', config,
            playWarningSound: false, onComplete: serveClockAfterBreak);
      } else if (pointAdded && config.serveClockSeconds > 0) {
        _startClock(config.serveClockSeconds, 'Saque', config,
            playWarningSound: false);
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
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Align(
                        alignment: _isPortrait(context)
                            ? Alignment.bottomCenter
                            : Alignment.bottomLeft,
                        child: const BottomBannerAd(),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: _ScoreContent(
                      score: score,
                      config: config,
                      clockLabel: _clockLabel,
                      clockRemaining: _clockRemaining,
                      flashingIsA: _flashingIsA,
                      flashState: _flashState,
                      undoFlashActive: _undoFlashActive,
                      gameJustEnded: _gameJustEnded,
                      setJustEnded: _setJustEnded,
                      preGameEndPointsA: _preGameEndPointsA,
                      preGameEndPointsB: _preGameEndPointsB,
                      preGameEndTbPointsA: _preGameEndTbPointsA,
                      preGameEndTbPointsB: _preGameEndTbPointsB,
                      onPointA: () {
                        if (!score.matchOver)
                          ref.read(scoreStateProvider.notifier).addPointA();
                      },
                      onPointB: () {
                        if (!score.matchOver)
                          ref.read(scoreStateProvider.notifier).addPointB();
                      },
                      onUndo: () =>
                          ref.read(scoreStateProvider.notifier).undo(),
                    ),
                  ),
                  AnimatedSlide(
                    offset:
                        _isMenuVisible ? Offset.zero : const Offset(0, -1.2),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOutCubic,
                    child: Container(
                      color: AppTheme.surface.withOpacity(0.95),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              config.sportName.isNotEmpty
                                  ? config.sportName
                                  : loc.text('score'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.history,
                                        color: neonColor),
                                    tooltip: loc.text('history'),
                                    onPressed: () => _openHistory(context)),
                                IconButton(
                                    icon: const Icon(Icons.casino,
                                        color: neonColor),
                                    tooltip: loc.text('coinToss'),
                                    onPressed: () => _coinToss(context)),
                                IconButton(
                                    icon: const Icon(Icons.refresh,
                                        color: neonColor),
                                    tooltip: loc.text('newMatch'),
                                    onPressed: () => _confirmReset(context)),
                                IconButton(
                                    icon: Icon(Icons.sports_tennis,
                                        color: config.lockSettingsDuringMatch &&
                                                score.setsA == 0 &&
                                                score.setsB == 0 &&
                                                score.gamesA == 0 &&
                                                score.gamesB == 0
                                            ? neonColor
                                            : config.lockSettingsDuringMatch
                                                ? Colors.white24
                                                : neonColor),
                                    tooltip: config.lockSettingsDuringMatch &&
                                            (score.setsA > 0 ||
                                                score.setsB > 0 ||
                                                score.gamesA > 0 ||
                                                score.gamesB > 0)
                                        ? loc.text('lockedDuringMatch')
                                        : loc.text('configurations'),
                                    onPressed: config.lockSettingsDuringMatch &&
                                            (score.setsA > 0 ||
                                                score.setsB > 0 ||
                                                score.gamesA > 0 ||
                                                score.gamesB > 0)
                                        ? null
                                        : () => _openSettings(context)),
                                IconButton(
                                    icon: const Icon(
                                        Icons.settings_input_antenna,
                                        color: neonColor),
                                    tooltip: loc.text('mapButtons'),
                                    onPressed: () =>
                                        _openButtonMapping(context)),
                                IconButton(
                                    icon: const Icon(Icons.home,
                                        color: neonColor),
                                    tooltip: loc.text('home'),
                                    onPressed: () => _goHome(context)),
                              ],
                            ),
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

  bool _isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  void _openSettings(BuildContext context) async {
    ref.read(keyEventServiceProvider).setGameMode(false);
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    ref.read(keyEventServiceProvider).setGameMode(true);
  }

  void _openButtonMapping(BuildContext context) async {
    ref.read(keyEventServiceProvider).setGameMode(false);
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ButtonMappingScreen()));
    ref.read(keyEventServiceProvider).setGameMode(true);
  }

  void _openHistory(BuildContext context) async {
    ref.read(keyEventServiceProvider).setGameMode(false);
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
    ref.read(keyEventServiceProvider).setGameMode(true);
  }

  Future<void> _goHome(BuildContext context) async {
    final loc = AppConfig.of(context);
    final score = ref.read(scoreStateProvider);
    final hasStarted = score.matchStarted ||
        score.setsA > 0 ||
        score.setsB > 0 ||
        score.gamesA > 0 ||
        score.gamesB > 0;

    if (hasStarted && !score.matchOver) {
      await ref.read(ongoingMatchesProvider.notifier).saveCurrentMatch();
    }

    if (hasStarted && !score.matchOver) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceVariant,
          title: Text(loc.text('leaveMatch'),
              style: const TextStyle(
                  color: AppTheme.primary, fontWeight: FontWeight.bold)),
          content: Text(loc.text('leaveMatchHint'),
              style: const TextStyle(color: AppTheme.onSurface)),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(loc.text('stay'),
                    style: const TextStyle(color: AppTheme.onSurface))),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(loc.text('leave'),
                    style: const TextStyle(color: AppTheme.primary))),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    ref.read(keyEventServiceProvider).setGameMode(false);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final loc = AppConfig.of(context);
    final shouldReset = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceVariant,
              title: Text(loc.text('newMatch'),
                  style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.bold)),
              content: Text(loc.text('resetMatchConfirm'),
                  style: const TextStyle(color: AppTheme.onSurface)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(loc.text('cancel'),
                        style: const TextStyle(color: AppTheme.onSurface))),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(loc.text('newMatch'),
                        style: const TextStyle(color: AppTheme.primary))),
              ],
            );
          },
        ) ??
        false;
    if (shouldReset) {
      ref.read(scoreStateProvider.notifier).reset();
      setState(() => _isMenuVisible = true);
    }
  }

  Future<void> _coinToss(BuildContext context) async {
    final loc = AppConfig.of(context);
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
          title: Text(loc.text('coinToss'),
              style: const TextStyle(
                  color: AppTheme.primary, fontWeight: FontWeight.bold)),
          content: Text('$winnerName ${loc.text('coinToss')}',
              style: const TextStyle(color: AppTheme.onSurface)),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop('receive'),
                child: Text(loc.text('receive'),
                    style: const TextStyle(color: AppTheme.onSurface))),
            TextButton(
                onPressed: () => Navigator.of(context).pop('serve'),
                child: Text(loc.text('serve'),
                    style: const TextStyle(color: AppTheme.primary))),
          ],
        );
      },
    );

    if (choice == null) return;

    final serveIsA = (choice == 'serve') ? tossWinnerIsA : !tossWinnerIsA;
    ref.read(scoreStateProvider.notifier).setServer(serveIsA);

    final tts = ref.read(ttsServiceProvider);
    final ttsConfig = ref.read(ttsConfigProvider);
    final language = ttsConfig.languageCode;
    if (language == 'pt-BR') {
      final choiceText = choice == 'serve' ? 'sacar' : 'receber';
      await tts.speakCoinToss(
          '$winnerName ganhou o sorteio e escolheu $choiceText primeiro.',
          config,
          ttsConfig);
    } else {
      final choiceText = choice == 'serve' ? 'serve' : 'receive';
      await tts.speakCoinToss(
          '$winnerName won the coin toss and chose to $choiceText first.',
          config,
          ttsConfig);
    }
  }
}

class _ScoreContent extends StatelessWidget {
  const _ScoreContent({
    required this.score,
    required this.config,
    required this.clockLabel,
    required this.clockRemaining,
    required this.flashingIsA,
    required this.flashState,
    required this.undoFlashActive,
    required this.gameJustEnded,
    required this.setJustEnded,
    required this.preGameEndPointsA,
    required this.preGameEndPointsB,
    required this.preGameEndTbPointsA,
    required this.preGameEndTbPointsB,
    required this.onPointA,
    required this.onPointB,
    required this.onUndo,
  });

  final ScoreState score;
  final GameConfig config;
  final String clockLabel;
  final int? clockRemaining;
  final bool? flashingIsA;
  final bool flashState;
  final bool undoFlashActive;
  final bool gameJustEnded;
  final bool setJustEnded;
  final int preGameEndPointsA;
  final int preGameEndPointsB;
  final int preGameEndTbPointsA;
  final int preGameEndTbPointsB;
  final VoidCallback onPointA;
  final VoidCallback onPointB;
  final VoidCallback onUndo;

  Widget _buildBigClockPortrait(
      Color neonColor, double nameSize, double baseSize) {
    if (clockRemaining == null) return const SizedBox.shrink();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(clockLabel.toUpperCase(),
            style: TextStyle(
                color: Colors.white,
                fontSize: nameSize,
                fontWeight: FontWeight.w500)),
        Text('$clockRemaining',
            style: TextStyle(
                color: neonColor,
                fontWeight: FontWeight.bold,
                fontSize: baseSize,
                height: 1.1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppConfig.of(context);
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
        pA = score.pointsA < pts.length
            ? pts[score.pointsA]
            : '${score.pointsA}';
        pB = score.pointsB < pts.length
            ? pts[score.pointsB]
            : '${score.pointsB}';
      }
    }

    bool isMatchTiebreak =
        score.isTiebreak && score.gamesA == 0 && score.gamesB == 0;
    final bool hasGames = !score.matchOver &&
        !isMatchTiebreak &&
        (score.gamesA > 0 ||
            score.gamesB > 0 ||
            score.setsA > 0 ||
            score.setsB > 0);
    final showScoreDuringFlash =
        flashingIsA != null && (gameJustEnded || setJustEnded);

    if (showScoreDuringFlash) {
      if (score.isTiebreak) {
        pA = '$preGameEndTbPointsA';
        pB = '$preGameEndTbPointsB';
      } else {
        if (preGameEndPointsA >= 3 && preGameEndPointsB >= 3) {
          if (preGameEndPointsA == preGameEndPointsB) {
            pA = '40';
            pB = '40';
          } else if (preGameEndPointsA > preGameEndPointsB) {
            pA = 'AD';
            pB = '40';
          } else {
            pA = '40';
            pB = 'AD';
          }
        } else {
          const pts = ['0', '15', '30', '40'];
          pA = preGameEndPointsA < pts.length
              ? pts[preGameEndPointsA]
              : '$preGameEndPointsA';
          pB = preGameEndPointsB < pts.length
              ? pts[preGameEndPointsB]
              : '$preGameEndPointsB';
        }
      }
    }

    final bool hasPoints =
        !score.matchOver && (pA != '0' || pB != '0' || showScoreDuringFlash);
    final bool hasSets = score.setsA > 0 || score.setsB > 0;

    const neonColor = Color(0xFFCCFF00);
    const whiteColor = Colors.white;
    const grayColor = Color(0xFF9E9E9E);

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    Color bgA = Colors.transparent;
    Color bgB = Colors.transparent;
    Color pointColorA = neonColor;
    Color pointColorB = neonColor;

    if (flashingIsA != null && flashState) {
      final flashColor = undoFlashActive ? const Color(0xFFFF4444) : neonColor;
      if (flashingIsA == true) {
        bgA = flashColor;
        pointColorA = AppTheme.surface;
      } else {
        bgB = flashColor;
        pointColorB = AppTheme.surface;
      }
    }

    final screenH = MediaQuery.of(context).size.height;

    double baseSize;
    double nameFontSize;
    double scoreGap;

    if (isPortrait) {
      // â”€â”€â”€ PORTRAIT â”€â”€â”€
      final availableH = screenH - 50;
      baseSize = availableH * 0.25;
      nameFontSize = availableH * 0.05;
      scoreGap = availableH * 0.05;
    } else {
      return LandscapeScoreLayout(
        score: score,
        config: config,
        pointsA: pA,
        pointsB: pB,
        clockLabel: clockLabel,
        clockRemaining: clockRemaining,
        flashingIsA: flashingIsA,
        flashState: flashState,
        undoFlashActive: undoFlashActive,
        gameJustEnded: gameJustEnded,
        setJustEnded: setJustEnded,
        preGameEndPointsA: preGameEndPointsA,
        preGameEndPointsB: preGameEndPointsB,
        preGameEndTbPointsA: preGameEndTbPointsA,
        preGameEndTbPointsB: preGameEndTbPointsB,
        onPointA: onPointA,
        onPointB: onPointB,
        onUndo: onUndo,
      );
    }

    // â”€â”€â”€ PORTRAIT â”€â”€â”€
    Widget content;
    content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 160,
          child: clockRemaining != null
              ? _buildBigClockPortrait(neonColor, nameFontSize, baseSize)
              : null,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPointA,
          onLongPress: onUndo,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 60),
            decoration: BoxDecoration(
                color: bgA, borderRadius: BorderRadius.circular(8)),
            child: _buildPlayer(
              name: config.playerAName,
              isServer: score.serverIsA,
              previousSetsGames: score.previousSetsGamesA,
              previousSetsTbPts: score.previousSetsTiebreakPointsA,
              games: score.gamesA,
              points: pA,
              hasSets: hasSets,
              hasGames: hasGames,
              hasPoints: hasPoints,
              neonColor: pointColorA,
              whiteColor: flashingIsA == true && flashState
                  ? AppTheme.surface
                  : whiteColor,
              grayColor: flashingIsA == true && flashState
                  ? AppTheme.surface
                  : grayColor,
              baseSize: baseSize,
              nameFontSize: nameFontSize,
              scoreGap: scoreGap,
            ),
          ),
        ),
        SizedBox(height: baseSize * 0.2),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPointB,
          onLongPress: onUndo,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 60),
            decoration: BoxDecoration(
                color: bgB, borderRadius: BorderRadius.circular(8)),
            child: _buildPlayer(
              name: config.playerBName,
              isServer: !score.serverIsA,
              previousSetsGames: score.previousSetsGamesB,
              previousSetsTbPts: score.previousSetsTiebreakPointsB,
              games: score.gamesB,
              points: pB,
              hasSets: hasSets,
              hasGames: hasGames,
              hasPoints: hasPoints,
              neonColor: pointColorB,
              whiteColor: flashingIsA == false && flashState
                  ? AppTheme.surface
                  : whiteColor,
              grayColor: flashingIsA == false && flashState
                  ? AppTheme.surface
                  : grayColor,
              baseSize: baseSize,
              nameFontSize: nameFontSize,
              scoreGap: scoreGap,
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: content,
              ),
            ),
          ),
          if (score.matchOver && score.winnerIsA != null)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${loc.text('winner')}: ${score.winnerIsA! ? config.playerAName : config.playerBName}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: neonColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviousSetScore({
    required int gamesA,
    required int gamesB,
    required int tbPtsA,
    required int tbPtsB,
    required Color neonColor,
    required Color whiteColor,
    required Color grayColor,
    required double baseSize,
    required double scoreGap,
  }) {
    final setSize = baseSize;
    if (tbPtsA > 0 || tbPtsB > 0) {
      final aWon = gamesA > gamesB;
      final winnerGames = aWon ? gamesA : gamesB;
      final loserTbPts = aWon ? tbPtsB : tbPtsA;
      final loserDisplay = aWon ? gamesB : gamesA;

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$winnerGames',
              style: TextStyle(
                  fontSize: setSize,
                  color: grayColor,
                  fontWeight: FontWeight.bold)),
          SizedBox(width: scoreGap * 0.5),
          Padding(
            padding: EdgeInsets.only(top: setSize * 0.13),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$loserDisplay',
                    style: TextStyle(
                        fontSize: setSize,
                        color: grayColor,
                        fontWeight: FontWeight.bold),
                  ),
                  if (loserTbPts > 0)
                    TextSpan(
                      text: '$loserTbPts',
                      style: TextStyle(
                          fontSize: setSize * 0.47,
                          color: grayColor,
                          fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      '$gamesA',
      style: TextStyle(
          fontSize: setSize, color: grayColor, fontWeight: FontWeight.bold),
    );
  }

  /// Layout PORTRAIT: nome em cima, placar embaixo.
  Widget _buildPlayer({
    required String name,
    required bool isServer,
    required List<int> previousSetsGames,
    required List<int> previousSetsTbPts,
    required int games,
    required String points,
    required bool hasSets,
    required bool hasGames,
    required bool hasPoints,
    required Color neonColor,
    required Color whiteColor,
    required Color grayColor,
    required double baseSize,
    required double nameFontSize,
    required double scoreGap,
  }) {
    final nameRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: isServer ? 1.0 : 0.0,
          child: Icon(Icons.circle, color: neonColor, size: nameFontSize * 0.4),
        ),
        SizedBox(width: scoreGap),
        Text(name,
            style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.bold,
                color: whiteColor)),
      ],
    );

    final scoresRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSets) ...[
          for (int i = 0; i < previousSetsGames.length; i++) ...[
            _buildPreviousSetScore(
              gamesA: previousSetsGames[i],
              gamesB: 0,
              tbPtsA: previousSetsTbPts.length > i ? previousSetsTbPts[i] : 0,
              tbPtsB: 0,
              neonColor: neonColor,
              whiteColor: whiteColor,
              grayColor: grayColor,
              baseSize: baseSize,
              scoreGap: scoreGap,
            ),
            SizedBox(width: scoreGap),
          ],
        ],
        if (hasGames) ...[
          Center(
            child: Text('$games',
                style: TextStyle(
                    fontSize: baseSize,
                    color: whiteColor,
                    fontWeight: FontWeight.bold)),
          ),
          if (hasPoints) SizedBox(width: scoreGap),
        ],
        if (hasPoints)
          Center(
            child: Text(points,
                style: TextStyle(
                    fontSize: baseSize,
                    color: neonColor,
                    fontWeight: FontWeight.bold)),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        nameRow,
        SizedBox(height: scoreGap),
        Padding(
            padding: EdgeInsets.only(left: nameFontSize * 1.28),
            child: scoresRow),
      ],
    );
  }
}
