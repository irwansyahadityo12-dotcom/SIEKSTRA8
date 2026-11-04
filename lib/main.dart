import 'package:flutter/material.dart';
import 'app/session.dart';
import 'siswa/screens/welcome_screen.dart';

void main() => runApp(const SiekstraApp());

class SiekstraApp extends StatelessWidget {
  const SiekstraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: appTheme,
      builder: (_, theme, __) => MaterialApp(
        title: 'SIEKSTRA-8',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const WelcomeScreen(),
      ),
    );
  }
}
