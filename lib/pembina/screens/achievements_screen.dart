import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      tag: 'PMR',
      title: 'Lomba & Prestasi PMR',
      subtitle: 'Kelola pendaftaran lomba & capaian juara',
      trailing: Btn('Tambah', icon: Icons.add, h: 42),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(24)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Icon(Icons.star_rounded, color: Color(0xFF86EFAC), size: 16),
              SizedBox(width: 4),
              Text('PRESTASI TERBARU PMR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              Spacer(),
              Pill('Tingkat Kota', Color(0x33FFFFFF), Colors.white),
            ]),
            const SizedBox(height: 10),
            const Text('Juara 1 Lomba Pertolongan Pertama (PMR)', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Tingkat Kota Malang • Dimenangkan oleh Regu Putri PMR Wira Unit SMKN 8', style: TextStyle(color: Colors.white70)),
            const Divider(color: Colors.white24, height: 24),
            Row(children: [
              const Icon(Icons.verified_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              const Expanded(child: Text('Terverifikasi PMI Cabang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
              Btn('Lihat Sertifikat →', bg: Colors.white, fg: AppColors.red, h: 38),
            ]),
          ]),
        ),
        const SearchField('Cari nama lomba atau kejuaraan...'),
        const Chips(['Semua Tingkat', 'Kota Malang', 'Jawa Timur', 'Nasional']),
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('Semua (5)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))))),
            const Expanded(child: Center(child: Text('Juara & Selesai (3)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)))),
            const Expanded(child: Center(child: Text('Aktif / Mendatang (2)', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)))),
          ]),
        ),
        SCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Pill('Juara 1', AppColors.green, Colors.white, icon: Icons.emoji_events_outlined),
              SizedBox(width: 6),
              Flexible(child: Pill('Tingkat Kota Malang', AppColors.soft, AppColors.primary)),
              Spacer(),
              Text('Okt 2024', style: T.body),
            ]),
            const SizedBox(height: 10),
            const Text('Lomba Pertolongan Pertama & Tandu Darurat PMI Kota Malang 2024', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('📅 Sabtu, 26 Oktober 2024', style: T.body),
            const Text('📍 Markas PMI Kota Malang, Klojen', style: T.body),
            const Text('👥 Regu Putri PMR Wira (6 Siswa) • Danyon: Ahmad Fikri', style: T.body),
            const SizedBox(height: 12),
            const Text('DOKUMENTASI & PENYERAHAN PIALA', style: T.label),
            const SizedBox(height: 8),
            Row(children: const [
              Expanded(child: _Photo(Icons.medical_services_outlined, Color(0xFFD6E4FF), null)),
              SizedBox(width: 8),
              Expanded(child: _Photo(Icons.emoji_events_outlined, Color(0xFFFDE68A), null)),
              SizedBox(width: 8),
              Expanded(child: _Photo(Icons.groups_outlined, Color(0xFFFECACA), '+4 Foto')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Btn.soft('Detail & Arsip', icon: Icons.visibility_outlined, expand: true)),
              const SizedBox(width: 8),
              Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20)),
              const SizedBox(width: 8),
              Btn.soft('Dokumen', icon: Icons.add_a_photo_outlined),
            ]),
          ]),
        ),
        SCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Pill('Pendaftaran Selesai', AppColors.soft, AppColors.primary, icon: Icons.how_to_reg_outlined),
              SizedBox(width: 6),
              Flexible(child: Pill('Tingkat Provinsi Jatim', AppColors.redSoft, AppColors.red)),
              Spacer(),
              Text('12 Hari Lagi', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800, fontSize: 12)),
            ]),
            const SizedBox(height: 10),
            const Text('Olimpiade Kemanusiaan & Dapur Umum PMR Wira Se-Jatim', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('📅 15 – 17 November 2024', style: T.body),
            const Text('⛺ Bumi Perkemahan Coban Rondo, Batu', style: T.body),
            const Text('👥 12 Anggota Regu Gabungan (Wira 1 & 2)', style: T.body),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const CircleAvatar(radius: 20, backgroundColor: AppColors.primary, child: Text('12', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Status Berkas: Lengkap', style: T.title), Text('Surat Dispensasi Sekolah Tersedia', style: T.body)])),
                const Icon(Icons.check_circle_outline, color: AppColors.green, size: 28),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(flex: 3, child: Btn('Detail Tim Peserta', icon: Icons.badge_outlined, expand: true, h: 50)),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: Btn.soft('Edit Jadwal', icon: Icons.edit_calendar_outlined, expand: true, h: 50)),
            ]),
          ]),
        ),
        SCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Pill('Juara 2', AppColors.soft, AppColors.primary, icon: Icons.military_tech_outlined),
              SizedBox(width: 6),
              Flexible(child: Pill('Tandu Cepat Darurat', AppColors.soft, AppColors.primary)),
              Spacer(),
              Text('Agu 2024', style: T.body),
            ]),
            const SizedBox(height: 10),
            const Text('Lomba Ketangkasan Tandu Cepat PMI Rayon Lowokwaru', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('📅 12 Agustus 2024', style: T.body),
            const Text('👥 Regu Putra PMR Madya (Dimas Ibrahim & 3 Rekan)', style: T.body),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Btn.soft('Lihat Sertifikat Juara 2', icon: Icons.description_outlined, expand: true)),
              const SizedBox(width: 8),
              Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.more_horiz, color: AppColors.primary)),
            ]),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            const IconBox(Icons.sync_rounded, bg: AppColors.greenSoft, fg: AppColors.green, size: 40),
            const SizedBox(width: 12),
            const Expanded(child: Text('Data prestasi ini otomatis tampil pada Dashboard Pembina dan feed aplikasi siswa anggota PMR.', style: T.body)),
          ]),
        ),
      ],
    );
  }
}

class _Photo extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final String? more;
  const _Photo(this.icon, this.bg, this.more);
  @override
  Widget build(BuildContext context) => Container(
        height: 96,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Center(child: more != null ? Text(more!, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)) : Icon(icon, size: 34, color: AppColors.ink.withValues(alpha: 0.5))),
      );
}
