import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF00C2FF);
  static const Color danger = Color(0xFFFF3B3B);
  static const Color neutral = Color(0xFF1C1C2E);
  static const Color surface = Color(0xFF2A2A3D);
  static const Color onSurface = Color(0xFFEEEEFF);

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
