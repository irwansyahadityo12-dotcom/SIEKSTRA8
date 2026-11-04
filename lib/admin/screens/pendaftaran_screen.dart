import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PendaftaranScreen extends StatefulWidget {
  const PendaftaranScreen({super.key});
  @override
  State<PendaftaranScreen> createState() => _PendaftaranScreenState();
}

class _PendaftaranScreenState extends State<PendaftaranScreen> {
  int accepted = 142, waiting = 18;
  final items = <Map<String, Object>>[
    {'ini': 'MR', 'name': 'Muhammad Rizky Pratama', 'cls': 'X RPL 2 • NISN: 0078129381', 'ekskul': 'RPL Club & Cyber Security', 'quota': 'Sisa Kuota: 4 / 60 kursi', 'type': 0},
    {'ini': 'SN', 'name': 'Siti Nurhaliza', 'cls': 'X DKV 1 • NISN: 0079341201', 'ekskul': 'Paskibra SATYA BHAKTI', 'quota': 'Sisa Kuota: 12 / 50 kursi', 'type': 1},
    {'ini': 'DA', 'name': 'Dimas Arya Kusuma', 'cls': 'X TKJ 3 • NISN: 0081029415', 'ekskul': 'Futsal SMKN 8', 'quota': 'Sisa 1 Kursi Terakhir!', 'type': 2},
  ];

  void decide(int i, bool ok) {
    final n = items[i]['name'] as String;
    setState(() {
      items.removeAt(i);
      waiting--;
      if (ok) accepted++;
    });
    toast(context, '$n ${ok ? 'diterima' : 'ditolak'}');
  }

  @override
  Widget build(BuildContext context) {
    return AdminScreen(children: [
      SCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Pill('T.A. 2024/2025 • Gelombang 1 Ganjil', Color(0xFFDDE4FB), C.ink, dot: true)),
            const SizedBox(width: 8),
            Btn('ACC Masal', icon: Icons.done_all, h: 48),
          ]),
          const SizedBox(height: 10),
          const Text('Verifikasi Pendaftaran', style: T.h1),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _s('Menunggu', '$waiting', 'Perlu Ditinjau', C.ink, C.muted)),
            const SizedBox(width: 8),
            Expanded(child: _s('Diterima', '$accepted', 'Kouta Terisi', C.primary, C.primary)),
            const SizedBox(width: 8),
            Expanded(child: _s('Cadangan', '6', 'Daftar Tunggu', C.ink, C.muted)),
          ]),
        ]),
      ),
      const SearchBox('Cari nama, NISN, atau kelas...', filter: true),
      SegTabs(['Menunggu ACC ($waiting)', 'Sudah Diproses', 'Daftar Tunggu']),
      const Chips(['Semua (18)', 'RPL Club (7)', 'Futsal (5)', 'Paskibra (4)']),
      for (var i = 0; i < items.length; i++) _card(i),
      if (items.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Semua pendaftaran di layar ini sudah diproses 🎉', style: T.body))),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFEEF1F7), borderRadius: BorderRadius.circular(20)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CircleAvatar(radius: 26, backgroundColor: Color(0xFFDDE2EE), child: Icon(Icons.smart_toy_outlined, color: C.ink)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Otomasi Notifikasi WhatsApp', style: T.h2),
            SizedBox(height: 4),
            Text('Pemberitahuan hasil verifikasi pendaftaran otomatis diteruskan ke nomor WhatsApp siswa & wali murid melalui bot resmi SMKN 8 Malang.', style: T.body),
          ])),
        ]),
      ),
    ]);
  }

  Widget _s(String l, String v, String s, Color vc, Color dot) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(l, style: T.body.copyWith(fontWeight: FontWeight.w600, color: C.ink))), CircleAvatar(radius: 4, backgroundColor: dot)]),
          const SizedBox(height: 4),
          Text(v, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: vc)),
          Text(s, style: T.body.copyWith(fontSize: 12)),
        ]),
      );

  Widget _card(int i) {
    final m = items[i];
    final type = m['type'] as int;
    final last = type == 2;
    return SCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Photo(icon: Icons.person, w: 80, h: 80, bg: [const Color(0xFFD6E0F5), const Color(0xFFE0E7FF), const Color(0xFFCFE8D8)][type]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m['name'] as String, style: T.h2.copyWith(fontSize: 19)), Text(m['cls'] as String, style: T.body.copyWith(fontSize: 14))])),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 6, children: [
          Pill(m['ekskul'] as String, C.soft, C.ink, icon: Icons.terminal),
          last ? Pill(m['quota'] as String, const Color(0xFF0E7490), Colors.white, icon: Icons.warning_amber_rounded) : Pill(m['quota'] as String, C.soft, C.primary, icon: Icons.groups_outlined),
        ]),
        const SizedBox(height: 10),
        Panel(
          child: type == 0
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Row(children: [Icon(Icons.description_outlined, size: 18, color: C.primary), SizedBox(width: 6), Text('Form Ortu: ', style: T.body), Text('Ada (PDF)', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)), Spacer(), Icon(Icons.bar_chart, size: 18, color: C.muted), SizedBox(width: 6), Text('Rapor: 89.4', style: T.title)]),
                  SizedBox(height: 8),
                  Text('Fokus Minat: Pengembangan Web & Capture The Flag', style: T.title),
                ])
              : type == 1
                  ? Row(children: const [Icon(Icons.verified_outlined, size: 18, color: C.primary), SizedBox(width: 6), Text('Surat Sehat: ', style: T.body), Text('Valid', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)), Spacer(), Icon(Icons.height, size: 18, color: C.muted), SizedBox(width: 6), Text('Tinggi: 168 cm', style: T.title)])
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Row(children: [Icon(Icons.flag_outlined, size: 18, color: C.primary), SizedBox(width: 6), Text('Rekomendasi Pembina: ', style: T.body), Expanded(child: Text('Ya (Lolos Seleksi Fisik)', textAlign: TextAlign.right, style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)))]),
                      SizedBox(height: 6),
                      Text('* Catatan Pelatih: Memiliki rekam jejak turnamen O2SN tingkat kota Malang.', style: TextStyle(fontStyle: FontStyle.italic, color: C.ink)),
                    ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(flex: 2, child: Btn.danger('Tolak', icon: Icons.close, expand: true, h: 52, onTap: () => decide(i, false))),
          const SizedBox(width: 8),
          Expanded(flex: 4, child: Btn('Terima Siswa', icon: Icons.check_circle_outline, expand: true, h: 52, onTap: () => decide(i, true))),
        ]),
      ]),
    );
  }
}
