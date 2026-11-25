import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pusat Bantuan')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: kBlueGradient, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.support_agent, color: Colors.white, size: 34), const SizedBox(height: 10),
            tx('Ada yang bisa kami bantu?', size: 19, w: FontWeight.w800, color: Colors.white),
            tx('Temukan panduan penggunaan SIEKSTRA-8.', size: 11.5, color: Colors.white70),
          ])),
          const SectionTitle('Pertanyaan Umum'),
          const _Faq(q: 'Bagaimana cara mendaftar ekstrakurikuler?', a: 'Buka menu Ekskul, pilih ekstrakurikuler yang diminati, kemudian lengkapi formulir pendaftaran. Pantau hasilnya melalui Status Pendaftaran.'),
          const _Faq(q: 'Di mana saya melihat status pendaftaran?', a: 'Buka Profil lalu pilih Riwayat Pendaftaran. Pilih pengajuan untuk melihat tahapan verifikasi.'),
          const _Faq(q: 'Bagaimana cara mengajukan izin?', a: 'Buka menu Profil atau Riwayat Presensi, kemudian pilih formulir izin dan lengkapi informasi yang diminta.'),
          const _Faq(q: 'Siapa yang memverifikasi pengajuan?', a: 'Pengajuan terkait kegiatan ekstrakurikuler akan diperiksa oleh Pembina dan pihak sekolah sesuai ketentuan.'),
          const SectionTitle('Kontak Sekolah'),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const IconBox(Icons.school_outlined), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx('SMKN 8 Malang', size: 13, w: FontWeight.w800), tx('Hubungi Pembina atau bagian Kesiswaan melalui kanal resmi sekolah.', size: 11, color: C.muted)]))]),
            const SizedBox(height: 10), tx('Kontak langsung belum dikonfigurasi pada versi frontend ini.', size: 10.5, color: C.muted),
          ])),
        ]),
      );
}
class _Faq extends StatelessWidget {
  final String q, a;
  const _Faq({required this.q, required this.a});
  @override
  Widget build(BuildContext context) => AppCard(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), child: ExpansionTile(tilePadding: EdgeInsets.zero, childrenPadding: const EdgeInsets.only(bottom: 12), title: tx(q, size: 12.5, w: FontWeight.w800), children: [Align(alignment: Alignment.centerLeft, child: tx(a, size: 11.5, color: C.muted, height: 1.45))]));
}
