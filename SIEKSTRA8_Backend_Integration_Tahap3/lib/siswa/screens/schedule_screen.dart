import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'attendance_history_screen.dart';
import 'permission_form_screen.dart';

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
  int _selectedFilter = 0; // 0: Semua, 1: Mendatang, 2: Hari Ini, 3: Selesai
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _repo.getMySchedules();
      if (mounted) setState(() => _rows = rows);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _formatFullDate(DateTime? dt) {
    if (dt == null) return '-';
    final dayName = _days[(dt.weekday - 1) % 7];
    final monthName = _months[(dt.month - 1) % 12];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  int _dateStatus(DateTime? dt) {
    if (dt == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.compareTo(today);
    if (diff == 0) return 1; // Hari Ini
    if (diff > 0) return 2;  // Mendatang
    return 3;                // Selesai
  }

  List<Map<String, dynamic>> get _filteredRows {
    return _rows.where((row) {
      final dt = _parseDate(row['activity_date']);
      final status = _dateStatus(dt);

      if (_selectedFilter == 1 && status != 2 && status != 1) return false;
      if (_selectedFilter == 2 && status != 1) return false;
      if (_selectedFilter == 3 && status != 3) return false;

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final title = (row['title'] ?? '').toString().toLowerCase();
        final extra = row['extracurriculars'] is Map ? (row['extracurriculars']['name'] ?? '').toString().toLowerCase() : '';
        final location = (row['location'] ?? '').toString().toLowerCase();
        final notes = (row['notes'] ?? '').toString().toLowerCase();

        if (!title.contains(q) && !extra.contains(q) && !location.contains(q) && !notes.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showScheduleDetail(Map<String, dynamic> row) {
    final extra = row['extracurriculars'] as Map<String, dynamic>? ?? {};
    final extraName = extra['name']?.toString() ?? 'Ekstrakurikuler';
    final title = row['title']?.toString() ?? 'Sesi Latihan';
    final dt = _parseDate(row['activity_date']);
    final dateStr = _formatFullDate(dt);
    final timeStr = [row['start_time'], row['end_time']].where((e) => e != null && e.toString().isNotEmpty).join(' – ');
    final location = row['location']?.toString() ?? '';
    final notes = row['notes']?.toString() ?? '';
    final status = _dateStatus(dt);

    final statusLabel = status == 1 ? 'Hari Ini' : status == 2 ? 'Mendatang' : 'Selesai';
    final statusFg = status == 1 ? C.green : status == 2 ? C.primary : C.muted;
    final statusBg = status == 1 ? C.greenBg : status == 2 ? C.soft : const Color(0xFFF1F4FC);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(extraName.toUpperCase(), fg: C.primary, bg: C.soft, size: 10),
                      const SizedBox(height: 6),
                      tx(title, size: 18, w: FontWeight.w800),
                    ],
                  ),
                ),
                Pill(statusLabel, fg: statusFg, bg: statusBg, size: 10),
              ],
            ),
            const Divider(height: 24),
            _detailRow(Icons.calendar_today_outlined, 'Tanggal Pelaksanaan', dateStr),
            if (timeStr.isNotEmpty)
              _detailRow(Icons.access_time_rounded, 'Waktu Sesi', '$timeStr WIB'),
            if (location.isNotEmpty)
              _detailRow(Icons.location_on_outlined, 'Lokasi / Ruangan', location),
            if (notes.isNotEmpty)
              _detailRow(Icons.description_outlined, 'Catatan & Perlengkapan', notes),
            const SizedBox(height: 16),
            // Tombol / Aksi Absen & Presensi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fact_check_outlined, color: C.green, size: 20),
                      const SizedBox(width: 8),
                      tx('Presensi & Kehadiran Sesi', size: 13, w: FontWeight.w800, color: C.green),
                    ],
                  ),
                  const SizedBox(height: 4),
                  tx(
                    'Pantau rekap kehadiran atau cek status presensi yang telah diverifikasi oleh Pembina.',
                    size: 11,
                    color: C.muted,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.checklist_rounded, size: 18),
                      label: const Text('Buka Status & Riwayat Presensi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Tombol Izin
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB45309),
                  side: const BorderSide(color: Color(0xFFFDE68A)),
                  backgroundColor: const Color(0xFFFFFBEB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                label: const Text('Berhalangan Hadir? Ajukan Izin / Sakit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PermissionFormScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup Detail', style: TextStyle(color: C.muted)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: C.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tx(label, size: 11, color: C.muted),
                const SizedBox(height: 2),
                tx(value, size: 13.5, w: FontWeight.w700),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(int idx, String label) {
    final isSelected = _selectedFilter == idx;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = idx),
      selectedColor: C.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : C.text,
      ),
      side: BorderSide(color: isSelected ? C.primary : C.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcomingCount = _rows.where((r) {
      final dt = _parseDate(r['activity_date']);
      return dt != null && DateTime(dt.year, dt.month, dt.day).isAfter(today);
    }).length;
    final todayCount = _rows.where((r) {
      final dt = _parseDate(r['activity_date']);
      return dt != null && DateTime(dt.year, dt.month, dt.day).isAtSameMomentAs(today);
    }).length;
    final pastCount = _rows.where((r) {
      final dt = _parseDate(r['activity_date']);
      return dt != null && DateTime(dt.year, dt.month, dt.day).isBefore(today);
    }).length;

    final filtered = _filteredRows;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text('Jadwal Kegiatan & Latihan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        actions: [
          IconButton(
            tooltip: 'Riwayat Presensi',
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Segarkan Jadwal',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Quick Attendance Header Banner
              AppCard(
                color: const Color(0xFFF0FDF4),
                borderColor: const Color(0xFFBBF7D0),
                child: Row(
                  children: [
                    const IconBox(
                      Icons.fact_check_outlined,
                      color: C.green,
                      bg: Colors.white,
                      size: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tx('Presensi & Kehadiran Siswa', size: 13.5, w: FontWeight.w800, color: C.green),
                          const SizedBox(height: 2),
                          tx('Lihat riwayat status kehadiran pada sesi latihan.', size: 11, color: C.muted),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
                      ),
                      child: const Text('Presensi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: C.border),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari agenda, ekstrakurikuler, atau lokasi...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: C.muted),
                    prefixIcon: const Icon(Icons.search, size: 20, color: C.muted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(height: 12),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip(0, 'Semua (${_rows.length})'),
                    const SizedBox(width: 8),
                    _chip(1, 'Mendatang ($upcomingCount)'),
                    const SizedBox(width: 8),
                    _chip(2, 'Hari Ini ($todayCount)'),
                    const SizedBox(width: 8),
                    _chip(3, 'Selesai ($pastCount)'),
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
                      tx('Gagal Memuat Jadwal', size: 15, w: FontWeight.w800),
                      const SizedBox(height: 4),
                      tx(_error!, size: 12, color: C.muted, align: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: C.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _load,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              else if (filtered.isEmpty)
                AppCard(
                  child: Column(
                    children: [
                      const Icon(Icons.event_busy_outlined, size: 44, color: C.muted),
                      const SizedBox(height: 10),
                      tx('Tidak Ada Jadwal Kegiatan', size: 15, w: FontWeight.w800),
                      const SizedBox(height: 4),
                      tx(
                        _selectedFilter != 0 || _searchQuery.isNotEmpty
                            ? 'Tidak ditemukan sesi kegiatan yang cocok dengan filter.'
                            : 'Belum ada agenda jadwal untuk ekstrakurikuler yang kamu ikuti.',
                        size: 12,
                        color: C.muted,
                        align: TextAlign.center,
                      ),
                      if (_selectedFilter != 0 || _searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 0;
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          child: const Text('Tampilkan Semua Jadwal'),
                        ),
                      ],
                    ],
                  ),
                )
              else
                for (final row in filtered) _scheduleCard(row),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scheduleCard(Map<String, dynamic> row) {
    final extra = row['extracurriculars'] as Map<String, dynamic>? ?? {};
    final extraName = extra['name']?.toString() ?? 'Ekstrakurikuler';
    final title = row['title']?.toString() ?? 'Sesi Latihan';
    final dt = _parseDate(row['activity_date']);
    final time = [row['start_time'], row['end_time']].where((e) => e != null && e.toString().isNotEmpty).join(' – ');
    final location = row['location']?.toString() ?? '';
    final status = _dateStatus(dt);

    final statusLabel = status == 1 ? 'Hari Ini' : status == 2 ? 'Mendatang' : 'Selesai';
    final statusFg = status == 1 ? C.green : status == 2 ? C.primary : C.muted;
    final statusBg = status == 1 ? C.greenBg : status == 2 ? C.soft : const Color(0xFFF1F4FC);

    final dayNum = dt != null ? dt.day.toString() : '-';
    final monthShort = dt != null ? _shortMonths[(dt.month - 1) % 12] : '-';
    final dayName = dt != null ? _days[(dt.weekday - 1) % 7] : '-';

    return AppCard(
      onTap: () => _showScheduleDetail(row),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Styled Date Box
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: status == 1 ? C.greenBg : status == 2 ? C.soft : const Color(0xFFF1F4FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: status == 1 ? const Color(0xFFBBF7D0) : status == 2 ? const Color(0xFFD6E4FF) : C.border,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      dayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: statusFg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dayNum,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: statusFg,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      monthShort,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusFg,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Schedule Title & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            extraName,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: C.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Pill(statusLabel, fg: statusFg, bg: statusBg, size: 9),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: C.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (time.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 13, color: C.muted),
                          const SizedBox(width: 4),
                          Text(
                            '$time WIB',
                            style: const TextStyle(fontSize: 11.5, color: C.muted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: C.muted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(fontSize: 11.5, color: C.muted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          // Action Buttons Bar
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.how_to_reg_outlined, size: 14, color: C.green),
                        SizedBox(width: 4),
                        Text(
                          'Cek Presensi',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: C.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showScheduleDetail(row),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                    decoration: BoxDecoration(
                      color: C.soft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD6E4FF)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.info_outline_rounded, size: 14, color: C.primary),
                        SizedBox(width: 4),
                        Text(
                          'Detail Sesi',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: C.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
