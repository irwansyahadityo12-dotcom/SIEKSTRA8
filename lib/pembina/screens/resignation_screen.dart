import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ResignationScreen extends StatelessWidget {
  const ResignationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      tag: 'PMR',
      title: 'Pengajuan Pengunduran Diri',
      subtitle: 'Verifikasi permohonan keluar anggota ekskul PMR SMKN 8',
      trailing: const Pill('3 Baru', AppColors.red, Colors.white, icon: Icons.circle),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFE3E9FA), borderRadius: BorderRadius.circular(20)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Instruksi Pembina PMR', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 4),
                Text('Persetujuan pengunduran diri akan memperbarui status keanggotaan menjadi Non-Aktif serta mencabut hak inventaris fisik PMR (rompi, slayer, KTA).', style: TextStyle(fontSize: 14, color: AppColors.ink, height: 1.4)),
              ]),
            ),
          ]),
        ),
        const SearchField('Cari nama siswa, kelas, atau NIS...'),
        const Chips(['Semua 8', 'Menunggu Verifikasi 3', 'Disetujui Keluar']),
        SCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            Container(height: 5, decoration: const BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.vertical(top: Radius.circular(20)))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Avatar('RM', bg: AppColors.redSoft, fg: AppColors.red, size: 52),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Rizky Maulana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text('X DKV 2 • NIS 231155', style: T.body)])),
                  const Flexible(child: Pill('Menunggu Evaluasi', AppColors.redSoft, AppColors.red, icon: Icons.circle)),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF1F3FC), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: const [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tingkat Keanggotaan', style: T.body), Text('PMR Madya (Baru)', style: T.title)])),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Masa Aktif & Presensi', style: T.body), Text('3 Bulan (68%)', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800))])),
                  ]),
                ),
                const SizedBox(height: 12),
                Row(children: const [Expanded(child: Text('ALASAN PENGUNDURAN', style: T.label)), Text('Diajukan 22 Okt 2024', style: T.body)]),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFEFF2FD), borderRadius: BorderRadius.circular(14)),
                  child: const Text('“Jadwal ekskul bentrok dengan jam les bimbingan kejuruan DKV dan fokus persiapan magang industri semester genap.”', style: TextStyle(fontSize: 15, height: 1.4)),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF1F3FC), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: const [
                    Icon(Icons.picture_as_pdf_outlined, color: AppColors.red),
                    SizedBox(width: 8),
                    Expanded(child: Text('Surat_Izin_Orang_Tua_TTD.pdf', style: TextStyle(fontSize: 14))),
                    Text('Lihat ↗', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(height: 10),
                const Text('Catatan Pembina / Rekomendasi Konseling', style: T.label),
                const SizedBox(height: 6),
                const TextField(decoration: InputDecoration(hintText: 'Berikan saran / catatan tindak lanjut...', filled: true, fillColor: Color(0xFFEFF2FD), border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))), hintStyle: TextStyle(fontSize: 13, color: AppColors.muted))),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Btn('Setujui Keluar', icon: Icons.person_remove_outlined, bg: AppColors.red, expand: true, h: 50)),
                  const SizedBox(width: 8),
                  Expanded(child: Btn.soft('Arahkan Konseling', icon: Icons.support_agent_rounded, expand: true, h: 50)),
                ]),
              ]),
            ),
          ]),
        ),
        SCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Avatar('FN', bg: Color(0xFF86EFAC), fg: AppColors.green, size: 52),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Fani Novitasari', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text('XI RPL 1 • NIS 221045', style: T.body)])),
              Pill('Menunggu', AppColors.redSoft, AppColors.red, icon: Icons.circle),
            ]),
            const SizedBox(height: 10),
            Row(children: const [Pill('PMR Wira (Senior)', AppColors.soft, AppColors.primary), SizedBox(width: 8), Text('• Diajukan 20 Okt 2024', style: T.body)]),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFEFF2FD), borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Alasan Fisik / Kesehatan:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                Text('“Kondisi kesehatan fisik pasca-pemulihan cedera tidak memungkinkan untuk kegiatan simulasi lapangan & latihan basah rutin.”', style: TextStyle(fontSize: 15, height: 1.4)),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Btn('Setujui', icon: Icons.check_circle_outline, bg: AppColors.red, expand: true, h: 50)),
              const SizedBox(width: 8),
              Expanded(child: Btn('Pindah Administrasi', icon: Icons.swap_horiz_rounded, expand: true, h: 50)),
            ]),
          ]),
        ),
        SCard(
          bottom: 12,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Avatar('BA', size: 48),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Bagas Aditya', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), Text('XII MM 1 • Non-Aktif', style: T.body)])),
              Flexible(child: Pill('Disetujui Keluar', Color(0xFFF0F1F5), AppColors.muted, icon: Icons.done_all)),
            ]),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF1F3FC), borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Row(children: [Expanded(child: Text('Diproses: 10 Sep 2024', style: T.title)), Text('▣ Bebas Tanggungan', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 12))]),
                SizedBox(height: 4),
                Text('“Telah mengembalikan rompi tugas lapangan, KTA, dan buku saku ke inventaris ruang UKS.”', style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.muted)),
              ]),
            ),
          ]),
        ),
        SCard(
          child: Row(children: const [
            IconBox(Icons.bar_chart_rounded, size: 48),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Retensi Anggota PMR 2024', style: T.title), Text('92% anggota aktif bertahan di semester ini', style: T.body)])),
            Text('92%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 22)),
          ]),
        ),
      ],
    );
  }
}
