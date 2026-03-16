import 'package:flutter/material.dart';

/// Tema alto contraste para visibilidade sob sol na quadra.
class AppTheme {
  static const Color surface = Color(0xFF0D0D0D);
  static const Color surfaceVariant = Color(0xFF1A1A1A);
  static const Color onSurface = Color(0xFFF5F5F5);
  
  // A grande mudança: A cor principal do app agora é o Neon Padrão ATP!
  static const Color primary = Color(0xFFCCFF00); 
  
  static const Color onPrimary = Color(0xFF0D0D0D);
  static const Color accentA = Color(0xFF00C853); // Mantido para botões secundários caso existam
  static const Color accentB = Color(0xFF2196F3); // Mantido para botões secundários caso existam
  static const Color error = Color(0xFFE53935);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        onSurface: onSurface,
        primary: primary,
        onPrimary: onPrimary,
        error: error,
        onError: onSurface,
      ),
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
      ),
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.w800,
        color: onSurface,
        letterSpacing: -1,
      ),
      displayMedium: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: const TextStyle(
        fontSize: 18,
        color: onSurface,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        color: onSurface,
      ),
    );
  }
}