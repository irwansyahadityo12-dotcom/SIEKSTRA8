import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ScheduleFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const ScheduleFormScreen({super.key, this.initial});
  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _repo = SiekstraRepository();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _notes = TextEditingController();
  List<Map<String, dynamic>> _extras = [];
  List<Map<String, dynamic>> _unassignedExtras = [];
  String? _extraId;
  DateTime _date = DateTime.now();
  TimeOfDay? _start, _end;
  bool _loading = true, _saving = false;
  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final data = widget.initial;
    if (data != null) {
      _title.text = data['title']?.toString() ?? '';
      _location.text = data['location']?.toString() ?? '';
      _notes.text = data['notes']?.toString() ?? '';
      final d = DateTime.tryParse(data['activity_date']?.toString() ?? '');
      if (d != null) _date = d;
      _start = _parseTime(data['start_time']?.toString());
      _end = _parseTime(data['end_time']?.toString());
      _extraId = data['extracurricular_id']?.toString();
    }
    _loadExtras();
  }
  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
  }
  String? _time(TimeOfDay? t) => t == null ? null : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
  @override
  void dispose() { _title.dispose(); _location.dispose(); _notes.dispose(); super.dispose(); }

  Future<void> _loadExtras() async {
    try {
      final rows = await _repo.getCoachExtracurriculars();
      if (!mounted) return;
      if (rows.isNotEmpty) {
        setState(() {
          _extras = rows;
          _extraId ??= rows.first['id'].toString();
        });
      } else {
        // Jika belum ada ekskul binaan, cari ekskul yang belum ditugaskan pembina
        final all = await _repo.getExtracurriculars();
        if (!mounted) return;
        final unassigned = all.where((e) => e['coach_id'] == null).toList();
        setState(() {
          _unassignedExtras = unassigned.isNotEmpty ? unassigned : all;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat ekstrakurikuler: $e')));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _save() async {
    if (_extraId == null || _title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih ekstrakurikuler dan isi nama kegiatan.'))); return;
    }
    setState(() => _saving = true);
    try {
      if (_editing) {
        await _repo.updateSchedule(widget.initial!['id'].toString(), title: _title.text, date: _date,
          startTime: _time(_start), endTime: _time(_end), location: _location.text, notes: _notes.text);
      } else {
        await _repo.createSchedule(extracurricularId: _extraId!, title: _title.text, date: _date,
          startTime: _time(_start), endTime: _time(_end), location: _location.text, notes: _notes.text);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal berhasil disimpan ke Supabase.')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan jadwal: $e')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Screen(
    back: true, title: _editing ? 'Edit Jadwal' : 'Tambah Jadwal',
    subtitle: 'Jadwal akan ditampilkan kepada anggota ekstrakurikuler terkait.',
    bottom: Btn(_saving ? 'Menyimpan...' : 'Simpan Jadwal', icon: Icons.save_outlined, expand: true, h: 54, onTap: _saving ? null : _save),
    children: [
      if (_loading) const Center(child: CircularProgressIndicator()),
      if (!_loading && _extras.isEmpty)
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Tugaskan Ekstrakurikuler Binaan', style: T.title),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Akun pembina ini belum terhubung ke ekstrakurikuler. Pilih ekstrakurikuler binaan Anda di bawah ini untuk menghubungkannya:',
                style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 14),
              if (_unassignedExtras.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _extraId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Ekstrakurikuler Binaan',
                    border: OutlineInputBorder(),
                  ),
                  items: _unassignedExtras
                      .map((e) => DropdownMenuItem(
                            value: e['id'].toString(),
                            child: Text(e['name'].toString()),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _extraId = v),
                ),
                const SizedBox(height: 12),
                Btn(
                  'Hubungkan Ekstrakurikuler ke Akun Saya',
                  icon: Icons.check_circle_outline,
                  expand: true,
                  onTap: _extraId == null
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          try {
                            await _repo.claimExtracurricularAsCoach(_extraId!);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ekstrakurikuler berhasil ditugaskan ke akun Anda.')),
                            );
                            await _loadExtras();
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menghubungkan: $e')),
                            );
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                ),
              ] else
                const Text('Tidak ada ekstrakurikuler yang tersedia.'),
            ],
          ),
        ),
      if (_extras.isNotEmpty) SCard(child: Column(children: [
        DropdownButtonFormField<String>(value: _extraId, isExpanded: true, decoration: const InputDecoration(labelText: 'Ekstrakurikuler', border: OutlineInputBorder()),
          items: _extras.map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text(e['name'].toString()))).toList(),
          onChanged: _editing ? null : (v) => setState(() => _extraId = v)),
        const SizedBox(height: 12),
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Nama kegiatan', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () async { final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100)); if (d != null && mounted) setState(() => _date = d); }, icon: const Icon(Icons.calendar_month), label: Text('Tanggal: ${_date.day}/${_date.month}/${_date.year}')),
        Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () async { final t = await showTimePicker(context: context, initialTime: _start ?? const TimeOfDay(hour: 15, minute: 0)); if (t != null && mounted) setState(() => _start = t); }, icon: const Icon(Icons.access_time), label: Text('Mulai: ${_start?.format(context) ?? '-'}'))), const SizedBox(width: 8), Expanded(child: OutlinedButton.icon(onPressed: () async { final t = await showTimePicker(context: context, initialTime: _end ?? const TimeOfDay(hour: 17, minute: 0)); if (t != null && mounted) setState(() => _end = t); }, icon: const Icon(Icons.access_time_filled), label: Text('Selesai: ${_end?.format(context) ?? '-'}')))]),
        const SizedBox(height: 12),
        TextField(controller: _location, decoration: const InputDecoration(labelText: 'Lokasi', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Catatan', border: OutlineInputBorder())),
      ])),
      if (_saving) const LinearProgressIndicator(),
    ],
  );
}
