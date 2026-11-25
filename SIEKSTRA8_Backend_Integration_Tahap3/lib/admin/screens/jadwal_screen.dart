import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/siekstra_repository.dart';
import '../../app/backend.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../shell.dart';

// ============================================================
//  Admin Jadwal Screen
//  Menampilkan & mengelola seluruh jadwal kegiatan ekskul
//  dari Supabase melalui SiekstraRepository.
// ============================================================

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});
  @override
  State<JadwalScreen> createState() => _State();
}

class _State extends State<JadwalScreen> {
  final _repo = SiekstraRepository();
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> _ekskulList = [];
  bool _loading = true;
  String? _error;

  String _search = '';
  int _chip = 0; // 0: Semua, 1: Hari Ini, 2: Mendatang, 3: Selesai

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Load data dari Supabase ───────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Backend.ensureInitialized();
      final results = await Future.wait([
        _repo.getSchedules(),
        _repo.getExtracurriculars(onlyOpen: false),
      ]);
      if (!mounted) return;
      setState(() {
        _schedules = List<Map<String, dynamic>>.from(results[0] as List);
        _ekskulList = List<Map<String, dynamic>>.from(results[1] as List);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Kategori jadwal berdasarkan activity_date ─────────────
  String _category(Map<String, dynamic> r) {
    final raw = r['activity_date']?.toString() ?? '';
    final d = DateTime.tryParse(raw);
    if (d == null) return 'Mendatang';
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dOnly = DateTime(d.year, d.month, d.day);
    if (dOnly.isAtSameMomentAs(todayOnly)) return 'Hari Ini';
    if (dOnly.isBefore(todayOnly)) return 'Selesai';
    return 'Mendatang';
  }

  // ── Filter ────────────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    final cats = ['', 'Hari Ini', 'Mendatang', 'Selesai'];
    return _schedules.where((r) {
      if (_chip != 0 && _category(r) != cats[_chip]) return false;
      if (_search.trim().isNotEmpty) {
        final q = _search.toLowerCase().trim();
        final title = (r['title'] ?? '').toString().toLowerCase();
        final ekskul =
            ((r['extracurriculars'] as Map?)?['name'] ?? '').toString().toLowerCase();
        final loc = (r['location'] ?? '').toString().toLowerCase();
        final notes = (r['notes'] ?? '').toString().toLowerCase();
        if (!title.contains(q) &&
            !ekskul.contains(q) &&
            !loc.contains(q) &&
            !notes.contains(q)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final da = DateTime.tryParse(a['activity_date']?.toString() ?? '') ?? DateTime(2100);
        final db = DateTime.tryParse(b['activity_date']?.toString() ?? '') ?? DateTime(2100);
        return da.compareTo(db);
      });
  }

  // ── Stats ─────────────────────────────────────────────────
  int get _cAll => _schedules.length;
  int get _cToday => _schedules.where((r) => _category(r) == 'Hari Ini').length;
  int get _cUpcoming => _schedules.where((r) => _category(r) == 'Mendatang').length;
  int get _cDone => _schedules.where((r) => _category(r) == 'Selesai').length;

  // ── Format tanggal ────────────────────────────────────────
  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    const days = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final dow = days[d.weekday];
    return '$dow, ${d.day} ${months[d.month]} ${d.year}';
  }

  // ── Export CSV ────────────────────────────────────────────
  void _exportCsv() {
    final buf = StringBuffer('Judul,Ekstrakurikuler,Tanggal,Jam Mulai,Jam Selesai,Lokasi,Status\n');
    for (final r in _filtered) {
      final ekskul = (r['extracurriculars'] as Map?)?['name'] ?? '-';
      buf.writeln(
        '"${r['title'] ?? ''}",'
        '"$ekskul",'
        '"${_fmtDate(r['activity_date']?.toString())}",'
        '"${r['start_time'] ?? '-'}",'
        '"${r['end_time'] ?? '-'}",'
        '"${r['location'] ?? '-'}",'
        '"${_category(r)}"',
      );
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    toast(context, 'CSV disalin ke clipboard (${_filtered.length} jadwal).');
  }

  // ── Tambah / Edit Dialog ──────────────────────────────────
  Future<void> _showFormDialog([Map<String, dynamic>? existing]) async {
    final isEdit = existing != null;
    final titleCtrl =
        TextEditingController(text: existing?['title']?.toString() ?? '');
    final locCtrl =
        TextEditingController(text: existing?['location']?.toString() ?? '');
    final startTimeCtrl =
        TextEditingController(text: existing?['start_time']?.toString() ?? '');
    final endTimeCtrl =
        TextEditingController(text: existing?['end_time']?.toString() ?? '');
    final notesCtrl =
        TextEditingController(text: existing?['notes']?.toString() ?? '');
    DateTime? pickedDate =
        DateTime.tryParse(existing?['activity_date']?.toString() ?? '');
    String? selectedEkskulId = existing?['extracurricular_id']?.toString();
    bool saving = false;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEdit ? 'Edit Jadwal' : 'Tambah Jadwal Baru',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  _dlabel('Judul Kegiatan *'),
                  _dfield(titleCtrl, 'Contoh: Latihan Rutin Futsal',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null),
                  const SizedBox(height: 10),

                  // Ekstrakurikuler (wajib untuk tambah baru)
                  _dlabel(isEdit ? 'Ekstrakurikuler' : 'Ekstrakurikuler *'),
                  DropdownButtonFormField<String>(
                    value: selectedEkskulId,
                    decoration: _deco('Pilih ekstrakurikuler'),
                    isExpanded: true,
                    validator: isEdit
                        ? null
                        : (v) => (v == null || v.isEmpty) ? 'Pilih ekstrakurikuler' : null,
                    items: [
                      if (isEdit)
                        const DropdownMenuItem<String>(
                            value: null, child: Text('— Tidak diubah —')),
                      ..._ekskulList.map((e) => DropdownMenuItem<String>(
                            value: e['id']?.toString(),
                            child: Text(e['name']?.toString() ?? '',
                                overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: (v) => setLocal(() => selectedEkskulId = v),
                  ),
                  const SizedBox(height: 10),

                  // Tanggal
                  _dlabel('Tanggal Kegiatan *'),
                  _datePicker(
                    ctx,
                    pickedDate == null
                        ? 'Pilih tanggal'
                        : _fmtDate(pickedDate!.toIso8601String()),
                    () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: pickedDate ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) setLocal(() => pickedDate = d);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Jam mulai & selesai
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dlabel('Jam Mulai'),
                          _dfield(startTimeCtrl, 'HH:MM',
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9:]'))
                              ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dlabel('Jam Selesai'),
                          _dfield(endTimeCtrl, 'HH:MM',
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9:]'))
                              ]),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),

                  // Lokasi
                  _dlabel('Lokasi'),
                  _dfield(locCtrl, 'Contoh: Lapangan Utama SMKN 8'),
                  const SizedBox(height: 10),

                  // Catatan
                  _dlabel('Catatan / Keterangan'),
                  TextFormField(
                    controller: notesCtrl,
                    maxLines: 3,
                    decoration: _deco('Catatan tambahan untuk jadwal ini...'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      if (pickedDate == null && !isEdit) {
                        toast(context, 'Pilih tanggal kegiatan terlebih dahulu.');
                        return;
                      }
                      setLocal(() => saving = true);
                      try {
                        await Backend.ensureInitialized();
                        if (isEdit) {
                          await _repo.updateSchedule(
                            existing!['id'].toString(),
                            title: titleCtrl.text.trim(),
                            date: pickedDate ??
                                DateTime.parse(
                                    existing['activity_date'].toString()),
                            startTime: startTimeCtrl.text.trim().isEmpty
                                ? null
                                : startTimeCtrl.text.trim(),
                            endTime: endTimeCtrl.text.trim().isEmpty
                                ? null
                                : endTimeCtrl.text.trim(),
                            location: locCtrl.text.trim().isEmpty
                                ? null
                                : locCtrl.text.trim(),
                            notes: notesCtrl.text.trim().isEmpty
                                ? null
                                : notesCtrl.text.trim(),
                          );
                        } else {
                          await _repo.createSchedule(
                            extracurricularId: selectedEkskulId!,
                            title: titleCtrl.text.trim(),
                            date: pickedDate!,
                            startTime: startTimeCtrl.text.trim().isEmpty
                                ? null
                                : startTimeCtrl.text.trim(),
                            endTime: endTimeCtrl.text.trim().isEmpty
                                ? null
                                : endTimeCtrl.text.trim(),
                            location: locCtrl.text.trim().isEmpty
                                ? null
                                : locCtrl.text.trim(),
                            notes: notesCtrl.text.trim().isEmpty
                                ? null
                                : notesCtrl.text.trim(),
                          );
                        }
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        toast(context,
                            isEdit ? 'Jadwal berhasil diperbarui.' : 'Jadwal berhasil ditambahkan.');
                        await _loadData();
                      } catch (e) {
                        setLocal(() => saving = false);
                        if (mounted) toast(context, 'Gagal menyimpan: $e');
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Jadwal'),
            ),
          ],
        ),
      ),
    );
    titleCtrl.dispose();
    locCtrl.dispose();
    startTimeCtrl.dispose();
    endTimeCtrl.dispose();
    notesCtrl.dispose();
  }

  // ── Hapus jadwal ──────────────────────────────────────────
  Future<void> _deleteSchedule(Map<String, dynamic> row) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Jadwal?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Jadwal "${row['title']}" akan dihapus permanen.\n\nTindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: C.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await Backend.ensureInitialized();
      await _repo.deleteSchedule(row['id'].toString());
      if (!mounted) return;
      toast(context, 'Jadwal berhasil dihapus.');
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      toast(context, 'Gagal menghapus jadwal: $e');
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return AdminScreen(
      title: 'Jadwal Kegiatan',
      subtitle: 'Kelola seluruh jadwal latihan dan agenda ekskul.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Export CSV',
            onPressed: filtered.isEmpty ? null : _exportCsv,
            icon: const Icon(Icons.download_outlined, color: C.primary),
          ),
          IconButton(
            tooltip: 'Muat Ulang',
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: C.primary),
          ),
        ],
      ),
      children: [
        // ── Stat Cards
        Row(children: [
          Expanded(child: _SBox('Total', '$_cAll', C.primary)),
          const SizedBox(width: 8),
          Expanded(child: _SBox('Hari Ini', '$_cToday', C.green)),
          const SizedBox(width: 8),
          Expanded(child: _SBox('Mendatang', '$_cUpcoming', C.orange)),
          const SizedBox(width: 8),
          Expanded(child: _SBox('Selesai', '$_cDone', C.muted)),
        ]),
        const SizedBox(height: 4),

        // ── Tambah Button
        Btn(
          'Tambah Jadwal Baru',
          icon: Icons.add_circle_outline,
          expand: true,
          h: 50,
          onTap: () => _showFormDialog(),
        ),
        const SizedBox(height: 4),

        // ── Search
        SearchBox(
          'Cari judul, ekskul, lokasi, atau catatan...',
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _search = v),
          onClear: () {
            _searchCtrl.clear();
            setState(() => _search = '');
          },
        ),

        // ── Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _fchip('Semua ($_cAll)', 0),
            const SizedBox(width: 8),
            _fchip('Hari Ini ($_cToday)', 1,
                activeColor: C.green, activeBg: C.greenSoft),
            const SizedBox(width: 8),
            _fchip('Mendatang ($_cUpcoming)', 2,
                activeColor: C.orange, activeBg: C.orangeSoft),
            const SizedBox(width: 8),
            _fchip('Selesai ($_cDone)', 3,
                activeColor: C.muted,
                activeBg: const Color(0xFFE5E8EF)),
          ]),
        ),
        const SizedBox(height: 10),

        // ── Content
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          SCard(
            child: Column(children: [
              const Icon(Icons.error_outline, size: 40, color: C.red),
              const SizedBox(height: 8),
              Text('Gagal memuat data:\n$_error',
                  style: T.body, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Btn('Coba Lagi', icon: Icons.refresh, onTap: _loadData),
            ]),
          )
        else if (filtered.isEmpty)
          SCard(
            padding: const EdgeInsets.all(32),
            child: Column(children: [
              const Icon(Icons.event_note_outlined, size: 48, color: C.muted),
              const SizedBox(height: 10),
              Text(
                _search.isNotEmpty
                    ? 'Tidak ada jadwal yang cocok'
                    : _chip == 0
                        ? 'Belum ada jadwal kegiatan'
                        : 'Tidak ada jadwal ${['', 'hari ini', 'mendatang', 'selesai'][_chip]}',
                style: T.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Tekan "Tambah Jadwal Baru" untuk membuat jadwal.',
                style: T.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Btn('Tambah Jadwal', icon: Icons.add,
                  onTap: () => _showFormDialog()),
            ]),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Menampilkan ${filtered.length} dari $_cAll jadwal',
              style: T.body.copyWith(fontSize: 12),
            ),
          ),
          ...filtered.map(_buildCard),
        ],

        const SizedBox(height: 4),
        Btn.white('Muat Ulang Data',
            icon: Icons.refresh, expand: true, h: 48, onTap: _loadData),
      ],
    );
  }

  // ── Filter chip ───────────────────────────────────────────
  Widget _fchip(String label, int idx,
      {Color activeColor = C.primary, Color activeBg = C.soft}) {
    final active = _chip == idx;
    return GestureDetector(
      onTap: () => setState(() => _chip = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? activeColor : C.line, width: active ? 1.5 : 1),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? activeColor : C.muted,
            )),
      ),
    );
  }

  // ── Jadwal Card ───────────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> row) {
    final id = row['id']?.toString() ?? '';
    final title = row['title']?.toString() ?? 'Tanpa Judul';
    final ekskulName =
        ((row['extracurriculars'] as Map?)?['name'] ?? 'Umum').toString();
    final location = row['location']?.toString() ?? '-';
    final startTime = row['start_time']?.toString() ?? '';
    final endTime = row['end_time']?.toString() ?? '';
    final notes = row['notes']?.toString() ?? '';
    final dateStr = _fmtDate(row['activity_date']?.toString());
    final timeRange = startTime.isNotEmpty
        ? (endTime.isNotEmpty ? '$startTime – $endTime WIB' : '$startTime WIB')
        : '';

    final cat = _category(row);
    final Color statusColor;
    final Color statusBg;
    final IconData statusIcon;
    final bool isToday = cat == 'Hari Ini';
    switch (cat) {
      case 'Hari Ini':
        statusColor = C.green;
        statusBg = C.greenSoft;
        statusIcon = Icons.today_outlined;
        break;
      case 'Selesai':
        statusColor = C.muted;
        statusBg = const Color(0xFFE5E8EF);
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = C.orange;
        statusBg = C.orangeSoft;
        statusIcon = Icons.access_time;
    }

    return SCard(
      border: isToday ? C.green : C.line,
      borderWidth: isToday ? 1.5 : 1,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: statusBg, borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: T.title.copyWith(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(ekskulName,
                  style: T.body.copyWith(
                      fontSize: 12,
                      color: C.primary,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(width: 6),
          Pill(cat, statusBg, statusColor),
        ]),

        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 10),

        // ── Detail rows
        _infoRow(Icons.calendar_month_outlined, 'Tanggal', dateStr),
        if (timeRange.isNotEmpty) ...[
          const SizedBox(height: 4),
          _infoRow(Icons.schedule_outlined, 'Waktu', timeRange),
        ],
        const SizedBox(height: 4),
        _infoRow(Icons.location_on_outlined, 'Lokasi', location),
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: C.soft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 14, color: C.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(notes,
                    style: T.body.copyWith(fontSize: 12, color: C.primary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
        ],

        // ── Action buttons
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 10),
        Row(children: [
          // Buka Presensi (hanya untuk jadwal hari ini)
          if (isToday) ...[
            Expanded(
              flex: 3,
              child: Btn(
                'Presensi',
                icon: Icons.how_to_reg_outlined,
                h: 40,
                onTap: () => goTab(context, 4),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            flex: 2,
            child: Btn.gray(
              'Edit',
              icon: Icons.edit_outlined,
              h: 40,
              onTap: () => _showFormDialog(row),
            ),
          ),
          const SizedBox(width: 6),
          Btn.danger(
            '',
            icon: Icons.delete_outline,
            h: 40,
            onTap: () => _deleteSchedule(row),
          ),
        ]),
      ]),
    );
  }

  // ── Info row ──────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 15, color: C.muted),
          const SizedBox(width: 6),
          Text('$label: ',
              style: T.body.copyWith(fontSize: 12, color: C.muted)),
          Expanded(
            child: Text(value,
                style: T.body.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: C.ink),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  // ── Dialog helpers ────────────────────────────────────────
  Widget _dlabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(t,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: C.ink)),
      );

  Widget _dfield(TextEditingController ctrl, String hint,
      {String? Function(String?)? validator,
      List<TextInputFormatter>? inputFormatters}) =>
      TextFormField(
        controller: ctrl,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: _deco(hint),
      );

  Widget _datePicker(BuildContext ctx, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.line),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: C.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      color: label == 'Pilih tanggal' ? C.muted : C.ink)),
            ),
          ]),
        ),
      );

  InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: C.muted, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF1F4FC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: C.line)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: C.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: C.red)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}

// ── Mini stat box ─────────────────────────────────────────
class _SBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D1E3A8A),
                blurRadius: 8,
                offset: Offset(0, 3))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: T.body.copyWith(fontSize: 11, color: C.muted)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ]),
      );
}
