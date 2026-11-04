import 'package:flutter/material.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'ekskul_detail_screen.dart';
import 'registration_form_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> goTab;
  const HomeScreen({super.key, required this.goTab});

  Widget _stat(IconData icon, Color c, Color bg, String big, String label, {bool text = false}) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(children: [
            IconBox(icon, color: c, bg: bg, size: 36),
            const SizedBox(height: 8),
            tx(big, size: text ? 16 : 22, w: FontWeight.w800, color: text ? c : C.text),
            tx(label, size: 10.5, color: C.muted, align: TextAlign.center),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final popular = [ekskulList[0], ekskulList[4], ekskulList[5]];
    return Scaffold(
      appBar: mainAppBar(),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tx('Halo, Dimas Ibrahim 👋', size: 20, w: FontWeight.w800),
              tx('XII RPL D • NIS 212089 • SMKN 8 Malang', size: 11.5, color: C.muted),
            ]),
          ),
          Pill('Ganjil 2024/2025', icon: Icons.circle, size: 10),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _stat(Icons.workspace_premium_outlined, C.primary, C.soft, '2', 'Ekskul Diikuti'),
          const SizedBox(width: 8),
          _stat(Icons.event_note_outlined, C.amber, C.amberBg, '3', 'Jadwal Pekan Ini'),
          const SizedBox(width: 8),
          _stat(Icons.check_circle_outline, C.green, C.greenBg, 'Aktif', 'Status Siswa', text: true),
        ]),
        AppCard(
          color: const Color(0xFFFDECEC),
          borderColor: const Color(0xFFF7C9C9),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBox(Icons.campaign_outlined, color: Colors.white, bg: C.red, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Pill('PENTING', fg: Colors.white, bg: C.red, size: 9),
                  const SizedBox(width: 6),
                  Expanded(child: tx('PENGUMUMAN GLADI BERSIH', size: 12, w: FontWeight.w800)),
                ]),
                const SizedBox(height: 6),
                tx('Wajib membawa seragam lengkap & slayer PMR untuk simulasi gabungan & donor darah pekan ini di Lapangan Utama.', size: 11.5, color: C.muted, height: 1.4),
              ]),
            ),
            Icon(Icons.close, size: 16, color: C.muted),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(gradient: kBlueGradient, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Pill('HARI INI', fg: C.brown, bg: Color(0xFFFFD27D), size: 9.5),
              const SizedBox(width: 8),
              Icon(Icons.schedule, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              tx('15:30 – 17:00 WIB', size: 11.5, w: FontWeight.w700, color: Colors.white),
              const Spacer(),
              CircleAvatar(radius: 14, backgroundColor: Colors.white24, child: Icon(Icons.chevron_right, color: Colors.white, size: 18)),
            ]),
            const SizedBox(height: 14),
            tx('Robotik Club • Praktik Mikrokontroler', size: 17, w: FontWeight.w800, color: Colors.white),
            const SizedBox(height: 4),
            tx('Pemrograman ESP32 & Perakitan Sensor IoT Line Follower', size: 12, color: Colors.white70),
            const SizedBox(height: 14),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 15, color: Colors.white),
              const SizedBox(width: 4),
              Expanded(child: tx('Lab IoT Gedung C, Lantai 2', size: 11.5, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                child: tx('Presensi Dibuka', size: 10.5, w: FontWeight.w700, color: Colors.white),
              ),
            ]),
          ]),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: 'Cari ekskul (mis. PMR, Robotik, Futsal)...',
            hintStyle: const TextStyle(fontSize: 12.5, color: C.muted),
            prefixIcon: const Icon(Icons.search, color: C.muted),
            suffixIcon: Container(margin: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)), child: const Icon(Icons.tune, size: 18)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
          ),
        ),
        const SizedBox(height: 10),
        SectionTitle('Prestasi & Juara Terbaru', action: 'Lihat Semua', bar: true),
        SizedBox(
          height: 96,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            _prestasi('JUARA 1 JATIM', '2024', 'PP & Tandu Darurat Jatim 2024', 'PMR Wira SMKN 8 Malang', C.amberBg, C.amber),
            _prestasi('JUARA 1 WILAYAH', '2024', 'LKS Web Technology', 'Robotik & IT Club SMKN 8', C.soft, C.primary),
          ]),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2B4FE0), Color(0xFF5B3FD6)]), borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Pill('Rekomendasi Jurusan RPL', fg: Colors.white, bg: Colors.white24, icon: Icons.auto_awesome, size: 10),
            const SizedBox(height: 10),
            tx('Spesial Bidang IT & Kreatif SMKN 8', size: 17, w: FontWeight.w800, color: Colors.white),
            const SizedBox(height: 6),
            tx('Robotik & Multimedia Club resmi membuka gelombang 2! Asah skill coding, IoT, dan digital production sekarang.', size: 12, color: Colors.white70, height: 1.4),
            const SizedBox(height: 14),
            Row(children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationFormScreen(ekskul: ekskulList[0]))),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB82E), foregroundColor: C.text, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Text('Daftar Gelombang 2', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                label: const Icon(Icons.arrow_forward, size: 16),
              ),
              const Spacer(),
              tx('Sisa 6 hari lagi', size: 11, color: Colors.white70),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        SectionTitle('Kategori Bidang', action: 'Semua'),
        FilterChips(['Semua Bidang', 'Vokasi & IT', 'Kemanusiaan', 'Olahraga']),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: tx('Ekskul Populer', size: 16, w: FontWeight.w800)),
          Pill('Top 3', fg: C.brown, bg: C.amberBg, size: 10),
          const SizedBox(width: 8),
          GestureDetector(onTap: () => goTab(1), child: tx('Lihat 24 Lainnya', size: 12, w: FontWeight.w700, color: C.primary)),
        ]),
        const SizedBox(height: 10),
        for (final e in popular) _PopularCard(e),
        AppCard(
          color: const Color(0xFFEAF0FF),
          child: Row(children: [
            IconBox(Icons.headset_mic_outlined, color: Colors.white, bg: C.primary, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                tx('Butuh Bantuan Pendaftaran?', size: 13, w: FontWeight.w800),
                tx('Hubungi Pembina OSIS atau Kesiswaan di Ruang Ekstra SMKN 8.', size: 11.5, color: C.muted),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _prestasi(String tag, String year, String title, String sub, Color bg, Color fg) => Container(
        width: 260,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: fg.withValues(alpha: .25))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Pill(tag, fg: fg, bg: Colors.white, size: 9), const Spacer(), tx(year, size: 11, color: C.muted)]),
          const SizedBox(height: 8),
          tx(title, size: 13, w: FontWeight.w800, lines: 1),
          tx(sub, size: 11, color: C.muted, lines: 1),
        ]),
      );
}

class _PopularCard extends StatelessWidget {
  final Ekskul e;
  const _PopularCard(this.e);
  @override
  Widget build(BuildContext context) {
    final full = e.full;
    final barColor = e.color == C.brown ? C.red : e.color;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(e.icon, color: e.color, bg: e.colorBg, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Pill(e.category.toUpperCase().split(' & ').first, fg: e.color, bg: e.colorBg, size: 9),
                const SizedBox(width: 6),
                Icon(Icons.star, size: 14, color: C.amber),
                tx(' 4.9', size: 11.5, w: FontWeight.w800, color: C.amber),
              ]),
              const SizedBox(height: 4),
              tx(e.name, size: 15, w: FontWeight.w800, lines: 1),
              tx(e.desc, size: 11, color: C.muted, lines: 1),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.calendar_today_outlined, size: 13, color: C.muted),
          const SizedBox(width: 6),
          tx(e.schedule, size: 11.5, color: C.muted),
          const Spacer(),
          Icon(full ? Icons.lock_outline : Icons.group_outlined, size: 14, color: full ? C.red : C.primary),
          const SizedBox(width: 4),
          tx('${e.filled} / ${e.quota} Siswa${full ? ' (Penuh)' : ''}', size: 11.5, w: FontWeight.w700, color: full ? C.red : C.primary),
        ]),
        const SizedBox(height: 8),
        QuotaBar(e.ratio, color: barColor),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            flex: 3,
            child: full
                ? SoftButton('Waiting List', icon: Icons.schedule, bg: const Color(0xFFEFF1F7), fg: C.muted)
                : SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationFormScreen(ekskul: e))),
                      style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('Daftar Sekarang', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: SoftButton('Detail', bg: const Color(0xFFEFF1F7), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EkskulDetailScreen(ekskul: e)))),
          ),
        ]),
      ]),
    );
  }
}
