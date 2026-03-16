import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'features/score/score_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const ProviderScope(child: RemoteRacketScoreApp()));
}

class RemoteRacketScoreApp extends StatelessWidget {
  const RemoteRacketScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Racket Score',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const ScoreScreen(),
    );
  }
}
