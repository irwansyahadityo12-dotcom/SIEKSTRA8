import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) => Screen(
        back: true,
        title: 'Pusat Bantuan',
        subtitle: 'Panduan singkat penggunaan SIEKSTRA-8 untuk Pembina.',
        children: [
          SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('PANDUAN FITUR', style: T.label),
            const SizedBox(height: 12),
            _HelpItem(icon: Icons.groups_outlined, title: 'Manajemen Anggota', description: 'Buka menu Anggota untuk melihat daftar anggota dan informasi keanggotaannya.'),
            _HelpItem(icon: Icons.fact_check_outlined, title: 'Presensi', description: 'Gunakan Input Presensi untuk mencatat kehadiran pada setiap pertemuan, lalu periksa hasilnya di Rekap Kehadiran.'),
            _HelpItem(icon: Icons.event_outlined, title: 'Jadwal Kegiatan', description: 'Tambahkan jadwal latihan atau kegiatan khusus melalui menu Jadwal.'),
            _HelpItem(icon: Icons.mark_email_read_outlined, title: 'Persetujuan Izin', description: 'Periksa alasan dan dokumen pengajuan sebelum memberikan keputusan.'),
            _HelpItem(icon: Icons.emoji_events_outlined, title: 'Prestasi dan Diklat', description: 'Catat agenda pelatihan, perlombaan, dan pencapaian anggota.'),
          ])),
          const InfoRow(Icons.support_agent_outlined, 'Butuh bantuan lebih lanjut?', 'Hubungi administrator sekolah melalui saluran resmi yang ditentukan sekolah.'),
        ],
      );
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _HelpItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(icon, size: 42),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: T.title),
            const SizedBox(height: 3),
            Text(description, style: T.body),
          ])),
        ]),
      );
}
