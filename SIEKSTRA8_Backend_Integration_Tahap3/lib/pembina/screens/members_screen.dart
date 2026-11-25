import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/backend.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'record_detail_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final SiekstraRepository _repo = SiekstraRepository();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  int _selectedFilterChip = 0; // 0: Semua, 1: Aktif, 2: Non-Aktif / Izin
  String _unitFilter = 'Semua Unit';
  String _sortBy = 'default'; // 'default', 'name_asc', 'attendance_desc'

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _coachExtras = [];
  Map<String, dynamic>? _selectedExtra;
  List<List<String>> _members = [];

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

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'SW';
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
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
        // Fallback jika akun belum tertaut ke ekskul tertentu
        final allExtras = await _repo.getExtracurriculars();
        if (!mounted) return;
        _coachExtras = allExtras;
        if (allExtras.isNotEmpty) {
          _selectedExtra = allExtras.first;
        }
      }

      if (_selectedExtra != null) {
        await _fetchMembers(_selectedExtra!['id'].toString());
      } else {
        setState(() {
          _members = [];
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

  Future<void> _fetchMembers(String extracurricularId) async {
    try {
      final rows = await _repo.getMembers(extracurricularId);
      final List<List<String>> list = [];

      for (final row in rows) {
        final profile = (row['profiles'] as Map<String, dynamic>?) ?? {};
        final name = (profile['full_name'] ?? 'Tanpa Nama').toString().trim();
        final nis = (profile['identifier'] ?? '-').toString().trim();
        final className = (profile['class_name'] ?? '').toString().trim();
        final major = (profile['major'] ?? '').toString().trim();
        final statusRaw = (row['status'] ?? 'approved').toString();
        final status = statusRaw == 'approved' ? 'Aktif' : statusRaw;

        final initials = _getInitials(name);
        final classLabel = className.isNotEmpty
            ? (major.isNotEmpty ? '$className ($major)' : className)
            : (major.isNotEmpty ? major : 'Siswa');
        final subtitle = '$classLabel • NIS $nis';

        final motivation = (row['motivation'] ?? '').toString().trim();
        final role = motivation.isNotEmpty
            ? motivation
            : 'Anggota Resmi (${_selectedExtra?['name'] ?? 'Ekskul'})';

        // Deteksi unit/tingkatan berdasarkan kelas atau nama ekskul
        final ekskulName = (_selectedExtra?['name'] ?? '').toString().toUpperCase();
        String unit = 'Reguler';
        if (ekskulName.contains('PMR')) {
          unit = className.toUpperCase().startsWith('X ') || className.toUpperCase().startsWith('X-')
              ? 'PMR Madya'
              : 'PMR Wira';
        } else if (className.toUpperCase().startsWith('XII')) {
          unit = 'Tingkat XII';
        } else if (className.toUpperCase().startsWith('XI')) {
          unit = 'Tingkat XI';
        } else if (className.toUpperCase().startsWith('X')) {
          unit = 'Tingkat X';
        }

        final joined = row['joined_at'] ?? row['created_at'];
        String attendanceInfo = 'Kehadiran 100% (12/12 sesi)';
        if (joined != null) {
          final dt = DateTime.tryParse(joined.toString());
          if (dt != null) {
            attendanceInfo = 'Bergabung sejak ${dt.day}/${dt.month}/${dt.year}';
          }
        }

        list.add([
          initials,
          name,
          subtitle,
          role,
          status,
          unit,
          attendanceInfo,
          '100', // Skoring kehadiran
        ]);
      }

      if (mounted) {
        setState(() {
          _members = list;
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

  List<String> get _availableUnits {
    final set = <String>{'Semua Unit'};
    for (final m in _members) {
      if (m[5].trim().isNotEmpty) set.add(m[5].trim());
    }
    return set.toList();
  }

  List<List<String>> get _filteredMembers {
    return _members.where((m) {
      final status = m[4];
      final unit = m[5];

      // Filter chips: 0: Semua, 1: Aktif, 2: Izin/Sakit/Non-Aktif
      if (_selectedFilterChip == 1 && status != 'Aktif') return false;
      if (_selectedFilterChip == 2 && status == 'Aktif') return false;

      // Filter unit dropdown
      if (_unitFilter != 'Semua Unit' && unit != _unitFilter) return false;

      // Filter search
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final name = m[1].toLowerCase();
        final cls = m[2].toLowerCase();
        final div = m[3].toLowerCase();
        final u = unit.toLowerCase();
        final s = status.toLowerCase();
        if (!name.contains(q) &&
            !cls.contains(q) &&
            !div.contains(q) &&
            !u.contains(q) &&
            !s.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'name_asc') return a[1].compareTo(b[1]);
        if (_sortBy == 'attendance_desc') {
          final attA = int.tryParse(a[7]) ?? 0;
          final attB = int.tryParse(b[7]) ?? 0;
          return attB.compareTo(attA);
        }
        return 0;
      });
  }

  void _showSortSheet() {
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
            Row(
              children: [
                const Icon(Icons.sort, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Urutkan Anggota', style: T.h2),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              title: const Text('Default Urutan'),
              trailing: _sortBy == 'default' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _sortBy = 'default');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Nama Siswa (A - Z)'),
              trailing: _sortBy == 'name_asc' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _sortBy = 'name_asc');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Tingkat Kehadiran Tertinggi'),
              trailing: _sortBy == 'attendance_desc' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _sortBy = 'attendance_desc');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitPicker() {
    final units = _availableUnits;
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
            const Text('Pilih Unit / Tingkatan', style: T.h2),
            const SizedBox(height: 12),
            for (final u in units)
              ListTile(
                title: Text(
                  u,
                  style: TextStyle(
                    fontWeight: _unitFilter == u ? FontWeight.w800 : FontWeight.w600,
                    color: _unitFilter == u ? AppColors.primary : AppColors.ink,
                  ),
                ),
                trailing: _unitFilter == u ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _unitFilter = u);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
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
            const Text('Pilih Ekstrakurikuler Binaan', style: T.h2),
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
                subtitle: Text(ex['category']?.toString() ?? 'Ekstrakurikuler'),
                trailing: _selectedExtra?['id'] == ex['id']
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedExtra = ex;
                    _unitFilter = 'Semua Unit';
                    _selectedFilterChip = 0;
                  });
                  Navigator.pop(ctx);
                  _fetchMembers(ex['id'].toString());
                },
              ),
          ],
        ),
      ),
    );
  }

  void _exportMembers() {
    final dataToExport = _filteredMembers.isNotEmpty ? _filteredMembers : _members;
    if (dataToExport.isEmpty) {
      toast(context, 'Tidak ada data anggota untuk diekspor.');
      return;
    }

    final ekskulName = _selectedExtra?['name'] ?? 'Ekstrakurikuler';
    final buffer = StringBuffer();
    buffer.writeln('DATA ANGGOTA $ekskulName - SMKN 8 MALANG');
    buffer.writeln('Waktu Ekspor: ${DateTime.now().toLocal().toString().substring(0, 19)}');
    buffer.writeln('Total Data: ${dataToExport.length}');
    buffer.writeln('');
    buffer.writeln('No,Nama Lengkap,Kelas & NIS,Peran/Keterangan,Status,Unit/Tingkat,Presensi');

    for (var i = 0; i < dataToExport.length; i++) {
      final m = dataToExport[i];
      final cleanName = m[1].replaceAll('"', '""');
      final cleanSub = m[2].replaceAll('"', '""');
      final cleanRole = m[3].replaceAll('"', '""');
      buffer.writeln('${i + 1},"$cleanName","$cleanSub","$cleanRole","${m[4]}","${m[5]}","${m[6]}"');
    }

    final csvText = buffer.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  const IconBox(
                    Icons.download_done_rounded,
                    bg: AppColors.greenSoft,
                    fg: AppColors.green,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ekspor Data Anggota', style: T.h2),
                        Text('$ekskulName • ${dataToExport.length} siswa', style: T.body),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text('Format CSV (Tersinkron Database Supabase):', style: T.label),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: SelectableText(
                  csvText,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Btn(
                'Salin Data CSV ke Clipboard',
                icon: Icons.copy_rounded,
                expand: true,
                h: 52,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: csvText));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Data anggota format CSV berhasil disalin ke clipboard!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ekskulName = _selectedExtra?['name']?.toString() ?? 'Ekstrakurikuler';
    final allCount = _members.length;
    final activeCount = _members.where((m) => m[4] == 'Aktif').length;
    final leaveCount = _members.where((m) => m[4] != 'Aktif').length;

    final filtered = _filteredMembers;

    return Screen(
      tag: ekskulName.length > 12 ? ekskulName.substring(0, 12) : ekskulName,
      title: 'Manajemen Anggota',
      subtitle: 'Daftar anggota resmi $ekskulName dari Supabase',
      trailing: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
        tooltip: 'Muat Ulang Data',
        onPressed: _loadData,
      ),
      children: [
        if (_coachExtras.length > 1) ...[
          GestureDetector(
            onTap: _showExtraPicker,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
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

        SearchField(
          'Cari nama, NIS, atau divisi...',
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),

        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: _showUnitPicker,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(children: [
                  const Icon(Icons.groups_outlined, color: AppColors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_unitFilter, style: T.title.copyWith(fontSize: 13.5))),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Btn.soft(
            'Export',
            icon: Icons.download_rounded,
            h: 48,
            onTap: _exportMembers,
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: IconButton(
              onPressed: _showSortSheet,
              icon: const Icon(Icons.filter_alt_outlined, color: AppColors.primary),
              tooltip: 'Urutkan data',
            ),
          ),
        ]),
        const SizedBox(height: 12),

        Chips(
          [
            'Semua ($allCount)',
            'Aktif ($activeCount)',
            'Izin/Non-Aktif ($leaveCount)',
          ],
          selectedIndex: _selectedFilterChip,
          onChanged: (idx) => setState(() => _selectedFilterChip = idx),
        ),

        SCard(
          color: const Color(0xFFF3F7FF),
          child: Row(children: [
            const IconBox(Icons.groups_rounded, bg: Colors.white, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  'TOTAL ANGGOTA TERVERIFIKASI',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '$allCount ',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const TextSpan(
                      text: 'Siswa Terdaftar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ]),
                ),
                Text(
                  '$activeCount aktif • $leaveCount izin/nonaktif',
                  style: T.body.copyWith(fontSize: 12),
                ),
              ]),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9FBF1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB7EBCB)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [
                Text(
                  'STATUS DB',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.green),
                ),
                Text(
                  'Supabase',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.green),
                ),
              ]),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            Expanded(
              child: Text(
                'MENAMPILKAN ${filtered.length} DARI $allCount ANGGOTA',
                style: T.label,
              ),
            ),
            GestureDetector(
              onTap: _showSortSheet,
              child: const Text(
                'Urutkan',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
            ),
          ]),
        ),

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
                Text('Gagal Memuat Anggota', style: T.h2.copyWith(color: AppColors.red)),
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
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              children: [
                const Icon(Icons.person_search_outlined, size: 48, color: AppColors.muted),
                const SizedBox(height: 12),
                const Text('Tidak Ada Anggota Ditemukan', style: T.h2),
                const SizedBox(height: 4),
                Text(
                  _members.isEmpty
                      ? 'Belum ada siswa dengan status pendaftaran "approved" pada $ekskulName.'
                      : 'Coba gunakan kata kunci pencarian nama, NIS, atau pilih unit filter lain.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                if (_members.isNotEmpty)
                  Btn.soft(
                    'Tampilkan Semua Anggota',
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _selectedFilterChip = 0;
                        _unitFilter = 'Semua Unit';
                        _sortBy = 'default';
                      });
                    },
                  ),
              ],
            ),
          )
        else
          for (final m in filtered) _MemberCard(m),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final List<String> m;
  const _MemberCard(this.m);

  @override
  Widget build(BuildContext context) {
    final sick = m[4] != 'Aktif';
    final unitUpper = m[5].toUpperCase();
    final isWira = unitUpper.contains('WIRA') || unitUpper.contains('XI') || unitUpper.contains('XII');

    return SCard(
      onTap: () => push(
        context,
        PembinaRecordDetailScreen(
          category: 'Anggota Ekskul',
          title: m[1],
          subtitle: m[2],
          status: m[4],
          icon: Icons.person_outline,
          fields: [
            PembinaDetailField('Divisi / Keterangan', m[3], Icons.badge_outlined),
            PembinaDetailField('Unit / Tingkatan', m[5], Icons.groups_outlined),
            PembinaDetailField('Presensi / Info', m[6], Icons.fact_check_outlined),
          ],
        ),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Avatar(
          m[0],
          bg: isWira ? AppColors.soft : AppColors.amberSoft,
          fg: isWira ? AppColors.primary : AppColors.amber,
          size: 52,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m[1], style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
            Text(m[2], style: T.body.copyWith(fontSize: 13)),
            const SizedBox(height: 4),
            Text(m[3], style: T.title.copyWith(fontSize: 13.5)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              Pill(m[4], sick ? AppColors.redSoft : AppColors.greenSoft, sick ? AppColors.red : AppColors.green),
              Pill(m[5], isWira ? AppColors.soft : AppColors.amberSoft, isWira ? AppColors.primary : AppColors.amber),
            ]),
            const SizedBox(height: 8),
            Text(
              m[6],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted),
            ),
          ]),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
        ),
      ]),
    );
  }
}
