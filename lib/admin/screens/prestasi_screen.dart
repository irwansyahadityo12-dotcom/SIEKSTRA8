import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PrestasiScreen extends StatelessWidget {
  const PrestasiScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      back: 'Kembali ke Beranda & Sistem',
      title: 'Bank Prestasi & Kejuaraan',
      subtitle: 'Pusat data capaian lomba, kejuaraan, dan rekam jejak prestasi siswa SMKN 8 Malang.',
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFF0F2F8), borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Row(children: const [Expanded(child: Text('REKAPITULASI CAPAIAN T.A. 2024/2025', style: T.label)), Pill('Semester Ganjil', C.soft, C.primary)]),
            const SizedBox(height: 10),
            Row(children: const [
              Expanded(child: StatBox('🏆 Total', '42', 'Juara terdata')),
              SizedBox(width: 8),
              Expanded(child: StatBox('🏅 Prov/Nas', '16', 'Tingkat tinggi', valueColor: C.amber)),
              SizedBox(width: 8),
              Expanded(child: StatBox('📋 Review', '3 ●', 'Perlu verifikasi', valueColor: C.orange, subColor: C.orange)),
            ]),
          ]),
        ),
        Row(children: [Btn('+ Tambah Prestasi', icon: Icons.add_circle_outline, h: 54), const SizedBox(width: 10), Expanded(child: Btn.gray('Unduh Rekap', icon: Icons.download_rounded, expand: true, h: 54))]),
        const SizedBox(height: 14),
        const SearchBox('Cari nama lomba, ekskul, atau siswa juara...'),
        const Chips(['Semua  42', 'Verifikasi ● 3', 'Kota Malang (18)', 'Jawa Timur (15)', 'Nasional (9)']),
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Pill('RPL CLUB & CYBER', C.amberSoft, C.amber), SizedBox(width: 6), Pill('Tk. Jawa Timur', C.orangeSoft, C.orange), Spacer(), Pill('Terverifikasi', C.greenSoft, C.green, icon: Icons.verified_outlined)]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const IconBox(Icons.emoji_events_outlined, bg: C.amberSoft, fg: C.amber, size: 52),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Juara 1 Lomba Cyber Security Tingkat Provinsi Jawa Timur 2024', style: T.h2), SizedBox(height: 2), Text('Medali Emas & Sertifikat Resmi Disdik Jatim', style: TextStyle(color: C.amber, fontWeight: FontWeight.w700, fontSize: 14))])),
          ]),
          const SizedBox(height: 10),
          Panel(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('👥 Delegasi: M. Rizky Pratama (X RPL 2), Farhan Ramadh', style: T.body),
            SizedBox(height: 6),
            Text('🪪 Pembina: Ahmad Fauzi, S.Kom', style: T.body),
            SizedBox(height: 6),
            Text('📍 24–26 Nov 2024 • Politeknik Negeri Malang (POLINEMA)', style: T.body),
          ])),
          const SizedBox(height: 10),
          Row(children: const [Expanded(child: Photo(icon: Icons.emoji_events, w: 0, h: 96, label: 'Podium 1', bg: Color(0xFFC9D5EE))), SizedBox(width: 8), Expanded(child: Photo(icon: Icons.workspace_premium, w: 0, h: 96, label: 'Sertifikat Disdik', bg: Color(0xFFE6DDC4)))]),
          const SizedBox(height: 10),
          Row(children: [Btn.gray('Detail', icon: Icons.visibility_outlined, h: 44), const SizedBox(width: 8), Btn.gray('Edit', icon: Icons.edit_outlined, h: 44), const SizedBox(width: 8), Btn.soft('Cetak', icon: Icons.print_outlined, h: 44)]),
        ])),
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Pill('PMR WIRA UNIT 8', C.orangeSoft, C.orange), SizedBox(width: 6), Pill('Tk. Malang Raya', Color(0xFFEEF1F7), C.muted), Spacer(), Pill('Terverifikasi', C.greenSoft, C.green, icon: Icons.verified_outlined)]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const IconBox(Icons.military_tech_outlined, bg: C.amberSoft, fg: C.amber, size: 52),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Juara 1 Lomba Pertolongan Pertama (PP) Wira', style: T.h2), SizedBox(height: 2), Text('Piala Bergilir PMI Malang Raya & Piagam Emas', style: TextStyle(color: C.amber, fontWeight: FontWeight.w700, fontSize: 14))])),
          ]),
          const SizedBox(height: 10),
          Panel(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('👥 Peserta: Tim Putri PMR Unit 8 (Ketua: Siti Nurhaliza)', style: T.body),
            SizedBox(height: 6),
            Text('📅 12 Okt 2024 • Markas Palang Merah Indonesia Kota Malang', style: T.body),
          ])),
          const SizedBox(height: 10),
          const Photo(icon: Icons.photo_camera_outlined, w: 0, h: 120, label: '📷 Dokumentasi Praktik Triage Lapangan', bg: Color(0xFFD9DEEA)),
          const SizedBox(height: 10),
          Row(children: [Btn.gray('Detail', icon: Icons.visibility_outlined, h: 44), const SizedBox(width: 8), Btn.gray('Edit', icon: Icons.edit_outlined, h: 44), const SizedBox(width: 8), Btn.gray('Berkas', icon: Icons.download_rounded, h: 44)]),
        ])),
        SCard(
          border: C.orange,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [Pill('ROBOTIKA & OTOMASI', Color(0xFFEEF1F7), C.ink), Spacer(), Pill('Perlu Verifikasi', C.orangeSoft, C.orange, dot: true)]),
            const SizedBox(height: 6),
            const Pill('Tk. Nasional', C.orangeSoft, C.orange),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const IconBox(Icons.smart_toy_outlined, size: 52),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Best Innovation - IoT Smart School Solution', style: T.h2), SizedBox(height: 2), Text('Kompetisi Kreasi Vokasi Nasional 2024', style: TextStyle(color: C.amber, fontWeight: FontWeight.w700, fontSize: 14))])),
            ]),
            const SizedBox(height: 10),
            Panel(color: const Color(0xFFFFF3E8), padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('👥 Peserta: Dimas Arya Kusuma & Tim IoT SMKN 8', style: T.body),
              SizedBox(height: 6),
              Text('📅 04 Nov 2024 • Universitas Indonesia Expo Hall', style: T.body),
              SizedBox(height: 6),
              Text('📎 Piagam_Inovasi_DimasArya.pdf (3.4 MB)', style: TextStyle(color: C.orange, decoration: TextDecoration.underline, fontSize: 13)),
            ])),
            const SizedBox(height: 10),
            Btn('Verifikasi & Terbitkan SKPI', icon: Icons.how_to_reg_outlined, expand: true, h: 54),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: Btn.gray('Cek Lampiran', icon: Icons.visibility_outlined, expand: true, h: 48)), const SizedBox(width: 8), Expanded(child: Btn.warn('Minta Revisi', icon: Icons.cancel_outlined, expand: true, h: 48))]),
          ]),
        ),
        const InfoCard(Icons.menu_book_outlined, 'Integrasi Otomatis Buku SKPI', 'Setiap sertifikat yang telah disetujui Admin Kesiswaan secara otomatis diakumulasikan ke Surat Keterangan Pendamping Ijazah (SKPI) siswa bersangkutan.'),
      ],
    );
  }
}
