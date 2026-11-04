import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'permission_form_screen.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});
  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _Log {
  final String date, title, status, footer;
  final String? place, note, file;
  final Color c, bg;
  final IconData footerIcon;
  const _Log(this.date, this.title, this.status, this.c, this.bg, this.footer, this.footerIcon, {this.place, this.note, this.file});
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  int filter = 0;
  static const logs = <_Log>[
    _Log('Jumat, 25 Okt 2024 • 15.30 - 17.00 WIB', 'Simulasi Pertolongan Pertama (PP) & Tandu Darurat', 'Hadir', C.green, C.greenBg, 'Validasi GPS & QR • 15.25 WIB', Icons.qr_code_2, place: 'Lapangan Utama & Ruang UKS'),
    _Log('Jumat, 18 Okt 2024 • 15.30 - 17.00 WIB', 'Materi Dapur Umum & Triage Lapangan', 'Hadir', C.green, C.greenBg, 'Presensi Masuk Tervalidasi • 15.28 WIB', Icons.check_circle_outline, place: 'Ruang UKS Utama SMKN 8 Malang'),
    _Log('Jumat, 11 Okt 2024 • 15.30 - 17.00 WIB', 'Pembekalan Lomba Jumbara PMR Jatim', 'Izin', C.amber, C.amberBg, 'Surat Dispensasi Resmi Terverifikasi', Icons.verified_outlined, note: 'Persiapan Olimpiade Sains Terapan • Disetujui Pembina PMR'),
    _Log('Jumat, 04 Okt 2024 • 15.30 - 17.00 WIB', 'Latihan Fisik & Ketahanan Medis', 'Sakit', C.brown, Color(0xFFFFE4D6), 'Divalidasi oleh UKS & Pembina', Icons.shield_outlined, file: 'Surat_Keterangan_Dokter.pdf'),
    _Log('Jumat, 27 Sep 2024 • 15.30 - 17.00 WIB', 'Pengenalan Obat-obatan & Perlengkapan PP', 'Hadir', C.green, C.greenBg, 'Presensi Masuk Tervalidasi • 15.20 WIB', Icons.check_circle_outline, place: 'Lab Farmasi & UKS 2'),
  ];

  Widget _stat(IconData i, Color c, Color bg, String n, String l) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.border)),
          child: Column(children: [
            CircleAvatar(radius: 15, backgroundColor: bg, child: Icon(i, size: 16, color: c)),
            const SizedBox(height: 6),
            tx(n, size: 17, w: FontWeight.w800),
            tx(l, size: 11, color: C.muted),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final filters = ['Semua (21)', 'Hadir (18)', 'Izin (2)', 'Sakit (1)'];
    final shown = logs.where((l) => filter == 0 || l.status == ['', 'Hadir', 'Izin', 'Sakit'][filter]).toList();
    return Scaffold(
      appBar: subAppBar(context, 'Riwayat Presensi', badge: 'PMR Wira'),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: kBlueGradient, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: tx('EVALUASI PRESENSI EKSKUL', size: 10, w: FontWeight.w700, color: Colors.white70)),
                  Pill('Sangat Baik', fg: Colors.white, bg: Colors.white24, icon: Icons.verified_outlined, size: 10),
                ]),
                const SizedBox(height: 8),
                tx('Tingkat Partisipasi Kehadiran', size: 18, w: FontWeight.w800, color: Colors.white),
                tx('Semester Ganjil TA 2024/2025', size: 11.5, color: Colors.white70),
                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  tx('95%', size: 28, w: FontWeight.w800, color: Colors.white),
                  const SizedBox(width: 6),
                  Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 5), child: tx('dari total 21 sesi', size: 11.5, color: Colors.white70))),
                  tx('Target: 80%', size: 11, color: Colors.white70),
                ]),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: .95, minHeight: 8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white))),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _stat(Icons.check_circle_outline, C.green, C.greenBg, '18', 'Hadir'),
              _stat(Icons.assignment_outlined, C.amber, C.amberBg, '2', 'Izin'),
              _stat(Icons.medical_services_outlined, C.red, C.redBg, '1', 'Sakit'),
              _stat(Icons.cancel_outlined, C.muted, const Color(0xFFEFF1F7), '0', 'Alfa'),
            ]),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Icon(Icons.calendar_month_outlined, size: 20, color: C.primary),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx('PERIODE AKTIF', size: 9.5, w: FontWeight.w700, color: C.muted), tx('Oktober – November 2024', size: 14, w: FontWeight.w800)])),
                Pill('21 Sesi', size: 10),
                Icon(Icons.keyboard_arrow_down, color: C.muted),
              ]),
            ),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => filter = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: filter == i ? C.primaryDark : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: filter == i ? C.primaryDark : C.border)),
                    child: tx(filters[i], size: 12, w: FontWeight.w700, color: filter == i ? Colors.white : C.text),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [Expanded(child: tx('Log Pertemuan PMR', size: 16, w: FontWeight.w800)), tx('Terakhir diperbarui hari ini', size: 10.5, color: C.muted)]),
            const SizedBox(height: 10),
            for (final l in shown)
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: l.c),
                        const SizedBox(width: 6),
                        Expanded(child: tx(l.date, size: 11, w: FontWeight.w700, color: C.muted)),
                        Pill(l.status, fg: l.c, bg: l.bg, size: 10.5),
                      ]),
                      const SizedBox(height: 8),
                      tx(l.title, size: 14.5, w: FontWeight.w800, height: 1.3),
                      if (l.place != null) ...[const SizedBox(height: 6), Row(children: [Icon(Icons.place_outlined, size: 13, color: C.muted), const SizedBox(width: 4), Expanded(child: tx(l.place!, size: 11, color: C.muted))])],
                      if (l.note != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(10)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx('Keterangan Izin:', size: 10.5, color: C.muted), tx(l.note!, size: 11.5, w: FontWeight.w600)]),
                        ),
                      ],
                      if (l.file != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(10)),
                          child: Row(children: [Icon(Icons.attach_file, size: 16, color: C.amber), const SizedBox(width: 6), Expanded(child: tx(l.file!, size: 11.5, w: FontWeight.w600)), tx('Valid', size: 11, w: FontWeight.w700, color: C.green)]),
                        ),
                      ],
                    ]),
                  ),
                  Divider(height: 1, color: C.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(children: [Icon(l.footerIcon, size: 14, color: l.c == C.green ? C.primary : l.c), const SizedBox(width: 6), Expanded(child: tx(l.footer, size: 11, w: FontWeight.w700, color: l.c == C.green ? C.primary : l.c)), Icon(Icons.chevron_right, size: 18, color: C.muted)]),
                  ),
                ]),
              ),
            AppCard(
              color: const Color(0xFFEEF2FF),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, size: 18, color: C.primary),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  tx('Syarat Sertifikat Ekstrakurikuler', size: 12, w: FontWeight.w800),
                  tx('Pastikan kehadiran minimal 80% pada akhir semester untuk mendapatkan sertifikat keaktifan PMR Wira SMKN 8 Malang.', size: 11, color: C.muted, height: 1.45),
                ])),
              ]),
            ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: PrimaryButton('Ajukan Izin / Sakit Baru', icon: Icons.note_add_outlined, trailingIcon: false, color: const Color(0xFFB45309),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PermissionFormScreen()))),
          ),
        ),
      ]),
    );
  }
}
