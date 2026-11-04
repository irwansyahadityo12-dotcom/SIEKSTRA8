import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class EkskulFormScreen extends StatelessWidget {
  const EkskulFormScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      title: 'Detail Ekstrakurikuler',
      bottom: Row(children: [
        Expanded(flex: 2, child: Btn('Batal', h: 54, expand: true, bg: Colors.white, fg: AppColors.ink, onTap: () => Navigator.pop(context))),
        const SizedBox(width: 12),
        Expanded(
            flex: 4,
            child: Btn('Simpan Perubahan', icon: Icons.check, h: 54, expand: true, onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perubahan disimpan')));
              Navigator.pop(context);
            })),
      ]),
      children: [
        SCard(
          color: const Color(0xFFEFF4FF),
          child: Row(children: [
            const IconBox(Icons.edit_outlined, bg: Colors.white, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('FORM PEMBINA / PEMBIMBING', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
                SizedBox(height: 4),
                Text('Atur detail ekskul, pembimbing, jadwal, presensi, dan kapasitas anggota PMR.', style: TextStyle(fontSize: 15, color: AppColors.muted)),
              ]),
            ),
          ]),
        ),
        const AchievementBanner(label: 'PRESTASI PMR WIRA', title: 'Juara 1 Lomba Pertolongan Pertama (PMR)', subtitle: 'Tingkat Kota • Dimenangkan oleh Regu Putri PMR Wira Unit 8'),
        const _F(Icons.menu_book_outlined, 'NAMA EKSKUL', 'Palang Merah Remaja (PMR Wira & Madya)'),
        const _F(Icons.inventory_2_outlined, 'KATEGORI', 'Kepalangmerahan & Kemanusiaan'),
        const _F(Icons.person_outline, 'PEMBINA / PEMBIMBING', 'Dimas Pratama, S.Pd.'),
        const _F(Icons.calendar_month_outlined, 'JADWAL RUTIN', 'Rabu & Jumat • 15:00 WIB'),
        const _F(Icons.place_outlined, 'LOKASI', 'Ruang UKS / Lab PMR Gedung B'),
        const _F(Icons.groups_outlined, 'KAPASITAS ANGGOTA', '60 siswa (48 aktif terisi)'),
        SCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const IconBox(Icons.published_with_changes_rounded, bg: AppColors.greenSoft, fg: AppColors.green, size: 44),
              const SizedBox(width: 12),
              const Expanded(child: Text('Presensi & Kehadiran PMR', style: T.title)),
              const Pill('94% Hadir', Color(0xFFE9FBF1), AppColors.green),
            ]),
            const SizedBox(height: 8),
            const Text('Latihan Rutin Terakhir', style: T.body),
            const Text('46 dari 48 anggota PMR hadir pada sesi materi evakuasi tandu & bidai.', style: T.body),
          ]),
        ),
        SCard(
          child: Row(children: [
            const IconBox(Icons.schedule_rounded, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('JADWAL MENDATANG', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12)),
                Text('Simulasi Pertolongan Pertama', style: T.title),
                Text('Jumat, 15:00 WIB • Lapangan & UKS', style: T.body),
              ]),
            ),
            const Pill('2 hari lagi', Color(0xFFF0F1F5), AppColors.muted),
          ]),
        ),
      ],
    );
  }
}

class _F extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _F(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF3F7FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFDDE7FF))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 8), Text(label, style: T.label.copyWith(fontSize: 12))]),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ]),
      );
}
