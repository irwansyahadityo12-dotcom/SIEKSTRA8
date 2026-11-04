import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class CompetitionInfoScreen extends StatefulWidget {
  const CompetitionInfoScreen({super.key});
  @override
  State<CompetitionInfoScreen> createState() => _CompetitionInfoScreenState();
}

class _CompetitionInfoScreenState extends State<CompetitionInfoScreen> {
  int tab = 0;

  Widget _stat(String big, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [tx(big, size: 18, w: FontWeight.w800, color: Colors.white), tx(label, size: 10, color: Colors.white70)]),
        ),
      );

  Widget _prestasi(String badge, Color badgeBg, String date, List<Color> colors, String title, String desc, IconData fIcon, String fTop, String fMain, String fTag) => AppCard(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PhotoBox(height: 130, colors: colors, icon: Icons.emoji_events_outlined, overlays: [
            Overlay1(Alignment.topLeft, Pill(badge, fg: Colors.white, bg: badgeBg, size: 10)),
            Overlay1(Alignment.bottomRight, DarkChip(date, icon: Icons.calendar_today_outlined)),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tx(title, size: 15, w: FontWeight.w800, height: 1.3),
              const SizedBox(height: 4),
              tx(desc, size: 11.5, color: C.muted, lines: 2, height: 1.4),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(fIcon, size: 18, color: C.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx(fTop, size: 10, color: C.muted), tx(fMain, size: 12, w: FontWeight.w800, lines: 1)])),
                  Pill(fTag, fg: C.brown, bg: C.amberBg, size: 10),
                ]),
              ),
            ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subAppBar(context, 'Info Lomba', badge: 'PMR Wira'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: kBlueGradient, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Pill('JUARA UMUM 1 JUMBARA PMR JATIM 2024', fg: const Color(0xFFFFD27D), bg: Colors.white12, icon: Icons.emoji_events_outlined, size: 9.5),
            const SizedBox(height: 12),
            tx('PMR Wira SMKN 8 Malang', size: 20, w: FontWeight.w800, color: Colors.white),
            tx('Kemanusiaan, Ketangkasan Tandu & Ketangguhan Medis Tanggap Bencana', size: 11.5, color: Colors.white70, height: 1.4),
            const SizedBox(height: 14),
            Row(children: [_stat('14', 'Trofi Juara'), _stat('2024/2025', 'Periode Aktif'), _stat('Grade A', 'Akreditasi PMI')]),
          ]),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: const Color(0xFFEAEFFC), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            for (final t in [(Icons.emoji_events_outlined, 'Prestasi & Penghargaan'), (Icons.flag_outlined, 'Lomba Mendatang')].asMap().entries)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => tab = t.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: tab == t.key ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(t.value.$1, size: 16, color: tab == t.key ? C.primary : C.muted),
                      const SizedBox(width: 6),
                      tx(t.value.$2, size: 11.5, w: FontWeight.w700, color: tab == t.key ? C.primary : C.muted),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        if (tab == 0) ...[
          Row(children: [
            Container(width: 4, height: 18, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(4))),
            Expanded(child: tx('Galeri Prestasi Unggulan', size: 15, w: FontWeight.w800)),
            tx('Total 14 Gelar', size: 11, color: C.muted),
          ]),
          const SizedBox(height: 10),
          _prestasi('Juara 1 Tingkat Provinsi', C.amber, 'Oktober 2024', const [Color(0xFF7F1D1D), Color(0xFFEF4444)], 'LKS Tandu Darurat & Pertolongan Pertama Jawa Timur 2024',
              'Simulasi rintangan evakuasi korban bencana lapangan berkecepatan 3 menit 12 detik dengan teknik balut bidai...', Icons.groups_2_outlined, 'Delegasi', 'Tim PMR Wira Inti (Regu Alpha)', 'Emas & Piagam Gub.'),
          _prestasi('Piala Bergilir', C.brown, 'Agustus 2024', const [Color(0xFF78350F), Color(0xFFF59E0B)], 'Juara Umum Jumbara PMR Wira Tingkat Kota Malang 2024',
              'Kemenangan mutlak pada divisi Madya-Wira Terpadu yang mencakup kepemimpinan, donor darah sukarela, sanitasi...', Icons.apartment_outlined, 'Apresiasi Tertinggi', 'Piala Bergilir Walikota Malang', 'Juara Umum I'),
          _prestasi('Penghargaan Khusus', C.primary, 'Juli 2024', const [Color(0xFF14532D), Color(0xFF3B82F6)], 'Best Field First Aid Team & Fast Response Triage',
              'Simulasi tanggap darurat massal bencana gempa bumi garapan PMI Kota Malang dengan akurasi penentuan kode...', Icons.health_and_safety_outlined, 'Kategori Kecepatan Reaksi Klinis', 'Kategori Kecepatan Reaksi Klinis', 'Terbaik I'),
        ] else
          AppCard(
            child: Column(children: [
              Icon(Icons.flag_outlined, size: 36, color: C.muted),
              const SizedBox(height: 8),
              tx('Lomba PP & Kesiapsiagaan Bencana Jumbara PMI Jatim', size: 14, w: FontWeight.w800, align: TextAlign.center),
              tx('2 – 3 Nov 2024 • Gedung Diklat PMI Malang & Rampal', size: 11.5, color: C.muted, align: TextAlign.center),
            ]),
          ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.support_agent, size: 20, color: C.primary), const SizedBox(width: 8), tx('Kontak Pembina & Seleksi', size: 14, w: FontWeight.w800)]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                CircleAvatar(radius: 24, backgroundColor: C.soft, child: Icon(Icons.person, color: C.primary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    tx('Raudlatul Hakiki Fadila, S.Pd', size: 13, w: FontWeight.w800),
                    tx('Pembina Teknis & Pelatih PMR Wira', size: 11, color: C.muted),
                    Row(children: [Icon(Icons.circle, size: 7, color: C.green), const SizedBox(width: 4), tx('Tersedia di Ruang UKS', size: 10.5, color: C.green)]),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: PrimaryButton('Konsultasi Lomba', icon: Icons.chat_outlined, trailingIcon: false)),
              const SizedBox(width: 8),
              Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFEFF1F7), shape: BoxShape.circle), child: Icon(Icons.calendar_month_outlined)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
