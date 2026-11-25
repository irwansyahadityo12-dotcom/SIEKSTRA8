import 'package:flutter/material.dart';
import '../../app/backend.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'record_form_screen.dart';
import 'record_detail_screen.dart';

class DiklatScreen extends StatefulWidget {
  const DiklatScreen({super.key});

  @override
  State<DiklatScreen> createState() => _DiklatScreenState();
}

class _DiklatScreenState extends State<DiklatScreen> {
  final SiekstraRepository _repo = SiekstraRepository();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  int _selectedFilterChip = 0; // 0: Semua Diklat, 1: Pendaftaran, 2: Siap Dilaksanakan, 3: Selesai

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _coachExtras = [];
  Map<String, dynamic>? _selectedExtra;
  List<Map<String, dynamic>> _diklatItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Backend.ensureInitialized();
      final extras = await _repo.getCoachExtracurriculars();

      if (!mounted) return;

      if (extras.isNotEmpty) {
        _coachExtras = extras;
        _selectedExtra = extras.first;
      } else {
        final allExtras = await _repo.getExtracurriculars();
        if (!mounted) return;
        _coachExtras = allExtras;
        if (allExtras.isNotEmpty) {
          _selectedExtra = allExtras.first;
        }
      }

      await _fetchTrainings();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchTrainings() async {
    try {
      final extraId = _selectedExtra?['id']?.toString();
      final rows = await _repo.getTrainings(extracurricularId: extraId);

      final now = DateTime.now();
      final todayStr = now.toIso8601String().substring(0, 10);

      final List<Map<String, dynamic>> mapped = [];
      for (final r in rows) {
        final id = r['id']?.toString() ?? '';
        final title = (r['title'] ?? 'Diklat Anggota').toString().trim();
        final desc = (r['description'] ?? '').toString().trim();
        final loc = (r['location'] ?? 'SMKN 8 Malang').toString().trim();
        final start = (r['start_date'] ?? '').toString().trim();
        final end = (r['end_date'] ?? '').toString().trim();
        final quota = int.tryParse(r['quota']?.toString() ?? '40') ?? 40;

        // Tentukan kategori status berdasarkan tanggal
        String category = 'Pendaftaran';
        String status = 'PENDAFTARAN DIBUKA';
        Color statusBg = AppColors.soft;
        Color statusFg = AppColors.primary;
        String extra = 'Siap Daftar';
        Color extraBg = AppColors.greenSoft;
        Color extraFg = AppColors.green;

        if (start.isNotEmpty) {
          final startDate = DateTime.tryParse(start);
          final endDate = end.isNotEmpty ? DateTime.tryParse(end) : startDate;

          if (endDate != null && endDate.isBefore(now.subtract(const Duration(days: 1)))) {
            category = 'Selesai';
            status = 'SELESAI DILAKSANAKAN';
            statusBg = const Color(0xFFF1F4FD);
            statusFg = AppColors.muted;
            extra = 'Arsip';
            extraBg = const Color(0xFFE2E8F0);
            extraFg = AppColors.muted;
          } else if (startDate != null &&
              (start == todayStr || (startDate.isBefore(now) && endDate != null && endDate.isAfter(now)))) {
            category = 'Siap Dilaksanakan';
            status = 'SEDANG BERJALAN';
            statusBg = AppColors.greenSoft;
            statusFg = AppColors.green;
            extra = 'Kegiatan Aktif';
            extraBg = AppColors.greenSoft;
            extraFg = AppColors.green;
          } else {
            category = 'Pendaftaran';
            status = 'PENDAFTARAN DIBUKA';
            statusBg = AppColors.soft;
            statusFg = AppColors.primary;
            extra = 'Mendatang';
            extraBg = AppColors.soft;
            extraFg = AppColors.primary;
          }
        }

        String dateFormatted = start;
        if (start.isNotEmpty) {
          final dtStart = DateTime.tryParse(start);
          if (dtStart != null) {
            dateFormatted = '${dtStart.day}/${dtStart.month}/${dtStart.year}';
            if (end.isNotEmpty && end != start) {
              final dtEnd = DateTime.tryParse(end);
              if (dtEnd != null) {
                dateFormatted += ' - ${dtEnd.day}/${dtEnd.month}/${dtEnd.year}';
              }
            }
          }
        } else {
          dateFormatted = 'Jadwal Segera Diumumkan';
        }

        mapped.add({
          'id': id,
          'status': status,
          'category': category,
          'statusBg': statusBg,
          'statusFg': statusFg,
          'extra': extra,
          'extraBg': extraBg,
          'extraFg': extraFg,
          'title': title,
          'description': desc,
          'lines': [
            '📅 Waktu: $dateFormatted',
            '📍 Tempat: $loc',
            if (desc.isNotEmpty) '📝 Materi: $desc',
          ],
          'footer': 'Target Kuota: $quota Peserta',
          'registered': 0,
          'maxQuota': quota,
          'date': dateFormatted,
          'place': loc,
          'raw': r,
        });
      }

      if (mounted) {
        setState(() {
          _diklatItems = mapped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredDiklat {
    return _diklatItems.where((item) {
      final cat = item['category'] as String;

      // Filter chips: 0: Semua, 1: Pendaftaran, 2: Siap Dilaksanakan, 3: Selesai
      if (_selectedFilterChip == 1 && cat != 'Pendaftaran') return false;
      if (_selectedFilterChip == 2 && cat != 'Siap Dilaksanakan') return false;
      if (_selectedFilterChip == 3 && cat != 'Selesai') return false;

      // Filter search
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final title = (item['title'] as String).toLowerCase();
        final place = (item['place'] as String).toLowerCase();
        final status = (item['status'] as String).toLowerCase();
        final lines = (item['lines'] as List).join(' ').toLowerCase();

        if (!title.contains(q) && !place.contains(q) && !status.contains(q) && !lines.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _handleCreateTraining() async {
    final ekskulName = _selectedExtra?['name'] ?? 'Ekstrakurikuler';
    final res = await push<Map<String, String>>(
      context,
      PembinaRecordFormScreen(
        title: 'Buat Diklat Baru',
        subtitle: 'Buat agenda pendidikan dan pelatihan anggota ke Supabase.',
        fields: const [
          'Nama diklat',
          'Tanggal mulai (YYYY-MM-DD)',
          'Tanggal selesai (YYYY-MM-DD)',
          'Lokasi pelatihan',
          'Kuota peserta',
          'Deskripsi / Materi pelatihan',
        ],
        initialValues: {
          'Tanggal mulai (YYYY-MM-DD)': DateTime.now().add(const Duration(days: 7)).toIso8601String().substring(0, 10),
          'Tanggal selesai (YYYY-MM-DD)': DateTime.now().add(const Duration(days: 8)).toIso8601String().substring(0, 10),
          'Lokasi pelatihan': 'Aula & Lab $ekskulName SMKN 8 Malang',
          'Kuota peserta': '40',
        },
      ),
    );

    if (res != null && res.isNotEmpty && mounted) {
      final title = res['Nama diklat']?.trim() ?? '';
      if (title.isEmpty) {
        toast(context, 'Nama diklat wajib diisi.');
        return;
      }

      final startStr = res['Tanggal mulai (YYYY-MM-DD)']?.trim();
      final endStr = res['Tanggal selesai (YYYY-MM-DD)']?.trim();
      final loc = res['Lokasi pelatihan']?.trim();
      final quota = int.tryParse(res['Kuota peserta']?.trim() ?? '40') ?? 40;
      final desc = res['Deskripsi / Materi pelatihan']?.trim();

      DateTime? start;
      if (startStr != null && startStr.isNotEmpty) {
        start = DateTime.tryParse(startStr);
      }
      start ??= DateTime.now();

      DateTime? end;
      if (endStr != null && endStr.isNotEmpty) {
        end = DateTime.tryParse(endStr);
      }

      try {
        await _repo.createTraining(
          extracurricularId: _selectedExtra?['id']?.toString(),
          title: title,
          description: desc,
          startDate: start,
          endDate: end,
          location: loc,
          quota: quota,
        );

        if (!mounted) return;
        toast(context, '✅ Agenda diklat baru berhasil disimpan ke Supabase!');
        await _fetchTrainings();
      } catch (e) {
        if (mounted) {
          toast(context, '❌ Gagal menyimpan diklat ke Supabase: $e');
        }
      }
    }
  }

  void _showExtraPicker() {
    if (_coachExtras.length <= 1) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Ekstrakurikuler', style: T.h2),
            const SizedBox(height: 12),
            for (final ex in _coachExtras)
              ListTile(
                title: Text(
                  ex['name']?.toString() ?? '',
                  style: TextStyle(
                    fontWeight: _selectedExtra?['id'] == ex['id'] ? FontWeight.w800 : FontWeight.w600,
                    color: _selectedExtra?['id'] == ex['id'] ? AppColors.primary : AppColors.ink,
                  ),
                ),
                trailing: _selectedExtra?['id'] == ex['id']
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedExtra = ex);
                  Navigator.pop(ctx);
                  _fetchTrainings();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ekskulName = _selectedExtra?['name']?.toString() ?? 'Ekstrakurikuler';
    final allCount = _diklatItems.length;
    final pendCount = _diklatItems.where((d) => d['category'] == 'Pendaftaran').length;
    final readyCount = _diklatItems.where((d) => d['category'] == 'Siap Dilaksanakan').length;
    final doneCount = _diklatItems.where((d) => d['category'] == 'Selesai').length;

    final filtered = _filteredDiklat;
    final topDiklat = _diklatItems.isNotEmpty ? _diklatItems.first : null;

    return Screen(
      back: true,
      tag: ekskulName.length > 12 ? ekskulName.substring(0, 12) : ekskulName,
      title: 'Kelola Diklat & Pelatihan',
      subtitle: 'Pendidikan & Pelatihan Anggota $ekskulName SMKN 8 Malang',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Muat Ulang',
            onPressed: _loadData,
          ),
          Btn(
            'Buat Diklat',
            icon: Icons.add,
            h: 42,
            onTap: _handleCreateTraining,
          ),
        ],
      ),
      children: [
        if (_coachExtras.length > 1) ...[
          GestureDetector(
            onTap: _showExtraPicker,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDDE3FF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EKSTRAKURIKULER BINAAN',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          ekskulName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],

        // Banner Agenda Diklat Unggulan / Terkini
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF0A3DB8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Pill(
                topDiklat != null ? topDiklat['status'] : 'DIKLAT RESMI',
                AppColors.red,
                Colors.white,
                icon: Icons.circle,
              ),
              const Spacer(),
              Pill(
                ekskulName.length > 14 ? ekskulName.substring(0, 14) : ekskulName,
                const Color(0x33FFFFFF),
                Colors.white,
              ),
            ]),
            const SizedBox(height: 12),
            Text(
              topDiklat != null
                  ? topDiklat['title']
                  : 'Belum Ada Agenda Diklat Terjadwal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              topDiklat != null
                  ? '📅 ${topDiklat['date']}  •  📍 ${topDiklat['place']}'
                  : 'Gunakan tombol "Buat Diklat" di pojok kanan atas untuk menerbitkan pelatihan baru.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(children: [
                Row(children: [
                  const Expanded(
                    child: Text(
                      'Kapasitas & Kuota Target',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    topDiklat != null
                        ? '${topDiklat['maxQuota']} Kuota Peserta'
                        : '0 Kuota',
                    style: const TextStyle(
                      color: Color(0xFF86EFAC),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Bar(
                  topDiklat != null ? 0.8 : 0.0,
                  const Color(0xFF86EFAC),
                  track: const Color(0x40FFFFFF),
                ),
                const SizedBox(height: 8),
                Row(children: const [
                  Expanded(
                    child: Text(
                      'ⓘ Tersinkronisasi dengan database Supabase',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  Text(
                    'ONLINE DB',
                    style: TextStyle(
                      color: Color(0xFF86EFAC),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ]),
              ]),
            ),
          ]),
        ),

        SearchField(
          'Cari diklat atau materi pelatihan...',
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),

        Chips(
          [
            'Semua Diklat ($allCount)',
            'Pendaftaran ($pendCount)',
            'Siap Dilaksanakan ($readyCount)',
            'Selesai ($doneCount)',
          ],
          selectedIndex: _selectedFilterChip,
          onChanged: (idx) => setState(() => _selectedFilterChip = idx),
        ),

        Row(children: [
          const Expanded(child: Text('Daftar Agenda Diklat', style: T.h2)),
          Pill('Menampilkan: ${filtered.length}', const Color(0xFFEDEFF7), AppColors.muted),
        ]),
        const SizedBox(height: 12),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          SCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: AppColors.red, size: 40),
                const SizedBox(height: 10),
                Text('Gagal Memuat Diklat', style: T.h2.copyWith(color: AppColors.red)),
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Btn.soft('Coba Lagi', icon: Icons.refresh, onTap: _loadData),
              ],
            ),
          )
        else if (filtered.isEmpty)
          SCard(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              children: [
                const Icon(Icons.school_outlined, size: 44, color: AppColors.muted),
                const SizedBox(height: 10),
                const Text('Tidak Ada Agenda Diklat', style: T.h2),
                const SizedBox(height: 4),
                Text(
                  _diklatItems.isEmpty
                      ? 'Belum ada agenda diklat yang tersimpan di Supabase untuk $ekskulName.'
                      : 'Tidak ditemukan agenda pelatihan yang sesuai dengan kata kunci atau filter.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                if (_diklatItems.isNotEmpty)
                  Btn.soft(
                    'Tampilkan Semua Diklat',
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _selectedFilterChip = 0;
                      });
                    },
                  )
                else
                  Btn(
                    'Buat Diklat Pertama',
                    icon: Icons.add,
                    onTap: _handleCreateTraining,
                  ),
              ],
            ),
          )
        else
          for (final item in filtered) _buildAgendaCard(item),
      ],
    );
  }

  Widget _buildAgendaCard(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final statusBg = item['statusBg'] as Color;
    final statusFg = item['statusFg'] as Color;
    final extra = item['extra'] as String;
    final extraBg = item['extraBg'] as Color;
    final extraFg = item['extraFg'] as Color;
    final title = item['title'] as String;
    final lines = (item['lines'] as List).cast<String>();
    final footer = item['footer'] as String?;
    final registered = item['registered'] as int;
    final date = item['date'] as String;
    final place = item['place'] as String;
    final desc = item['description'] as String;

    return SCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(status, statusBg, statusFg),
          const SizedBox(width: 6),
          Flexible(child: Pill(extra, extraBg, extraFg)),
          const Spacer(),
          const Icon(Icons.verified_outlined, color: AppColors.primary, size: 18),
        ]),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (lines.isNotEmpty || footer != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(l, style: const TextStyle(fontSize: 13.5, color: AppColors.ink)),
                ),
              if (footer != null)
                Text(
                  footer,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
            ]),
          ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          Btn(
            'Kelola Peserta',
            icon: Icons.how_to_reg_outlined,
            h: 42,
            onTap: () => push(
              context,
              PembinaRecordDetailScreen(
                category: 'Peserta Diklat',
                title: title,
                subtitle: place,
                status: status,
                icon: Icons.groups_outlined,
                fields: [
                  PembinaDetailField('Jadwal Kegiatan', date, Icons.calendar_month_outlined),
                  PembinaDetailField('Lokasi Pelaksanaan', place, Icons.place_outlined),
                  PembinaDetailField('Target Kuota', '${item['maxQuota']} siswa', Icons.people_outline),
                  if (desc.isNotEmpty)
                    PembinaDetailField('Keterangan', desc, Icons.description_outlined),
                ],
              ),
            ),
          ),
          Btn.soft(
            'Detail & Arsip',
            icon: Icons.visibility_outlined,
            h: 42,
            onTap: () => push(
              context,
              PembinaRecordDetailScreen(
                category: 'Agenda Diklat',
                title: title,
                subtitle: place,
                status: status,
                icon: Icons.school_outlined,
                fields: [
                  PembinaDetailField('Waktu', date, Icons.calendar_month_outlined),
                  PembinaDetailField('Lokasi', place, Icons.place_outlined),
                  PembinaDetailField('Target Peserta', '${item['maxQuota']} siswa', Icons.groups_outlined),
                  if (desc.isNotEmpty)
                    PembinaDetailField('Silabus / Materi', desc, Icons.menu_book_outlined),
                ],
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
