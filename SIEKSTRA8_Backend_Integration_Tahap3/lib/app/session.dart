import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'backend.dart';

// Tiap peran punya folder sendiri (siswa/, pembina/, admin/) dengan nama class
// yang mirip (MainShell, HomeScreen, dll). Karena itu diimpor dengan prefix.
import '../siswa/core/theme.dart' as siswa_theme;
import '../siswa/screens/main_shell.dart' as siswa;
import '../siswa/screens/login_screen.dart' as siswa_login;
import '../pembina/theme/app_theme.dart' as pembina_theme;
import '../pembina/screens/main_shell.dart' as pembina;
import '../admin/theme.dart' as admin_theme;
import '../admin/shell.dart' as admin;

enum Role { admin, pembina, siswa }

/// Tema aktif aplikasi. Berganti sesuai peran yang sedang masuk.
final ValueNotifier<ThemeData> appTheme = ValueNotifier<ThemeData>(siswa_theme.buildSiswaTheme());

/// Data profil pengguna aktif yang login ke sistem (dari tabel profiles Supabase).
final ValueNotifier<Map<String, dynamic>?> currentUserProfile = ValueNotifier<Map<String, dynamic>?>(null);

/// Mendapatkan nama lengkap pengguna aktif secara dinamis.
String get currentUserName {
  final profile = currentUserProfile.value;
  if (profile != null && profile['full_name'] != null && profile['full_name'].toString().trim().isNotEmpty) {
    return profile['full_name'].toString().trim();
  }
  final user = Backend.user;
  if (user != null) {
    if (user.userMetadata?['full_name'] != null && user.userMetadata!['full_name'].toString().trim().isNotEmpty) {
      return user.userMetadata!['full_name'].toString().trim();
    }
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@').first;
    }
  }
  return 'Siswa';
}

/// Mendapatkan NIS / NIP / Identifier pengguna aktif.
String get currentIdentifier {
  final profile = currentUserProfile.value;
  if (profile != null && profile['identifier'] != null && profile['identifier'].toString().trim().isNotEmpty) {
    return profile['identifier'].toString().trim();
  }
  return '-';
}

/// Mendapatkan kelas dan jurusan pengguna aktif.
String get currentClassName {
  final profile = currentUserProfile.value;
  if (profile != null) {
    final c = profile['class_name']?.toString().trim() ?? '';
    final m = profile['major']?.toString().trim() ?? '';
    if (c.isNotEmpty && m.isNotEmpty) return '$c • $m';
    if (c.isNotEmpty) return c;
    if (m.isNotEmpty) return m;
  }
  return 'SMKN 8 Malang';
}

/// Mendapatkan email pengguna aktif.
String get currentUserEmail {
  final profile = currentUserProfile.value;
  if (profile != null && profile['email'] != null && profile['email'].toString().trim().isNotEmpty) {
    return profile['email'].toString().trim();
  }
  return Backend.user?.email ?? '';
}

/// Mendapatkan 2 huruf inisial dari nama pengguna aktif (contoh: "Irwansyah Adityo" -> "IA").
String get userInitials {
  final name = currentUserName;
  if (name.isEmpty) return 'U';
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.length >= 2) {
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
  return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
}

/// Memuat atau menyegarkan profil pengguna langsung dari database Supabase.
Future<Map<String, dynamic>?> loadCurrentProfile() async {
  if (!SupabaseConfig.isConfigured) return currentUserProfile.value;
  await Backend.ensureInitialized();
  final uid = Backend.user?.id;
  if (uid == null) return currentUserProfile.value;

  try {
    final profile = await Backend.client
        .from('profiles')
        .select('id, full_name, identifier, role, email, class_name, major, phone, is_active')
        .eq('id', uid)
        .maybeSingle();

    if (profile != null) {
      currentUserProfile.value = Map<String, dynamic>.from(profile);
    }
    return currentUserProfile.value;
  } catch (e) {
    debugPrint('loadCurrentProfile error: $e');
    return currentUserProfile.value;
  }
}

/// Dipanggil dari layar Login: buka beranda sesuai peran yang dipilih.
void enterRole(BuildContext context, Role role, {Map<String, dynamic>? profile}) {
  if (profile != null) {
    currentUserProfile.value = Map<String, dynamic>.from(profile);
  }
  // Selalu muat ulang profil dari DB untuk memastikan data terbaru
  // (runs async, tidak memblokir navigasi)
  loadCurrentProfile();

  late final Widget home;
  switch (role) {
    case Role.admin:
      appTheme.value = admin_theme.buildTheme();
      admin.tabIndex.value = 0;
      home = const admin.MainShell();
    case Role.pembina:
      appTheme.value = pembina_theme.buildTheme();
      pembina.tabIndex.value = 0;
      home = const pembina.MainShell();
    case Role.siswa:
      appTheme.value = siswa_theme.buildSiswaTheme();
      home = const siswa.MainShell();
  }
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => home), (r) => false);
}

/// Keluar dari akun: kembali ke layar Login (tema dikembalikan ke tema siswa).
Future<void> logout(BuildContext context) async {
  currentUserProfile.value = null;
  if (SupabaseConfig.isConfigured) {
    try { await Backend.signOut(); } catch (_) {}
  }
  if (!context.mounted) return;
  appTheme.value = siswa_theme.buildSiswaTheme();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const siswa_login.LoginScreen()),
    (r) => false,
  );
}
