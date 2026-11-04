import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'attendance_input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Beranda Pembimbing',
      trailing: const Pill('3 ekskul aktif', AppColors.soft, AppColors.primary),
      bottom: Btn('Lihat jadwal hari ini', icon: Icons.event_available_rounded, expand: true, h: 54, onTap: () => goTab(context, 4)),
      children: [
        const Text('Halo, Pak Budi!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const Text('Robotic & Pembina Kegiatan', style: TextStyle(fontSize: 15, color: AppColors.muted)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _Stat('EKSKUL AKTIF', '3', Icons.layers_rounded, const Color(0xFFEFF4FF), AppColors.primary, AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: _Stat('ANGGOTA', '84', Icons.groups_rounded, Colors.white, AppColors.primary, AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: _Stat('PENDAFTAR', '12', Icons.person_add_alt_1_rounded, const Color(0xFFFBEFDD), const Color(0xFF9A4A0A), AppColors.amber)),
        ]),
        const SizedBox(height: 12),
        SCard(
          child: Row(children: [
            const IconBox(Icons.assignment_turned_in_rounded, bg: Color(0xFFE7F8EF), fg: AppColors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Flexible(child: Text('Presensi Rata-rata', style: T.title)),
                  const SizedBox(width: 6),
                  const Pill('Tinggi', AppColors.greenSoft, AppColors.green),
                ]),
                const Text('Tingkat kehadiran 3 ekskul minggu ini', style: T.body),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [
              Text('92%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.green)),
              Text('dari 84 siswa', style: T.body),
            ]),
          ]),
        ),
        const AchievementBanner(label: 'PRESTASI PMR WIRA', title: 'Juara 1 Lomba Pertolongan Pertama (PMR)', subtitle: 'Tingkat Kota • Dimenangkan oleh Regu Putri PMR Wira Unit 8'),
        const SectionTitle('Aksi Cepat'),
        Row(children: [
          _Quick('Kelola', Icons.layers_rounded, true, () => goTab(context, 1)),
          _Quick('Anggota', Icons.groups_rounded, false, () => goTab(context, 2)),
          _Quick('Pendaftar', Icons.person_add_alt_1_rounded, false, () => goTab(context, 3)),
          _Quick('Presensi', Icons.assignment_turned_in_rounded, false, () => push(context, const AttendanceInputScreen())),
        ]),
        SectionTitle('Jadwal Mendatang', action: 'Semua', onAction: () => goTab(context, 4)),
        const InfoRow(Icons.smart_toy_rounded, 'Robotic Club', 'Lab Komputer 2', top: 'Rabu, 15:30', bottom: 'Hari ini', bottomColor: AppColors.primary),
        const InfoRow(Icons.medical_services_rounded, 'PMR Madya & Wira', 'Ruang UKS & Lapangan', iconBg: AppColors.redSoft, iconFg: AppColors.red, top: 'Kamis, 14:00', bottom: 'Besok'),
        const InfoRow(Icons.sports_soccer_rounded, 'Futsal Putra/Putri', 'Lapangan Utama', iconBg: AppColors.amberSoft, iconFg: AppColors.amber, top: 'Jumat, 15:45', bottom: '2 hari lagi'),
        const SectionTitle('Aktivitas Terbaru'),
        const InfoRow(Icons.add, 'Pendaftaran baru', '3 siswa menunggu persetujuan', iconBg: Color(0xFFFFEBD5), iconFg: AppColors.amber, top: '2 menit lalu'),
        const InfoRow(Icons.event_rounded, 'Jadwal diperbarui', 'Robotik • Rabu 15:30', top: '1 jam lalu'),
        const InfoRow(Icons.groups_rounded, 'Anggota ditambahkan', 'Futsal • 2 anggota baru', top: '3 jam lalu'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bg, fg, iconFg;
  const _Stat(this.label, this.value, this.icon, this.bg, this.fg, this.iconFg);
  @override
  Widget build(BuildContext context) => SCard(
        color: bg,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: fg == AppColors.primary ? AppColors.muted : fg))),
            Container(width: 28, height: 28, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(icon, size: 15, color: iconFg)),
          ]),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: fg)),
        ]),
      );
}

class _Quick extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _Quick(this.label, this.icon, this.active, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 76,
              decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, color: active ? Colors.white : AppColors.primary),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.ink)),
              ]),
            ),
          ),
        ),
      );
}
