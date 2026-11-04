import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DiklatScreen extends StatelessWidget {
  const DiklatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      back: 'Kembali ke Beranda & Sistem',
      eyebrow: '●  MODUL KADERISASI & SERTIFIKASI',
      title: 'Kelola Diklat & Kaderisasi',
      subtitle: 'Pusat manajemen pendidikan dan pelatihan dasar kepemimpinan serta sertifikasi ekskul terintegrasi.',
      children: [
        SCard(child: Row(children: const [
          Expanded(child: _S('Total Agenda', '8', 'Diklat', 'T.A. 2024/2025')),
          SizedBox(width: 8),
          Expanded(child: _S('Peserta Terdaftar', '215', 'Siswa', 'Dari 12 Ekskul', color: C.orange)),
          SizedBox(width: 8),
          Expanded(child: _S('Perlu Verifikasi', '1', 'Proposal', '● Kesiswaan', color: C.red)),
        ])),
        Row(children: [
          Expanded(child: Btn('Tambah Agenda Diklat', icon: Icons.add_circle_outline, expand: true, h: 56)),
          const SizedBox(width: 10),
          Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.line)), child: const Icon(Icons.download_rounded, color: C.primary)),
        ]),
        const SizedBox(height: 14),
        const SearchBox('Cari nama diklat, ekskul, lokasi...'),
        const Chips(['Semua (8)', 'Akan Datang (3)', 'Berjalan (1)', 'Selesai (4)']),
        _card(
          tags: const [Pill('PMR Wira Unit 8', C.orangeSoft, C.orange), Text('• Wajib Ekskul', style: T.body)], status: const Pill('Dibuka', C.orangeSoft, C.orange, dot: true),
          photoIcon: Icons.medical_services_outlined, title: 'Diklat Gabungan PMR Wira Tingkat Madya & Triage Bencana', date: '14 - 15 Des 2024 (2 Hari, Menginap)',
          place: 'Bumi Perkemahan Coban Rondo & SMKN 8 Malang', quota: '45 / 50 Kursi (90%)', value: 0.9, barColor: C.primary, quotaColor: C.primary,
          sync: 'Tersinkron ke Dashboard Siswa PMR & Pembina', syncIcon: Icons.sync, syncBg: C.soft,
          actions: [Expanded(flex: 4, child: Btn('Kelola Peserta (45)', icon: Icons.groups_outlined, expand: true, h: 50)), const SizedBox(width: 6), Btn.gray('Detail', h: 50), const SizedBox(width: 6), Btn.gray('', icon: Icons.edit_outlined, h: 50), const SizedBox(width: 6), Btn.danger('', icon: Icons.block, h: 50)],
        ),
        _card(
          tags: const [Pill('RPL Club & Cyber Security', C.soft, C.primary), Text('• Kejuruan IT', style: T.body)], status: const Pill('Siap Jalan', C.soft, C.primary, dot: true),
          photoIcon: Icons.computer, title: 'Bootcamp & Training Camp CTF Cyber Security SMKN 8', date: '07 - 08 Des 2024 • 08:00 - 16:00 WIB',
          place: 'Lab Komputer RPL 2 & Server Gedung B', quota: '32 / 35 Kursi Terisi', value: 0.91, barColor: C.orange, quotaColor: C.orange,
          sync: 'Tampil di Pembina & Calon Delegasi LKS', syncIcon: Icons.visibility_outlined, syncBg: const Color(0xFFEEF1F7),
          actions: [Expanded(flex: 4, child: Btn('Kelola Peserta (32)', icon: Icons.groups_outlined, expand: true, h: 50)), const SizedBox(width: 6), Btn.gray('Detail', h: 50), const SizedBox(width: 6), Btn.gray('', icon: Icons.edit_outlined, h: 50), const SizedBox(width: 6), Btn.danger('', icon: Icons.block, h: 50)],
        ),
        _card(
          tags: const [Pill('Paskibra SATYA BHAKTI', C.orangeSoft, C.orange), Text('• Bela Negara', style: T.body)], status: const Pill('Butuh Verifikasi', C.orangeSoft, C.orange, dot: true),
          photoIcon: Icons.flag_outlined, title: 'Latsar & Pelantikan Bantara Paskibra Satya Bhakti', date: '28 - 29 Des 2024',
          place: 'Lapangan Utama SMKN 8 & Aula Graha Wiyata', quota: '38 dari 40 Kuota Maksimal', value: 0.95, barColor: C.amber, quotaColor: C.ink, quotaLabel: 'Pendaftar Terkumpul:',
          actions: [Expanded(flex: 4, child: Btn('Verifikasi & Terbitkan SK', icon: Icons.verified_outlined, expand: true, h: 50)), const SizedBox(width: 6), Btn.gray('Proposal', h: 50), const SizedBox(width: 6), Btn.gray('', icon: Icons.edit_outlined, h: 50)],
        ),
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Photo(icon: Icons.sports_soccer, w: 88, h: 88, bg: Color(0xFFE5E8EF)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Row(children: [Pill('Futsal SMKN 8', C.amberSoft, C.amber), SizedBox(width: 6), Flexible(child: Text('• Olahraga', style: T.body))]),
              SizedBox(height: 6),
              Text('Latihan Alam & Pembekalan Mental...', style: T.h2),
              Text('12 - 13 Okt 2024 • 48 Peserta Lulus', style: T.body),
            ])),
          ]),
          const SizedBox(height: 12),
          Row(children: [Expanded(flex: 3, child: Btn.soft('Lihat Arsip Sertifikat', icon: Icons.workspace_premium_outlined, expand: true, h: 50)), const SizedBox(width: 8), Expanded(flex: 2, child: Btn.gray('Laporan', icon: Icons.description_outlined, expand: true, h: 50))]),
        ])),
        const InfoCard(Icons.hub_outlined, 'Integrasi Otomatis Modul SKPI', 'Agenda diklat yang disetujui otomatis menerbitkan jadwal ke dashboard siswa yang memenuhi syarat, serta otomatis mengintegrasikan sertifikat kelulusan ke modul Surat Keterangan Pendamping Ijazah (SKPI).', bg: Color(0xFFFFF7E6), border: Color(0xFFF8DCA0), fg: C.amber),
      ],
    );
  }

  Widget _card({required List<Widget> tags, required Widget status, required IconData photoIcon, required String title, required String date, required String place, required String quota, required double value, required Color barColor, required Color quotaColor, String quotaLabel = 'Kapasitas Peserta:', String? sync, IconData? syncIcon, Color? syncBg, required List<Widget> actions}) => SCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Flexible(child: tags.first), const SizedBox(width: 6), Flexible(child: tags.last), const Spacer(), status]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Photo(icon: photoIcon, w: 80, h: 80),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: T.h2), const SizedBox(height: 4), Text('📅 $date', style: T.body.copyWith(fontSize: 13))])),
          ]),
          const SizedBox(height: 12),
          Panel(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.apartment, size: 18, color: C.muted), const SizedBox(width: 8), Expanded(child: Text(place, style: const TextStyle(fontSize: 14)))]),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: Text(quotaLabel, style: T.body)), Text(quota, style: TextStyle(color: quotaColor, fontWeight: FontWeight.w800, fontSize: 13))]),
            const SizedBox(height: 6),
            Bar(value, barColor),
          ])),
          if (sync != null) ...[const SizedBox(height: 10), Panel(color: syncBg, padding: const EdgeInsets.all(12), child: Row(children: [Icon(syncIcon, size: 18, color: C.primary), const SizedBox(width: 8), Expanded(child: Text(sync, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))]))],
          const SizedBox(height: 12),
          Row(children: actions),
        ]),
      );
}

class _S extends StatelessWidget {
  final String l, v, u, s;
  final Color? color;
  const _S(this.l, this.v, this.u, this.s, {this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: T.body.copyWith(fontSize: 11.5)),
          const SizedBox(height: 4),
          RichText(text: TextSpan(children: [TextSpan(text: '$v ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color ?? C.primary)), TextSpan(text: u, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.ink))])),
          Text(s, style: TextStyle(fontSize: 11, color: color ?? C.muted, fontWeight: FontWeight.w600)),
        ]),
      );
}
