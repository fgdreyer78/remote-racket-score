import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/key_event_provider.dart';
import '../button_mapping/button_mapping_screen.dart';
import '../history/history_screen.dart';
import '../../providers/locale_provider.dart';
import '../settings/settings_screen.dart';
import 'new_game_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Logo / Título
              Column(
                children: [
                  Icon(Icons.sports_tennis, color: neonColor, size: 72),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.appTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: neonColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 56),

              _MenuButton(
                icon: Icons.play_circle_fill,
                label: AppLocalizations.of(context)!.newGame,
                color: neonColor,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewGameScreen()),
                ),
              ),

              const SizedBox(height: 16),

              _MenuButton(
                icon: Icons.tune,
                label: AppLocalizations.of(context)!.presets,
                color: Colors.white,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),

              const SizedBox(height: 16),

              _MenuButton(
                icon: Icons.history,
                label: AppLocalizations.of(context)!.history,
                color: Colors.white,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),

              const SizedBox(height: 16),

              _MenuButton(
                icon: Icons.settings,
                label: AppLocalizations.of(context)!.settings,
                color: Colors.white,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _ConfigScreen()),
                ),
              ),

              const Spacer(),

              // Versão
              const Text(
                'v1.0',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right,
                  color: color.withOpacity(0.5), size: 24),
            ],
          ),
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
