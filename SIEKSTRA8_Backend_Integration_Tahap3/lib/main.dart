import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/supabase_config.dart';
import 'app/session.dart';
import 'siswa/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );
    } catch (e) {
      debugPrint('Supabase initialize error: $e');
    }
  }
  runApp(const SiekstraApp());
}

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
