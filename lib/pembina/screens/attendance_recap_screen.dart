import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class AttendanceRecapScreen extends StatelessWidget {
  const AttendanceRecapScreen({super.key});

  // ini, nama, kelas, hadir, izin, sakit, alfa, persen, label, unit, warna
  static final _d = [
    ['AF', 'Ahmad Fikri', 'XI RPL 2 • NIS 221085', '15/16', '1', '0', '0', 0.938, '93.8%', 'Sangat Baik', 'PMR Wira', AppColors.green],
    ['NP', 'Nabila Putri', 'X TKJ 1 • NIS 231120', '14/16', '2', '0', '0', 0.875, '87.5%', 'Baik', 'PMR Madya', const Color(0xFF4ADE80)],
    ['DI', 'Dimas Ibrahim', 'XI RPL 1 • NIS 221060', '13/16', '1', '2', '0', 0.812, '81.2%', 'Cukup', 'PMR Wira', AppColors.primary],
    ['RM', 'Rizky Maulana', 'X DKV 2 • NIS 231155', '11/16', '2', '1', '2', 0.688, '68.8%', 'Peringatan', 'PMR Madya', AppColors.red],
    ['SA', 'Siti Aisyah', 'XI RPL 1 • NIS 221012', '16/16', '0', '0', '0', 1.0, '100%', 'Sempurna', 'PMR Wira (Koordinator Medis)', const Color(0xFF166534)],
  ];

  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      tag: 'PMR',
      title: 'Rekap Kehadiran',
      subtitle: 'Laporan dan statistik presensi anggota PMR SMKN 8 Malang',
      children: [
        SCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('PERIODE PRESENSI', style: T.label),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEFF2FD), borderRadius: BorderRadius.circular(14)),
              child: Row(children: const [
                Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(child: Text('Semester Ganjil 2024/2025 (Okt 2024)', style: T.title)),
                Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
              ]),
            ),
            const SizedBox(height: 14),
            const Text('KATEGORI KEGIATAN', style: T.label),
            const SizedBox(height: 8),
            const Chips(['Semua Kegiatan', 'Latihan Rutin', 'Simulasi Bencana', 'Diklat PMR', 'Lomba & PP']),
            const SearchField('Cari nama, NIS, atau kelas anggota...'),
          ]),
        ),
        SCard(
          color: const Color(0xFFEEF2FF),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const IconBox(Icons.insert_chart_outlined_rounded, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('RANGKUMAN UNIT', style: T.label),
                  Text('Rata-Rata Kehadiran Unit PMR', style: T.title),
                ]),
              ),
              const Pill('Tinggi 91.8%', Color(0xFF86EFAC), AppColors.green, icon: Icons.trending_up),
            ]),
            const SizedBox(height: 12),
            Row(children: const [
              Expanded(child: _Box('Total Pertemuan', '16', 'Sesi')),
              SizedBox(width: 10),
              Expanded(child: _Box('Total Anggota', '48', 'Siswa')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Expanded(child: _Box('Kehadiran Tertinggi', 'Wira', '94.2%', badge: true)),
              const SizedBox(width: 10),
              Expanded(child: _Box('Perlu Perhatian', '3', '<75%', badge: true, red: true)),
            ]),
          ]),
        ),
        Row(children: const [
          Expanded(child: Text('Laporan Presensi Per Siswa', style: T.h2)),
          Text('Urutkan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        for (final r in _d) _row(r),
        SCard(
          child: Column(children: [
            Btn('Unduh Laporan (PDF / Excel)', icon: Icons.download_rounded, expand: true, h: 54),
            const SizedBox(height: 10),
            Btn.soft('Cetak Rekap Bulanan', icon: Icons.print_outlined, expand: true, h: 50),
          ]),
        ),
      ],
    );
  }

  Widget _row(List<Object> r) {
    final c = r[11] as Color;
    final warn = r[9] == 'Peringatan';
    final perfect = r[9] == 'Sempurna';
    return SCard(
      child: Column(children: [
        Row(children: [
          Avatar(r[0] as String, bg: warn ? AppColors.redSoft : perfect ? AppColors.greenSoft : AppColors.soft, fg: warn ? AppColors.red : perfect ? AppColors.green : AppColors.primary, size: 48),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r[1] as String, style: T.title.copyWith(fontSize: 17)), Text(r[2] as String, style: T.body)])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Pill(r[9] as String, warn ? AppColors.redSoft : AppColors.greenSoft, warn ? AppColors.red : AppColors.green),
            Text(r[8] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: warn ? AppColors.red : AppColors.ink)),
          ]),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFF1F3FC), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _cnt('Hadir', r[3] as String, AppColors.green),
            _cnt('Izin', r[4] as String, AppColors.primary),
            _cnt('Sakit', r[5] as String, AppColors.ink),
            _cnt('Alfa', r[6] as String, warn ? AppColors.red : AppColors.ink),
          ]),
        ),
        const SizedBox(height: 10),
        Bar(r[7] as double, c),
        const SizedBox(height: 6),
        Row(children: [
          if (warn) const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.red) else CircleAvatar(radius: 4, backgroundColor: r[10].toString().contains('Wira') ? AppColors.primary : AppColors.red),
          const SizedBox(width: 6),
          Expanded(child: Text(warn ? 'Perlu Panggilan Pembina' : r[10] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: warn ? AppColors.red : AppColors.ink))),
          Text(warn ? 'Di bawah 75%' : perfect ? 'Apresiasi Kehadiran' : 'Target semester: 85%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: warn ? AppColors.red : perfect ? AppColors.green : AppColors.muted)),
        ]),
      ]),
    );
  }

  Widget _cnt(String l, String v, Color c) => Column(children: [
        Text(l, style: T.body.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
        Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c)),
      ]);
}

class _Box extends StatelessWidget {
  final String l, v, s;
  final bool badge, red;
  const _Box(this.l, this.v, this.s, {this.badge = false, this.red = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: T.body.copyWith(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(v, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: red ? AppColors.red : badge ? AppColors.ink : AppColors.primary)),
            const SizedBox(width: 6),
            if (badge) Pill(s, red ? AppColors.redSoft : AppColors.greenSoft, red ? AppColors.red : AppColors.green) else Text(s, style: T.body.copyWith(fontSize: 15)),
          ]),
        ]),
      );
}
