import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'permission_screen.dart';
import 'resignation_screen.dart';
import 'achievements_screen.dart';
import 'diklat_screen.dart';
import 'attendance_recap_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      tag: 'PMR',
      title: 'Notifikasi Pembina',
      subtitle: 'Pemberitahuan aktivitas, pendaftaran, izin, dan jadwal PMR',
      trailing: const Pill('5 Baru', AppColors.primary, Colors.white),
      children: [
        Chips(const ['Semua', 'Belum Dibaca (5)', 'Pendaftaran', 'Izin & Mundur']),
        const Text('HARI INI', style: T.label),
        const SizedBox(height: 10),
        _N(Icons.priority_high_rounded, AppColors.soft, AppColors.primary, 'Pengajuan Izin: Ahmad Fikri', 'Mengajukan izin latihan rutin Tandu & Bidai untuk dispensasi LKS. Menunggu verifikasi Anda.', '15m lalu', 'XI MIPA 2 • PMR Wira', 'Buka Halaman Izin', AppColors.primary, true, () => push(context, const PermissionScreen())),
        _N(Icons.person_add_alt_1_rounded, AppColors.greenSoft, AppColors.green, '3 Calon Anggota Baru Mendaftar', 'Fajar Aditya, Siti Aulia, dan 1 siswa lainnya menunggu persetujuan verifikasi pendaftaran.', '2 jam lalu', 'Unit PMR Wira & Madya', 'Review di PB Pendaftaran', AppColors.green, true, () => goTab(context, 3)),
        _N(Icons.person_remove_rounded, AppColors.redSoft, AppColors.red, 'Pengunduran Diri: Rizky M.', 'Siswa kelas X DKV 2 mengajukan pengunduran diri karena jadwal bentrok les kejuruan sore.', '3 jam lalu', 'X DKV 2 • NIS 231155', 'Lihat Pengajuan', AppColors.red, true, () => push(context, const ResignationScreen())),
        const SizedBox(height: 8),
        const Text('SEBELUMNYA', style: T.label),
        const SizedBox(height: 10),
        _N(Icons.emoji_events_rounded, AppColors.soft, AppColors.primary, 'Prestasi: Juara 1 PP Terverifikasi', 'Sertifikat lomba tingkat kota telah divalidasi oleh PMI Cabang Kota Malang untuk Regu PMR Wira.', 'Kemarin, 14:20', 'Tingkat Kota Malang', 'Lihat Prestasi', AppColors.primary, false, () => push(context, const AchievementsScreen())),
        _N(Icons.event_available_rounded, AppColors.soft, AppColors.primary, 'Pengingat: Diklat Calon Anggota', 'Kuota peserta mencapai 42/50 siswa (84%). Persiapkan modul pertolongan pertama & ...', '2 hari lalu', '42 Terdaftar (84%)', 'Buka Kelola Diklat', AppColors.primary, false, () => push(context, const DiklatScreen())),
        _N(Icons.fact_check_rounded, AppColors.soft, AppColors.ink, 'Rekap Presensi Pekan Ke-3 Selesai', 'Tingkat kehadiran PMR Wira mencapai 94.2%. 1 anggota tercatat tanpa keterangan pada latihan...', '3 hari lalu', 'Tingkat Hadir 94.2%', 'Buka Rekap Kehadiran', AppColors.primary, false, () => push(context, const AttendanceRecapScreen())),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFEEF1FC), borderRadius: BorderRadius.circular(18)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            CircleAvatar(radius: 5, backgroundColor: AppColors.green),
            SizedBox(width: 10),
            Text('Notifikasi otomatis diperbarui secara real-time.', style: T.body),
          ]),
        ),
      ],
    );
  }
}

class _N extends StatelessWidget {
  final IconData icon;
  final Color bg, fg, linkColor;
  final String title, body, time, meta, link;
  final bool unread;
  final VoidCallback onTap;
  const _N(this.icon, this.bg, this.fg, this.title, this.body, this.time, this.meta, this.link, this.linkColor, this.unread, this.onTap);
  @override
  Widget build(BuildContext context) => SCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(clipBehavior: Clip.none, children: [
                IconBox(icon, bg: bg, fg: fg, size: 50),
                if (unread) Positioned(right: -2, top: -2, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Text(time, style: T.body.copyWith(fontSize: 11)),
                  ]),
                  const SizedBox(height: 4),
                  Text(body, style: T.body.copyWith(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFFF6F8FE),
            child: Row(children: [
              CircleAvatar(radius: 4, backgroundColor: linkColor),
              const SizedBox(width: 8),
              Expanded(child: Text(meta, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: linkColor == AppColors.primary ? AppColors.muted : linkColor), overflow: TextOverflow.ellipsis)),
              Text('$link →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: linkColor)),
            ]),
          ),
        ]),
      );
}
