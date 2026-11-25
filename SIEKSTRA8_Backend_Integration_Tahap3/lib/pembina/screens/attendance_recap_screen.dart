import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class AttendanceRecapScreen extends StatefulWidget {
  const AttendanceRecapScreen({super.key});
  @override
  State<AttendanceRecapScreen> createState() => _AttendanceRecapScreenState();
}

class _AttendanceRecapScreenState extends State<AttendanceRecapScreen> {
  final _repo = SiekstraRepository();
  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try { final rows = await _repo.getCoachAttendanceSessions(); if (mounted) setState(() => _sessions = rows); }
    catch (e) { if (mounted) setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) => Screen(
    back: true, tag: 'PMR', title: 'Rekap Kehadiran',
    subtitle: 'Riwayat sesi presensi yang tersimpan di Supabase',
    trailing: IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: AppColors.primary)),
    children: [
      if (_loading) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
      if (_error != null) SCard(child: Text('Gagal memuat rekap: $_error', style: T.body)),
      if (!_loading && _error == null && _sessions.isEmpty) SCard(child: Text('Belum ada sesi presensi yang dibuat.', style: T.body)),
      for (final session in _sessions) _sessionCard(session),
    ],
  );
  Widget _sessionCard(Map<String, dynamic> session) {
    final extra = session['extracurriculars'] as Map<String, dynamic>? ?? {};
    final date = DateTime.tryParse(session['session_date']?.toString() ?? '');
    final dateLabel = date == null ? '-' : '${date.day}/${date.month}/${date.year}';
    return SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(session['title']?.toString() ?? 'Pertemuan', style: T.title),
      const SizedBox(height: 4),
      Text('${extra['name'] ?? 'Ekstrakurikuler'} • $dateLabel', style: T.body),
      if ((session['notes'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(session['notes'].toString(), style: T.body)),
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => _showDetails(session), icon: const Icon(Icons.list_alt), label: const Text('Lihat rincian'))),
    ]));
  }
  Future<void> _showDetails(Map<String, dynamic> session) async {
    showDialog(context: context, builder: (ctx) => const AlertDialog(content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Memuat rincian...')])));
    try {
      final records = await _repo.getSessionAttendance(session['id'].toString());
      if (!mounted) return;
      Navigator.of(context).pop();
      await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
        title: Text(session['title']?.toString() ?? 'Rincian Presensi'),
        content: SizedBox(width: 420, child: records.isEmpty ? const Text('Belum ada catatan presensi.') : ListView(shrinkWrap: true, children: records.map((r) {
          final profile = r['profiles'] as Map<String, dynamic>? ?? {};
          return ListTile(dense: true, title: Text(profile['full_name']?.toString() ?? 'Siswa'), subtitle: Text(profile['identifier']?.toString() ?? ''), trailing: Text(r['status']?.toString() ?? '-'));
        }).toList())),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
      ));
    } catch (e) {
      if (mounted) { Navigator.of(context).pop(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat rincian: $e'))); }
    }
  }
}
