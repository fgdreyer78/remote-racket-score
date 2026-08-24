import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../core/tts_dictionary.dart';
import '../../providers/locale_provider.dart';
import '../../providers/tts_config_provider.dart';
import '../../providers/tts_provider.dart';

/// Tela de configuração de idioma para interface e locução.
class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() =>
      _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState
    extends ConsumerState<LanguageSettingsScreen> {
  List<Map<String, String>> _availableVoices = [];
  bool _loadingVoices = false;
  bool _previewPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVoices();
    });
  }

  Future<void> _loadVoices() async {
    final ttsConfig = ref.read(ttsConfigProvider);
    setState(() => _loadingVoices = true);
    final tts = ref.read(ttsServiceProvider);
    final voices = await tts.getAvailableVoices(ttsConfig.languageCode);
    if (mounted) {
      setState(() {
        _availableVoices = voices;
        _loadingVoices = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  _loadVoices();
                }
              },
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // ================= SESSÃO 3: VOZ DA LOCUÇÃO =================
          _buildHeader(
              'Voz da Locução', 'Escolha a voz do narrador', neonColor),
          if (_loadingVoices)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else ...[
            // Opção padrão (automática)
            _VoiceTile(
              voiceName: null,
              displayName: 'Padrão (automática)',
              gender: '',
              isSelected: ttsConfig.voiceName == null,
              isPreviewPlaying: _previewPlaying && ttsConfig.voiceName == null,
              activeColor: neonColor,
              onSelect: () {
                ref.read(ttsConfigProvider.notifier).setVoice(null);
                _applyVoice(null);
              },
              onPreview: () => _previewVoice(null),
            ),
            if (_availableVoices.isNotEmpty)
              const Divider(color: Colors.white12, height: 1),
            for (final voice in _availableVoices)
              _VoiceTile(
                voiceName: voice['name'],
                displayName: _voiceDisplayName(voice),
                gender: voice['gender']!,
                isSelected: ttsConfig.voiceName == voice['name'],
                isPreviewPlaying:
                    _previewPlaying && ttsConfig.voiceName == voice['name'],
                activeColor: neonColor,
                onSelect: () {
                  ref.read(ttsConfigProvider.notifier).setVoice(voice['name']);
                  _applyVoice(voice['name']);
                },
                onPreview: () => _previewVoice(voice['name']),
              ),
            if (_availableVoices.isEmpty && !_loadingVoices)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Nenhuma voz adicional encontrada para este idioma.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
          ],
          const Divider(color: Colors.white12, height: 1),

          // ================= SESSÃO 4: PERSONALIZAR FRASES =================
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

  String _voiceDisplayName(Map<String, String> voice) {
    final name = voice['name'] ?? '';
    final gender = voice['gender'] ?? '';
    if (gender.isNotEmpty) {
      return '$name ($gender)';
    }
    return name;
  }

  Future<void> _applyVoice(String? voiceName) async {
    final ttsConfig = ref.read(ttsConfigProvider);
    final tts = ref.read(ttsServiceProvider);
    await tts.setVoiceByName(voiceName, ttsConfig.languageCode);
  }

  Future<void> _previewVoice(String? voiceName) async {
    if (_previewPlaying) {
      final tts = ref.read(ttsServiceProvider);
      await tts.stop();
      if (mounted) setState(() => _previewPlaying = false);
      return;
    }
    final ttsConfig = ref.read(ttsConfigProvider);
    final tts = ref.read(ttsServiceProvider);
    if (mounted) setState(() => _previewPlaying = true);
    await tts.speakVoicePreview(ttsConfig.languageCode, voiceName: voiceName);
    if (mounted) setState(() => _previewPlaying = false);
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

/// Tile de seleção de voz com botão de preview.
class _VoiceTile extends StatelessWidget {
  const _VoiceTile({
    required this.voiceName,
    required this.displayName,
    required this.gender,
    required this.isSelected,
    required this.isPreviewPlaying,
    required this.activeColor,
    required this.onSelect,
    required this.onPreview,
  });

  final String? voiceName;
  final String displayName;
  final String gender;
  final bool isSelected;
  final bool isPreviewPlaying;
  final Color activeColor;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Radio<String?>(
        value: voiceName,
        groupValue: isSelected ? voiceName : null,
        activeColor: activeColor,
        onChanged: (_) => onSelect(),
      ),
      title: Text(
        displayName,
        style: const TextStyle(color: AppTheme.onSurface),
      ),
      subtitle: gender.isNotEmpty
          ? Text(gender,
              style: const TextStyle(color: Colors.white54, fontSize: 12))
          : null,
      trailing: IconButton(
        icon: Icon(
          isPreviewPlaying ? Icons.stop_circle : Icons.play_circle_outline,
          color: activeColor,
          size: 28,
        ),
        tooltip: 'Ouvir exemplo',
        onPressed: onPreview,
      ),
      onTap: onSelect,
    );
  }
}
