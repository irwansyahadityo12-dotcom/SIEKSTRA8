import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ResignationScreen extends StatefulWidget {
  const ResignationScreen({super.key});
  @override
  State<ResignationScreen> createState() => _ResignationScreenState();
}

class _ResignationScreenState extends State<ResignationScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  @override
  void initState() { super.initState(); _future = SiekstraRepository().getPendingResignationsForCoach(); }
  void _reload() => setState(() => _future = SiekstraRepository().getPendingResignationsForCoach());

  Future<void> _review(String id, bool approve) async {
    try {
      await SiekstraRepository().reviewResignation(id, approve: approve);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(approve ? 'Pengunduran diri disetujui.' : 'Pengajuan ditolak.')));
      _reload();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan keputusan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => Screen(
    back: true, tag: 'PMR', title: 'Pengunduran Diri', subtitle: 'Tinjau permohonan anggota ekstrakurikuler',
    children: [
      FutureBuilder<List<Map<String, dynamic>>>(future: _future, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
        if (snapshot.hasError) return SCard(child: Column(children: [Text('Gagal memuat pengajuan: ${snapshot.error}'), TextButton(onPressed: _reload, child: const Text('Coba lagi'))]));
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) return const SCard(child: Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Tidak ada pengajuan pengunduran diri yang menunggu.'))));
        return Column(children: [
          Align(alignment: Alignment.centerLeft, child: Pill('${rows.length} Menunggu', AppColors.redSoft, AppColors.red)),
          const SizedBox(height: 12),
          for (final row in rows) _requestCard(row),
        ]);
      }),
    ],
  );

  Widget _requestCard(Map<String, dynamic> row) {
    final profile = row['profiles'] is Map ? row['profiles'] as Map : <String, dynamic>{};
    final extra = row['extracurriculars'] is Map ? row['extracurriculars'] as Map : <String, dynamic>{};
    return SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text((profile['full_name'] ?? 'Siswa').toString(), style: T.h2),
      Text('${profile['identifier'] ?? '-'} • ${extra['name'] ?? 'Ekstrakurikuler'}', style: T.body),
      const SizedBox(height: 10),
      Text((row['reason_category'] ?? 'Alasan pengunduran diri').toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text((row['reason'] ?? '').toString(), style: T.body),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: Btn('Setujui', icon: Icons.check, bg: AppColors.red, expand: true, onTap: () => _review(row['id'].toString(), true))),
        const SizedBox(width: 8),
        Expanded(child: Btn.soft('Tolak', icon: Icons.close, expand: true, onTap: () => _review(row['id'].toString(), false))),
      ]),
    ]));
  }
}
