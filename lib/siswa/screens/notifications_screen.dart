import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Widget _item(IconData icon, Color c, Color bg, String title, String body, String time, bool unread) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(icon, color: c, bg: bg, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: tx(title, size: 13.5, w: FontWeight.w800, height: 1.3)),
                if (unread) Container(margin: const EdgeInsets.only(left: 6, top: 4), width: 8, height: 8, decoration: BoxDecoration(color: C.primary, shape: BoxShape.circle)),
              ]),
              const SizedBox(height: 4),
              tx(body, size: 11.5, color: C.muted, height: 1.45),
              const SizedBox(height: 8),
              Row(children: [Icon(Icons.schedule, size: 12, color: C.muted), const SizedBox(width: 4), tx(time, size: 10.5, color: C.muted)]),
            ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          Expanded(child: Row(children: [tx('Pemberitahuan', size: 20, w: FontWeight.w800), const SizedBox(width: 8), Pill('4 Baru', size: 10)])),
          Pill('Tandai dibaca', icon: Icons.done_all, size: 10.5),
        ]),
        const SizedBox(height: 12),
        FilterChips(['Semua  5', 'Pendaftaran  2', 'Jadwal  2', 'Perizinan']),
        const SizedBox(height: 14),
        _item(Icons.check_rounded, C.green, C.greenBg, 'Pendaftaran Berhasil Diterima',
            'Selamat, Anda telah resmi terdaftar di Robotik SMKN 8 Gelombang 2! Silakan cek jadwal latihan pertama dan konfirmasi grup komunikasi.', '10 menit yang lalu', true),
        _item(Icons.schedule, C.amber, C.amberBg, 'Pengingat Latihan Sore Ini',
            'Robotik SMKN 8 dimulai pukul 15:30 WIB di Lab Gedung B, Lantai 2. Jangan lupa membawa modul mikrokontroler ESP32.', '1 jam yang lalu', true),
        _item(Icons.emoji_events_outlined, C.amber, C.amberBg, 'Seleksi Delegasi Lomba LKS Vokasi 2024',
            'Dibuka pendaftaran seleksi kontingen Lomba Keterampilan Siswa (LKS) bidang Otomasi & Web Technologies tingkat Kota Malang. Daftarkan diri sebelum 28 Oktober.', '3 jam yang lalu', true),
        _item(Icons.bolt, C.purple, C.purpleBg, 'Jadwal Briefing DIKLAT Orientasi PMR',
            'Gladi bersih dan pengarahan perlengkapan wajib DIKLAT Orientasi & Pelantikan Anggota Madya PMR Wira XXIV diadakan Jumat pukul 14:00 WIB di Aula.', 'Kemarin', true),
        _item(Icons.description_outlined, C.primary, C.soft, 'Surat Dispensasi & Izin Orang Tua Disetujui',
            'Surat permohonan dispensasi kegiatan simulasi gabungan PMR telah diverifikasi oleh Tim Kesiswaan SMKN 8 Malang. Unduh lembar konfirmasi kegiatan.', '2 hari yang lalu', false),
      ]),
    );
  }
}
