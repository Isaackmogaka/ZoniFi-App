import 'package:flutter/material.dart';

/// AppColors: a single source of truth for every color in the app.
/// Change a color here, and it updates everywhere that references it —
/// same idea as a CSS variable.
class AppColors {
  static const Color navy = Color(0xFF0F2A5C);
  static const Color teal = Color(0xFF14B8A6);
  static const Color yellow = Color(0xFFF5C242);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFDC2626);
  static const Color background = Color(0xFFF8FAFC);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
}

/// AppTheme: tells MaterialApp how every widget should look by default,
/// so we don't restyle every button/text individually on every screen.
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        primary: AppColors.navy,
        secondary: AppColors.teal,
      ),
      fontFamily: 'Roboto',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          elevation: 0,
        ),
      ),
      useMaterial3: true,
    );
  }
}