import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryDarker = Color(0xFF1565C0);

  static const Color background = Color(0xFFF0F7FF);
  static const Color surfaceLight = Color(0xFFE3F2FD);

  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textDark = Color(0xFF374151);

  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color purple = Color(0xFFAB47BC);

  static const Color white = Color(0xFFFFFFFF);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color successBg = Color(0xFFE8F5E9);

  // ---MODO OSCURO
  // --- Dark Theme Colors ---
  static const Color backgroundDark = Color(
    0xFF0F172A,
  ); // Azul muy oscuro/negro
  static const Color surfaceDark = Color(0xFF1E293B); // Gris azulado profundo
  static const Color surfaceDarkLighter = Color(0xFF334155);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: purple,
      error: error,
      surface: surfaceLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundDark,

    colorScheme: const ColorScheme.dark(
      primary: primary, // El azul 1E88E5 funciona bien en oscuro
      secondary: purple,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      error: Color(0xFFEF5350), // Un rojo un poco más vibrante para contraste
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimaryDark),
      bodyMedium: TextStyle(color: textSecondaryDark),
    ),
  );
}
