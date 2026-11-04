import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AkunPembinaScreen extends StatefulWidget {
  const AkunPembinaScreen({super.key});
  @override
  State<AkunPembinaScreen> createState() => _State();
}

class _State extends State<AkunPembinaScreen> {
  // nama, id, username, cabang, jenis, aktif
  final data = <List<Object>>[
    ['Drs. Hj. Meita Juwita, M.Pd', 'NIP: 19780412 200312 2 004', 'meita.pembina@smkn8malang.', 'PMR Wira Unit 8', 'ASN Guru', true],
    ['Ahmad Fauzi, S.Kom', 'NIP: 19850915 201001 1 012', 'ahmad.fauzi', 'RPL Club & Cyber Sec', 'ASN Guru', true],
    ['Dedi Wahyudi, S.Pd', 'NIP: 19890214 201402 1 003', 'dedi.wahyudi', 'Futsal SMKN 8', 'ASN Guru', true],
    ['Hendra Gunawan, S.Pd', 'ID Mitra: PEL-2023–019', 'hendra.coach', 'Paskibra SATYA BHAKTI', 'Pelatih Luar', false],
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      back: 'Kembali ke Sistem & Akun',
      title: 'Kelola Akun Pembina & Pelatih',
      subtitle: 'Manajemen hak akses resmi, NIP/ID kerja, dan distribusi pembina cabang ekstrakurikuler SMKN 8 Malang.',
      trailing: const Pill('T.A. 2024/2025 Ganjil', C.soft, C.primary, dot: true),
      children: [
        Row(children: const [
          Expanded(child: StatBox('Pembina ASN', '34 Guru', '100% Valid', icon: Icons.school_outlined, subColor: C.primary)),
          SizedBox(width: 8),
          Expanded(child: StatBox('Pelatih Luar', '18 Mitra', 'Kontrak Aktif', icon: Icons.sports, iconBg: C.amberSoft, iconFg: C.amber, subColor: C.amber)),
          SizedBox(width: 8),
          Expanded(child: StatBox('Akun Aktif', '48 / 52', '4 Nonaktif', icon: Icons.verified_user_outlined, subColor: C.orange)),
        ]),
        const SizedBox(height: 14),
        Btn('+ Tambah Akun Pembina / Pelatih Baru', icon: Icons.person_add_alt, expand: true, h: 56),
        const SizedBox(height: 14),
        const SearchBox('Cari nama, NIP, atau username...', filter: true),
        const Chips(['Semua (52)', 'Aktif (48)', 'Nonaktif (4)', 'Pembina ASN (34)', 'Pelatih Luar (18)']),
        for (var i = 0; i < data.length; i++) _card(i),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.line)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, color: C.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Kebijakan Akun Pembina SMKN 8 Malang', style: T.title),
              const SizedBox(height: 4),
              RichText(text: const TextSpan(style: TextStyle(fontSize: 14, color: C.muted, height: 1.4), children: [TextSpan(text: 'Reset password akan mengembalikan kredensial ke default sekolah ('), TextSpan(text: 'smkn8malang2024', style: TextStyle(fontFamily: 'monospace', color: C.primary, fontWeight: FontWeight.w700)), TextSpan(text: '). Pembina diwajibkan mengganti sandi pada login sesi berikutnya.')])),
            ])),
          ]),
        ),
      ],
    );
  }

  Widget _card(int i) {
    final d = data[i];
    final aktif = d[5] as bool;
    final luar = d[4] == 'Pelatih Luar';
    return SCard(
      child: Column(children: [
        Row(children: [
          Stack(children: [
            const Photo(icon: Icons.person, w: 64, h: 64),
            Positioned(right: 0, bottom: 0, child: Container(width: 16, height: 16, decoration: BoxDecoration(color: aktif ? C.primary : C.orange, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d[0] as String, style: T.h2.copyWith(fontSize: 17)), Text(d[1] as String, style: T.body.copyWith(fontSize: 14))])),
          Pill(aktif ? 'Aktif' : 'Nonaktif', aktif ? C.soft : C.orangeSoft, aktif ? C.primary : C.orange, dot: true),
        ]),
        const SizedBox(height: 12),
        Panel(padding: const EdgeInsets.all(12), child: Column(children: [
          Row(children: [const Icon(Icons.person_outline, size: 18, color: C.primary), const SizedBox(width: 8), const Text('Username:', style: T.body), Expanded(child: Text(d[2] as String, textAlign: TextAlign.right, style: T.title, overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.emoji_events_outlined, size: 18, color: C.amber), const SizedBox(width: 8), const Text('Cabang Tugas:', style: T.body), const Spacer(), Pill(d[3] as String, Colors.white, C.ink), const SizedBox(width: 6), Pill(d[4] as String, luar ? C.amberSoft : C.soft, luar ? C.amber : C.primary)]),
        ])),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Btn.gray('Edit', icon: Icons.edit_outlined, expand: true, h: 48)),
          const SizedBox(width: 8),
          Expanded(child: Btn.gray('Reset Pass', icon: Icons.lock_reset, expand: true, h: 48, onTap: () => toast(context, 'Password direset ke default'))),
          const SizedBox(width: 8),
          Expanded(
            child: aktif
                ? Btn.warn('Nonaktifkan', icon: Icons.person_off_outlined, expand: true, h: 48, onTap: () => setState(() => data[i][5] = false))
                : Btn.soft('Aktifkan', icon: Icons.how_to_reg_outlined, expand: true, h: 48, onTap: () => setState(() => data[i][5] = true)),
          ),
        ]),
      ]),
    );
  }
}
