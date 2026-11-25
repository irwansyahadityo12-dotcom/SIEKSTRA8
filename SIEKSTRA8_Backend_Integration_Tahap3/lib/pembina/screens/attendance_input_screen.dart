import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'attendance_recap_screen.dart';

class AttendanceInputScreen extends StatefulWidget {
  const AttendanceInputScreen({super.key});
  @override
  State<AttendanceInputScreen> createState() => _AttendanceInputScreenState();
}

class _AttendanceInputScreenState extends State<AttendanceInputScreen> {
  final _repo = SiekstraRepository();
  final _title = TextEditingController(text: 'Latihan Rutin');
  final _notes = TextEditingController();
  List<Map<String, dynamic>> _extracurriculars = [];
  List<Map<String, dynamic>> _members = [];
  String? _extracurricularId;
  DateTime _date = DateTime.now();
  final Map<String, String> _statuses = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;
  static const _options = ['Hadir', 'Izin', 'Sakit', 'Alfa'];

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _title.dispose(); _notes.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final extras = await _repo.getCoachExtracurriculars();
      if (!mounted) return;
      setState(() {
        _extracurriculars = extras;
        _extracurricularId ??= extras.isNotEmpty ? extras.first['id'] as String : null;
      });
      if (_extracurricularId != null) await _loadMembers();
    } catch (e) { if (mounted) setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _loadMembers() async {
    final id = _extracurricularId;
    if (id == null) return;
    try {
      final rows = await _repo.getMembers(id);
      if (!mounted) return;
      setState(() {
        _members = rows;
        _statuses.clear();
        for (final row in rows) {
          final profile = row['profiles'] as Map<String, dynamic>? ?? {};
          final studentId = profile['id']?.toString() ?? row['student_id'].toString();
          _statuses[studentId] = 'Hadir';
        }
      });
    } catch (e) { if (mounted) setState(() => _error = e.toString()); }
  }

  Future<void> _save() async {
    if (_extracurricularId == null || _members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih ekstrakurikuler yang memiliki anggota aktif.')));
      return;
    }
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul pertemuan wajib diisi.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final sessionId = await _repo.createAttendanceSession(
        extracurricularId: _extracurricularId!, title: _title.text.trim(), date: _date, notes: _notes.text.trim());
      final records = _statuses.entries.map((e) => <String, String>{
        'student_id': e.key, 'status': e.value,
      }).toList();
      await _repo.saveAttendance(sessionId, records);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Presensi berhasil disimpan ke Supabase.')));
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceRecapScreen()));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan presensi: $e')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      title: 'Presensi Kehadiran',
      subtitle: 'Catat kehadiran anggota dan simpan ke database',
      trailing: Btn.soft('Rekap', icon: Icons.bar_chart_rounded, h: 36, onTap: () => push(context, const AttendanceRecapScreen())),
      bottom: Btn('Simpan Presensi', icon: Icons.check_circle_outline, expand: true, h: 54, onTap: _saving ? null : _save),
      children: [
        if (_loading) const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
        if (_error != null) _message(_error!, isError: true),
        if (!_loading && _extracurriculars.isEmpty) _message('Belum ada ekstrakurikuler yang ditugaskan kepada akun Pembina.'),
        if (_extracurriculars.isNotEmpty) ...[
          SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('EKSTRAKURIKULER', style: T.label),
            DropdownButtonFormField<String>(
              value: _extracurricularId,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              items: _extracurriculars.map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text(e['name'].toString(), overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) async { setState(() { _extracurricularId = v; _members = []; }); await _loadMembers(); },
            ),
            const SizedBox(height: 12),
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Judul pertemuan', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Catatan (opsional)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: () async {
              final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (picked != null && mounted) setState(() => _date = picked);
            }, icon: const Icon(Icons.calendar_month), label: Text('Tanggal: ${_date.day}/${_date.month}/${_date.year}')),
          ])),
          Row(children: [const Expanded(child: Text('Daftar Anggota', style: T.h2)), Pill('${_members.length} anggota', AppColors.soft, AppColors.primary)]),
          if (_members.isEmpty) _message('Belum ada anggota berstatus disetujui pada ekstrakurikuler ini.'),
          for (final row in _members) _memberCard(row),
        ],
        if (_saving) const LinearProgressIndicator(),
      ],
    );
  }

  Widget _memberCard(Map<String, dynamic> row) {
    final p = row['profiles'] as Map<String, dynamic>? ?? {};
    final id = (p['id'] ?? row['student_id']).toString();
    final name = (p['full_name'] ?? 'Siswa').toString();
    final identifier = (p['identifier'] ?? '').toString();
    return SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name, style: T.title),
      Text('${p['class_name'] ?? ''} ${identifier.isEmpty ? '' : '• $identifier'}', style: T.body),
      const SizedBox(height: 10),
      Wrap(spacing: 6, runSpacing: 6, children: _options.map((status) => ChoiceChip(
        label: Text(status), selected: _statuses[id] == status,
        onSelected: (_) => setState(() => _statuses[id] = status),
      )).toList()),
    ]));
  }

  Widget _message(String text, {bool isError = false}) => SCard(child: Row(children: [
    Icon(isError ? Icons.error_outline : Icons.info_outline, color: isError ? AppColors.red : AppColors.primary),
    const SizedBox(width: 10), Expanded(child: Text(text, style: T.body)),
  ]));
}
