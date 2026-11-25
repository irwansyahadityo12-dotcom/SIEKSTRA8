import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'schedule_form_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _repo = SiekstraRepository();
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try { final rows = await _repo.getCoachSchedules(); if (mounted) setState(() => _rows = rows); }
    catch (e) { if (mounted) setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  String _date(dynamic value) {
    final d = DateTime.tryParse(value?.toString() ?? '');
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
  @override
  Widget build(BuildContext context) => Screen(
    tag: 'PMR', title: 'Jadwal Ekskul', subtitle: 'Jadwal kegiatan yang tersimpan di Supabase',
    trailing: IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: AppColors.primary)),
    children: [
      Btn('Tambah Jadwal', icon: Icons.add, expand: true, h: 52, onTap: () async { final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const ScheduleFormScreen())); if (changed == true) _load(); }),
      const SizedBox(height: 14),
      if (_loading) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
      if (_error != null) SCard(child: Text('Gagal memuat jadwal: $_error', style: T.body)),
      if (!_loading && _error == null && _rows.isEmpty) SCard(child: Text('Belum ada jadwal. Tambahkan jadwal kegiatan pertama.', style: T.body)),
      for (final row in _rows) _scheduleCard(row),
    ],
  );

  Widget _scheduleCard(Map<String, dynamic> row) {
    final extra = row['extracurriculars'] as Map<String, dynamic>? ?? {};
    final time = [row['start_time'], row['end_time']].where((e) => e != null && e.toString().isNotEmpty).join(' – ');
    return SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(row['title']?.toString() ?? 'Kegiatan', style: T.title)), Pill(_date(row['activity_date']), AppColors.soft, AppColors.primary)]),
      const SizedBox(height: 6), Text(extra['name']?.toString() ?? 'Ekstrakurikuler', style: T.body.copyWith(fontWeight: FontWeight.w700)),
      if (time.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 5), child: Text('Waktu: $time', style: T.body)),
      if ((row['location'] ?? '').toString().isNotEmpty) Text('Lokasi: ${row['location']}', style: T.body),
      if ((row['notes'] ?? '').toString().isNotEmpty) Text('Catatan: ${row['notes']}', style: T.body),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () async { final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ScheduleFormScreen(initial: row))); if (changed == true) _load(); }, icon: const Icon(Icons.edit_outlined), label: const Text('Edit'))), const SizedBox(width: 8), IconButton(onPressed: () => _delete(row), icon: const Icon(Icons.delete_outline, color: AppColors.red), tooltip: 'Hapus jadwal')]),
    ]));
  }
  Future<void> _delete(Map<String, dynamic> row) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Hapus jadwal?'), content: Text('Jadwal "${row['title']}" akan dihapus.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus'))]));
    if (ok != true) return;
    try { await _repo.deleteSchedule(row['id'].toString()); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal dihapus.'))); _load(); } }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus jadwal: $e'))); }
  }
}
