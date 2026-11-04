import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'notifications_screen.dart';
import 'diklat_screen.dart';
import 'achievements_screen.dart';
import 'permission_screen.dart';
import 'resignation_screen.dart';
import 'attendance_input_screen.dart';
import 'attendance_recap_screen.dart';
import 'ekskul_form_screen.dart';
import 'schedule_form_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      title: 'Profil Pembimbing',
      children: [
        SCard(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            const CircleAvatar(radius: 40, backgroundColor: AppColors.primary, child: Text('P', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Dimas Pratama', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const Text('Pembimbing Robotik • SMKN 8 Malang', style: T.body),
                const SizedBox(height: 10),
                Btn.soft('Edit Profil', h: 36),
              ]),
            ),
          ]),
        ),
        InfoRow(Icons.notifications_none_rounded, 'Notifikasi', 'Kelola notifikasi pendaftaran & jadwal', onTap: () => push(context, const NotificationsScreen())),
        const InfoRow(Icons.person_outline, 'Data Akun', 'Email, nomor telepon & keamanan'),
        const InfoRow(Icons.help_outline_rounded, 'Bantuan', 'Panduan penggunaan SIEKSTRA-8'),
        const SectionTitle('Menu Pembimbing'),
        InfoRow(Icons.assignment_turned_in_outlined, 'Input Presensi', 'Catat kehadiran pertemuan', onTap: () => push(context, const AttendanceInputScreen())),
        InfoRow(Icons.bar_chart_rounded, 'Rekap Kehadiran', 'Laporan presensi per siswa', onTap: () => push(context, const AttendanceRecapScreen())),
        InfoRow(Icons.campaign_outlined, 'Kelola Diklat', 'Pendidikan & pelatihan PMR', onTap: () => push(context, const DiklatScreen())),
        InfoRow(Icons.emoji_events_outlined, 'Lomba & Prestasi', 'Pendaftaran lomba & capaian juara', onTap: () => push(context, const AchievementsScreen())),
        InfoRow(Icons.mark_email_read_outlined, 'Persetujuan Izin', 'Surat izin & dispensasi anggota', onTap: () => push(context, const PermissionScreen())),
        InfoRow(Icons.logout_rounded, 'Pengunduran Diri', 'Verifikasi permohonan keluar', onTap: () => push(context, const ResignationScreen())),
        InfoRow(Icons.edit_note_rounded, 'Form Detail Ekskul', 'Ubah data ekstrakurikuler', onTap: () => push(context, const EkskulFormScreen())),
        InfoRow(Icons.add_alarm_rounded, 'Tambah Jadwal', 'Buat jadwal kegiatan baru', onTap: () => push(context, const ScheduleFormScreen())),
        const SectionTitle('Akun'),
        InfoRow(Icons.logout, 'Keluar dari Akun', 'Kembali ke halaman login', onTap: () => logout(context)),
      ],
    );
  }
}
