import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProposalDetailScreen extends StatefulWidget {
  const ProposalDetailScreen({super.key});
  @override
  State<ProposalDetailScreen> createState() => _State();
}

class _State extends State<ProposalDetailScreen> {
  int tab = 0;
  bool notify = true;

  @override
  Widget build(BuildContext context) {
    return AdminScreen(back: 'Kembali ke Daftar', children: [
      Row(children: [
        const Pill('#PROP-8-092', Color(0xFFEEF1F7), C.muted),
        const SizedBox(width: 8),
        const Icon(Icons.calendar_today_outlined, size: 14, color: C.muted),
        const SizedBox(width: 4),
        const Expanded(child: Text('20 Nov 2024 • 09:30 WIB', style: T.body, overflow: TextOverflow.ellipsis)),
        const Pill('Menunggu Kesiswaan', C.amberSoft, C.amber, dot: true),
      ]),
      const SizedBox(height: 12),
      SCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          Container(height: 5, decoration: const BoxDecoration(color: C.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(20)))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Wrap(spacing: 8, runSpacing: 6, children: const [Pill('Lomba Kejuruan Nasional', C.soft, C.primary), Pill('RPL Club & Cyber Sec', Color(0xFFD9F1FB), Color(0xFF0369A1))])),
                const IconBox(Icons.verified_user_outlined, size: 44),
              ]),
              const SizedBox(height: 12),
              const Text('Keikutsertaan Lomba Kompetensi Siswa (LKS) Cyber Security Tingkat Provinsi Jawa Timur 2024', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.25)),
              const SizedBox(height: 12),
              Row(children: const [
                Expanded(child: Panel(child: Row(children: [Icon(Icons.place_outlined, color: C.primary), SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Lokasi Acara', style: T.body), Text('POLINEMA', style: T.title)]))]))),
                SizedBox(width: 10),
                Expanded(child: Panel(child: Row(children: [Icon(Icons.event_repeat, color: C.primary), SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Durasi Lomba', style: T.body), Text('24–26 Nov', style: T.title)]))]))),
              ]),
              const SizedBox(height: 10),
              Panel(child: Row(children: [
                const Photo(icon: Icons.person, w: 52, h: 52),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Bpk. Ahmad Fauzi, S.Kom', style: T.title), Text('Pembina Ekstra • NIP 1985...', style: T.body)])),
                Btn.soft('WhatsApp', icon: Icons.chat_outlined, h: 40),
              ])),
            ]),
          ),
        ]),
      ),
      SCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.account_tree_outlined, color: C.primary),
            const SizedBox(width: 10),
            const Expanded(child: Text('Alur Persetujuan & Disposisi', style: T.h2)),
            const Pill('Tahap 2 dari 5', C.soft, C.primary),
          ]),
          const SizedBox(height: 14),
          _step(Icons.check_circle, C.green, 'Pengajuan Pembina Ekstra', 'Bpk. Ahmad Fauzi • 18 Nov, 10:15 WIB', tag: 'SELESAI', tagBg: C.greenSoft, tagFg: C.green),
          _step(Icons.manage_accounts_outlined, C.primary, 'Verifikasi Admin Kesiswaan', 'Evaluasi kelayakan siswa, dispensasi, & RAB', tag: 'TINDAKAN ANDA', tagBg: C.amberSoft, tagFg: C.amber, active: true),
          _step(Icons.hourglass_empty, C.muted, 'Disposisi Wakasek Kesiswaan & Sarpras', 'Penyediaan fasilitas & rekomendasi teknis'),
          _step(Icons.description_outlined, C.muted, 'Persetujuan KS & Terbit SK Dispensasi', 'Tanda tangan digital Kepala Sekolah SMKN 8'),
          _step(Icons.payments_outlined, C.muted, 'Pencairan Dana BOS / Komite', 'Verifikasi kwitansi oleh Bendahara Sekolah', last: true),
        ]),
      ),
      SegTabs(const ['RAB Dana', 'Delegasi (6)', 'Berkas SOP'], onChanged: (i) => setState(() => tab = i)),
      if (tab == 0) ..._rab() else if (tab == 1) _delegasi() else _berkas(),
      SCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.edit_note_rounded, color: C.primary, size: 30),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Catatan Verifikasi Kesiswaan', style: T.h2), Text('Rekomendasi yang akan diteruskan ke Wakasek & Kepala Sekolah', style: T.body)])),
          ]),
          const SizedBox(height: 12),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Tuliskan catatan khusus atau arahan teknis...\nContoh: 'Disetujui. Transportasi delegasi wajib berkoordinasi dengan Sarpras untuk pemakaian minibus sekolah.'",
              hintStyle: const TextStyle(color: C.muted, fontSize: 14),
              filled: true,
              fillColor: C.field,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: const [
            Text('Template Cepat:', style: T.body),
            Pill('+ Rekomendasi Terbit SK', C.field, C.ink),
            Pill('+ Armada Sekolah', C.field, C.ink),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(value: notify, onChanged: (v) => setState(() => notify = v ?? false), activeColor: C.primary),
            const Expanded(child: Padding(padding: EdgeInsets.only(top: 12), child: Text('Kirim notifikasi otomatis WhatsApp ke Pembina & Delegasi Siswa', style: TextStyle(fontSize: 14)))),
          ]),
          const SizedBox(height: 8),
          Btn('Setujui & Teruskan ke Kepala Sekolah', icon: Icons.check_circle_outline, expand: true, h: 56, onTap: () => toast(context, 'Proposal diteruskan ke Kepala Sekolah')),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Btn('Minta Revisi', icon: Icons.edit_note, bg: C.amberSoft, fg: C.amber, expand: true, h: 50)),
            const SizedBox(width: 8),
            Expanded(child: Btn.danger('Tolak Proposal', icon: Icons.cancel_outlined, expand: true, h: 50)),
          ]),
        ]),
      ),
    ]);
  }

  Widget _step(IconData ic, Color c, String t, String s, {String? tag, Color? tagBg, Color? tagFg, bool active = false, bool last = false}) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: active ? C.soft : (c == C.green ? C.greenSoft : const Color(0xFFEEF1F7)), shape: BoxShape.circle, border: active ? Border.all(color: C.primary, width: 2) : null), child: Icon(ic, size: 18, color: c)),
            if (!last) Expanded(child: Container(width: 2, color: C.line)),
          ]),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: active ? C.primary : (c == C.muted ? C.muted : C.ink))), if (tag != null) Pill(tag, tagBg!, tagFg!)]),
                Text(s, style: T.body),
              ]),
            ),
          ),
        ]),
      );

  List<Widget> _rab() => [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Row(children: [Expanded(child: Text('TOTAL ESTIMASI USULAN', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.8))), Icon(Icons.monetization_on_outlined, color: Colors.white70)]),
            SizedBox(height: 6),
            Text('Rp 4.500.000', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
            Divider(color: Colors.white24, height: 22),
            Wrap(spacing: 16, children: [Text('● BOS Kinerja: Rp 3.500.000', style: TextStyle(color: Colors.white, fontSize: 12.5)), Text('● Kas RPL: Rp 1.000.000', style: TextStyle(color: Colors.white, fontSize: 12.5))]),
          ]),
        ),
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Expanded(child: Text('Rincian Komponen Biaya', style: T.h2)), Text('3 Pos Pengeluaran', style: T.body)]),
          const SizedBox(height: 12),
          _rp(Icons.how_to_reg_outlined, 'Pendaftaran Lomba 3 Tim', '3 Tim x Rp 500.000 @ POLINEMA', 'Rp 1.500.000'),
          _rp(Icons.restaurant, 'Konsumsi & Uang Saku Siswa', '6 Siswa x 3 Hari @ Rp 100.000', 'Rp 1.800.000'),
          _rp(Icons.hotel_outlined, 'Akomodasi & BBM Pembina', 'Transportasi operasional & stand by 3 hari', 'Rp 1.200.000'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [Icon(Icons.info_outline, color: C.primary), SizedBox(width: 10), Expanded(child: Text('Standar satuan biaya honorarium dan konsumsi sudah sesuai dengan ketentuan Juknis BOS Kinerja SMK Jawa Timur 2024.', style: T.body))]),
          ),
        ])),
      ];

  Widget _rp(IconData i, String t, String s, String v) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          IconBox(i, bg: const Color(0xFFDDE7FF), size: 44),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: T.title), Text(s, style: T.body.copyWith(fontSize: 12))])),
          const SizedBox(width: 8),
          Text(v, textAlign: TextAlign.right, style: T.title),
        ]),
      );

  Widget _delegasi() => SCard(child: Column(children: [
        for (final d in const [['MR', 'M. Rizky Pratama', 'X RPL 2'], ['DA', 'Dimas Arya Kusuma', 'X TKJ 3'], ['FR', 'Farhan Ramadhan', 'XI TKJ 2'], ['AP', 'Amelia Putri', 'X RPL 2'], ['SN', 'Siti Nurhaliza', 'X DKV 1'], ['RA', 'Rafi Alamsyah', 'XI RPL 1']])
          Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Avatar(d[0], size: 40), const SizedBox(width: 12), Expanded(child: Text(d[1], style: T.title)), Text(d[2], style: T.body)])),
      ]));

  Widget _berkas() => SCard(child: Column(children: [
        for (final f in const [['Proposal_LKS_CyberSec.pdf', '2.1 MB'], ['Surat_Undangan_POLINEMA.pdf', '640 KB'], ['SOP_Keberangkatan_Delegasi.pdf', '1.3 MB']])
          Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [const IconBox(Icons.picture_as_pdf_outlined, bg: C.redSoft, fg: C.red, size: 40), const SizedBox(width: 12), Expanded(child: Text(f[0], style: T.title.copyWith(fontSize: 14))), Text(f[1], style: T.body)])),
      ]));
}
