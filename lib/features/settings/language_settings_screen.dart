import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../core/tts_dictionary.dart';
import '../../providers/locale_provider.dart';
import '../../providers/tts_config_provider.dart';

/// Tela de configuração de idioma para interface e locução.
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const neonColor = Color(0xFFCCFF00);
    final ttsConfig = ref.watch(ttsConfigProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          'Idioma',
          style: const TextStyle(color: neonColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: neonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ================= SESSÃO 1: IDIOMA DA INTERFACE =================
          _buildHeader('Idioma da Interface', 'Textos exibidos no aplicativo',
              neonColor),
          ListTile(
            leading: const Icon(Icons.language, color: neonColor),
            title: const Text('Idioma da Interface',
                style: TextStyle(
                    color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
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
          const Divider(color: Colors.white12, height: 1),

          // ================= SESSÃO 2: IDIOMA DA LOCUÇÃO =================
          _buildHeader(
              'Idioma da Locução', 'Idioma falado pelo narrador', neonColor),
          ListTile(
            leading: const Icon(Icons.record_voice_over, color: neonColor),
            title: const Text('Idioma da Locução',
                style: TextStyle(
                    color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
            trailing: DropdownButton<String>(
              value: ttsConfig.languageCode,
              dropdownColor: AppTheme.surfaceVariant,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: 'pt-BR',
                  child: Text('Português',
                      style: TextStyle(color: AppTheme.onSurface)),
                ),
                DropdownMenuItem(
                  value: 'en-US',
                  child: Text('English',
                      style: TextStyle(color: AppTheme.onSurface)),
                ),
              ],
              onChanged: (code) {
                if (code != null) {
                  ref.read(ttsConfigProvider.notifier).setLanguage(code);
                }
              },
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // ================= SESSÃO 3: PERSONALIZAR FRASES =================
          _buildHeader('Personalizar Frases',
              'Edite o que é falado em cada situação', neonColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Toque em uma frase para editar. Deixe vazio para usar o padrão.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
            ),
          ),
          for (final key in TtsDictionary.customizableKeys)
            _PhraseEditTile(
              phraseKey: key,
              ttsConfig: ttsConfig,
              neonColor: neonColor,
            ),
          const SizedBox(height: 16),
          // Botão restaurar padrões
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(ttsConfigProvider.notifier).resetPhrases();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Frases restauradas para o padrão'),
                    backgroundColor: AppTheme.surfaceVariant,
                  ),
                );
              },
              icon: const Icon(Icons.restore, color: neonColor),
              label: const Text('Restaurar frases padrão',
                  style: TextStyle(color: neonColor)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: neonColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle, Color neonColor) {
    return Container(
      color: Colors.black12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Tile editável para cada frase do dicionário.
class _PhraseEditTile extends StatefulWidget {
  const _PhraseEditTile({
    required this.phraseKey,
    required this.ttsConfig,
    required this.neonColor,
  });

  final String phraseKey;
  final TtsConfig ttsConfig;
  final Color neonColor;

  @override
  State<_PhraseEditTile> createState() => _PhraseEditTileState();
}

class _PhraseEditTileState extends State<_PhraseEditTile> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final currentPhrase = widget.ttsConfig.phrase(widget.phraseKey);
    _controller = TextEditingController(text: currentPhrase);
  }

  @override
  void didUpdateWidget(_PhraseEditTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing) {
      final newPhrase = widget.ttsConfig.phrase(widget.phraseKey);
      _controller.text = newPhrase;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = TtsDictionary.keyLabels[widget.phraseKey] ?? widget.phraseKey;
    final currentPhrase = widget.ttsConfig.phrase(widget.phraseKey);
    final isCustom =
        widget.ttsConfig.customPhrases.containsKey(widget.phraseKey);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: AppTheme.surfaceVariant,
      child: ListTile(
        leading: Icon(
          isCustom ? Icons.edit_note : Icons.record_voice_over,
          color: isCustom ? widget.neonColor : Colors.white54,
        ),
        title: Text(label,
            style: const TextStyle(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        subtitle: _isEditing
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: currentPhrase,
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: widget.neonColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: widget.neonColor),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: _save,
                    ),
                  ),
                  onSubmitted: (_) => _save(),
                ),
              )
            : Text(
                isCustom ? '$currentPhrase (customizado)' : currentPhrase,
                style: TextStyle(
                  color: isCustom ? widget.neonColor : Colors.white54,
                  fontSize: 13,
                  fontStyle: isCustom ? FontStyle.normal : FontStyle.italic,
                ),
              ),
        onTap: () {
          setState(() => _isEditing = true);
        },
      ),
    );
  }

  void _save() {
    final value = _controller.text.trim();
    // Se o valor é igual ao padrão, remove a customização
    final defaultPhrase =
        TtsDictionary.get(widget.phraseKey, widget.ttsConfig.languageCode);
    final notifier =
        ProviderScope.containerOf(context).read(ttsConfigProvider.notifier);
    if (value == defaultPhrase) {
      notifier.setCustomPhrase(widget.phraseKey, '');
    } else {
      notifier.setCustomPhrase(widget.phraseKey, value);
    }
    setState(() => _isEditing = false);
  }
}
