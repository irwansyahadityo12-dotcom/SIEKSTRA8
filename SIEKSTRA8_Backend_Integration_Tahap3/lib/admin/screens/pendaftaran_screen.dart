import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../../app/supabase_config.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PendaftaranScreen extends StatefulWidget {
  const PendaftaranScreen({super.key});
  @override
  State<PendaftaranScreen> createState() => _PendaftaranScreenState();
}

class _PendaftaranScreenState extends State<PendaftaranScreen> {
  final _repository = SiekstraRepository();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;
  int _tab = 0; // 0 menunggu, 1 diterima, 2 ditolak
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  Future<void> _load() async {
    if (!SupabaseConfig.isConfigured) {
      setState(() { _loading = false; _error = 'Supabase belum dikonfigurasi.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final rows = await _repository.getMembershipsForAdmin();
      if (mounted) setState(() => _rows = rows);
    } catch (e) { if (mounted) setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _review(Map<String, dynamic> row, bool approve) async {
    try {
      await _repository.reviewMembership(row['id'].toString(), approve: approve);
      if (!mounted) return;
      toast(context, 'Pendaftaran ${approve ? 'disetujui' : 'ditolak'}.');
      await _load();
    } catch (e) { if (mounted) toast(context, 'Gagal menyimpan keputusan: $e'); }
  }

  List<Map<String, dynamic>> get _filtered {
    final status = ['pending', 'approved', 'rejected'][_tab];
    return _rows.where((row) {
      if (row['status'] != status) return false;
      if (_search.trim().isEmpty) return true;
      final q = _search.toLowerCase().trim();
      final profile = row['profiles'] as Map? ?? {};
      final extra = row['extracurriculars'] as Map? ?? {};
      return (profile['full_name'] ?? '').toString().toLowerCase().contains(q) ||
          (profile['identifier'] ?? '').toString().toLowerCase().contains(q) ||
          (extra['name'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _rows.where((r) => r['status'] == 'pending').length;
    final approved = _rows.where((r) => r['status'] == 'approved').length;
    final rejected = _rows.where((r) => r['status'] == 'rejected').length;
    final rows = _filtered;
    return AdminScreen(
      title: 'Pendaftaran Ekstrakurikuler',
      subtitle: 'Kelola seluruh pengajuan siswa yang tersimpan di Supabase.',
      children: [
        Row(children: [
          Expanded(child: StatBox('Menunggu', '$waiting', 'Perlu ditinjau', valueColor: C.orange, subColor: C.orange)),
          const SizedBox(width: 8),
          Expanded(child: StatBox('Disetujui', '$approved', 'Anggota aktif', valueColor: C.green, subColor: C.green)),
          const SizedBox(width: 8),
          Expanded(child: StatBox('Ditolak', '$rejected', 'Pengajuan ditolak', valueColor: C.red, subColor: C.red)),
        ]),
        SearchBox('Cari nama siswa, NIS, atau ekstrakurikuler...', controller: _searchController,
          onChanged: (v) => setState(() => _search = v), onClear: () { _searchController.clear(); setState(() => _search = ''); }),
        SegTabs(['Menunggu ($waiting)', 'Disetujui ($approved)', 'Ditolak ($rejected)'], selectedIndex: _tab, onChanged: (v) => setState(() => _tab = v)),
        const SizedBox(height: 10),
        if (_loading) const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator()))
        else if (_error != null) SCard(child: Column(children: [Text('Gagal memuat pendaftaran: $_error', style: T.body), Btn('Coba Lagi', icon: Icons.refresh, onTap: _load)]))
        else if (rows.isEmpty) SCard(padding: const EdgeInsets.all(28), child: Column(children: [
          const Icon(Icons.inbox_outlined, size: 42, color: C.muted),
          const SizedBox(height: 8),
          Text(_tab == 0 ? 'Belum Ada Pendaftaran Menunggu' : 'Belum Ada Data pada Kategori Ini', style: T.h2),
          const Text('Data akan muncul setelah siswa mengajukan keanggotaan.', style: T.body, textAlign: TextAlign.center),
        ]))
        else for (final row in rows) _membershipCard(row),
        Btn.white('Muat Ulang Data', icon: Icons.refresh, expand: true, h: 48, onTap: _load),
      ],
    );
  }

  Widget _membershipCard(Map<String, dynamic> row) {
    final profile = row['profiles'] as Map? ?? {};
    final extra = row['extracurriculars'] as Map? ?? {};
    final status = row['status']?.toString() ?? 'pending';
    final name = profile['full_name']?.toString() ?? 'Siswa';
    final className = profile['class_name']?.toString() ?? '-';
    final identifier = profile['identifier']?.toString() ?? '-';
    final date = DateTime.tryParse(row['created_at']?.toString() ?? '');
    final dateText = date == null ? '-' : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final isPending = status == 'pending';
    final color = status == 'approved' ? C.green : status == 'rejected' ? C.red : C.orange;
    final bg = status == 'approved' ? C.greenSoft : status == 'rejected' ? C.redSoft : C.orangeSoft;
    return SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.person_outline, color: C.primary), const SizedBox(width: 8), Expanded(child: Text(name, style: T.title)), Pill(status == 'approved' ? 'Disetujui' : status == 'rejected' ? 'Ditolak' : 'Menunggu', bg, color)]),
      const SizedBox(height: 6),
      Text('$className • NIS/NISN: $identifier', style: T.body),
      const SizedBox(height: 8),
      Row(children: [const Icon(Icons.groups_outlined, size: 16, color: C.muted), const SizedBox(width: 6), Expanded(child: Text(extra['name']?.toString() ?? 'Ekstrakurikuler', style: T.title)), Text(dateText, style: T.body)]),
      if (isPending) ...[
        const Divider(height: 22),
        Row(children: [const Spacer(), Btn.danger('Tolak', icon: Icons.close, h: 40, onTap: () => _review(row, false)), const SizedBox(width: 8), Btn('Setujui', icon: Icons.check, bg: C.green, fg: Colors.white, h: 40, onTap: () => _review(row, true))]),
      ],
    ]));
  }
}
