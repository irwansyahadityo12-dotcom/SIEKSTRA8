import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const primary = Color(0xFF1D4ED8);
  static const primaryDark = Color(0xFF0B3FA8);
  static const bg = Color(0xFFF5F7FD);
  static const text = Color(0xFF111B33);
  static const muted = Color(0xFF6B7690);
  static const border = Color(0xFFE3E8F4);
  static const soft = Color(0xFFE8EEFF);
  static const brown = Color(0xFF9A5B0A);
  static const amber = Color(0xFFD97706);
  static const amberBg = Color(0xFFFFF1DC);
  static const red = Color(0xFFDC2626);
  static const redBg = Color(0xFFFDE8E8);
  static const green = Color(0xFF16A34A);
  static const greenBg = Color(0xFFE3F6EA);
  static const purple = Color(0xFF7C3AED);
  static const purpleBg = Color(0xFFF1EAFE);
  static const teal = Color(0xFF0E7490);
}

const kBlueGradient = LinearGradient(
  colors: [Color(0xFF2563EB), Color(0xFF0B3FA8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

ThemeData buildSiswaTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: C.primary, primary: C.primary),
      scaffoldBackgroundColor: C.bg,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: C.text,
      ),
    );
