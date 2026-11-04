import 'package:flutter/material.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'registration_form_screen.dart';

/// Detail ekskul. Konten rinci mengikuti desain "Detail Ekskul PMR".
class EkskulDetailScreen extends StatelessWidget {
  final Ekskul ekskul;
  const EkskulDetailScreen({super.key, required this.ekskul});

  Widget _prog(IconData icon, Color c, Color bg, String title, String desc) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg.withValues(alpha: .55), borderRadius: BorderRadius.circular(14), border: Border.all(color: bg)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(icon, color: c, bg: bg, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tx(title, size: 12.5, w: FontWeight.w800),
              const SizedBox(height: 3),
              tx(desc, size: 11, color: C.muted, height: 1.4),
            ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final e = ekskul;
    final sisa = e.quota == 0 ? 0 : e.quota - e.filled;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        titleSpacing: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: tx('Detail Ekskul', size: 17, w: FontWeight.w800),
        actions: [Padding(padding: const EdgeInsets.only(right: 14), child: AvatarDot())],
      ),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            AppCard(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                PhotoBox(height: 200, colors: e.photo, icon: e.icon, overlays: [
                  Overlay1(Alignment.topLeft, Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(e.icon, size: 14, color: e.color),
                        const SizedBox(width: 4),
                        tx(e.category, size: 11, w: FontWeight.w700),
                      ]),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: C.amber, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.star, size: 14, color: Colors.white),
                        tx(' 4.9 (145 Ulasan)', size: 11, w: FontWeight.w700, color: Colors.white),
                      ]),
                    ),
                  ])),
                  Overlay1(Alignment.bottomLeft, Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: .55), borderRadius: BorderRadius.circular(10)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      tx('PRESTASI UNGGULAN', size: 10, w: FontWeight.w800, color: const Color(0xFFFFD27D)),
                      tx('Juara 1 Lomba Pertolongan Pertama (PP) & Tandu Darurat Tingkat Jawa Timur 2024', size: 11, color: Colors.white),
                    ]),
                  )),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      tx(e.name.toUpperCase(), size: 18, w: FontWeight.w800),
                      tx('SMKN 8 Malang • ${e.category}', size: 12, color: C.muted),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: C.soft, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.bookmark_border, color: C.primary),
                  ),
                ]),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.groups, size: 20, color: C.primary),
                  const SizedBox(width: 8),
                  Expanded(child: tx('Kuota Peserta Didik', size: 13.5, w: FontWeight.w800)),
                  Pill(e.quota == 0 ? 'Tanpa Kuota' : 'Sisa $sisa Kursi', fg: C.red, bg: C.redBg, size: 10.5),
                ]),
                const SizedBox(height: 10),
                QuotaBar(e.ratio, color: C.amber, height: 9),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: tx('${e.filled} Siswa Terdaftar', size: 11, color: C.muted)),
                  tx(e.quota == 0 ? '-' : 'Target ${e.quota} Siswa', size: 11, w: FontWeight.w800),
                ]),
              ]),
            ),
            AppCard(
              child: Row(children: [
                CircleAvatar(radius: 24, backgroundColor: C.soft, child: Icon(Icons.person, color: C.primary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    tx('PEMBINA EKSKUL', size: 10, w: FontWeight.w700, color: C.muted),
                    tx(e.coach, size: 13.5, w: FontWeight.w800),
                    tx('NIP. 198604122010011014', size: 11, color: C.primary),
                  ]),
                ),
                IconBox(Icons.chat_bubble_outline, size: 40),
              ]),
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    IconBox(Icons.calendar_today_outlined, size: 36),
                    const SizedBox(height: 10),
                    tx('JADWAL LATIHAN RUTIN', size: 9.5, color: C.muted, w: FontWeight.w700),
                    const SizedBox(height: 4),
                    tx('${e.schedule.split(' & ').first} 15:30 - 17:30', size: 11.5, w: FontWeight.w800),
                    tx('${e.schedule.split(' & ').last} 08:00 - 11:00', size: 11.5, w: FontWeight.w800),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    IconBox(Icons.account_balance_wallet_outlined, size: 36),
                    const SizedBox(height: 10),
                    tx('BIAYA PELATIHAN', size: 9.5, color: C.muted, w: FontWeight.w700),
                    const SizedBox(height: 4),
                    tx('GRATIS', size: 16, w: FontWeight.w800, color: C.primary),
                    tx('Didanai BOS & Sekolah', size: 10.5, color: C.muted),
                  ]),
                ),
              ),
            ]),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconBox(Icons.place_outlined, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      tx('RUANG PELAKSANAAN / MARKAS', size: 9.5, w: FontWeight.w700, color: C.muted),
                      tx('${e.place} & Lapangan Upacara', size: 13, w: FontWeight.w800),
                      tx('SMKN 8 Malang, Jl. Teluk Pacitan, Arjosari, Malang', size: 11, color: C.muted),
                    ]),
                  ),
                ]),
                const SizedBox(height: 12),
                Container(
                  height: 90,
                  decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
                  child: Center(child: Icon(Icons.map_outlined, color: C.muted)),
                ),
              ]),
            ),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.menu_book_outlined, size: 20, color: C.primary), const SizedBox(width: 8), tx('Program & Kurikulum Praktis', size: 14, w: FontWeight.w800)]),
                const SizedBox(height: 10),
                tx('Klub dirancang langsung untuk menanamkan kecakapan pertolongan medis darurat, kesiapsiagaan bencana terpadu, dan keterampilan kepalangmerahan aplikatif.', size: 11.5, color: C.muted, height: 1.5),
                const SizedBox(height: 12),
                _prog(Icons.add, C.primary, C.soft, 'Pertolongan Pertama (PP) & Evakuasi Tandu', 'Penerapan balut-bidai modern, penanganan fraktur & perdarahan, CPR/RJP darurat, dan evakuasi tandu cepat.'),
                _prog(Icons.favorite, C.purple, C.soft, 'Remaja Sehat & Donor Darah (RSPS)', 'Penyuluhan kesehatan remaja, pola hidup bersih & sehat, serta koordinasi donor darah sukarela.'),
                _prog(Icons.warning_amber_rounded, C.amber, C.amberBg, 'Bimbingan Siaga Bencana & Lomba', 'Pelatihan intensif manajemen posko bencana sekolah dan simulasi kompetisi pertolongan pertama.'),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.task_alt, size: 20, color: C.primary), const SizedBox(width: 8), tx('Syarat Pendaftaran', size: 14, w: FontWeight.w800)]),
                const SizedBox(height: 10),
                for (final s in const [
                  'Siswa/i aktif tingkat X atau XI SMKN 8 Malang semua jurusan.',
                  'Sehat jasmani dan rohani serta siap bertugas dalam piket pertolongan UKS.',
                  'Berkomitmen mengikuti seluruh jadwal kegiatan rutin mingguan secara disiplin.',
                  'Mendapatkan izin tertulis resmi dari orang tua / wali murid.',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: C.soft, shape: BoxShape.circle), child: Icon(Icons.check, size: 13, color: C.primary)),
                      const SizedBox(width: 10),
                      Expanded(child: tx(s, size: 12, color: C.text, height: 1.4)),
                    ]),
                  ),
              ]),
            ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x141D4ED8), blurRadius: 16, offset: Offset(0, -4))]),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Icon(Icons.timer_outlined, size: 13, color: C.muted),
                const SizedBox(width: 4),
                Expanded(child: tx('Pendaftaran ditutup 30 Sept', size: 11, color: C.muted)),
                tx('100% Bebas Biaya', size: 11, w: FontWeight.w800, color: C.green),
              ]),
              const SizedBox(height: 10),
              PrimaryButton('Daftar Sekarang (Gratis)',
                  icon: Icons.how_to_reg_outlined,
                  trailingIcon: false,
                  color: C.brown,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationFormScreen(ekskul: e)))),
            ]),
          ),
        ),
      ]),
    );
  }
}
