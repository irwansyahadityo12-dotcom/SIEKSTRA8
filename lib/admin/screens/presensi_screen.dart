import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PresensiScreen extends StatelessWidget {
  const PresensiScreen({super.key});

  // ini, nama, kelas, persen, hadir, izin, sakit, alfa, sesi, label
  static const _r = [
    ['SN', 'Siti Nurhaliza', 'Kelas XI RPL 1 • NIS: 22891', 1.0, '12', '0', '0', '0', '12 dari 12 Sesi', '100% Sempurna'],
    ['FR', 'Farhan Ramadhan', 'Kelas X TKJ 2 • NIS: 23412', 0.917, '11', '1', '0', '0', '11 dari 12 Sesi', '91.7% Baik'],
    ['DA', 'Dimas Anggara', 'Kelas XI MM 3 • NIS: 22780', 0.833, '10', '1', '1', '0', '10 dari 12 Sesi', '83.3% Cukup'],
    ['AP', 'Amelia Putri', 'Kelas X RPL 2 • NIS: 23119', 0.667, '8', '1', '1', '2', '8 dari 12 Sesi', '66.7% Perlu Perhatian'],
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScreen(children: [
      Row(children: const [Expanded(child: DropField('Semester Ganjil 2024/2025', icon: Icons.calendar_month_outlined)), SizedBox(width: 8), CircleAvatar(radius: 24, backgroundColor: C.soft, child: Icon(Icons.search, color: C.primary))]),
      const SizedBox(height: 10),
      Row(children: const [Expanded(child: DropField('PMR WIRA Unit 8 (Palang Merah)', icon: Icons.tune)), SizedBox(width: 8), Pill('42 Siswa', C.soft, C.primary, icon: Icons.groups_outlined)]),
      const SizedBox(height: 14),
      HeroBanner(children: [
        Row(children: [
          const IconBox(Icons.school_outlined, bg: Color(0x33FFFFFF), fg: Colors.white, size: 44),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MONITORING PRESENSI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), Text('SMKN 8 Malang', style: TextStyle(color: Colors.white70, fontSize: 13))])),
          const Pill('SEMESTER GANJIL', Color(0x33FFFFFF), Colors.white),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _m('Total Sesi', '12', 'Pertemuan')),
          const SizedBox(width: 8),
          Expanded(child: _m('Rata Kehadiran', '92.4%', '↗ Baik', accent: true)),
          const SizedBox(width: 8),
          Expanded(child: _m('Perlu Verifikasi', '2', '⏱ Menunggu', orange: true)),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0x26FFFFFF), borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Row(children: const [Expanded(child: Text('Distribusi Akumulasi Periode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))), Text('492 Absensi Siswa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(height: 8, child: Row(children: const [Expanded(flex: 88, child: ColoredBox(color: Color(0xFF10B981))), Expanded(flex: 6, child: ColoredBox(color: Color(0xFF38BDF8))), Expanded(flex: 4, child: ColoredBox(color: Color(0xFFFBBF24))), Expanded(flex: 2, child: ColoredBox(color: Color(0xFFEF4444)))]))),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [_Leg('Hadir 88%', Color(0xFF10B981)), _Leg('Izin 6%', Color(0xFF38BDF8)), _Leg('Sakit 4%', Color(0xFFFBBF24)), _Leg('Alpa 2%', Color(0xFFEF4444))]),
          ]),
        ),
      ]),
      const SegTabs(['Verifikasi 2', 'Rekap Anggota', 'Riwayat Sesi (12)']),
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Rekap Presensi Anggota', style: T.h2), Text('PMR WIRA Unit 8 • 12 Sesi Terlaksana', style: T.body)])),
        const Text('⇅ Urutkan', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 12),
      const Chips(['Semua (42)', 'Disiplin >90% (34)', '● Perhatian <75% (3)']),
      const SearchBox('Cari nama atau NIS siswa...'),
      for (final r in _r) _row(r),
      Btn.white('Muat 38 Siswa Lainnya...', expand: true, h: 50),
      const SectionTitle('VERIFIKASI SESI TERAKHIR MASUK', action: 'Lihat Semua (2)'),
      SCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const IconBox(Icons.add, bg: C.redSoft, fg: C.red, size: 54),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('PMR WIRA Unit 8', style: T.h2),
              Row(children: const [Pill('Pertemuan #12', C.soft, C.primary), SizedBox(width: 6), Flexible(child: Text('• Latihan Evakuasi', style: T.body))]),
              const SizedBox(height: 4),
              const Text('Pembina: Bpk. Hendra Gunawan, S.Pd', style: T.body),
            ])),
            const Pill('18 Okt 2024', Color(0xFFEEF1F7), C.muted),
          ]),
          const SizedBox(height: 12),
          Panel(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
            _Cnt('Hadir', '40', C.primary), _Cnt('Izin/Sakit', '2', C.orange), _Cnt('Alpa', '0', C.muted),
          ])),
          const SizedBox(height: 12),
          const Text('📎 Bukti Fisik Terlampir:', style: T.body),
          const SizedBox(height: 8),
          Row(children: [
            const Expanded(flex: 5, child: Photo(icon: Icons.photo_outlined, w: 0, h: 110, label: 'Foto Kegiatan Lab', bg: Color(0xFFC9D5EE))),
            const SizedBox(width: 10),
            Expanded(flex: 4, child: Container(
              height: 110,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: C.line)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Row(children: [Icon(Icons.description_outlined, color: C.primary, size: 20), SizedBox(width: 6), Expanded(child: Text('Berita Acara #12', style: T.title))]), Text('PDF (1.2 MB)', style: T.body), Spacer(), Text('👁 Pratinjau', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700))]),
            )),
          ]),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: Btn.danger('Tolak / Revisi', icon: Icons.close, expand: true, h: 50)), const SizedBox(width: 8), Expanded(child: Btn('Setujui & Terbitkan', icon: Icons.check_circle_outline, expand: true, h: 50))]),
        ]),
      ),
      SCard(child: Row(children: [
        const IconBox(Icons.description_outlined, size: 48),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Unduh Laporan Rekap', style: T.title), Text('Format resmi Cabang Dinas Dikbud', style: T.body)])),
        Btn.gray('XLS', icon: Icons.table_chart_outlined, h: 40),
        const SizedBox(width: 6),
        Btn('PDF', icon: Icons.download_rounded, h: 40),
      ])),
    ]);
  }

  Widget _m(String l, String v, String s, {bool accent = false, bool orange = false}) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0x26FFFFFF), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(v, style: TextStyle(color: accent ? const Color(0xFF86EFAC) : orange ? const Color(0xFFFBBF24) : Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          Text(s, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      );

  Widget _row(List<Object> r) {
    final pct = r[3] as double;
    final warn = pct < 0.75;
    final Color c = pct == 1 ? C.green : pct > 0.9 ? C.primary : pct > 0.8 ? C.muted : C.red;
    return SCard(
      color: warn ? const Color(0xFFFFF5F5) : null,
      border: warn ? const Color(0xFFFBC4C4) : null,
      child: Column(children: [
        Row(children: [
          Avatar(r[0] as String, size: 46, bg: warn ? C.redSoft : C.soft, fg: warn ? C.red : C.primary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${r[1]}${warn ? '  ●' : ''}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.ink)), Text(r[2] as String, style: T.body)])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Pill(r[9] as String, warn ? C.redSoft : pct == 1 ? C.greenSoft : C.soft, warn ? C.red : pct == 1 ? C.green : C.primary), const SizedBox(height: 2), Text(r[8] as String, style: T.body.copyWith(fontSize: 12))]),
        ]),
        const SizedBox(height: 12),
        Bar(pct, c),
        const Divider(height: 22),
        Row(children: [
          RichText(text: TextSpan(style: const TextStyle(fontSize: 14, color: C.muted), children: [
            TextSpan(text: '${r[4]} ', style: const TextStyle(fontWeight: FontWeight.w800, color: C.ink)), const TextSpan(text: 'Hadir   '),
            TextSpan(text: '${r[5]} ', style: const TextStyle(fontWeight: FontWeight.w800, color: C.primary)), const TextSpan(text: 'Izin   '),
            TextSpan(text: '${r[6]} ', style: const TextStyle(fontWeight: FontWeight.w800, color: C.orange)), const TextSpan(text: 'Sakit   '),
            TextSpan(text: '${r[7]} ', style: TextStyle(fontWeight: FontWeight.w800, color: warn ? C.red : C.ink)), const TextSpan(text: 'Alpa'),
          ])),
          const Spacer(),
          warn ? Btn('Peringatan', icon: Icons.send, bg: C.red, h: 38) : const Text('Rincian  ›', style: TextStyle(color: C.primary, fontWeight: FontWeight.w800)),
        ]),
      ]),
    );
  }
}

class _Leg extends StatelessWidget {
  final String t;
  final Color c;
  const _Leg(this.t, this.c);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(radius: 4, backgroundColor: c), const SizedBox(width: 4), Text(t, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))]);
}

class _Cnt extends StatelessWidget {
  final String l, v;
  final Color c;
  const _Cnt(this.l, this.v, this.c);
  @override
  Widget build(BuildContext context) => Column(children: [Text(l, style: T.body), Text(v, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: c))]);
}
