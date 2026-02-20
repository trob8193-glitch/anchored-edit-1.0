import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF00FFD1);     // neon teal/mint
  static const Color secondary = Color(0xFF7B2FFF);   // neon purple
  static const Color accent = Color(0xFF00C2FF);      // cyan
  static const Color danger = Color(0xFFFF3B3B);
  static const Color warning = Color(0xFFFF9F00);
  static const Color success = Color(0xFF39FF14);     // neon green
  static const Color neutral = Color(0xFF0B0B14);     // near-black bg
  static const Color surface = Color(0xFF141424);     // card bg
  static const Color surfaceHigh = Color(0xFF1E1E30); // elevated card bg
  static const Color onSurface = Color(0xFFEEEEFF);
  static const Color hudBorder = Color(0x5000FFD1); // semi-transparent mint

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        primaryColor: primary,
        scaffoldBackgroundColor: neutral,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          surface: surface,
          onSurface: onSurface,
          error: danger,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: neutral,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
