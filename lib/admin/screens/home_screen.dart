import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../shell.dart';
import 'jadwal_screen.dart';
import 'prestasi_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AdminScreen(children: [
      HeroBanner(children: const [
        Pill('Tahun Ajaran 2024/2025', Color(0x33FFFFFF), Colors.white, dot: true),
        SizedBox(height: 14),
        Text('Halo, Admin Kesiswaan! 👋', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
        SizedBox(height: 6),
        Text('Pantau seluruh kegiatan ekstrakurikuler SMKN 8 Malang secara real-time.', style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4)),
      ]),
      SCard(
        color: const Color(0xFFFFFAEB),
        border: const Color(0xFFFDE9B8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Pill('PRESTASI BARU', Color(0xFFF59E0B), Colors.white, icon: Icons.star_rounded),
            const SizedBox(width: 8),
            const Expanded(child: Text('PMR Wira SMKN 8', style: TextStyle(color: C.amber, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
            Text('12 Okt 2024', style: T.body),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFDE68A))), child: const Center(child: Text('🏆', style: TextStyle(fontSize: 32)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Juara 1 Lomba Pertolongan Pertama (PP) Wira', style: T.title),
              Text('Jumbara PMR & Temu Relawan Se-Jawa Timur 2024', style: T.body),
              const SizedBox(height: 6),
              Row(children: const [Pill('Tingkat Provinsi', C.greenSoft, C.green), SizedBox(width: 8), Flexible(child: Text('• 10 Anggota Tim PMR', style: T.body))]),
            ])),
          ]),
        ]),
      ),
      Row(children: const [
        Expanded(child: StatBox('Total Ekstra', '28 Ekstra', 'Semester Ganjil', icon: Icons.pie_chart_outline, badge: '+2 Aktif')),
        SizedBox(width: 12),
        Expanded(child: StatBox('Siswa Terdaftar', '1.240 Siswa', 'Dari 1.442 total murid', icon: Icons.groups_outlined, badge: '86% Ikut', iconBg: Color(0xFFE8E9FF), iconFg: Color(0xFF4F46E5), badgeBg: Color(0xFFE8E9FF), badgeFg: Color(0xFF4F46E5))),
      ]),
      const SizedBox(height: 12),
      Row(children: const [
        Expanded(child: StatBox('Pembina & Pelatih', '34 Guru', 'Guru & Instruktur Ahli', icon: Icons.school_outlined, badge: 'Aktif', badgeBg: Color(0xFFE0F2FE), badgeFg: Color(0xFF0369A1))),
        SizedBox(width: 12),
        Expanded(child: StatBox('Presensi Hari Ini', '94.2%', 'Kehadiran tercatat', icon: Icons.speed_outlined, badge: '8 Sesi', iconBg: C.greenSoft, iconFg: C.green, badgeBg: C.greenSoft, badgeFg: C.green)),
      ]),
      const SectionTitle('Aksi Cepat Admin', action: 'Pintasan Fitur'),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        Btn('+ Ekstra Baru', h: 46, onTap: () => goTab(context, 1)),
        const SizedBox(width: 10),
        Btn.white('Validasi Presensi  5', icon: Icons.person_outline, h: 46, onTap: () => goTab(context, 4)),
        const SizedBox(width: 10),
        Btn.white('Broadcast', icon: Icons.campaign_outlined, h: 46),
      ])),
      const SizedBox(height: 8),
      Row(children: const [Text('! ', style: TextStyle(color: C.red, fontWeight: FontWeight.w900, fontSize: 18)), Expanded(child: Text('Perlu Tindakan Cepat', style: T.h2)), Pill('2 Antrean', C.redSoft, C.red)]),
      const SizedBox(height: 10),
      SCard(child: Column(children: [
        Row(children: [
          const IconBox(Icons.description_outlined),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Proposal Lomba Futsal...', style: T.title), Text('OSIS & Ekstra Futsal SMK', style: T.body)])),
          const Pill('Menunggu ACC', C.soft, C.primary),
        ]),
        const Divider(height: 24),
        Row(children: [
          const Icon(Icons.schedule, size: 16, color: C.muted), const SizedBox(width: 6),
          const Expanded(child: Text('10 Okt 2024 • 14:00', style: T.body)),
          Btn.white('Tinjau', h: 40, onTap: () => goTab(context, 3)),
          const SizedBox(width: 8),
          Btn('Setujui', h: 40),
        ]),
      ])),
      SCard(child: Column(children: [
        Row(children: [
          const IconBox(Icons.memory_outlined),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Presensi Ekstra Robotik', style: T.title), Text('Sesi Sabtu, 5 Oktober 2024', style: T.body)])),
          const Pill('Belum Verif', C.redSoft, C.red),
        ]),
        const Divider(height: 24),
        Row(children: [
          const Icon(Icons.person_outline, size: 16, color: C.muted), const SizedBox(width: 6),
          const Expanded(child: Text('Pembina: Bpk. Bambang, S.T.', style: T.body)),
          Btn.soft('Ingatkan Guru', h: 40),
        ]),
      ])),
      SectionTitle('Daftar Prestasi Ekstrakurikuler', icon: Icons.apps_rounded, iconColor: C.orange, action: 'Semua Prestasi', onAction: () => push(context, const PrestasiScreen())),
      _prestasi('🥇', 'Juara 1', 'Jatim 2024', 'Pertolongan Pertama - PMR Wira', 'Jumbara PMR Jatim • PMI Provinsi', const Pill('Baru', C.greenSoft, C.green), C.amberSoft),
      _prestasi('🥈', 'Juara 2', 'Kota Malang', 'Turnamen Pelajar Kota Malang', 'Ekstra Futsal SMKN 8 Malang', Text('28 Sep', style: T.body), const Color(0xFFEEF1F7)),
      _prestasi('💡', 'Best Innovation', 'Nasional', 'IoT Smart School Innovation', 'Ekstra Robotik & Otomasi', Text('14 Sep', style: T.body), C.soft),
      SectionTitle('Jadwal Ekstra Terdekat (Hari Ini)', icon: Icons.calendar_month_outlined, action: 'Lihat Semua', onAction: () => push(context, const JadwalScreen())),
      _jadwal('15:30', 'Paskibraka SMKN 8', 'Lapangan Utama', const Pill('Siap', C.greenSoft, C.green)),
      _jadwal('15:45', 'English Club', 'Lab Bahasa 2', const Pill('Siap', C.greenSoft, C.green)),
      _jadwal('15:30', 'Teater & Seni Tari', 'Aula Graha Bhakti', const Pill('Persiapan', C.soft, C.primary)),
      const InfoCard(Icons.lightbulb_outline, 'Tips Pengelolaan', 'Rekap presensi bulanan akan otomatis dikunci setiap tanggal 28 pukul 23:59 WIB. Pastikan pelatih menyelesaikan entri tepat waktu.', bg: Color(0xFFEFF4FF), border: Color(0xFFD6E2FF)),
    ]);
  }

  Widget _prestasi(String emoji, String tag, String where, String title, String sub, Widget trail, Color bg) => SCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Pill(tag, bg, C.ink), const SizedBox(width: 6), Text(where, style: T.body.copyWith(fontSize: 12))]),
            const SizedBox(height: 4),
            Text(title, style: T.title.copyWith(fontSize: 16)),
            Text(sub, style: T.body.copyWith(fontSize: 12)),
          ])),
          trail,
        ]),
      );

  Widget _jadwal(String time, String name, String place, Widget pill) => SCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [Text(time, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const Text('WIB', style: TextStyle(fontSize: 11, color: C.muted, fontWeight: FontWeight.w700))]),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: T.title.copyWith(fontSize: 16)), Row(children: [const Icon(Icons.place_outlined, size: 14, color: C.muted), const SizedBox(width: 4), Text(place, style: T.body)])])),
          pill,
        ]),
      );
}
