import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class DiklatScreen extends StatelessWidget {
  const DiklatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      tag: 'PMR',
      title: 'Kelola Diklat PMR',
      subtitle: 'Pendidikan & Pelatihan Calon Anggota & Lanjutan PMR Unit 8',
      trailing: Btn('Buat Diklat', icon: Icons.add, h: 42),
      children: [
        const SearchField('Cari diklat atau materi pelatihan...'),
        const Chips(['Semua Diklat (3)', 'Pendaftaran (1)', 'Siap Dilaksanakan (1)']),
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF0A3DB8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Pill('DIKLAT WAJIB 2024', AppColors.red, Colors.white, icon: Icons.circle),
              const Spacer(),
              const Pill('Unit 8 Malang', Color(0x33FFFFFF), Colors.white),
            ]),
            const SizedBox(height: 12),
            const Text('Diklat Calon Anggota PMR Angkatan 2024/2025', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('📅 16–17 November 2024  •  Aula & Lapangan SMKN 8', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0x26FFFFFF), borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                Row(children: const [
                  Expanded(child: Text('Peserta Terdaftar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  Text('42 / 50 Siswa (84%)', style: TextStyle(color: Color(0xFF86EFAC), fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 8),
                const Bar(0.84, Color(0xFF86EFAC), track: Color(0x40FFFFFF)),
                const SizedBox(height: 8),
                Row(children: const [
                  Expanded(child: Text('ⓘ Pendaftaran dibuka hingga 10 Nov', style: TextStyle(color: Colors.white70, fontSize: 12))),
                  Text('TERSISA 8 KURSI', style: TextStyle(color: Color(0xFF86EFAC), fontWeight: FontWeight.w800, fontSize: 12)),
                ]),
              ]),
            ),
          ]),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFE3E9FA), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.event_available_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => goTab(context, 4),
                child: RichText(
                  text: const TextSpan(style: TextStyle(color: AppColors.ink, fontSize: 14), children: [
                    TextSpan(text: 'Kegiatan ini '),
                    TextSpan(text: 'otomatis terhubung', style: TextStyle(fontWeight: FontWeight.w800)),
                    TextSpan(text: ' dan ditampilkan pada kalender '),
                    TextSpan(text: 'Jadwal Ekskul', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, decoration: TextDecoration.underline)),
                    TextSpan(text: '.'),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        Row(children: const [
          Expanded(child: Text('Daftar Agenda Diklat', style: T.h2)),
          Pill('Total: 3 Agenda', Color(0xFFEDEFF7), AppColors.muted),
        ]),
        const SizedBox(height: 12),
        _Agenda(
          status: 'SIAP DILAKSANAKAN', statusBg: AppColors.greenSoft, statusFg: AppColors.green, extra: 'Hampir Penuh', extraBg: AppColors.redSoft, extraFg: AppColors.red,
          title: 'Diklat Dasar Pertolongan Pertama (PP)',
          lines: const ['📅 Sabtu, 28 Oktober 2024 • 07:30 – 15:00 WIB', '📍 Lab PMR & Koridor Gedung B', '🪪 Pemateri: Dimas Pratama, S.Pd. & PMI Kota Malang'],
          footer: 'Peserta: 48 / 50 Siswa   •   Tingkat: Wira & Madya',
          actions: [Btn('Kelola Peserta (48)', icon: Icons.how_to_reg_outlined, h: 44), Btn.soft('Edit', icon: Icons.edit_outlined, h: 44), Btn.danger('Batal', icon: Icons.cancel_outlined, h: 44)],
        ),
        _Agenda(
          status: 'DRAFT / PERENCANAAN', statusBg: const Color(0xFFEDEFF7), statusFg: AppColors.muted, extra: 'PMR Lanjutan', extraBg: AppColors.soft, extraFg: AppColors.primary,
          title: 'Diklat Water Rescue & Evakuasi Bencana',
          lines: const ['📅 Minggu, 24 November 2024 • 08:00 – 14:00 WIB', '📍 Kolam Renang Tirtasani & Aula Serbaguna', '👥 Target Kapasitas: 30 Siswa (Belum dibuka)'],
          actions: [Btn('Buka Daftar', icon: Icons.campaign_outlined, h: 44), Btn.soft('Edit', icon: Icons.edit_outlined, h: 44), Btn.soft('Detail', icon: Icons.visibility_outlined, h: 44)],
        ),
        _Agenda(
          status: 'SELESAI', statusBg: Colors.white, statusFg: AppColors.green, extra: '14 September 2024', extraBg: Colors.white, extraFg: AppColors.muted,
          title: 'Diklat Manajemen Posko & Dapur Umum',
          lines: const [],
          footer: '45 Peserta Lulus — Semua sertifikat digital terbit   •   100% Tuntas',
          actions: [Btn.soft('Nilai & Sertifikat', icon: Icons.workspace_premium_outlined, h: 44), Btn.soft('Arsip Dokumentasi', icon: Icons.inventory_2_outlined, h: 44)],
        ),
      ],
    );
  }
}

class _Agenda extends StatelessWidget {
  final String status, extra, title;
  final Color statusBg, statusFg, extraBg, extraFg;
  final List<String> lines;
  final String? footer;
  final List<Widget> actions;
  const _Agenda({required this.status, required this.statusBg, required this.statusFg, required this.extra, required this.extraBg, required this.extraFg, required this.title, required this.lines, this.footer, required this.actions});
  @override
  Widget build(BuildContext context) => SCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Pill(status, statusBg, statusFg),
            const SizedBox(width: 6),
            Flexible(child: Pill(extra, extraBg, extraFg)),
            const Spacer(),
            const Icon(Icons.more_vert, color: AppColors.muted),
          ]),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (lines.isNotEmpty || footer != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF1F4FD), borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final l in lines) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(l, style: const TextStyle(fontSize: 14, color: AppColors.ink))),
                if (footer != null) Text(footer!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
              ]),
            ),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: actions),
        ]),
      );
}
