import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../../app/session.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int role = 2;
  bool remember = true;
  bool hide = true;
  final roles = const [
    (Icons.shield_outlined, 'Admin'),
    (Icons.supervisor_account_outlined, 'Pembina'),
    (Icons.school_outlined, 'Siswa'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(children: [
          const BrandLogo(size: 32),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              tx('SIEKSTRA-8', size: 15, w: FontWeight.w800),
              const SizedBox(width: 6),
              Pill('SMKN 8', size: 9),
            ]),
            tx('SMKN 8 Malang', size: 10.5, color: C.muted),
          ]),
        ]),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}))],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: kBlueGradient, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Pill('Tahun Ajaran 2024/2025', fg: Colors.white, bg: Colors.white24, size: 10),
            const SizedBox(height: 12),
            tx('Selamat Datang! 👋', size: 24, w: FontWeight.w800, color: Colors.white),
            const SizedBox(height: 6),
            tx('Masuk untuk mengelola kegiatan, presensi, dan data ekstrakurikuler SMKN 8 Malang secara terpadu.',
                size: 12.5, color: Colors.white, height: 1.4),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: tx('Pilih Hak Akses Peran', size: 12, color: C.muted)),
          tx('Wajib Dipilih', size: 12, w: FontWeight.w700, color: C.primary),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: const Color(0xFFEAEFFC), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            for (int i = 0; i < roles.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => role = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: role == i ? C.primary : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                    child: Column(children: [
                      Icon(roles[i].$1, size: 18, color: role == i ? Colors.white : C.muted),
                      const SizedBox(height: 2),
                      tx(roles[i].$2, size: 11.5, w: FontWeight.w700, color: role == i ? Colors.white : C.muted),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LabeledField('Nomor Identitas (NIP / Username)',
                hint: 'Masukkan NIP atau username resmi',
                icon: Icons.badge_outlined,
                helper: const [
                  'Gunakan akun administrator yang telah didaftarkan Bagian Kesiswaan.',
                  'Gunakan NIP pembimbing yang telah didaftarkan Bagian Kesiswaan.',
                  'Gunakan NIS atau username siswa yang terdaftar.',
                ][role]),
            tx('Kata Sandi', size: 12.5, w: FontWeight.w700),
            const SizedBox(height: 6),
            TextFormField(
              obscureText: hide,
              initialValue: 'password1234',
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, size: 19, color: C.muted),
                suffixIcon: IconButton(icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 19), onPressed: () => setState(() => hide = !hide)),
                filled: true,
                fillColor: const Color(0xFFF1F4FC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Checkbox(value: remember, activeColor: C.primary, onChanged: (v) => setState(() => remember = v ?? false)),
              Expanded(child: tx('Ingat Saya', size: 12.5, w: FontWeight.w600)),
              tx('Lupa Sandi?', size: 12.5, w: FontWeight.w700, color: C.primary),
            ]),
            PrimaryButton('Masuk ke SIEKSTRA',
                icon: Icons.arrow_forward,
                onPressed: () => enterRole(context, Role.values[role])),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Divider(color: C.border)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: tx('atau', size: 11, color: C.muted)),
              Expanded(child: Divider(color: C.border)),
            ]),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46), side: const BorderSide(color: C.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 18, color: C.primary),
              label: tx('Registrasi Akun Baru', size: 13, w: FontWeight.w700, color: C.primary),
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                tx('Belum memiliki akun? ', size: 11.5, color: C.muted),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: tx('Daftar di sini', size: 11.5, w: FontWeight.w700, color: C.primary),
                ),
              ]),
            ),
          ]),
        ),
        AppCard(
          color: const Color(0xFFEEF2FF),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconBox(Icons.support_agent, size: 38, color: C.primary, bg: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  tx('Kendala Akses Masuk?', size: 13, w: FontWeight.w800),
                  tx('Hubungi Tim Kesiswaan atau Ruang IT Gedung B SMKN 8 Malang untuk verifikasi status akun.', size: 11, color: C.muted, height: 1.4),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const SizedBox(width: 48),
              Icon(Icons.menu_book_outlined, size: 14, color: C.primary),
              const SizedBox(width: 4),
              tx('Panduan SIEKSTRA', size: 11, w: FontWeight.w700, color: C.primary),
              const SizedBox(width: 16),
              Icon(Icons.chat_outlined, size: 14, color: C.green),
              const SizedBox(width: 4),
              tx('Helpdesk WA', size: 11, w: FontWeight.w700, color: C.green),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.circle, size: 8, color: C.green),
          const SizedBox(width: 6),
          tx('Server SMKN 8 Malang: Terkoneksi Normal', size: 10.5, color: C.muted),
        ]),
        const SizedBox(height: 4),
        Center(child: tx('v2.4.0 • SIEKSTRA-8 Official System © 2024 SMKN 8 Malang', size: 10, color: C.muted)),
      ]),
    );
  }
}
