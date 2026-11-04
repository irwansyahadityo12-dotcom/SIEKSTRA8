import 'package:flutter/material.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'ekskul_detail_screen.dart';
import 'registration_form_screen.dart';

class EkskulListScreen extends StatelessWidget {
  const EkskulListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SizedBox(
          height: 40,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            _tab('Semua', 28, true),
            _tab('Vokasi & Keahlian', 8, false),
            _tab('Olahraga', 9, false),
          ]),
        ),
        const SizedBox(height: 12),
        AppCard(
          color: const Color(0xFFEAF0FF),
          child: Row(children: [
            IconBox(Icons.campaign_outlined, color: C.primary, bg: Colors.white, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                tx('PENDAFTARAN EKSKUL TA 2024/2025', size: 11.5, w: FontWeight.w800, color: C.primary),
                tx('Sisa 3 hari sebelum penutupan kuota resmi!', size: 12, color: C.text),
              ]),
            ),
            Icon(Icons.chevron_right, color: C.muted),
          ]),
        ),
        for (final e in ekskulList) _EkskulCard(e),
      ]),
    );
  }

  Widget _tab(String label, int count, bool active) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: active ? C.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? C.primary : C.border)),
        child: Row(children: [
          tx(label, size: 12.5, w: FontWeight.w700, color: active ? Colors.white : C.text),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: active ? Colors.white24 : C.soft, borderRadius: BorderRadius.circular(10)),
            child: tx('$count', size: 10.5, w: FontWeight.w800, color: active ? Colors.white : C.muted),
          ),
        ]),
      );
}

class _EkskulCard extends StatelessWidget {
  final Ekskul e;
  const _EkskulCard(this.e);

  @override
  Widget build(BuildContext context) {
    final warn = e.almostFull;
    final accent = warn ? C.brown : C.primary;
    final noQuota = e.quota == 0;
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PhotoBox(height: 130, colors: e.photo, icon: e.icon, overlays: [
          Overlay1(Alignment.topLeft, Row(mainAxisSize: MainAxisSize.min, children: [
            DarkChip(e.category, icon: Icons.category_outlined),
            if (warn) ...[const SizedBox(width: 6), Pill(e.full ? 'Penuh' : 'Hampir Penuh', fg: C.brown, bg: C.amberBg, size: 10)],
          ])),
          Overlay1(Alignment.bottomLeft, DarkChip(e.schedule, icon: Icons.calendar_today_outlined)),
          Overlay1(Alignment.bottomRight, DarkChip(e.place)),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            tx(e.name, size: 17, w: FontWeight.w800),
            const SizedBox(height: 6),
            tx(e.desc, size: 12, color: C.muted, height: 1.45),
            const SizedBox(height: 10),
            Text.rich(TextSpan(style: const TextStyle(fontSize: 12, color: C.muted), children: [
              TextSpan(text: e.name.contains('Futsal') ? 'Pelatih: ' : 'Pembina: '),
              TextSpan(text: e.coach, style: const TextStyle(fontWeight: FontWeight.w800, color: C.text)),
            ])),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: tx(noQuota ? 'Jumlah Peserta Terdata' : 'Kapasitas Kuota', size: 12, color: C.text)),
              tx(noQuota ? '${e.filled} Siswa Terdaftar' : '${e.filled} / ${e.quota} Siswa (${(e.ratio * 100).toStringAsFixed(e.ratio * 1000 % 10 == 0 ? 0 : 1)}%)',
                  size: 12, w: FontWeight.w700, color: noQuota ? C.text : accent),
            ]),
            const SizedBox(height: 6),
            QuotaBar(e.ratio, color: noQuota ? const Color(0xFF3F4A66) : accent, height: 7),
            const SizedBox(height: 14),
            if (noQuota)
              SoftButton('Lihat Informasi & Presensi', icon: Icons.chevron_right, bg: C.soft, fg: C.primary,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EkskulDetailScreen(ekskul: e))))
            else
              PrimaryButton(warn ? 'Daftar Segera' : 'Detail / Daftar',
                  icon: warn ? Icons.bolt : Icons.arrow_forward,
                  color: warn ? C.brown : C.primary,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => warn ? RegistrationFormScreen(ekskul: e) : EkskulDetailScreen(ekskul: e)))),
          ]),
        ),
      ]),
    );
  }
}
