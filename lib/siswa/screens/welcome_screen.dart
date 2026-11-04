import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget feature(IconData icon, Color c, Color bg, String title, String tag, String desc) => AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBox(icon, color: c, bg: bg, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: tx(title, size: 14, w: FontWeight.w800)),
                  const SizedBox(width: 6),
                  Pill(tag, fg: c, bg: bg, size: 9.5),
                ]),
                const SizedBox(height: 4),
                tx(desc, size: 12, color: C.muted, height: 1.4),
              ]),
            ),
          ]),
        );

    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 24), children: [
          Center(child: BrandLogo(size: 72)),
          const SizedBox(height: 12),
          Center(child: Pill('VOKASI', fg: C.brown, bg: C.amberBg, icon: Icons.school_outlined, size: 10)),
          const SizedBox(height: 10),
          Center(child: Pill('RESMI SMKN 8 MALANG', icon: Icons.verified_outlined, size: 10)),
          const SizedBox(height: 12),
          Center(child: tx('SIEKSTRA-8', size: 28, w: FontWeight.w800)),
          Center(child: tx('SMKN 8 Malang', size: 18, w: FontWeight.w700, color: C.primary)),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: C.soft, borderRadius: BorderRadius.circular(20)),
              child: tx('"Temukan Minatmu, Raih Prestasimu!"', size: 12.5, w: FontWeight.w700, color: C.primary),
            ),
          ),
          const SizedBox(height: 18),
          PhotoBox(height: 150, colors: const [Color(0xFF0F766E), Color(0xFF2563EB)], icon: Icons.groups_2_outlined, overlays: [
            Overlay1(Alignment.bottomLeft, DarkChip('Komunitas Aktif • Bakat Teknik & Seni', icon: Icons.bolt)),
          ]),
          const SizedBox(height: 18),
          SectionTitle('Fitur Unggulan', action: 'TERINTEGRASI'),
          feature(Icons.groups_outlined, C.primary, C.soft, '30+ Pilihan Ekskul', 'Lengkap',
              'Teknologi, robotika, seni musik, paskibra hingga olahraga prestasi kejuruan.'),
          feature(Icons.event_available_outlined, C.primary, C.soft, 'Jadwal & Presensi Real-Time', 'GPS & QR',
              'Cek jam latihan, ruang kegiatan, dan absensi digital langsung lewat ponsel.'),
          feature(Icons.bolt, C.amber, C.amberBg, 'Pendaftaran Online Cepat', '1-Klik',
              'Pilih pembina favorit, unggah berkas instan, dan pantau status kelolosan.'),
          AppCard(
            color: const Color(0xFFF1F4FF),
            child: Row(children: [
              Icon(Icons.groups, color: C.primary, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  tx('1.850+ Siswa Aktif', size: 14, w: FontWeight.w800),
                  tx('Bergabung semester ini', size: 11.5, color: C.muted),
                ]),
              ),
              Pill('Juara 1 LKS', fg: C.brown, bg: C.amberBg, icon: Icons.emoji_events_outlined),
            ]),
          ),
          const SizedBox(height: 6),
          PrimaryButton('Mulai Eksplorasi',
              icon: Icons.explore_outlined,
              trailingIcon: false,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            tx('Sudah punya akun? ', size: 12.5, color: C.muted),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: tx('Masuk', size: 12.5, w: FontWeight.w800, color: C.primary),
            ),
          ]),
          const SizedBox(height: 16),
          Center(child: tx('SIEKSTRA-8 • Sistem Informasi Ekstrakurikuler SMKN 8 Malang', size: 10, color: C.muted, align: TextAlign.center)),
        ]),
      ),
    );
  }
}
