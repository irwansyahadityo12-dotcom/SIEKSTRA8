import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});
  @override
  State<JadwalScreen> createState() => _State();
}

class _State extends State<JadwalScreen> {
  int sel = 3;
  static const days = [['Sen', '18', 0], ['Sel', '19', 1], ['Rab', '20', 1], ['Kam', '21', 1], ['Jum', '22', 1], ['Sab', '23', 2], ['Min', '24', 2]];

  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      back: 'Kembali ke Beranda & Sistem',
      title: 'Kelola Jadwal Kegiatan',
      subtitle: 'Master jadwal latihan rutin, gladi bersih, dan agenda lomba seluruh ekskul SMKN 8 Malang.',
      trailing: const Pill('T.A. 2024/2025', C.soft, C.primary),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: const Color(0xFFE9EDF6), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.calendar_month, color: C.primary, size: 20), SizedBox(width: 6), Text('Tampilan Kalender', style: TextStyle(color: C.primary, fontWeight: FontWeight.w800))]))),
            Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.table_rows_outlined, color: C.muted, size: 20), SizedBox(width: 6), Text('Tabel Agenda', style: TextStyle(color: C.muted, fontWeight: FontWeight.w700))])),
          ]),
        ),
        Btn('Tambah Jadwal Kegiatan Baru', icon: Icons.add_circle_outline, expand: true, h: 54),
        const SizedBox(height: 14),
        SCard(child: Column(children: [
          Row(children: [
            const Icon(Icons.calendar_month_outlined, color: C.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('November 2024', style: T.h2)),
            _nav(Icons.chevron_left), const SizedBox(width: 8), _nav(Icons.chevron_right),
          ]),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (var i = 0; i < days.length; i++)
              GestureDetector(
                onTap: () => setState(() => sel = i),
                child: Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: sel == i ? C.primary : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                  child: Column(children: [
                    Text(days[i][0] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel == i ? Colors.white : (i == 6 ? C.orange : C.muted))),
                    const SizedBox(height: 4),
                    Text(days[i][1] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: sel == i ? Colors.white : (i == 6 ? C.orange : C.ink))),
                    const SizedBox(height: 4),
                    CircleAvatar(radius: 3, backgroundColor: sel == i ? Colors.white : [const Color(0xFFCBD5E1), C.primary, C.orange][days[i][2] as int]),
                  ]),
                ),
              ),
          ]),
        ])),
        const Chips(['Hari Ini (4)', 'Minggu Ini (18)', 'Rutin Mingguan', 'Agenda Khusus']),
        Row(children: const [Expanded(child: Text('Jadwal Kamis, 21 Nov 2024', style: T.title)), Text('Tersisa 2 Sesi', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 10),
        _event(['Futsal SMKN 8', 'Latihan Rutin'], 'Siap Berjalan', C.soft, C.primary, 'Latihan Rutin & Drill Taktik Futsal', Icons.schedule, 'Hari Ini, 15:30 - 17:30 WIB (120 Menit)', 'Lapangan Utama SMKN 8 Malang', 'PJ: Dedi Wahyudi, S.Pd (Pembina)', 'Tampil di Pembina & 82 Siswa Futsal', true),
        _event(['RPL Club & Cyber', 'Kelas Khusus'], 'Ruangan Siap', C.soft, C.primary, 'Pelatihan Keamanan Jaringan & CTF Session', Icons.schedule, 'Hari Ini, 15:45 - 17:30 WIB', 'Lab Komputer RPL 2 & Cyber Room', 'PJ: Ahmad Fauzi, S.Kom', 'Tampil di Pembina & 64 Siswa RPL Club', true),
        _event(['PMR Wira Unit 8', 'Latihan Rutin'], 'Terjadwal', const Color(0xFFEEF1F7), C.amber, 'Simulasi Pertolongan Pertama Medis & Tandu', Icons.event, 'Sabtu, 23 Nov 2024 • 07:30 WIB', 'Ruang UKS & Area Lapangan Barat', 'PJ: Drs. Hj. Meita Juwita, M.Pd', 'Tampil di Pembina & 48 Siswa PMR Wira', false),
        const InfoCard(Icons.info_outline, 'Otomasi Sinkronisasi Jadwal', 'Setiap jadwal yang dibuat atau diubah otomatis tersinkronisasi ke aplikasi mobile Pembina dan kalender dashboard Siswa anggota terkait secara real-time.'),
      ],
    );
  }

  Widget _nav(IconData i) => Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFEEF1F7), borderRadius: BorderRadius.circular(12)), child: Icon(i, color: C.ink));

  Widget _event(List<String> tags, String status, Color sbg, Color sfg, String title, IconData timeIcon, String time, String place, String pj, String sync, bool presensi) => SCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Pill(tags[0], C.orangeSoft, C.orange),
            const SizedBox(width: 6),
            Pill(tags[1], tags[1] == 'Kelas Khusus' ? const Color(0xFFEEF1F7) : C.amberSoft, tags[1] == 'Kelas Khusus' ? C.muted : C.amber),
            const Spacer(),
            Pill(status, sbg, sfg, dot: true),
          ]),
          const SizedBox(height: 10),
          Text(title, style: T.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 10),
          Panel(padding: const EdgeInsets.all(14), child: Column(children: [
            _l(timeIcon, time, bold: true),
            _l(Icons.place_outlined, place),
            _l(Icons.person_outline, pj),
          ])),
          const SizedBox(height: 10),
          Panel(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Row(children: [const Icon(Icons.sync, size: 16, color: C.primary), const SizedBox(width: 6), Expanded(child: Text(sync, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)))])),
          const SizedBox(height: 12),
          presensi
              ? Row(children: [Expanded(flex: 5, child: Btn('Buka Presensi', expand: true, h: 50)), const SizedBox(width: 8), Btn.gray('Edit', h: 50), const SizedBox(width: 8), Btn.warn('', icon: Icons.event_busy_outlined, h: 50)])
              : Row(children: [Expanded(child: Btn.gray('Edit Jadwal', expand: true, h: 50)), const SizedBox(width: 8), Expanded(child: Btn.warn('Batalkan', expand: true, h: 50))]),
        ]),
      );

  Widget _l(IconData i, String t, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Icon(i, size: 20, color: C.primary), const SizedBox(width: 10), Expanded(child: Text(t, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: bold ? C.ink : C.muted)))]));
}
