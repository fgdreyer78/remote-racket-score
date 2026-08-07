import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/key_event_provider.dart';
import '../../providers/score_provider.dart';
import '../button_mapping/button_mapping_screen.dart';
import '../history/history_screen.dart';
import '../../providers/locale_provider.dart';
import '../score/score_screen.dart';
import '../settings/settings_screen.dart';
import 'new_game_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Verifica se há uma partida em andamento (pelo menos 1 ponto, game ou set registrado)
  static bool _hasActiveMatch(WidgetRef ref) {
    final score = ref.read(scoreStateProvider);
    if (score.matchOver) return false;
    return score.setsA > 0 ||
        score.setsB > 0 ||
        score.gamesA > 0 ||
        score.gamesB > 0 ||
        score.pointsA > 0 ||
        score.pointsB > 0 ||
        score.tiebreakPointsA > 0 ||
        score.tiebreakPointsB > 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Garante que o game mode está desligado no menu principal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(keyEventServiceProvider).setGameMode(false);
    });

    const neonColor = Color(0xFFCCFF00);

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

                // Logo / Título
                Column(
                  children: [
                    Icon(Icons.sports_tennis,
                        color: neonColor, size: isLandscape ? 48 : 72),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.appTitle,
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
                  label: AppLocalizations.of(context)!.newGame,
                  color: neonColor,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NewGameScreen()),
                  ),
                ),

                // Botão "Continuar Partida" — só aparece se há jogo em andamento
                if (_hasActiveMatch(ref)) ...[
                  const SizedBox(height: 12),
                  _MenuButton(
                    icon: Icons.play_circle,
                    label: 'Continuar Partida em Andamento',
                    color: const Color(0xFF80FF80),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScoreScreen()),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                _MenuButton(
                  icon: Icons.tune,
                  label: AppLocalizations.of(context)!.presets,
                  color: Colors.white,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),

                const SizedBox(height: 12),

                _MenuButton(
                  icon: Icons.history,
                  label: AppLocalizations.of(context)!.history,
                  color: Colors.white,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                ),

                const SizedBox(height: 12),

                _MenuButton(
                  icon: Icons.settings,
                  label: AppLocalizations.of(context)!.settings,
                  color: Colors.white,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _ConfigScreen()),
                  ),
                ),

                const SizedBox(height: 16),

                // Versão
                const Text(
                  'v1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            );

            // Em landscape, usa SingleChildScrollView para permitir scroll
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

            // Em portrait, mantém o layout original
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
            Text(
              widget.label,
              style: TextStyle(
                color: fgColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right,
                color: fgColor.withValues(alpha: 0.5), size: 24),
          ],
        ),
      ),
    );
  }
}

/// Tela de Configurações Gerais
class _ConfigScreen extends ConsumerWidget {
  const _ConfigScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const neonColor = Color(0xFFCCFF00);
    final currentLocale = ref.watch(localeProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          loc.settings,
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
            title: loc.sportSettings,
            subtitle: loc.sportSettingsHint,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ButtonMappingScreen()),
            ),
          ),
          const Divider(color: Colors.white12),
          _ConfigTile(
            icon: Icons.dashboard_customize,
            title: loc.scoreLayout,
            subtitle: loc.scoreLayoutHint,
            onTap: null,
          ),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.language, color: neonColor),
            title: Text(
              loc.speechLanguage,
              style: const TextStyle(
                  color: AppTheme.onSurface, fontWeight: FontWeight.bold),
            ),
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              dropdownColor: AppTheme.surfaceVariant,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: Locale('pt', 'BR'),
                  child: Text('Português',
                      style: TextStyle(color: AppTheme.onSurface)),
                ),
                DropdownMenuItem(
                  value: Locale('en', 'US'),
                  child: Text('English',
                      style: TextStyle(color: AppTheme.onSurface)),
                ),
              ],
              onChanged: (locale) {
                if (locale != null) {
                  ref.read(localeProvider.notifier).setLocale(locale);
                }
              },
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
