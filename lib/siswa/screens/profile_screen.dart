import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'attendance_history_screen.dart';
import 'competition_info_screen.dart';
import 'login_screen.dart';
import 'resignation_form_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _go(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

  Widget _stat(IconData i, Color c, Color bg, String big, String l, {Color? bigColor}) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(children: [IconBox(i, color: c, bg: bg, size: 36), const SizedBox(height: 8), tx(big, size: 19, w: FontWeight.w800, color: bigColor ?? C.text), tx(l, size: 10.5, color: C.muted)]),
        ),
      );

  Widget _menu(IconData i, Color c, Color bg, String title, String sub, {Pill? tag, Pill? status, VoidCallback? onTap}) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          IconBox(i, color: c, bg: bg, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Flexible(child: tx(title, size: 13.5, w: FontWeight.w800)), if (tag != null) ...[const SizedBox(width: 6), tag]]),
              const SizedBox(height: 2),
              tx(sub, size: 11, color: C.muted),
            ]),
          ),
          if (status != null) ...[status, const SizedBox(width: 4)],
          Icon(Icons.chevron_right, color: C.muted, size: 20),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        titleSpacing: 16,
        title: Row(children: [
          BrandLogo(size: 38),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx('SIEKSTRA-8', size: 16, w: FontWeight.w800, color: C.primary), tx('SMKN 8 Malang', size: 11, color: C.muted)]),
        ]),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: AvatarDot())],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD9E5FF), Color(0xFFF1F5FF)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(22)),
          child: Column(children: [
            Stack(children: [
              CircleAvatar(radius: 48, backgroundColor: Colors.white, child: CircleAvatar(radius: 44, backgroundColor: C.soft, child: Icon(Icons.person, size: 48, color: C.primary))),
              Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 13, backgroundColor: C.primary, child: Icon(Icons.check, size: 15, color: Colors.white))),
            ]),
            const SizedBox(height: 12),
            tx('Dimas Ibrahim', size: 20, w: FontWeight.w800),
            const SizedBox(height: 2),
            tx('NIS: 212089  •  XII Rekayasa Perangkat Lunak D', size: 11.5, color: C.muted),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 8, color: C.primary), const SizedBox(width: 6), tx('Siswa Aktif SMKN 8 Malang', size: 11.5, w: FontWeight.w700, color: C.primary)]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          const SizedBox(width: 0),
          _stat(Icons.groups_2_outlined, C.primary, C.soft, '2', 'Ekskul Aktif', bigColor: C.primary),
          const SizedBox(width: 8),
          _stat(Icons.fact_check_outlined, C.primary, C.soft, '95%', 'Kehadiran'),
          const SizedBox(width: 8),
          _stat(Icons.card_giftcard, C.amber, C.amberBg, '3', 'Sertifikat', bigColor: C.amber),
        ]),
        Row(children: [
          Expanded(child: tx('MENU PROFIL & EKSKUL', size: 11, w: FontWeight.w800, color: C.muted)),
          tx('Aktivitas Siswa', size: 12, w: FontWeight.w700, color: C.primary),
        ]),
        const SizedBox(height: 10),
        _menu(Icons.contact_page_outlined, C.primary, C.soft, 'Data Diri Siswa', 'NIS, email sekolah, kontak wali, kelas'),
        _menu(Icons.add, C.red, C.redBg, 'PMR Wira SMKN 8', 'Madya • Angkatan XXIV • Divisi PP',
            tag: Pill('Utama', fg: C.red, bg: C.redBg, size: 9), status: Pill('Aktif', size: 10), onTap: () => _go(context, const AttendanceHistoryScreen())),
        _menu(Icons.memory, C.primary, C.soft, 'Robotik Club', 'Anggota Reguler • Bidang IoT & Otomasi', status: Pill('Aktif', size: 10)),
        _menu(Icons.verified_outlined, C.purple, C.purpleBg, 'Riwayat Seleksi, Lomba & Diklat', 'Juara 1 PP Jatim, Diklat XXIV Lulus',
            status: Pill('Disetujui', fg: C.green, bg: C.greenBg, size: 10), onTap: () => _go(context, const CompetitionInfoScreen())),
        _menu(Icons.tune, C.muted, const Color(0xFFEFF1F7), 'Pengaturan Notifikasi & Akun', 'Jadwal latihan, dispensasi & notifikasi WA'),
        AppCard(
          color: const Color(0xFFFFF8E1),
          borderColor: const Color(0xFFF5E2A0),
          onTap: () => _go(context, const ResignationFormScreen()),
          child: Row(children: [
            IconBox(Icons.assignment_late_outlined, color: C.brown, bg: const Color(0xFFFFE9B0), size: 44),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Flexible(child: tx('Pengajuan Pengunduran Diri Ekskul', size: 12.5, w: FontWeight.w800)), const SizedBox(width: 6), Pill('RESMI', fg: C.brown, bg: const Color(0xFFFFE9B0), size: 9)]),
              tx('Formulir keluar ekskul, validasi pembina & kesiswaan', size: 11, color: C.muted),
            ])),
            Icon(Icons.chevron_right, color: C.muted),
          ]),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 50,
          child: TextButton.icon(
            style: TextButton.styleFrom(backgroundColor: const Color(0xFFFDE2E2), foregroundColor: C.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 14),
        Center(child: tx('SIEKSTRA-8 v2.4.0', size: 11, w: FontWeight.w700, color: C.muted)),
        Center(child: tx('Hak Cipta SMKN 8 Malang', size: 10.5, color: C.muted)),
      ]),
    );
  }
}
