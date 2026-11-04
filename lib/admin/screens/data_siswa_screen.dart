import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DataSiswaScreen extends StatelessWidget {
  const DataSiswaScreen({super.key});

  static const _s = [
    ['Muhammad Rizky Pratama', 'NISN: 0076121361 • X RPL 2', 'Rekayasa Perangkat Lunak', 'RPL Club & Cyber Security', '96%', Icons.terminal],
    ['Siti Nurhaliza', 'NISN: 0079161201 • X DKV 1', 'Desain Komunikasi Visual', 'Paskibra SATYA BHAKTI', '100%', Icons.flag_outlined],
    ['Dimas Arya Kusuma', 'NISN: 0083029415 • X TKJ 3', 'Teknik Komputer & Jaringan', 'Futsal SMKN 8', '88%', Icons.sports_soccer],
    ['Farhan Ramadhan', 'NISN: 0064128911 • XI TKJ 2', 'Teknik Komputer & Jaringan', 'PMR Wira Unit 8', '92%', Icons.medical_services_outlined],
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      back: 'Kembali ke Sistem & Akun',
      title: 'Kelola Data Siswa & Anggota',
      subtitle: 'Master database anggota aktif ekstrakurikuler SMKN 8 Malang.',
      trailing: Btn.soft('', icon: Icons.person_add_alt_1, h: 52),
      children: [
        Row(children: const [
          Expanded(child: StatBox('Total Siswa', '1.240', 'Terdaftar')),
          SizedBox(width: 8),
          Expanded(child: StatBox('Tergabung', '1.185', '95.5% Siswa', valueColor: C.primary, subColor: C.primary)),
          SizedBox(width: 8),
          Expanded(child: StatBox('Belum Ekskul', '55', 'Wajib Ditetapkan', valueColor: C.orange, subColor: C.orange)),
        ]),
        const SizedBox(height: 14),
        const SearchBox('Cari nama siswa, NISN, atau kelas...'),
        Row(children: const [Expanded(child: DropField('Tingkat: Semua')), SizedBox(width: 6), Expanded(child: DropField('Jurusan: Semua')), SizedBox(width: 6), Expanded(child: DropField('Ekskul: Semua'))]),
        const SizedBox(height: 12),
        const SegTabs(['Semua (1.240)', 'Aktif (1.185)', 'Belum (55)']),
        for (final s in _s)
          SCard(child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Photo(icon: Icons.person, w: 62, h: 62),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s[0] as String, style: T.h2.copyWith(fontSize: 17)), Text(s[1] as String, style: T.body), const SizedBox(height: 2), Text(s[2] as String, style: const TextStyle(color: C.amber, fontWeight: FontWeight.w700, fontSize: 13))])),
              const Pill('Aktif', C.soft, C.primary, dot: true),
            ]),
            const SizedBox(height: 12),
            Panel(padding: const EdgeInsets.all(12), child: Row(children: [
              IconBox(s[5] as IconData, bg: C.amberSoft, fg: C.amber, size: 40),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('EKSTRAKURIKULER', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: C.amber, letterSpacing: 0.5)), Text(s[3] as String, style: T.title.copyWith(fontSize: 16))])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('Kehadiran', style: T.body), Text(s[4] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.amber))]),
            ])),
            const SizedBox(height: 12),
            Row(children: [Expanded(flex: 4, child: Btn.gray('Detail Profil', icon: Icons.visibility_outlined, expand: true, h: 50)), const SizedBox(width: 8), Expanded(flex: 5, child: Btn('Edit Data', icon: Icons.edit_note, expand: true, h: 50))]),
          ])),
        SCard(child: Column(children: [
          Row(children: [
            const Photo(icon: Icons.person, w: 62, h: 62),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Amelia Putri', style: T.h2), Text('NISN: 0075549102 • X RPL 2', style: T.body), Text('Rekayasa Perangkat Lunak', style: TextStyle(color: C.amber, fontWeight: FontWeight.w700, fontSize: 13))])),
            const Pill('Belum Terdaftar', C.orangeSoft, C.orange, dot: true),
          ]),
          const SizedBox(height: 12),
          Panel(padding: const EdgeInsets.all(12), child: Row(children: [
            const IconBox(Icons.hourglass_bottom, bg: C.orangeSoft, fg: C.orange, size: 40),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('STATUS PEMILIHAN', style: T.label), Text('Belum Memilih Ekskul', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.orange))])),
            const Pill('T.A. 24/25', Color(0xFFE5E8EF), C.muted),
          ])),
          const SizedBox(height: 12),
          Btn('Tetapkan Ekskul Siswa', icon: Icons.add_circle_outline, expand: true, h: 52),
        ])),
        const SizedBox(height: 4),
        Center(child: RichText(text: const TextSpan(style: TextStyle(color: C.muted, fontSize: 14), children: [TextSpan(text: 'Menampilkan '), TextSpan(text: '5', style: TextStyle(fontWeight: FontWeight.w800, color: C.ink)), TextSpan(text: ' dari '), TextSpan(text: '1.240', style: TextStyle(fontWeight: FontWeight.w800, color: C.ink)), TextSpan(text: ' siswa')]))),
        const SizedBox(height: 10),
        Btn.white('Muat Lebih Banyak  ⌄', expand: true, h: 54),
      ],
    );
  }
}
