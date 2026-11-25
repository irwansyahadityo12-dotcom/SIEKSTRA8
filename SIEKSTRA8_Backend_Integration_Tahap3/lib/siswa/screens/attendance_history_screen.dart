import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'permission_form_screen.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});
  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final _repo = SiekstraRepository();
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;
  String _filter = 'Semua';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _repo.getMyAttendance();
      if (mounted) setState(() => _rows = rows);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Hadir':
        return C.green;
      case 'Izin':
        return C.primary;
      case 'Sakit':
        return C.amber;
      default:
        return C.red;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Hadir':
        return C.greenBg;
      case 'Izin':
        return C.soft;
      case 'Sakit':
        return C.amberBg;
      default:
        return C.redBg;
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    final dt = DateTime.tryParse(value.toString());
    if (dt == null) return value.toString();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final dayName = days[(dt.weekday - 1) % 7];
    final monthName = months[(dt.month - 1) % 12];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  void _showAttendanceDetail(Map<String, dynamic> row) {
    final session = row['attendance_sessions'] as Map<String, dynamic>? ?? {};
    final extra = session['extracurriculars'] as Map<String, dynamic>? ?? {};
    final extraName = (extra['name'] ?? 'Ekstrakurikuler').toString();
    final title = (session['title'] ?? 'Pertemuan / Sesi Latihan').toString();
    final status = (row['status'] ?? '-').toString();
    final isApprovedPermission = row['is_approved_permission'] == true;
    final date = _formatDate(session['session_date'] ?? row['marked_at']);
    final note = (row['note'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(extraName.toUpperCase(), fg: C.primary, bg: C.soft, size: 9.5),
                      const SizedBox(height: 4),
                      tx(title, size: 17, w: FontWeight.w800),
                    ],
                  ),
                ),
                Pill(
                  status,
                  fg: _statusColor(status),
                  bg: _statusBg(status),
                  size: 11,
                ),
              ],
            ),
            const Divider(height: 24),
            _infoRow(Icons.calendar_today_outlined, 'Tanggal Pertemuan', date),
            if (isApprovedPermission)
              _infoRow(
                Icons.verified_outlined,
                'Status Verifikasi',
                'Otomatis tercatat dari Pengajuan Izin yang Disetujui Pembina',
                highlight: true,
              ),
            if (note.isNotEmpty)
              _infoRow(Icons.notes_rounded, 'Keterangan / Catatan', note),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup Detail Presensi', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: highlight ? C.green : C.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tx(label, size: 11, color: C.muted),
                const SizedBox(height: 2),
                tx(
                  value,
                  size: 13,
                  w: highlight ? FontWeight.w700 : FontWeight.w600,
                  color: highlight ? C.green : C.text,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hadirCount = _rows.where((r) => r['status'] == 'Hadir').length;
    final izinCount = _rows.where((r) => r['status'] == 'Izin').length;
    final sakitCount = _rows.where((r) => r['status'] == 'Sakit').length;
    final alfaCount = _rows.where((r) => r['status'] == 'Alfa').length;

    final shown = _rows.where((r) => _filter == 'Semua' || r['status'] == _filter).toList();
    final percent = _rows.isEmpty ? 0 : (hadirCount * 100 ~/ _rows.length);

    return Scaffold(
      appBar: subAppBar(context, 'Riwayat Presensi', badge: 'SMKN 8'),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Ringkasan Kehadiran
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_outlined, size: 18, color: C.primary),
                            const SizedBox(width: 6),
                            tx('RINGKASAN KEHADIRAN SISWA', size: 11, w: FontWeight.w800, color: C.muted),
                            const Spacer(),
                            Pill(
                              _rows.isEmpty ? 'Belum Ada Sesi' : '$percent% Kehadiran',
                              fg: percent >= 75 ? C.green : C.amber,
                              bg: percent >= 75 ? C.greenBg : C.amberBg,
                              size: 10,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        tx(
                          '$hadirCount dari ${_rows.length} Sesi Hadir',
                          size: 19,
                          w: FontWeight.w800,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _rows.isEmpty ? 0 : hadirCount / _rows.length,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFEFF2F8),
                            color: percent >= 75 ? C.green : C.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Status Breakdown Row
                        Row(
                          children: [
                            _statMini('Hadir', hadirCount, C.green, C.greenBg),
                            const SizedBox(width: 6),
                            _statMini('Izin', izinCount, C.primary, C.soft),
                            const SizedBox(width: 6),
                            _statMini('Sakit', sakitCount, C.amber, C.amberBg),
                            const SizedBox(width: 6),
                            _statMini('Alfa', alfaCount, C.red, C.redBg),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('Semua', _rows.length),
                        const SizedBox(width: 8),
                        _filterChip('Hadir', hadirCount),
                        const SizedBox(width: 8),
                        _filterChip('Izin', izinCount),
                        const SizedBox(width: 8),
                        _filterChip('Sakit', sakitCount),
                        const SizedBox(width: 8),
                        _filterChip('Alfa', alfaCount),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    AppCard(
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_off_outlined, color: C.red, size: 36),
                          const SizedBox(height: 8),
                          tx('Gagal Memuat Presensi', size: 15, w: FontWeight.w800),
                          const SizedBox(height: 4),
                          tx(_error!, size: 12, color: C.muted, align: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white),
                            onPressed: _load,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  else if (shown.isEmpty)
                    AppCard(
                      child: Column(
                        children: [
                          const Icon(Icons.fact_check_outlined, size: 42, color: C.muted),
                          const SizedBox(height: 10),
                          tx('Belum Ada Riwayat Presensi', size: 15, w: FontWeight.w800),
                          const SizedBox(height: 4),
                          tx(
                            _filter != 'Semua'
                                ? 'Tidak ada riwayat presensi dengan status "$_filter".'
                                : 'Riwayat kehadiran akan otomatis tercatat saat sesi dimulai atau ketika pengajuan izinmu disetujui Pembina.',
                            size: 12,
                            color: C.muted,
                            align: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    for (final row in shown) _attendanceCard(row),
                ],
              ),
            ),
          ),
          // Bottom CTA: Pengajuan Izin Baru
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: C.border)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  'Ajukan Izin / Sakit Baru',
                  icon: Icons.note_add_outlined,
                  trailingIcon: false,
                  color: const Color(0xFFB45309),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PermissionFormScreen()),
                    );
                    _load();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statMini(String label, int count, Color fg, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fg),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int count) {
    final isSelected = _filter == label;
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = label),
      selectedColor: C.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : C.text,
      ),
      side: BorderSide(color: isSelected ? C.primary : C.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _attendanceCard(Map<String, dynamic> row) {
    final session = row['attendance_sessions'] as Map<String, dynamic>? ?? {};
    final extra = session['extracurriculars'] as Map<String, dynamic>? ?? {};
    final extraName = (extra['name'] ?? 'Ekstrakurikuler').toString();
    final title = (session['title'] ?? 'Pertemuan Sesi').toString();
    final status = (row['status'] ?? '-').toString();
    final isApprovedPermission = row['is_approved_permission'] == true;
    final date = _formatDate(session['session_date'] ?? row['marked_at']);
    final note = (row['note'] ?? '').toString();

    return AppCard(
      onTap: () => _showAttendanceDetail(row),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Pill(status, fg: _statusColor(status), bg: _statusBg(status)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$extraName • $date',
                  style: const TextStyle(fontSize: 11.5, color: C.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isApprovedPermission)
                Pill('Izin Disetujui', fg: C.green, bg: C.greenBg, size: 9),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: C.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 13, color: C.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(fontSize: 11.5, color: C.text),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
