import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'proposal_detail_screen.dart';
import 'dispensasi_screen.dart';

class ProposalListScreen extends StatelessWidget {
  const ProposalListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      eyebrow: 'LAYANAN PROPOSAL & SURAT',
      title: 'Proposal & Surat',
      subtitle: 'Kelola pengajuan proposal kegiatan dan surat tugas ekstrakurikuler.',
      children: [
        Row(children: [
          Expanded(child: Btn('Dispensasi & Surat Tugas', icon: Icons.mark_email_read_outlined, expand: true, onTap: () => push(context, const DispensasiScreen()))),
        ]),
        const SizedBox(height: 14),
        const SearchBox('Cari proposal atau ekstra...', filter: true),
        const Chips(['Semua (8)', 'Menunggu Kesiswaan (2)', 'Disetujui', 'Revisi']),
        _p(context, '#PROP-8-092', 'Keikutsertaan Lomba Kompetensi Siswa (LKS) Cyber Security', 'RPL Club & Cyber Sec', 'Rp 4.500.000', const Pill('Menunggu Kesiswaan', C.amberSoft, C.amber, dot: true)),
        _p(context, '#PROP-8-088', 'Lomba Futsal Walikota Cup Malang 2024', 'Futsal SMKN 8', 'Rp 3.200.000', const Pill('Disetujui', C.greenSoft, C.green, dot: true)),
        _p(context, '#PROP-8-081', 'Jumbara PMR & Temu Relawan Se-Jawa Timur', 'PMR Wira Unit 8', 'Rp 6.750.000', const Pill('Revisi', C.orangeSoft, C.orange, dot: true)),
      ],
    );
  }

  Widget _p(BuildContext c, String id, String title, String ekskul, String total, Widget status) => SCard(
        onTap: () => push(c, const ProposalDetailScreen()),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(id, style: T.label), const Spacer(), status]),
          const SizedBox(height: 8),
          Text(title, style: T.title.copyWith(fontSize: 17)),
          const SizedBox(height: 8),
          Row(children: [Pill(ekskul, C.soft, C.primary), const Spacer(), Text(total, style: T.title)]),
        ]),
      );
}
