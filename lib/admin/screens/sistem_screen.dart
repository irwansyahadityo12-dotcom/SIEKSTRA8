import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'akun_pembina_screen.dart';
import 'data_siswa_screen.dart';
import 'prestasi_screen.dart';
import 'dispensasi_screen.dart';
import 'jadwal_screen.dart';
import 'diklat_screen.dart';

class SistemScreen extends StatefulWidget {
  const SistemScreen({super.key});
  @override
  State<SistemScreen> createState() => _State();
}

class _State extends State<SistemScreen> {
  bool batas = true, notif = true;

  @override
  Widget build(BuildContext context) {
    return AdminScreen(children: [
      SCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: const [Pill('Super Admin', C.soft, C.primary, icon: Icons.shield_outlined), Spacer(), Pill('Sistem Online', Colors.transparent, C.ink, dot: true)]),
              const SizedBox(height: 12),
              Row(children: [
                Container(width: 76, height: 76, alignment: Alignment.center, decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(18)), child: const Text('AK', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Admin Kesiswaan Utama', style: T.h2), SizedBox(height: 4), Text('🪪 NIP. 19820415 200801 1 008', style: T.body), Text('Unit Kesiswaan SMKN 8 Malang', style: T.body)])),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(color: Color(0xFFF3F5FB), borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
            child: Row(children: [
              const IconBox(Icons.event_note_outlined, size: 44),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('PERIODE AKTIF', style: T.label), Text('T.A. 2024/2025 (Ganjil)', style: T.h2)])),
              const Pill('Aktif', C.soft, C.primary),
            ]),
          ),
        ]),
      ),
      _hdr('MANAJEMEN DATA MASTER', '4 Modul'),
      _group([
        _row(Icons.manage_accounts_outlined, 'Kelola Akun Pembina & Pelatih', '34 akun terdaftar & aktif', () => push(context, const AkunPembinaScreen())),
        _row(Icons.groups_outlined, 'Kelola Data Siswa & Anggota', '1.240 siswa terdaftar ekskul', () => push(context, const DataSiswaScreen())),
        _row(Icons.calendar_month_outlined, 'Tahun Ajaran & Semester', 'Atur kalender kegiatan ekstra', null, trail: '2024/2025'),
        _row(Icons.apartment_outlined, 'Kategori & Ruangan Latihan', 'Lab Komputer, Lapangan, Aula', null),
      ]),
      _hdr('WEWENANG KESISWAAN & PRESTASI', 'SMK Pusat Keunggulan'),
      _group([
        _row(Icons.workspace_premium_outlined, 'Bank Prestasi & Kejuaraan', 'LKS SMK, O2SN, FLS2N & Umum', () => push(context, const PrestasiScreen()), badge: const Pill('84 Prestasi', C.amberSoft, C.amber), ibg: C.amberSoft, ifg: C.amber),
        _row(Icons.assignment_turned_in_outlined, 'Dispensasi & Surat Tugas', 'Penerbitan surat izin resmi tanding', () => push(context, const DispensasiScreen()), badge: const Pill('3 Baru', C.redSoft, C.red), ibg: C.greenSoft, ifg: C.green),
        _row(Icons.menu_book_outlined, 'Sertifikat SKPI Ekskul', 'Surat pendamping ijazah Kelas XII', null),
      ]),
      _hdr('AGENDA & KADERISASI', null),
      _group([
        _row(Icons.event_note_outlined, 'Kelola Jadwal Kegiatan', 'Master jadwal latihan & lomba', () => push(context, const JadwalScreen())),
        _row(Icons.school_outlined, 'Kelola Diklat & Kaderisasi', 'Pendidikan & pelatihan dasar', () => push(context, const DiklatScreen())),
      ]),
      _hdr('PENGATURAN & KONTROL SISTEM', null),
      _group([
        _toggle(Icons.timer_outlined, 'Batas Input Presensi', 'Maksimal pengunciran H+1 pukul 23:59 WIB', batas, (v) => setState(() => batas = v)),
        _toggle(Icons.notifications_none, 'Notifikasi Otomatis', 'Pengingat jadwal via WA Gateway & Email', notif, (v) => setState(() => notif = v)),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const IconBox(Icons.sync, bg: Color(0xFFEEF1F7), fg: C.ink, size: 46),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Sinkronisasi & Backup Dapodik', style: T.title), Text('Terakhir disinkron: Hari ini, 06:40 WIB', style: T.body)])),
            Btn.gray('Sinkron', h: 44, onTap: () => toast(context, 'Sinkronisasi dimulai')),
          ]),
        ),
      ]),
      _hdr('AKTIVITAS TERKINI (AUDIT LOG)', 'Semua Log'),
      SCard(child: Column(children: [
        _log(Icons.check_circle_outline, C.soft, C.primary, 'Admin Budi', ' menyetujui pengajuan proposal kegiatan PMR SMKN 8.', '10 menit yang lalu'),
        const Divider(height: 22),
        _log(Icons.timer_outlined, C.greenSoft, C.green, 'Pembina Futsal', ' memperbarui jadwal uji tanding antar-SMK.', '1 jam yang lalu'),
        const Divider(height: 22),
        _log(Icons.star_border, C.amberSoft, C.amber, 'Kesiswaan', ' memvalidasi Juara 1 LKS Web Tech Kota Malang.', '3 jam yang lalu'),
      ])),
      Btn.danger('Keluar dari Akun Admin', icon: Icons.logout, expand: true, h: 54, onTap: () => logout(context)),
      const SizedBox(height: 12),
      const Center(child: Text('SIEKSTRA–8 v2.4.0 • SMKN 8 Malang IT Infrastructure', style: T.body)),
    ]);
  }

  Widget _hdr(String t, String? a) => Padding(padding: const EdgeInsets.fromLTRB(4, 10, 4, 10), child: Row(children: [Expanded(child: Text(t, style: T.label)), if (a != null) Text(a, style: const TextStyle(color: C.primary, fontWeight: FontWeight.w800, fontSize: 13))]));

  Widget _group(List<Widget> rows) => SCard(
        padding: EdgeInsets.zero,
        child: Column(children: [for (var i = 0; i < rows.length; i++) ...[rows[i], if (i < rows.length - 1) const Divider(height: 1, indent: 14, endIndent: 14)]]),
      );

  Widget _row(IconData i, String t, String s, VoidCallback? onTap, {String? trail, Widget? badge, Color ibg = C.soft, Color ifg = C.primary}) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            IconBox(i, bg: ibg, fg: ifg, size: 46),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Text(t, style: T.title), if (badge != null) badge]), const SizedBox(height: 2), Text(s, style: T.body)])),
            if (trail != null) Padding(padding: const EdgeInsets.only(right: 4), child: Text(trail, style: const TextStyle(color: C.primary, fontWeight: FontWeight.w800))),
            const Icon(Icons.chevron_right, color: C.muted),
          ]),
        ),
      );

  Widget _toggle(IconData i, String t, String s, bool v, ValueChanged<bool> f) => Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          IconBox(i, bg: const Color(0xFFEEF1F7), fg: C.ink, size: 46),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: T.title), Text(s, style: T.body)])),
          Switch(value: v, onChanged: f, activeThumbColor: Colors.white, activeTrackColor: C.primary),
        ]),
      );

  Widget _log(IconData i, Color bg, Color fg, String who, String what, String when) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconBox(i, bg: bg, fg: fg, size: 40),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(text: TextSpan(style: const TextStyle(fontSize: 15, color: C.ink, height: 1.35), children: [TextSpan(text: who, style: const TextStyle(fontWeight: FontWeight.w800, color: C.primary)), TextSpan(text: what)])),
          const SizedBox(height: 2),
          Text(when, style: T.body),
        ])),
      ]);
}
