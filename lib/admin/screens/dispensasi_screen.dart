import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DispensasiScreen extends StatelessWidget {
  const DispensasiScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      back: 'Kembali ke Proposal & Surat',
      eyebrow: 'LAYANAN RESMI  •  T.A. 2024/2025 Ganjil',
      title: 'Dispensasi & Surat Tugas',
      subtitle: 'Penerbitan surat tugas resmi delegasi lomba dan izin dispensasi KBM siswa SMKN 8 Malang.',
      children: [
        Row(children: const [
          Expanded(child: StatBox('Pengajuan', '8', 'Surat Aktif')),
          SizedBox(width: 8),
          Expanded(child: StatBox('Verifikasi', '2', 'Perlu Tindakan', valueColor: C.orange, subColor: C.orange)),
          SizedBox(width: 8),
          Expanded(child: StatBox('Diterbitkan', '34', 'Surat Tugas')),
        ]),
        const SizedBox(height: 14),
        Btn('+ Buat Surat Tugas / Dispensasi Baru', icon: Icons.add_task, expand: true, h: 56),
        const SizedBox(height: 14),
        const SearchBox('Cari nomor surat, siswa, atau kegiatan...'),
        const Chips(['Semua  42', 'Menunggu Admin  2', 'Disetujui KS  34', 'Ditolak  6']),
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Pill('SURAT TUGAS RESMI', C.amberSoft, C.amber), SizedBox(width: 8), Flexible(child: Text('• 421.5/782/S', style: T.body)), Spacer()]),
          const SizedBox(height: 6),
          const Align(alignment: Alignment.centerRight, child: Pill('Menunggu Verifikasi Kesiswaan', C.orangeSoft, C.orange, dot: true)),
          const SizedBox(height: 8),
          const Text('Surat Tugas Delegasi LKS Cyber Security 2024', style: T.h2),
          const SizedBox(height: 10),
          Panel(padding: const EdgeInsets.all(12), child: Column(children: const [
            KV(Icons.groups_outlined, 'Delegasi Siswa:', 'M. Rizky (X RPL 2), Dimas Arya (X TKJ 3)'),
            KV(Icons.emoji_events_outlined, 'Ekskul / Event:', 'RPL Club • LKS Wilker 3 Jatim'),
            KV(Icons.calendar_month_outlined, 'Durasi Izin:', '24 Nov – 26 Nov 2024 (3 Hari)', valueColor: C.primary),
          ])),
          const SizedBox(height: 12),
          Row(children: const [Expanded(child: Text('Alur Persetujuan & Tanda Tangan:', style: T.body)), Text('Tahap 2 dari 3', style: TextStyle(color: C.orange, fontWeight: FontWeight.w800, fontSize: 13))]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Container(height: 6, decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(width: 6),
            Expanded(child: Container(height: 6, decoration: BoxDecoration(color: C.orange, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(width: 6),
            Expanded(child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFE5E9F5), borderRadius: BorderRadius.circular(4)))),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('✓ Pembina OK', style: TextStyle(color: C.primary, fontSize: 12, fontWeight: FontWeight.w700)), Text('⏱ Verif Admin', style: TextStyle(color: C.orange, fontSize: 12, fontWeight: FontWeight.w700)), Text('✍ TTD Kepala Sekolah', style: TextStyle(color: C.muted, fontSize: 12))]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Btn('Verifikasi & Setujui', icon: Icons.check_circle_outline, expand: true, h: 52, onTap: () => toast(context, 'Surat diverifikasi'))),
            const SizedBox(width: 8),
            Btn.danger('Tolak', icon: Icons.close, h: 52),
            const SizedBox(width: 8),
            Btn.gray('', icon: Icons.visibility_outlined, h: 52),
          ]),
        ])),
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Pill('DISPENSASI KBM', C.orangeSoft, C.orange), SizedBox(width: 8), Flexible(child: Text('• 421.5/710/SMKN.8/I', style: T.body))]),
          const SizedBox(height: 6),
          const Align(alignment: Alignment.centerRight, child: Pill('Surat Resmi Terbit', C.soft, C.primary, icon: Icons.verified_outlined)),
          const Text('Dispensasi Diklat Gabungan Palang Merah Remaja', style: T.h2),
          const SizedBox(height: 10),
          Panel(padding: const EdgeInsets.all(12), child: Column(children: const [
            KV(Icons.badge_outlined, 'Delegasi:', '14 Siswa PMR Wira Unit 8'),
            KV(Icons.event_available_outlined, 'Pelaksanaan:', '18 Okt 2024 (1 Hari Penuh)'),
            KV(Icons.qr_code_2, 'Verifikasi Digital:', 'Valid (E-Signature KS & Stempel)', valueColor: C.primary),
          ])),
          const SizedBox(height: 12),
          Row(children: [Expanded(flex: 4, child: Btn('Cetak PDF Resmi', icon: Icons.picture_as_pdf_outlined, expand: true, h: 52)), const SizedBox(width: 8), Expanded(flex: 4, child: Btn.gray('WhatsApp Guru', icon: Icons.share_outlined, expand: true, h: 52)), const SizedBox(width: 8), Btn.gray('', icon: Icons.more_vert, h: 52)]),
        ])),
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Pill('SURAT TUGAS SELESAI', C.amberSoft, C.amber), SizedBox(width: 8), Flexible(child: Text('• 421.5/650/SMKN.8/DIS', style: T.body))]),
          const SizedBox(height: 6),
          const Align(alignment: Alignment.centerRight, child: Pill('Diarsipkan', C.amberSoft, C.amber, icon: Icons.archive_outlined)),
          const Text('Surat Tugas Turnamen Futsal Walikota Cup Malang', style: T.h2),
          const SizedBox(height: 10),
          Panel(padding: const EdgeInsets.all(12), child: Column(children: const [
            KV(Icons.sports_soccer, 'Tim / Ekskul:', '12 Siswa Tim Futsal SMKN 8'),
            KV(Icons.flag_outlined, 'Periode Selesai:', '05 Okt 2024 • Hasil: Juara 2 Kota'),
          ])),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [Btn.gray('Lihat Berkas Arsip', icon: Icons.folder_open_outlined, h: 44), const SizedBox(width: 8), Btn.gray('Cetak Ulang', icon: Icons.print_outlined, h: 44)]),
        ])),
        const InfoCard(Icons.info_outline, 'Sinkronisasi Otomatis Izin Presensi', 'Surat tugas dan dispensasi yang disetujui Kepala Sekolah otomatis tercatat pada daftar presensi KBM harian wali kelas, guru piket, dan sistem absensi digital SIEKSTRA-8.'),
      ],
    );
  }
}
