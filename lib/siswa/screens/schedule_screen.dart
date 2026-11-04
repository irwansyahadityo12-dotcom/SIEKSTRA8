import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'attendance_history_screen.dart';
import 'competition_info_screen.dart';
import 'diklat_info_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int sel = 1;
  final List<(String, String, Color?)> days = const [
    ('SEN', '21', C.amber),
    ('SEL', '22', C.primary),
    ('RAB', '23', C.amber),
    ('KAM', '24', null),
    ('JUM', '25', C.amber),
    ('SAB', '26', C.amber),
    ('MIN', '27', null),
  ];

  void go(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));

  Widget _agenda({
    required String when,
    required Widget? tag,
    required IconData icon,
    required Color c,
    required Color bg,
    required String kind,
    required String title,
    required String place,
    required Widget button,
  }) =>
      AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.calendar_today_outlined, size: 13, color: C.primary),
            const SizedBox(width: 6),
            Expanded(child: tx(when, size: 11.5, w: FontWeight.w700, color: C.primary)),
            if (tag != null) tag,
          ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBox(icon, color: c, bg: bg, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                tx(kind, size: 10.5, color: C.muted),
                tx(title, size: 15, w: FontWeight.w800, height: 1.3),
                const SizedBox(height: 4),
                Row(children: [Icon(Icons.place_outlined, size: 12, color: C.muted), const SizedBox(width: 3), Expanded(child: tx(place, size: 11, color: C.muted))]),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          button,
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(badge: Pill('PMR', fg: C.red, bg: C.redBg, size: 9)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          IconBox(Icons.calendar_month_outlined, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tx('Jadwal & Agenda PMR', size: 17, w: FontWeight.w800),
              tx('PMR Wira SMKN 8 Malang • Sem. Ganjil', size: 11, color: C.muted),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
            child: Row(children: [Icon(Icons.chevron_left, size: 16), tx('Okt', size: 12, w: FontWeight.w800), Icon(Icons.chevron_right, size: 16)]),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          for (int i = 0; i < days.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => sel = i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: sel == i ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(14), border: sel == i ? Border.all(color: C.primary, width: 1.4) : null),
                  child: Column(children: [
                    tx(days[i].$1, size: 10, w: FontWeight.w700, color: sel == i ? C.primary : C.muted),
                    const SizedBox(height: 4),
                    tx(days[i].$2, size: 17, w: FontWeight.w800, color: i == 6 ? C.muted : C.text),
                    const SizedBox(height: 4),
                    Container(width: 5, height: 5, decoration: BoxDecoration(color: days[i].$3 ?? Colors.transparent, shape: BoxShape.circle)),
                  ]),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 14),
        FilterChips(['Semua Agenda', 'Latihan Rutin', 'Lomba & Diklat']),
        const SizedBox(height: 14),
        Row(children: [
          Icon(Icons.circle, size: 10, color: C.primary),
          const SizedBox(width: 8),
          Expanded(child: tx('Oktober – November 2024', size: 13.5, w: FontWeight.w800)),
          Pill('3 Agenda Terdekat', size: 10),
        ]),
        const SizedBox(height: 10),
        _agenda(
          when: 'Jumat, 25 Okt 2024 • 15:30 WIB',
          tag: Pill('QR Dibuka', size: 10),
          icon: Icons.medical_services_outlined,
          c: C.red,
          bg: C.redBg,
          kind: 'Latihan Rutin PP & Evakuasi',
          title: 'Simulasi Pertolongan Pertama (PP) & Tandu Darurat',
          place: 'UKS & Lapangan SMKN 8 Malang',
          button: PrimaryButton('Presensi Digital (GPS / QR)', icon: Icons.qr_code_scanner, trailingIcon: false, onPressed: () => go(const AttendanceHistoryScreen())),
        ),
        _agenda(
          when: 'Sabtu – Minggu, 2 – 3 Nov 2024',
          tag: Pill('H-10 Lomba', fg: C.brown, bg: C.amberBg, size: 10),
          icon: Icons.workspace_premium_outlined,
          c: C.amber,
          bg: C.amberBg,
          kind: 'Kompetisi • Delegasi Tim Inti',
          title: 'Lomba PP & Kesiapsiagaan Bencana Jumbara PMI Jatim',
          place: 'Gedung Diklat PMI Malang & Rampal',
          button: SoftButton('Rundown & Dispensasi Kesiswaan', icon: Icons.description_outlined, bg: const Color(0xFFEFF1F7), onPressed: () => go(const CompetitionInfoScreen())),
        ),
        _agenda(
          when: '15 – 16 Nov 2024 • 14:00 WIB',
          tag: Pill('Wajib Calon Anggota', fg: C.brown, bg: C.amberBg, size: 10),
          icon: Icons.local_fire_department_outlined,
          c: C.amber,
          bg: C.amberBg,
          kind: 'Pendidikan & Pelantikan',
          title: 'DIKLAT Orientasi & Pelantikan Anggota Madya PMR XXIV',
          place: 'Aula SMKN 8 & Lapangan Terbuka',
          button: SoftButton('Cek Perlengkapan & Surat Izin', icon: Icons.inventory_2_outlined, bg: const Color(0xFFEFF1F7), onPressed: () => go(const DiklatInfoScreen())),
        ),
        AppCard(
          color: const Color(0xFFEEF2FF),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, size: 16, color: C.primary),
            const SizedBox(width: 8),
            Expanded(child: tx('Presensi GPS valid radius 150m dari gerbang SMKN 8. Dispensasi lomba dan kegiatan luar sekolah dikonfirmasi via Pembina Ekskul.', size: 11, color: C.muted, height: 1.45)),
          ]),
        ),
      ]),
    );
  }
}
