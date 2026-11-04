import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  static const _m = [
    ['AF', 'Ahmad Fikri', 'XI MIPA 2 • NIS 221045', 'PMR Wira (Ketua Regu Pertolongan Pertama)', 'Aktif', 'PMR Wira', 'Kehadiran 98% (12/12 sesi)'],
    ['NP', 'Nabila Putri', 'X-E 1 • NIS 231120', 'PMR Madya (Bidang Pertolongan & Tandu)', 'Aktif', 'PMR Madya', 'Kehadiran 92% (11/12 sesi)'],
    ['DI', 'Dimas Ibrahim', 'XI IPS 1 • NIS 221089', 'PMR Wira (Logistik & Tandu Darurat)', 'Aktif', 'PMR Wira', 'Kehadiran 95% (11/12 sesi)'],
    ['RM', 'Rizky Maulana', 'X-E 4 • NIS 231155', 'PMR Madya (Anggota Baru)', 'Izin Sakit', 'PMR Madya', 'Kehadiran 75% (9/12 sesi)'],
    ['SA', 'Siti Aisyah', 'XI MIPA 1 • NIS 221012', 'PMR Wira (Koordinator Medis)', 'Aktif', 'PMR Wira', 'Kehadiran 100% (12/12 sesi)'],
  ];

  @override
  Widget build(BuildContext context) {
    return Screen(
      tag: 'PMR',
      title: 'Manajemen Anggota PMR',
      subtitle: 'Unit Palang Merah Remaja Wira & Madya 2024/2025',
      children: [
        const SearchField('Cari nama, NIS, atau divisi...'),
        Row(children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
              child: Row(children: const [
                Icon(Icons.add, color: AppColors.red, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('PMR (Wira & Madya)', style: T.title)),
                Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          Btn.soft('Export', icon: Icons.download_rounded, h: 48),
          const SizedBox(width: 8),
          Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
              child: const Icon(Icons.filter_alt_outlined, color: AppColors.muted)),
        ]),
        const SizedBox(height: 14),
        SCard(
          color: const Color(0xFFF3F7FF),
          child: Row(children: [
            const IconBox(Icons.groups_rounded, bg: Colors.white, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TOTAL ANGGOTA', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '48 ', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  TextSpan(text: 'Siswa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.muted)),
                ])),
                const Text('45 aktif • 3 izin/nonaktif', style: T.body),
              ]),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFE9FBF1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFB7EBCB))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [
                Text('RERATA PRESENSI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.green)),
                Text('94% Hadir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.green)),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: const [
            Expanded(child: Text('DAFTAR ANGGOTA PMR AKTIF & TERDAFTAR', style: T.label)),
            Text('Urutkan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
          ]),
        ),
        for (final m in _m) _MemberCard(m),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final List<String> m;
  const _MemberCard(this.m);
  @override
  Widget build(BuildContext context) {
    final wira = m[5] == 'PMR Wira';
    final sick = m[4] != 'Aktif';
    final perfect = m[6].contains('100%');
    return SCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Avatar(m[0], bg: m[0] == 'SA' ? AppColors.redSoft : AppColors.soft, fg: m[0] == 'SA' ? AppColors.red : AppColors.primary, size: 52),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m[1], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            Text(m[2], style: T.body),
            const SizedBox(height: 4),
            Text(m[3], style: T.title.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              Pill(m[4], sick ? AppColors.redSoft : AppColors.greenSoft, sick ? AppColors.red : AppColors.green),
              Pill(m[5], wira ? AppColors.redSoft : AppColors.amberSoft, wira ? AppColors.red : AppColors.amber),
            ]),
            const SizedBox(height: 8),
            Text(m[6], style: TextStyle(fontSize: 12, fontWeight: perfect ? FontWeight.w700 : FontWeight.w500, color: perfect ? AppColors.green : AppColors.muted)),
          ]),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: const Color(0xFFF3F4F8), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.more_horiz, color: AppColors.muted),
        ),
      ]),
    );
  }
}
