import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class DiklatInfoScreen extends StatefulWidget {
  const DiklatInfoScreen({super.key});
  @override
  State<DiklatInfoScreen> createState() => _DiklatInfoScreenState();
}

class _DiklatInfoScreenState extends State<DiklatInfoScreen> {
  final checks = [true, true, false, false];
  final gear = const [
    ('Seragam PDL / Kaos Olahraga & Slayer PMR', 'Membawa 2 stel pakaian ganti lapangan'),
    ('Perlengkapan Ibadah & Obat Pribadi', 'Khusus yang memiliki riwayat asma/alergi bawa obat khusus'),
    ('Alat Tulis & Modul Pertolongan Pertama', 'Buku catatan saku kedap air dan pulpen hitam'),
    ('Jas Hujan Ponco, Senter, & Sepatu Lapangan', 'Wajib sepatu bersol karet antiselip dan baterai cadangan'),
  ];

  Widget _day(int n, Color c, String head, String time, String title, List<String> items) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 10, backgroundColor: c, child: tx('$n', size: 10, w: FontWeight.w800, color: Colors.white)),
            const SizedBox(width: 8),
            Expanded(child: tx(head, size: 11.5, w: FontWeight.w700, color: c)),
            tx(time, size: 11, color: C.muted),
          ]),
          const SizedBox(height: 6),
          tx(title, size: 14, w: FontWeight.w800),
          const SizedBox(height: 6),
          for (final i in items) Padding(padding: const EdgeInsets.only(bottom: 4), child: tx(i, size: 11.5, color: C.muted, height: 1.35)),
        ]),
      );

  Widget _head(IconData i, String t, {String? trailing}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [Icon(i, size: 20, color: C.primary), const SizedBox(width: 8), Expanded(child: tx(t, size: 14, w: FontWeight.w800)), if (trailing != null) tx(trailing, size: 11, color: C.muted)]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subAppBar(context, 'Info Diklat', badge: 'PMR Wira'),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: kBlueGradient, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Pill('Diklat Wajib Anggota Baru & Madya', fg: C.brown, bg: const Color(0xFFFFD27D), icon: Icons.flag_outlined, size: 9.5), const SizedBox(width: 6), Pill('T.A. 2024/2025', fg: Colors.white, bg: Colors.white24, size: 9.5)]),
                const SizedBox(height: 12),
                tx('DIKLAT Orientasi & Pelantikan Anggota PMR Wira XXV', size: 21, w: FontWeight.w800, color: Colors.white, height: 1.2),
                const SizedBox(height: 6),
                tx('Membentuk Relawan Remaja Tanggap, Tangguh, dan Humanis • SMKN 8 Malang', size: 11.5, color: Colors.white70),
                const SizedBox(height: 14),
                Row(children: [
                  Icon(Icons.event_note_outlined, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx('Durasi Kegiatan', size: 10, color: Colors.white70), tx('3 Hari 2 Malam', size: 12.5, w: FontWeight.w800, color: Colors.white)])),
                  Icon(Icons.verified_user_outlined, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx('Akreditasi', size: 10, color: Colors.white70), tx('PMI Kota Malang', size: 12.5, w: FontWeight.w800, color: Colors.white)])),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconBox(Icons.calendar_today_outlined, size: 34),
                  const SizedBox(height: 8),
                  tx('WAKTU PELAKSANAAN', size: 9.5, w: FontWeight.w700, color: C.muted),
                  tx('22 - 24 Nov 2024', size: 13.5, w: FontWeight.w800),
                  tx('Mulai Pkl 07.00 WIB', size: 11, color: C.muted),
                ])),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconBox(Icons.payments_outlined, color: C.green, bg: C.greenBg, size: 34),
                  const SizedBox(height: 8),
                  tx('BIAYA REGISTRASI', size: 9.5, w: FontWeight.w700, color: C.muted),
                  tx('100% Gratis', size: 13.5, w: FontWeight.w800, color: C.green),
                  tx('Subsidi BOS & Ekskul', size: 11, color: C.muted),
                ])),
              ),
            ]),
            AppCard(
              child: Row(children: [
                IconBox(Icons.place_outlined, color: C.amber, bg: C.amberBg, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: tx('LOKASI KEGIATAN', size: 9.5, w: FontWeight.w700, color: C.muted)), tx('Batu, Jatim', size: 10.5, color: C.muted)]),
                    tx('Bumi Perkemahan Coban Rondo', size: 14, w: FontWeight.w800),
                    tx('Jl. Coban Rondo, Pandesari, Kec. Pujon, Kab. Malang', size: 11, color: C.muted),
                  ]),
                ),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.groups_2_outlined, size: 20, color: C.primary), const SizedBox(width: 8), Expanded(child: tx('Status Kuota Diklat', size: 14, w: FontWeight.w800)), Pill('Sisa 12 Kursi', fg: C.red, bg: C.redBg, size: 10)]),
                const SizedBox(height: 10),
                QuotaBar(48 / 60, height: 9),
                const SizedBox(height: 6),
                Row(children: [Expanded(child: tx('48 Siswa terkonfirmasi', size: 11, color: C.muted)), tx('Kapasitas: 60 Siswa', size: 11, color: C.muted)]),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.photo_camera_outlined, size: 20, color: C.primary), const SizedBox(width: 8), Expanded(child: tx('Sekilas Diklat Lapangan', size: 14, w: FontWeight.w800)), tx('Dokumentasi XXIV', size: 11, w: FontWeight.w700, color: C.primary)]),
                const SizedBox(height: 10),
                PhotoBox(height: 170, colors: const [Color(0xFF14532D), Color(0xFF4D7C0F)], icon: Icons.landscape_outlined, overlays: [
                  Overlay1(Alignment.bottomLeft, tx('Simulasi Pertolongan Pertama (PP) dan Evakuasi Bencana Alam di Alam Terbuka Coban Rondo', size: 11, color: Colors.white, w: FontWeight.w600)),
                ]),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _head(Icons.view_agenda_outlined, 'Rangkaian Agenda 3 Hari', trailing: '22–24 Nov 2024'),
                _day(1, C.primary, 'Hari 1 • Jumat, 22 Nov', '07.00-21.00', 'Registrasi & Prinsip Dasar Kepalangmerahan',
                    ['Pemberangkatan dari Kampus SMKN 8 Malang', 'Pemasangan tenda pleton & orientasi sanitasi bivak', 'Kuliah interaktif: 7 Prinsip Palang Merah & Bulan Sabit Merah']),
                _day(2, C.brown, 'Hari 2 • Sabtu, 23 Nov', '05.30-22.00', 'Simulasi Lapangan, Triage, & Api Unggun',
                    ['Simulasi Pertolongan Pertama (PP) fraktur dan luka pendarahan', 'Pembuatan tandu darurat & evakuasi medan terjal', 'Praktik Dapur Umum Lapangan & Manajemen Posko', 'Malam Keakraban, Renungan Suci & Api Unggun']),
                _day(3, C.amber, 'Hari 3 • Minggu, 24 Nov', '06.00-15.00', 'Uji Kecakapan & Upacara Pelantikan Resmi',
                    ['Ujian Syarat Kecakapan PMR Wira (SKR) Tingkat Madya & Utama', 'Upacara Pembaitan dan Penyematan Slayer Kuning Wira', 'Operasi Bersih Lingkungan Camp & Kepulangan']),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _head(Icons.checklist, 'Perlengkapan Wajib Peserta', trailing: 'Siapkan Mandiri'),
                tx('Ketuk item untuk menandai barang bawaan yang sudah kamu masukkan ke dalam tas carrier / ransel:', size: 11, color: C.muted, height: 1.4),
                const SizedBox(height: 10),
                for (int i = 0; i < gear.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => checks[i] = !checks[i]),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Icon(checks[i] ? Icons.check_box : Icons.check_box_outline_blank, color: checks[i] ? C.primary : C.muted, size: 22),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx(gear[i].$1, size: 12, w: FontWeight.w800), tx(gear[i].$2, size: 11, color: C.muted)])),
                      ]),
                    ),
                  ),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _head(Icons.gavel_outlined, 'Kriteria Kelulusan & Pelantikan'),
                for (final k in const [('Kehadiran Minimal 90% Agenda', 'Wajib mengikuti seluruh materi ruang, simulasi malam, serta renungan suci.'), ('Uji Praktik Balut Bidai & Tandu Darurat', 'Mencapai standar kecakapan minimum penilaian instruktur KSR PMI Kota Malang.')])
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: C.greenBg.withValues(alpha: .5), borderRadius: BorderRadius.circular(12)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.check_circle, size: 20, color: C.green),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx(k.$1, size: 12, w: FontWeight.w800), tx(k.$2, size: 11, color: C.muted, height: 1.4)])),
                    ]),
                  ),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.support_agent, size: 20, color: C.primary), const SizedBox(width: 8), Expanded(child: tx('Penanggung Jawab Kegiatan', size: 14, w: FontWeight.w800)), Icon(Icons.circle, size: 8, color: C.green), tx(' Aktif', size: 11, w: FontWeight.w700, color: C.green)]),
                const SizedBox(height: 10),
                for (final p in const [('RH', 'Raudlatul Hakiki Fadila, S.Pd', 'Pembina Ekstrakurikuler PMR Wira', Icons.phone_outlined, C.primary), ('AF', 'Ahmad Fauzi (Kelas XII TKJ)', 'Ketua Panitia Pelaksana Diklat XXIV', Icons.chat_outlined, C.green)])
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      CircleAvatar(radius: 20, backgroundColor: p.$5 == C.primary ? C.soft : C.amberBg, child: tx(p.$1, size: 13, w: FontWeight.w800, color: p.$5 == C.primary ? C.primary : C.amber)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx(p.$2, size: 12.5, w: FontWeight.w800), tx(p.$3, size: 10.5, color: C.muted)])),
                      CircleAvatar(radius: 17, backgroundColor: p.$5 == C.primary ? C.soft : C.greenBg, child: Icon(p.$4, size: 16, color: p.$5)),
                    ]),
                  ),
              ]),
            ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x141D4ED8), blurRadius: 16, offset: Offset(0, -4))]),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              PrimaryButton('Konfirmasi Kehadiran Diklat', icon: Icons.how_to_reg_outlined, trailingIcon: false),
              const SizedBox(height: 8),
              SoftButton('Unduh Surat Izin Orang Tua (PDF)', icon: Icons.download_outlined, bg: const Color(0xFFF1F4FC)),
            ]),
          ),
        ),
      ]),
    );
  }
}
