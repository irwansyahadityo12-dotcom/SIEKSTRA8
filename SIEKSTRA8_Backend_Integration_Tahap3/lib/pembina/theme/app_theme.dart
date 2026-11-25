import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0A4BD0);
  static const bg = Color(0xFFF8F9FE);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const line = Color(0xFFE5E9F5);
  static const soft = Color(0xFFE8EEFF);
  static const green = Color(0xFF15803D);
  static const greenSoft = Color(0xFFDCFCE7);
  static const red = Color(0xFFC81E1E);
  static const redSoft = Color(0xFFFEE2E2);
  static const amber = Color(0xFFD97706);
  static const amberSoft = Color(0xFFFEF3C7);
  static const orange = Color(0xFFF59E0B);
}

class T {
  static const h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.15);
  static const h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink);
  static const title = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const body = TextStyle(fontSize: 13, color: AppColors.muted, height: 1.35);
  static const label = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.8);
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: s.contains(WidgetState.selected) ? AppColors.primary : AppColors.muted)),
      ),
    );
