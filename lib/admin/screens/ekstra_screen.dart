import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class EkstraScreen extends StatelessWidget {
  const EkstraScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AdminScreen(children: [
      HeroBanner(children: [
        Row(children: const [Pill('Tahun Ajaran 2024/2025', Color(0x33FFFFFF), Colors.white, dot: true), Spacer(), Text('Total 28 Cabang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))]),
        const SizedBox(height: 14),
        const Text('Kelola Ekstrakurikuler', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Pusat pengaturan pembina, kuota siswa, dan jadwal.', style: TextStyle(color: Colors.white70, fontSize: 15)),
        const SizedBox(height: 16),
        Btn.white('Tambah Ekstrakurikuler Baru', icon: Icons.add_circle_outline, expand: true, h: 54),
      ]),
      const SearchBox('Cari ekstrakurikuler atau pembina...', filter: true),
      const Chips(['Semua', '⚽ Olahraga', '🩺 Kemanusiaan / PMR', '💻 Teknologi & IT']),
      const SegTabs(['Semua (28)', 'Aktif (26)', 'Non-Aktif (2)']),
      Stack(children: [
        SCard(
          border: const Color(0xFFFBC4C4),
          borderWidth: 2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const IconBox(Icons.add, bg: C.redSoft, fg: C.red, size: 60),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Wrap(spacing: 6, runSpacing: 6, children: [Pill('Kemanusiaan & Relawan', C.redSoft, C.red), Pill('Aktif', C.greenSoft, C.green, dot: true), Pill('🏆 Juara 1 Jumbara Prov', C.amberSoft, C.amber)]),
                SizedBox(height: 8),
                Text('PMR Wira (Palang Merah Remaja)', style: T.h2),
              ])),
            ]),
            const Divider(height: 24),
            const Text('👩‍🏫 Pembina: Dra. Hj. Ratna Juwita, M.Pd  (NIP. 19780412...)', style: T.body),
            const SizedBox(height: 4),
            const Text('🚑 Pelatih PMI: Kak Farhan Maulana (KSR Kota Malang)', style: T.body),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.line)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Row(children: [Icon(Icons.groups_outlined, size: 18, color: C.primary), SizedBox(width: 6), Text('Total Anggota', style: T.body)]), SizedBox(height: 4), Text('48 Siswa', style: T.h2), Text('18 Laki-laki • 30 Perempuan', style: T.body)])),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Row(children: [Icon(Icons.calendar_month_outlined, size: 18, color: C.primary), SizedBox(width: 6), Text('Jadwal Rutin', style: T.body)]), SizedBox(height: 4), Text('Sab 08:00 & Rab 15:30', style: T.h2), Text('UKS / Lapangan Utama', style: T.body)])),
              ]),
            ),
            const Divider(height: 24),
            Row(children: const [CircleAvatar(radius: 5, backgroundColor: C.green), SizedBox(width: 8), Text('Presensi: ', style: T.body), Expanded(child: Text('98% Kehadiran Rata-rata', style: T.title)), Text('Lihat Rekap', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700))]),
            const SizedBox(height: 10),
            Row(children: [Expanded(flex: 4, child: Btn.gray('Kelola Anggota (48)', expand: true)), const SizedBox(width: 8), Expanded(flex: 3, child: Btn.gray('Data Pembina', expand: true)), const SizedBox(width: 8), Btn('Detail  ›')]),
          ]),
        ),
        Positioned(right: 0, top: 0, child: ClipRRect(borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(14)), child: Container(color: C.red, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), child: const Text('UNGGULAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11))))),
      ]),
      _card(Icons.code, C.soft, C.primary, 'Teknologi & IT', C.soft, C.primary, 'RPL Club & Cyber Security', '👨‍🏫 Bpk. Ahmad Fauzi, S.Kom', '64 Siswa', 'Kamis 15:30', 'Presensi: 94% Kehadiran'),
      _card(Icons.sports_soccer, C.soft, C.primary, 'Olahraga', const Color(0xFFE8E9FF), const Color(0xFF4F46E5), 'Futsal SMKN 8', '👨‍🏫 Bpk. Didik Wahyudi, S.Pd', '82 Siswa', 'Sel & Jum 15:30', 'Presensi: 85% Kehadiran'),
      _card(Icons.flag, C.redSoft, C.red, 'Bela Negara', C.redSoft, C.red, 'Paskibra SATYA BHAKTI', '👩‍🏫 Ibu Sri Rahayu, M.Pd', '55 Siswa', 'Rab & Sab 07:00', 'Presensi: 97% Kehadiran'),
    ]);
  }

  Widget _card(IconData ic, Color ibg, Color ifg, String cat, Color cbg, Color cfg, String name, String pembina, String total, String jadwal, String presensi) => SCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBox(ic, bg: ibg, fg: ifg, size: 56),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Pill(cat, cbg, cfg), const SizedBox(width: 6), const Pill('Aktif', Colors.transparent, C.green, dot: true)]),
              const SizedBox(height: 6),
              Text(name, style: T.h2),
              Text(pembina, style: T.body.copyWith(fontSize: 14)),
            ])),
            const Icon(Icons.more_vert, color: C.muted),
          ]),
          const SizedBox(height: 12),
          Panel(padding: const EdgeInsets.all(14), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total Anggota', style: T.body), const SizedBox(height: 4), Text(total, style: T.h2)])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Jadwal Rutin', style: T.body), const SizedBox(height: 4), Text(jadwal, style: T.h2)])),
          ])),
          const SizedBox(height: 12),
          Row(children: [const CircleAvatar(radius: 4, backgroundColor: C.green), const SizedBox(width: 8), Expanded(child: Text(presensi, style: T.body.copyWith(fontSize: 14))), Btn.gray('Edit', icon: Icons.edit_outlined, h: 40), const SizedBox(width: 8), Btn('Detail', h: 40)]),
        ]),
      );
}
