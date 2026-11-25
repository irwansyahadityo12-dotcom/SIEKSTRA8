import 'package:flutter/material.dart';

class C {
  static const primary = Color(0xFF1F5BD6);
  static const bg = Color(0xFFF6F8FD);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFE6EAF4);
  static const soft = Color(0xFFEAF0FF);
  static const field = Color(0xFFF1F4FD);
  static const green = Color(0xFF059669);
  static const greenSoft = Color(0xFFD1FAE5);
  static const red = Color(0xFFDC2626);
  static const redSoft = Color(0xFFFEE2E2);
  static const amber = Color(0xFFB45309);
  static const amberSoft = Color(0xFFFEF3C7);
  static const orange = Color(0xFFEA580C);
  static const orangeSoft = Color(0xFFFFEDD5);
}

class T {
  static const h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.ink, height: 1.15);
  static const h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.ink);
  static const title = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.ink);
  static const body = TextStyle(fontSize: 13, color: C.muted, height: 1.35);
  static const label = TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.muted, letterSpacing: 0.8);
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: C.bg,
      colorScheme: ColorScheme.fromSeed(seedColor: C.primary, primary: C.primary),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: s.contains(WidgetState.selected) ? C.primary : C.muted)),
      ),
    );
