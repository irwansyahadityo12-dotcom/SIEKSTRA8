import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProposalDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? proposal;
  const ProposalDetailScreen({super.key, this.proposal});

  @override
  State<ProposalDetailScreen> createState() => _State();
}

class _State extends State<ProposalDetailScreen> {
  final _repository = SiekstraRepository();
  int tab = 0;
  bool notify = true;
  bool _isSubmitting = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleReview(String status, String successMsg) async {
    final p = widget.proposal;
    final rawId = p?['rawId']?.toString() ?? p?['id']?.toString() ?? '';
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(rawId);

    setState(() => _isSubmitting = true);
    if (isUuid) {
      try {
        await _repository.reviewProposal(rawId, status: status);
        if (mounted) {
          toast(context, successMsg);
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          toast(context, 'Gagal memproses proposal: $e');
          setState(() => _isSubmitting = false);
        }
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        toast(context, successMsg);
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.proposal;
    final idText = p?['id']?.toString() ?? '#PROP-8-092';
    final dateText = p?['date']?.toString() ?? '20 Nov 2024';
    final statusText = p?['status']?.toString() ?? 'Menunggu Kesiswaan';
    final titleText = p?['title']?.toString() ??
        'Keikutsertaan Lomba Kompetensi Siswa (LKS) Cyber Security Tingkat Provinsi Jawa Timur 2024';
    final ekskulText = p?['ekskul']?.toString() ?? 'RPL Club & Cyber Sec';
    final locationText = p?['location']?.toString() ?? 'POLINEMA Malang';
    final submitterText = p?['submitter']?.toString() ?? 'Bpk. Ahmad Fauzi, S.Kom';
    final totalText = p?['total']?.toString() ?? 'Rp 4.500.000';
    final delegatesText = p?['delegates']?.toString() ?? '6 Siswa';

    return AdminScreen(back: 'Kembali ke Daftar', children: [
      Row(children: [
        Pill(idText, const Color(0xFFEEF1F7), C.muted),
        const SizedBox(width: 8),
        const Icon(Icons.calendar_today_outlined, size: 14, color: C.muted),
        const SizedBox(width: 4),
        Expanded(child: Text('$dateText • Terdaftar', style: T.body, overflow: TextOverflow.ellipsis)),
        _buildDetailStatusPill(statusText),
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
                Expanded(child: Wrap(spacing: 8, runSpacing: 6, children: [
                  const Pill('Lomba Kejuruan Nasional', C.soft, C.primary),
                  Pill(ekskulText, const Color(0xFFD9F1FB), const Color(0xFF0369A1)),
                ])),
                const IconBox(Icons.verified_user_outlined, size: 44),
              ]),
              const SizedBox(height: 12),
              Text(titleText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.25)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Panel(child: Row(children: [
                  const Icon(Icons.place_outlined, color: C.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Lokasi Acara', style: T.body),
                    Text(locationText, style: T.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                ]))),
                const SizedBox(width: 10),
                Expanded(child: Panel(child: Row(children: [
                  const Icon(Icons.groups_outlined, color: C.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Delegasi', style: T.body),
                    Text(delegatesText, style: T.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                ]))),
              ]),
              const SizedBox(height: 10),
              Panel(child: Row(children: [
                const Photo(icon: Icons.person, w: 52, h: 52),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(submitterText, style: T.title),
                  const Text('Pembina Ekstra SMKN 8', style: T.body),
                ])),
                Btn.soft('WhatsApp', icon: Icons.chat_outlined, h: 40, onTap: () => toast(context, 'Fitur pesan WhatsApp disiapkan')),
              ])),
            ]),
          ),
        ]),
      ),
      SCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.account_tree_outlined, color: C.primary),
            SizedBox(width: 10),
            Expanded(child: Text('Alur Persetujuan & Disposisi', style: T.h2)),
            Pill('Tahap Verifikasi', C.soft, C.primary),
          ]),
          const SizedBox(height: 14),
          _step(Icons.check_circle, C.green, 'Pengajuan Pembina Ekstra', '$submitterText • Berkas terunggah', tag: 'SELESAI', tagBg: C.greenSoft, tagFg: C.green),
          _step(Icons.manage_accounts_outlined, C.primary, 'Verifikasi Admin Kesiswaan', 'Evaluasi kelayakan siswa, dispensasi, & RAB', tag: 'TINDAKAN ANDA', tagBg: C.amberSoft, tagFg: C.amber, active: true),
          _step(Icons.hourglass_empty, C.muted, 'Disposisi Wakasek Kesiswaan & Sarpras', 'Penyediaan fasilitas & rekomendasi teknis'),
          _step(Icons.description_outlined, C.muted, 'Persetujuan KS & Terbit SK Dispensasi', 'Tanda tangan digital Kepala Sekolah SMKN 8'),
          _step(Icons.payments_outlined, C.muted, 'Pencairan Dana BOS / Komite', 'Verifikasi kwitansi oleh Bendahara Sekolah', last: true),
        ]),
      ),
      SegTabs(const ['RAB Dana', 'Delegasi', 'Berkas SOP'], onChanged: (i) => setState(() => tab = i)),
      if (tab == 0) ..._rab(totalText) else if (tab == 1) _delegasi() else _berkas(),
      SCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.edit_note_rounded, color: C.primary, size: 30),
            SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Catatan Verifikasi Kesiswaan', style: T.h2),
              Text('Rekomendasi yang akan diteruskan ke Wakasek & Kepala Sekolah', style: T.body),
            ])),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
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
          Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            const Text('Template Cepat:', style: T.body),
            InkWell(
              onTap: () => setState(() => _notesController.text = 'Rekomendasi terbit SK Dispensasi dan akomodasi disetujui.'),
              child: const Pill('+ Rekomendasi Terbit SK', C.field, C.ink),
            ),
            InkWell(
              onTap: () => setState(() => _notesController.text = 'Armada minibus sekolah disiapkan untuk delegasi.'),
              child: const Pill('+ Armada Sekolah', C.field, C.ink),
            ),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(value: notify, onChanged: (v) => setState(() => notify = v ?? false), activeColor: C.primary),
            const Expanded(child: Padding(padding: EdgeInsets.only(top: 12), child: Text('Kirim notifikasi otomatis ke Pembina & Delegasi Siswa', style: TextStyle(fontSize: 14)))),
          ]),
          const SizedBox(height: 8),
          if (_isSubmitting)
            const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: CircularProgressIndicator()))
          else ...[
            Btn(
              'Setujui & Teruskan ke Kepala Sekolah',
              icon: Icons.check_circle_outline,
              expand: true,
              h: 54,
              onTap: () => _handleReview('forwarded', 'Proposal disetujui dan diteruskan ke Kepala Sekolah.'),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: Btn(
                  'Minta Revisi',
                  icon: Icons.edit_note,
                  bg: C.amberSoft,
                  fg: C.amber,
                  expand: true,
                  h: 48,
                  onTap: () => _handleReview('rejected', 'Catatan revisi dikirimkan ke Pembina.'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Btn.danger(
                  'Tolak Proposal',
                  icon: Icons.cancel_outlined,
                  expand: true,
                  h: 48,
                  onTap: () => _handleReview('rejected', 'Proposal kegiatan resmi ditolak.'),
                ),
              ),
            ]),
          ],
        ]),
      ),
    ]);
  }

  Widget _buildDetailStatusPill(String status) {
    switch (status) {
      case 'Disetujui':
        return const Pill('Disetujui', C.greenSoft, C.green, dot: true);
      case 'Diteruskan':
        return const Pill('Diteruskan', C.soft, C.primary, dot: true);
      case 'Revisi':
      case 'Ditolak':
        return const Pill('Revisi', C.orangeSoft, C.orange, dot: true);
      default:
        return const Pill('Menunggu Kesiswaan', C.amberSoft, C.amber, dot: true);
    }
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

  List<Widget> _rab(String total) => [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [Expanded(child: Text('TOTAL ESTIMASI USULAN', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.8))), Icon(Icons.monetization_on_outlined, color: Colors.white70)]),
            const SizedBox(height: 6),
            Text(total, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
            const Divider(color: Colors.white24, height: 22),
            Wrap(spacing: 16, children: const [Text('● Pos BOS Kinerja', style: TextStyle(color: Colors.white, fontSize: 12.5)), Text('● Kas Ekskul', style: TextStyle(color: Colors.white, fontSize: 12.5))]),
          ]),
        ),
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Expanded(child: Text('Rincian Komponen Biaya', style: T.h2)), Text('Pos Pengeluaran', style: T.body)]),
          const SizedBox(height: 12),
          _rp(Icons.how_to_reg_outlined, 'Pendaftaran Kegiatan & Administrasi', 'Biaya registrasi resmi kompetisi', total),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [Icon(Icons.info_outline, color: C.primary), SizedBox(width: 10), Expanded(child: Text('Standar satuan biaya honorarium dan konsumsi sudah sesuai dengan ketentuan Juknis BOS Kinerja SMK Jawa Timur.', style: T.body))]),
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
        for (final f in const [['Proposal_Kegiatan_Lengkap.pdf', '2.1 MB'], ['Surat_Undangan_Penyelenggara.pdf', '640 KB'], ['SOP_Keberangkatan_Delegasi.pdf', '1.3 MB']])
          Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [const IconBox(Icons.picture_as_pdf_outlined, bg: C.redSoft, fg: C.red, size: 40), const SizedBox(width: 12), Expanded(child: Text(f[0], style: T.title.copyWith(fontSize: 14))), Text(f[1], style: T.body)])),
      ]));
}
