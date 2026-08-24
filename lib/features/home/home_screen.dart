import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../models/ongoing_match.dart';
import '../../providers/app_config_provider.dart';
import '../../providers/key_event_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/ongoing_matches_provider.dart';
import '../../providers/score_provider.dart';
import '../button_mapping/button_mapping_screen.dart';
import '../history/history_screen.dart';
import '../score/score_screen.dart';
import '../settings/language_settings_screen.dart';
import '../settings/settings_screen.dart';
import 'new_game_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(keyEventServiceProvider).setGameMode(false);
    });

    ref.watch(localeProvider);

    const neonColor = Color(0xFFCCFF00);
    final loc = AppConfig.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;

            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: isLandscape ? 16 : 32),
                Column(
                  children: [
                    Icon(Icons.sports_tennis,
                        color: neonColor, size: isLandscape ? 48 : 72),
                    const SizedBox(height: 12),
                    Text(
                      loc.text('appTitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: neonColor,
                        fontSize: isLandscape ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isLandscape ? 24 : 48),
                _MenuButton(
                  icon: Icons.play_circle_fill,
                  label: loc.text('newGame'),
                  color: neonColor,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NewGameScreen()),
                  ),
                ),
                const _OngoingMatchesSection(),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.tune,
                  label: loc.text('presets'),
                  color: Colors.white,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.history,
                  label: loc.text('history'),
                  color: Colors.white,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.settings,
                  label: loc.text('settings'),
                  color: Colors.white,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _ConfigScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'v1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            );

            if (isLandscape) {
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(child: content),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: content,
            );
          },
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = _isPressed ? widget.color : AppTheme.surfaceVariant;
    final fgColor = _isPressed ? AppTheme.surfaceVariant : widget.color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        child: Row(
          children: [
            Icon(widget.icon, color: fgColor, size: 28),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                color: fgColor.withValues(alpha: 0.5), size: 24),
          ],
        ),
      ),
    );
  }
}

class _OngoingMatchesSection extends ConsumerWidget {
  const _OngoingMatchesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ongoingAsync = ref.watch(ongoingMatchesProvider);
    final ongoing = ongoingAsync.valueOrNull ?? [];

    final activeScore = ref.read(scoreStateProvider);
    final hasActiveInMemory = !activeScore.matchOver &&
        (activeScore.setsA > 0 ||
            activeScore.setsB > 0 ||
            activeScore.gamesA > 0 ||
            activeScore.gamesB > 0 ||
            activeScore.pointsA > 0 ||
            activeScore.pointsB > 0 ||
            activeScore.tiebreakPointsA > 0 ||
            activeScore.tiebreakPointsB > 0);

    if (ongoing.isEmpty && !hasActiveInMemory) {
      return const SizedBox.shrink();
    }

    const neonColor = Color(0xFF80FF80);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        _MenuButton(
          icon: Icons.play_circle,
          label: 'Partidas em Andamento',
          color: neonColor,
          onTap: () {
            // Inclui a partida ativa em memória + partidas salvas
            final allMatches = <_OngoingEntry>[];
            if (hasActiveInMemory) {
              allMatches.add(_OngoingEntry(
                label:
                    '${activeScore.pointsA > 0 || activeScore.pointsB > 0 ? "Em jogo" : "Iniciada"} '
                    '(partida ativa)',
                summary: '',
                isActive: true,
              ));
            }
            for (final m in ongoing) {
              allMatches.add(_OngoingEntry(
                label: '${m.playerAName} vs ${m.playerBName}',
                summary: m.scoreSummary,
                isActive: false,
                match: m,
              ));
            }
            _showOngoingMatches(context, ref, allMatches);
          },
        ),
      ],
    );
  }

  void _showOngoingMatches(
      BuildContext context, WidgetRef ref, List<_OngoingEntry> entries) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Partidas em Andamento',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: entries.length,
                itemBuilder: (ctx, index) {
                  final entry = entries[index];
                  return ListTile(
                    leading: Icon(
                      entry.isActive ? Icons.play_circle : Icons.sports_tennis,
                      color: entry.isActive
                          ? const Color(0xFF80FF80)
                          : AppTheme.primary,
                    ),
                    title: Text(
                      entry.label,
                      style: const TextStyle(color: AppTheme.onSurface),
                    ),
                    subtitle: entry.summary.isNotEmpty
                        ? Text(
                            entry.summary,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow,
                              color: Color(0xFF80FF80)),
                          tooltip: entry.isActive ? 'Continuar' : 'Retomar',
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            if (entry.isActive) {
                              // Partida ativa em memória — vai direto para o placar
                              if (context.mounted) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const ScoreScreen()));
                              }
                            } else if (entry.match != null) {
                              // Partida salva — restaura
                              await ref
                                  .read(ongoingMatchesProvider.notifier)
                                  .restoreMatch(entry.match!);
                              if (context.mounted) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const ScoreScreen()));
                              }
                            }
                          },
                        ),
                        if (!entry.isActive)
                          IconButton(
                            icon:
                                const Icon(Icons.delete, color: AppTheme.error),
                            tooltip: 'Deletar',
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
                                    'Deseja deletar a partida ${entry.label}?',
                                    style: const TextStyle(
                                        color: AppTheme.onSurface),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dctx).pop(false),
                                      child: const Text('Cancelar',
                                          style: TextStyle(
                                              color: AppTheme.onSurface)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dctx).pop(true),
                                      child: const Text('Deletar',
                                          style:
                                              TextStyle(color: AppTheme.error)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await ref
                                    .read(ongoingMatchesProvider.notifier)
                                    .deleteMatch(entry.match!.id);
                                if (ctx.mounted) Navigator.of(ctx).pop();
                              }
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OngoingEntry {
  _OngoingEntry({
    required this.label,
    required this.summary,
    required this.isActive,
    this.match,
  });

  final String label;
  final String summary;
  final bool isActive;
  final OngoingMatch? match;
}

class _ConfigScreen extends ConsumerWidget {
  const _ConfigScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    const neonColor = Color(0xFFCCFF00);
    final loc = AppConfig.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          loc.text('configurations'),
          style: const TextStyle(color: neonColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: neonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          _ConfigTile(
            icon: Icons.settings_input_antenna,
            title: loc.text('sportSettings'),
            subtitle: loc.text('sportSettingsHint'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ButtonMappingScreen()),
            ),
          ),
          const Divider(color: Colors.white12),
          _ConfigTile(
            icon: Icons.dashboard_customize,
            title: loc.text('scoreLayout'),
            subtitle: loc.text('scoreLayoutHint'),
            onTap: null,
          ),
          const Divider(color: Colors.white12),
          _ConfigTile(
            icon: Icons.language,
            title: loc.text('speechLanguage'),
            subtitle: loc.text('languageHint'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LanguageSettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  const _ConfigTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const neonColor = Color(0xFFCCFF00);
    return ListTile(
      leading: Icon(icon, color: onTap != null ? neonColor : Colors.white38),
      title: Text(
        title,
        style: TextStyle(
          color: onTap != null ? AppTheme.onSurface : Colors.white38,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: Colors.white38)
          : null,
      onTap: onTap,
    );
  }
}
