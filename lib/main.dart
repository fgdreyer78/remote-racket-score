import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

import 'core/app_theme.dart';
import 'features/home/home_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'services/match_audio_handler.dart';

void main() async {
  // Garante que o Flutter está pronto antes de iniciarmos os serviços pesados
  WidgetsFlutterBinding.ensureInitialized();

  // INICIALIZA O NOSSO CÉREBRO DE MÍDIA ANTES DE TUDO
  try {
    globalAudioHandler = await AudioService.init(
      builder: () => MatchAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.remoteracketscore.channel.audio',
        androidNotificationChannelName: 'Placar em Andamento',
        androidNotificationOngoing: true,
      ),
    );
  } catch (e) {
    // Se o áudio falhar, cria um handler dummy para o app não quebrar
    globalAudioHandler = MatchAudioHandler();
  }

  // Mantém a sua configuração original de orientação de tela
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const ProviderScope(child: RemoteRacketScoreApp()));
}

class RemoteRacketScoreApp extends ConsumerWidget {
  const RemoteRacketScoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Remote Racket Score',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      home: const HomeScreen(),
    );
  }
}
