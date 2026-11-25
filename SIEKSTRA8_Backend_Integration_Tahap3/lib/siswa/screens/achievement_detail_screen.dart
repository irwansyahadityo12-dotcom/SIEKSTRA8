import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class AchievementDetailScreen extends StatelessWidget {
  const AchievementDetailScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Detail Prestasi')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          PhotoBox(height: 180, colors: const [Color(0xFF1E3A8A), Color(0xFF60A5FA)], icon: Icons.emoji_events_outlined, overlays: const [Overlay1(Alignment.topLeft, Pill('JUARA 1', fg: Colors.white, bg: Colors.black45))]),
          const SizedBox(height: 14),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Pill('PRESTASI EKSTRAKURIKULER', fg: C.amber, bg: C.amberBg), const SizedBox(height: 10),
            tx('Juara 1 Pertolongan Pertama Jumbara PMR Jawa Timur', size: 18, w: FontWeight.w800, height: 1.3),
            const SizedBox(height: 8), tx('Prestasi tim PMR Wira SMKN 8 Malang pada kegiatan Jumbara tingkat Provinsi Jawa Timur.', size: 12, color: C.muted, height: 1.5),
            const SizedBox(height: 14), _row('Penyelenggara', 'PMI Provinsi Jawa Timur'), _row('Tahun', '2024'), _row('Ekstrakurikuler', 'PMR Wira SMKN 8'), _row('Status verifikasi', 'Terverifikasi'),
          ])),
          AppCard(color: C.soft, child: Row(children: [const Icon(Icons.workspace_premium_outlined, color: C.primary), const SizedBox(width: 10), Expanded(child: tx('Bukti sertifikat akan tersedia setelah dokumen diunggah dan diverifikasi oleh Pembina.', size: 11, color: C.primary))])),
        ]),
      );
  Widget _row(String a, String b) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Expanded(child: tx(a, size: 11.5, color: C.muted)), Flexible(child: tx(b, size: 11.5, w: FontWeight.w700, align: TextAlign.right))]));
}
