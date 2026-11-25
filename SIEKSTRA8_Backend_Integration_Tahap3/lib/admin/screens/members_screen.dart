import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/siekstra_repository.dart';
import '../../app/backend.dart';
import '../theme.dart';
import '../widgets/common.dart';

// ============================================================
//  Admin Members Screen
//  Menampilkan & mengelola seluruh keanggotaan (membership)
//  dari semua ekstrakurikuler di satu tampilan terpadu.
// ============================================================

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _repo = SiekstraRepository();
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _rows = [];
  List<Map<String, dynamic>> _ekskulList = [];
  bool _loading = true;
  String? _error;

  // Filter state
  String _statusFilter = 'all'; // 'all' | 'pending' | 'approved' | 'rejected'
  String _ekskulFilter = 'all'; // 'all' | ekskul id
  String _search = '';

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

  // ── Load Data ──────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Backend.ensureInitialized();
      final results = await Future.wait([
        _repo.getMembershipsForAdmin(),
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

  // ── Review membership (approve / reject) ───────────────────
  Future<void> _review(Map<String, dynamic> row, bool approve) async {
    final id = row['id']?.toString() ?? '';
    if (id.isEmpty) return;

    if (!approve) {
      // Confirm dialog sebelum menolak
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tolak Pendaftaran?', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Text(
            'Anda akan menolak pendaftaran dari\n'
            '${(row['profiles'] as Map?)?['full_name'] ?? 'siswa ini'}.\n\n'
            'Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tolak', style: TextStyle(color: C.red)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      await _repo.reviewMembership(id, approve: approve);
      if (!mounted) return;
      toast(context, approve ? 'Pendaftaran berhasil disetujui.' : 'Pendaftaran berhasil ditolak.');
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      toast(context, 'Gagal menyimpan keputusan: $e');
    }
  }

  // ── Bulk reject semua pending ──────────────────────────────
  Future<void> _bulkRejectPending() async {
    final pending = _rows.where((r) => r['status'] == 'pending').toList();
    if (pending.isEmpty) {
      toast(context, 'Tidak ada pendaftaran yang menunggu.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tolak Semua?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Anda akan menolak ${pending.length} pendaftaran sekaligus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Tolak Semua', style: TextStyle(color: C.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await Backend.ensureInitialized();
      for (final row in pending) {
        await _repo.reviewMembership(row['id'].toString(), approve: false);
      }
      if (!mounted) return;
      toast(context, '${pending.length} pendaftaran ditolak.');
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      toast(context, 'Gagal menolak semua: $e');
    }
  }

  // ── Export CSV ─────────────────────────────────────────────
  void _exportCsv() {
    final buf = StringBuffer('Nama,NIS/NISN,Kelas,Jurusan,Ekstrakurikuler,Status,Tanggal Daftar\n');
    for (final row in _filtered) {
      final p = row['profiles'] as Map? ?? {};
      final e = row['extracurriculars'] as Map? ?? {};
      final date = DateTime.tryParse(row['created_at']?.toString() ?? '');
      final dateStr = date == null
          ? '-'
          : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      buf.writeln(
        '"${p['full_name'] ?? ''}",'
        '"${p['identifier'] ?? ''}",'
        '"${p['class_name'] ?? ''}",'
        '"${p['major'] ?? ''}",'
        '"${e['name'] ?? ''}",'
        '"${row['status'] ?? ''}",'
        '"$dateStr"',
      );
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    toast(context, 'Data CSV disalin ke clipboard (${_filtered.length} baris).');
  }

  // ── Filtered list ──────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    return _rows.where((row) {
      // Filter status
      if (_statusFilter != 'all' && row['status'] != _statusFilter) return false;

      // Filter ekskul
      if (_ekskulFilter != 'all') {
        final extra = row['extracurriculars'] as Map? ?? {};
        if (extra['id']?.toString() != _ekskulFilter) return false;
      }

      // Filter search
      if (_search.trim().isNotEmpty) {
        final q = _search.toLowerCase().trim();
        final p = row['profiles'] as Map? ?? {};
        final e = row['extracurriculars'] as Map? ?? {};
        final match = (p['full_name'] ?? '').toString().toLowerCase().contains(q) ||
            (p['identifier'] ?? '').toString().toLowerCase().contains(q) ||
            (p['class_name'] ?? '').toString().toLowerCase().contains(q) ||
            (e['name'] ?? '').toString().toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Pending first, then by date desc
        final sa = a['status']?.toString() ?? '';
        final sb = b['status']?.toString() ?? '';
        if (sa == 'pending' && sb != 'pending') return -1;
        if (sb == 'pending' && sa != 'pending') return 1;
        final da = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2000);
        final db = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2000);
        return db.compareTo(da);
      });
  }

  // ── Stats ──────────────────────────────────────────────────
  int get _totalAll => _rows.length;
  int get _totalPending => _rows.where((r) => r['status'] == 'pending').length;
  int get _totalApproved => _rows.where((r) => r['status'] == 'approved').length;
  int get _totalRejected => _rows.where((r) => r['status'] == 'rejected').length;

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      title: 'Manajemen Anggota',
      subtitle: 'Kelola keanggotaan siswa di seluruh ekstrakurikuler.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Export CSV',
            onPressed: _filtered.isEmpty ? null : _exportCsv,
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
            child: StatBox('Total', '$_totalAll', 'Semua keanggotaan',
                valueColor: C.primary, subColor: C.muted),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatBox('Menunggu', '$_totalPending', 'Perlu ditinjau',
                valueColor: C.orange, subColor: C.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatBox('Aktif', '$_totalApproved', 'Disetujui',
                valueColor: C.green, subColor: C.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatBox('Ditolak', '$_totalRejected', 'Tidak lulus',
                valueColor: C.red, subColor: C.red),
          ),
        ]),
        const SizedBox(height: 4),

        // ── Search
        SearchBox(
          'Cari nama, NIS/NISN, kelas, atau ekskul...',
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _search = v),
          onClear: () {
            _searchCtrl.clear();
            setState(() => _search = '');
          },
        ),

        // ── Status Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _chip('Semua (${_rows.length})', 'all'),
            const SizedBox(width: 8),
            _chip('Menunggu ($_totalPending)', 'pending',
                activeColor: C.orange, activeBg: C.orangeSoft),
            const SizedBox(width: 8),
            _chip('Disetujui ($_totalApproved)', 'approved',
                activeColor: C.green, activeBg: C.greenSoft),
            const SizedBox(width: 8),
            _chip('Ditolak ($_totalRejected)', 'rejected',
                activeColor: C.red, activeBg: C.redSoft),
          ]),
        ),
        const SizedBox(height: 10),

        // ── Ekskul Filter Dropdown
        if (_ekskulList.isNotEmpty)
          SCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            bottom: 12,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _ekskulFilter,
                icon: const Icon(Icons.arrow_drop_down, color: C.muted),
                style: T.body,
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('Semua Ekstrakurikuler')),
                  ..._ekskulList.map((e) => DropdownMenuItem(
                        value: e['id']?.toString() ?? '',
                        child: Text(e['name']?.toString() ?? 'Tanpa Nama'),
                      )),
                ],
                onChanged: (v) => setState(() => _ekskulFilter = v ?? 'all'),
              ),
            ),
          ),

        // ── Bulk action bar (hanya tampil jika ada pending)
        if (_totalPending > 0 && _statusFilter != 'approved' && _statusFilter != 'rejected')
          SCard(
            color: C.orangeSoft,
            border: C.orange,
            bottom: 12,
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: C.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$_totalPending pendaftaran menunggu persetujuan.',
                  style: T.body.copyWith(color: C.orange, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _bulkRejectPending,
                child: const Text('Tolak Semua',
                    style: TextStyle(color: C.red, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ]),
          ),

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
        else if (_filtered.isEmpty)
          SCard(
            padding: const EdgeInsets.all(32),
            child: Column(children: [
              const Icon(Icons.groups_outlined, size: 48, color: C.muted),
              const SizedBox(height: 10),
              Text(
                _search.isNotEmpty
                    ? 'Tidak ada anggota yang cocok'
                    : _statusFilter == 'pending'
                        ? 'Tidak ada pendaftaran menunggu'
                        : _statusFilter == 'approved'
                            ? 'Belum ada anggota disetujui'
                            : _statusFilter == 'rejected'
                                ? 'Belum ada yang ditolak'
                                : 'Belum ada data keanggotaan',
                style: T.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Data akan muncul setelah siswa mendaftar ekskul.',
                style: T.body,
                textAlign: TextAlign.center,
              ),
            ]),
          )
        else
          ...[ 
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Menampilkan ${_filtered.length} data',
                  style: T.body.copyWith(fontSize: 12)),
            ),
            ..._filtered.map(_buildMemberCard),
          ],

        // ── Footer refresh
        const SizedBox(height: 4),
        Btn.white('Muat Ulang Data', icon: Icons.refresh, expand: true, h: 48, onTap: _loadData),
      ],
    );
  }

  // ── Status Filter Chip ────────────────────────────────────
  Widget _chip(
    String label,
    String value, {
    Color activeColor = C.primary,
    Color activeBg = C.soft,
  }) {
    final active = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
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

  // ── Member Card ────────────────────────────────────────────
  Widget _buildMemberCard(Map<String, dynamic> row) {
    final profile = row['profiles'] as Map? ?? {};
    final ekskul = row['extracurriculars'] as Map? ?? {};
    final status = row['status']?.toString() ?? 'pending';
    final isPending = status == 'pending';

    final name = profile['full_name']?.toString() ?? 'Siswa';
    final nis = profile['identifier']?.toString() ?? '-';
    final kelas = profile['class_name']?.toString() ?? '-';
    final jurusan = profile['major']?.toString() ?? '-';
    final ekskulName = ekskul['name']?.toString() ?? 'Ekstrakurikuler';

    final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
    final joinedAt = DateTime.tryParse(row['joined_at']?.toString() ?? '');
    final displayDate = joinedAt ?? createdAt;
    final dateLabel = displayDate == null
        ? '-'
        : '${displayDate.day.toString().padLeft(2, '0')}/'
            '${displayDate.month.toString().padLeft(2, '0')}/'
            '${displayDate.year}';

    // Status styling
    final statusLabel = status == 'approved'
        ? 'Aktif'
        : status == 'rejected'
            ? 'Ditolak'
            : 'Menunggu';
    final statusColor = status == 'approved'
        ? C.green
        : status == 'rejected'
            ? C.red
            : C.orange;
    final statusBg = status == 'approved'
        ? C.greenSoft
        : status == 'rejected'
            ? C.redSoft
            : C.orangeSoft;

    return SCard(
      border: isPending ? C.orange : C.line,
      borderWidth: isPending ? 1.5 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: nama + status pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: C.soft,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: C.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: T.title.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('NIS/NISN: $nis  •  $kelas',
                        style: T.body.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Pill(statusLabel, statusBg, statusColor),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Detail rows
          _kv(Icons.school_outlined, 'Jurusan', jurusan),
          const SizedBox(height: 4),
          _kv(Icons.groups_outlined, 'Ekstrakurikuler', ekskulName),
          const SizedBox(height: 4),
          _kv(
            status == 'approved'
                ? Icons.check_circle_outline
                : status == 'rejected'
                    ? Icons.cancel_outlined
                    : Icons.access_time,
            status == 'approved'
                ? 'Bergabung'
                : status == 'rejected'
                    ? 'Tanggal Tolak'
                    : 'Tanggal Daftar',
            dateLabel,
          ),

          // ── Action buttons (hanya untuk pending)
          if (isPending) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Btn.danger(
                    'Tolak',
                    icon: Icons.close_rounded,
                    h: 42,
                    onTap: () => _review(row, false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Btn(
                    'Setujui',
                    icon: Icons.check_rounded,
                    bg: C.green,
                    fg: Colors.white,
                    h: 42,
                    onTap: () => _review(row, true),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── KV Row Helper ──────────────────────────────────────────
  Widget _kv(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: C.muted),
        const SizedBox(width: 6),
        Text('$label: ', style: T.body.copyWith(fontSize: 12, color: C.muted)),
        Expanded(
          child: Text(
            value,
            style: T.body.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: C.ink),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

