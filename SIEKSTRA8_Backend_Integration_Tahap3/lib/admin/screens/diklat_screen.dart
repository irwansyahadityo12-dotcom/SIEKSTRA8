import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/siekstra_repository.dart';
import '../../app/backend.dart';
import '../theme.dart';
import '../widgets/common.dart';

// ============================================================
//  Admin Diklat Screen
//  Menampilkan & mengelola seluruh agenda Diklat / Kaderisasi
//  dari Supabase melalui SiekstraRepository.
// ============================================================

class DiklatScreen extends StatefulWidget {
  const DiklatScreen({super.key});

  @override
  State<DiklatScreen> createState() => _DiklatScreenState();
}

class _DiklatScreenState extends State<DiklatScreen> {
  final _repo = SiekstraRepository();
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _rows = [];
  List<Map<String, dynamic>> _ekskulList = [];
  bool _loading = true;
  String? _error;

  String _search = '';
  int _chip = 0; // 0: Semua, 1: Akan Datang, 2: Berjalan, 3: Selesai

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
        _repo.getTrainings(),
        _repo.getExtracurriculars(onlyOpen: false),
      ]);
      if (!mounted) return;
      setState(() {
        _rows = List<Map<String, dynamic>>.from(results[0] as List);
        _ekskulList = List<Map<String, dynamic>>.from(results[1] as List);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Hitung kategori status dari tanggal ──────────────────
  String _statusCategory(Map<String, dynamic> row) {
    final start = DateTime.tryParse(row['start_date']?.toString() ?? '');
    final end = DateTime.tryParse(row['end_date']?.toString() ?? '');
    final now = DateTime.now();
    if (start == null) return 'Akan Datang';
    if (now.isBefore(start)) return 'Akan Datang';
    if (end != null && now.isAfter(end)) return 'Selesai';
    return 'Berjalan';
  }

  // ── Filter list ───────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    final cats = ['', 'Akan Datang', 'Berjalan', 'Selesai'];
    return _rows.where((r) {
      if (_chip != 0 && _statusCategory(r) != cats[_chip]) return false;
      if (_search.trim().isNotEmpty) {
        final q = _search.toLowerCase().trim();
        final title = (r['title'] ?? '').toString().toLowerCase();
        final ekskul =
            ((r['extracurriculars'] as Map?)?['name'] ?? '').toString().toLowerCase();
        final loc = (r['location'] ?? '').toString().toLowerCase();
        if (!title.contains(q) && !ekskul.contains(q) && !loc.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final sa = DateTime.tryParse(a['start_date']?.toString() ?? '') ?? DateTime(2100);
        final sb = DateTime.tryParse(b['start_date']?.toString() ?? '') ?? DateTime(2100);
        return sa.compareTo(sb); // upcoming first
      });
  }

  // ── Stats ─────────────────────────────────────────────────
  int get _countAll => _rows.length;
  int get _countUpc => _rows.where((r) => _statusCategory(r) == 'Akan Datang').length;
  int get _countRun => _rows.where((r) => _statusCategory(r) == 'Berjalan').length;
  int get _countDone => _rows.where((r) => _statusCategory(r) == 'Selesai').length;

  // ── Format tanggal ────────────────────────────────────────
  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // ── Tambah Diklat Dialog ──────────────────────────────────
  Future<void> _showTambahDialog([Map<String, dynamic>? existing]) async {
    final isEdit = existing != null;
    final titleCtrl = TextEditingController(text: existing?['title']?.toString() ?? '');
    final descCtrl = TextEditingController(text: existing?['description']?.toString() ?? '');
    final locCtrl = TextEditingController(text: existing?['location']?.toString() ?? '');
    final quotaCtrl = TextEditingController(
        text: existing?['quota']?.toString() ?? '');
    DateTime? startDate = DateTime.tryParse(existing?['start_date']?.toString() ?? '');
    DateTime? endDate = DateTime.tryParse(existing?['end_date']?.toString() ?? '');
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
            isEdit ? 'Edit Agenda Diklat' : 'Tambah Agenda Diklat',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Diklat
                  _dialogLabel('Nama Kegiatan *'),
                  _dialogField(titleCtrl, 'Contoh: Diklat Dasar PMR Wira', validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null),
                  const SizedBox(height: 10),

                  // Ekstrakurikuler dropdown
                  _dialogLabel('Ekstrakurikuler'),
                  DropdownButtonFormField<String>(
                    value: selectedEkskulId,
                    decoration: _inputDeco('Pilih ekstrakurikuler'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                          value: null, child: Text('— Tidak Terikat —')),
                      ..._ekskulList.map((e) => DropdownMenuItem<String>(
                            value: e['id']?.toString(),
                            child: Text(e['name']?.toString() ?? '',
                                overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: (v) => setLocal(() => selectedEkskulId = v),
                  ),
                  const SizedBox(height: 10),

                  // Tanggal mulai
                  _dialogLabel('Tanggal Mulai'),
                  _dateField(
                    ctx,
                    startDate == null ? 'Pilih tanggal mulai' : _fmtDate(startDate!.toIso8601String()),
                    () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) setLocal(() => startDate = d);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Tanggal selesai
                  _dialogLabel('Tanggal Selesai'),
                  _dateField(
                    ctx,
                    endDate == null ? 'Pilih tanggal selesai' : _fmtDate(endDate!.toIso8601String()),
                    () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: endDate ?? startDate ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) setLocal(() => endDate = d);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Lokasi
                  _dialogLabel('Lokasi'),
                  _dialogField(locCtrl, 'Contoh: Aula Graha Wiyata SMKN 8'),
                  const SizedBox(height: 10),

                  // Kuota
                  _dialogLabel('Kuota Peserta'),
                  TextFormField(
                    controller: quotaCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDeco('Contoh: 50'),
                  ),
                  const SizedBox(height: 10),

                  // Deskripsi
                  _dialogLabel('Deskripsi'),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: _inputDeco('Deskripsi singkat kegiatan...'),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setLocal(() => saving = true);
                      try {
                        await Backend.ensureInitialized();
                        if (isEdit) {
                          await _repo.updateTraining(
                            existing!['id'].toString(),
                            {
                              'title': titleCtrl.text.trim(),
                              'description': descCtrl.text.trim().isEmpty
                                  ? null
                                  : descCtrl.text.trim(),
                              'extracurricular_id': selectedEkskulId,
                              'start_date': startDate?.toIso8601String().substring(0, 10),
                              'end_date': endDate?.toIso8601String().substring(0, 10),
                              'location': locCtrl.text.trim().isEmpty
                                  ? null
                                  : locCtrl.text.trim(),
                              'quota': int.tryParse(quotaCtrl.text),
                            },
                          );
                        } else {
                          await _repo.createTraining(
                            extracurricularId: selectedEkskulId,
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim().isEmpty
                                ? null
                                : descCtrl.text.trim(),
                            startDate: startDate,
                            endDate: endDate,
                            location: locCtrl.text.trim().isEmpty
                                ? null
                                : locCtrl.text.trim(),
                            quota: int.tryParse(quotaCtrl.text),
                          );
                        }
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        toast(context,
                            isEdit ? 'Diklat berhasil diperbarui.' : 'Diklat berhasil ditambahkan.');
                        await _loadData();
                      } catch (e) {
                        setLocal(() => saving = false);
                        if (mounted) {
                          toast(context, 'Gagal menyimpan: $e');
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Diklat'),
            ),
          ],
        ),
      ),
    );
    titleCtrl.dispose();
    descCtrl.dispose();
    locCtrl.dispose();
    quotaCtrl.dispose();
  }

  // ── Hapus Diklat ──────────────────────────────────────────
  Future<void> _deleteDiklat(Map<String, dynamic> row) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Agenda Diklat?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Agenda "${row['title']}" akan dihapus permanen dari database.\n\nTindakan ini tidak dapat dibatalkan.'),
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
      await _repo.deleteTraining(row['id'].toString());
      if (!mounted) return;
      toast(context, 'Agenda diklat berhasil dihapus.');
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      toast(context, 'Gagal menghapus: $e');
    }
  }

  // ── Export CSV ────────────────────────────────────────────
  void _exportCsv() {
    final buf = StringBuffer('Judul,Ekstrakurikuler,Tanggal Mulai,Tanggal Selesai,Lokasi,Kuota,Status\n');
    for (final r in _filtered) {
      final ekskul = (r['extracurriculars'] as Map?)?['name'] ?? '-';
      final status = _statusCategory(r);
      buf.writeln(
        '"${r['title'] ?? ''}",'
        '"$ekskul",'
        '"${_fmtDate(r['start_date']?.toString())}",'
        '"${_fmtDate(r['end_date']?.toString())}",'
        '"${r['location'] ?? '-'}",'
        '"${r['quota'] ?? '-'}",'
        '"$status"',
      );
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    toast(context, 'Data CSV disalin ke clipboard (${_filtered.length} agenda).');
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return AdminScreen(
      title: 'Diklat & Kaderisasi',
      subtitle: 'Kelola seluruh agenda pendidikan & pelatihan ekstrakurikuler.',
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
          Expanded(
            child: _StatBox('Total', '$_countAll', 'Agenda', C.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatBox('Akan Datang', '$_countUpc', 'Agenda', C.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatBox('Berjalan', '$_countRun', 'Aktif', C.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatBox('Selesai', '$_countDone', 'Agenda', C.muted),
          ),
        ]),
        const SizedBox(height: 4),

        // ── Tambah Button
        Btn(
          'Tambah Agenda Diklat',
          icon: Icons.add_circle_outline,
          expand: true,
          h: 50,
          onTap: () => _showTambahDialog(),
        ),
        const SizedBox(height: 4),

        // ── Search
        SearchBox(
          'Cari nama diklat, ekskul, atau lokasi...',
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
            _filterChip('Semua ($_countAll)', 0),
            const SizedBox(width: 8),
            _filterChip('Akan Datang ($_countUpc)', 1, activeColor: C.orange, activeBg: C.orangeSoft),
            const SizedBox(width: 8),
            _filterChip('Berjalan ($_countRun)', 2, activeColor: C.green, activeBg: C.greenSoft),
            const SizedBox(width: 8),
            _filterChip('Selesai ($_countDone)', 3, activeColor: C.muted, activeBg: const Color(0xFFE5E8EF)),
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
              const Icon(Icons.school_outlined, size: 48, color: C.muted),
              const SizedBox(height: 10),
              Text(
                _search.isNotEmpty
                    ? 'Tidak ada diklat yang cocok'
                    : _chip == 0
                        ? 'Belum ada agenda diklat'
                        : 'Tidak ada diklat ${['', 'akan datang', 'berjalan', 'selesai'][_chip]}',
                style: T.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Tekan "Tambah Agenda Diklat" untuk membuat agenda baru.',
                style: T.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Btn('Tambah Diklat', icon: Icons.add, onTap: () => _showTambahDialog()),
            ]),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Menampilkan ${filtered.length} dari $_countAll agenda',
              style: T.body.copyWith(fontSize: 12),
            ),
          ),
          ...filtered.map(_buildCard),
        ],

        const SizedBox(height: 4),
        Btn.white('Muat Ulang Data', icon: Icons.refresh, expand: true, h: 48, onTap: _loadData),
      ],
    );
  }

  // ── Chip Filter ───────────────────────────────────────────
  Widget _filterChip(
    String label,
    int idx, {
    Color activeColor = C.primary,
    Color activeBg = C.soft,
  }) {
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
            color: active ? activeColor : C.line,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? activeColor : C.muted,
          ),
        ),
      ),
    );
  }

  // ── Diklat Card ───────────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> row) {
    final title = row['title']?.toString() ?? 'Tanpa Judul';
    final ekskulName =
        ((row['extracurriculars'] as Map?)?['name'] ?? 'Umum').toString();
    final location = row['location']?.toString() ?? '-';
    final quota = row['quota'] as int?;
    final startRaw = row['start_date']?.toString();
    final endRaw = row['end_date']?.toString();
    final desc = row['description']?.toString() ?? '';

    final startStr = _fmtDate(startRaw);
    final endStr = _fmtDate(endRaw);
    final dateRange = endRaw != null && endRaw != startRaw
        ? '$startStr – $endStr'
        : startStr;

    final cat = _statusCategory(row);
    final Color statusColor;
    final Color statusBg;
    final IconData statusIcon;
    switch (cat) {
      case 'Berjalan':
        statusColor = C.green;
        statusBg = C.greenSoft;
        statusIcon = Icons.play_circle_outline;
        break;
      case 'Selesai':
        statusColor = C.muted;
        statusBg = const Color(0xFFE5E8EF);
        statusIcon = Icons.check_circle_outline;
        break;
      default: // Akan Datang
        statusColor = C.orange;
        statusBg = C.orangeSoft;
        statusIcon = Icons.access_time;
    }

    return SCard(
      border: cat == 'Berjalan' ? C.green : C.line,
      borderWidth: cat == 'Berjalan' ? 1.5 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Pill(cat, statusBg, statusColor),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Detail rows
          _infoRow(Icons.calendar_month_outlined, 'Tanggal', dateRange),
          const SizedBox(height: 4),
          _infoRow(Icons.location_on_outlined, 'Lokasi', location),
          if (quota != null) ...[
            const SizedBox(height: 4),
            _infoRow(Icons.groups_outlined, 'Kuota', '$quota peserta'),
          ],
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(desc,
                style: T.body.copyWith(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],

          // ── Action buttons
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Btn(
                  'Edit',
                  icon: Icons.edit_outlined,
                  h: 40,
                  onTap: () => _showTambahDialog(row),
                ),
              ),
              const SizedBox(width: 8),
              Btn.danger(
                'Hapus',
                icon: Icons.delete_outline,
                h: 40,
                onTap: () => _deleteDiklat(row),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info row helper ───────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 15, color: C.muted),
          const SizedBox(width: 6),
          Text('$label: ',
              style: T.body.copyWith(fontSize: 12, color: C.muted)),
          Expanded(
            child: Text(
              value,
              style: T.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: C.ink),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  // ── Dialog helpers ────────────────────────────────────────
  Widget _dialogLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: C.ink)),
      );

  Widget _dialogField(
    TextEditingController ctrl,
    String hint, {
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        validator: validator,
        decoration: _inputDeco(hint),
      );

  Widget _dateField(BuildContext ctx, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.line),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: C.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        color: label.startsWith('Pilih') ? C.muted : C.ink)),
              ),
            ],
          ),
        ),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}

// ── Stat Box kecil ────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _StatBox(this.label, this.value, this.sub, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
          boxShadow: const [
            BoxShadow(color: Color(0x0D1E3A8A), blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: T.body.copyWith(fontSize: 11, color: C.muted)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(sub,
                style: T.body.copyWith(fontSize: 11, color: color)),
          ],
        ),
      );
}
