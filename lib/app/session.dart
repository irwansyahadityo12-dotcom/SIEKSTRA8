import 'package:flutter/material.dart';

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

/// Dipanggil dari layar Login: buka beranda sesuai peran yang dipilih.
void enterRole(BuildContext context, Role role) {
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
void logout(BuildContext context) {
  appTheme.value = siswa_theme.buildSiswaTheme();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const siswa_login.LoginScreen()),
    (r) => false,
  );
}
