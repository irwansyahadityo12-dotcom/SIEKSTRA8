import 'package:flutter/material.dart';

import '../../app/backend.dart';
import '../../data/siekstra_repository.dart';
import '../data/ekstra_store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';
import 'kategori_filter_screen.dart';
import 'record_form_screen.dart';

class EkstraScreen extends StatefulWidget {
  const EkstraScreen({super.key});

  @override
  State<EkstraScreen> createState() => _EkstraScreenState();
}

typedef EkskulScreen = EkstraScreen;

class _EkstraScreenState extends State<EkstraScreen> {
  final SiekstraRepository _repo = SiekstraRepository();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  int _selectedCategoryIndex = 0;
  int _selectedStatusIndex = 0;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  List<EkstraItem> _items = [];
  List<Map<String, dynamic>> _coaches = [];
  List<Map<String, dynamic>> _categories = [];

  final Map<String, Map<String, dynamic>> _rowsById = {};

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
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Backend.ensureInitialized();

      final results = await Future.wait([
        _repo.getExtracurriculars(onlyOpen: false),
        _repo.getActiveCoaches(),
        _repo.getCategories(),
      ]);

      final extracurricularRows =
          List<Map<String, dynamic>>.from(results[0]);
      final coachRows =
          List<Map<String, dynamic>>.from(results[1]);
      final categoryRows =
          List<Map<String, dynamic>>.from(results[2]);

      final loadedItems = <EkstraItem>[];
      _rowsById.clear();

      for (final row in extracurricularRows) {
        final id = row['id']?.toString() ?? '';
        if (id.isEmpty) continue;

        _rowsById[id] = Map<String, dynamic>.from(row);

        final category = row['category']?.toString() ?? 'Umum';
        var coachName = row['coach_name']?.toString() ?? '';
        final coachId = row['coach_id']?.toString();

        if ((coachName.isEmpty || coachName == 'Belum ditugaskan') &&
            coachId != null &&
            coachId.isNotEmpty) {
          final matchedCoach = coachRows.firstWhere(
            (c) => c['id']?.toString() == coachId,
            orElse: () => {},
          );
          if (matchedCoach.isNotEmpty) {
            coachName = matchedCoach['full_name']?.toString() ?? '';
          }
        }

        final schedule = row['schedule_summary']?.toString() ?? '';
        final location = row['location']?.toString() ?? '';
        final isOpen = row['is_open'] == true;

        final quotaValue = row['quota'];
        final quota = quotaValue is int
            ? quotaValue
            : int.tryParse(quotaValue?.toString() ?? '') ?? 0;

        var totalMembers = 0;
        final membershipData = row['memberships'];

        if (membershipData is List && membershipData.isNotEmpty) {
          final countData = membershipData.first;
          if (countData is Map) {
            final count = countData['count'];
            totalMembers = count is int
                ? count
                : int.tryParse(count?.toString() ?? '') ?? 0;
          }
        }

        loadedItems.add(
          EkstraItem(
            id: id,
            name: row['name']?.toString() ?? 'Tanpa Nama',
            category: category,
            pembina: coachName.isEmpty ? 'Belum ditugaskan' : coachName,
            pelatih: '',
            totalAnggota: '$totalMembers Siswa',
            quota: quota,
            jadwal: schedule.isEmpty ? 'Belum ditentukan' : schedule,
            lokasi: location.isEmpty ? 'SMKN 8 Malang' : location,
            presensi: 'Aktif berkegiatan',
            status: isOpen ? 'Aktif' : 'Non-Aktif',
            isUnggulan: false,
            icon: _pickIconForCategory(category),
            iconBg: C.soft,
            iconFg: C.primary,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _items = loadedItems;
        _coaches = coachRows;
        _categories = categoryRows;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _resetAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'Semua';
      _selectedCategoryIndex = 0;
      _selectedStatusIndex = 0;
    });
  }

  List<EkstraItem> _filteredItems() {
    final query = _searchQuery.toLowerCase().trim();

    return _items.where((item) {
      if (_selectedStatusIndex == 1 && item.status != 'Aktif') {
        return false;
      }

      if (_selectedStatusIndex == 2 && item.status != 'Non-Aktif') {
        return false;
      }

      if (_selectedCategory != 'Semua' &&
          !EkstraCategoryFilterHelper.matchesCategory(
            item.category,
            _selectedCategory,
          )) {
        return false;
      }

      if (query.isNotEmpty) {
        final matches = item.name.toLowerCase().contains(query) ||
            item.pembina.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query) ||
            item.lokasi.toLowerCase().contains(query);

        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ekstraStore,
      builder: (context, _) {
        final activeCategories = ekstraStore.activeCategories;

        final chipLabels = <String>[
          'Semua',
          for (final category in activeCategories) category.label,
        ];

        if (_selectedCategoryIndex >= chipLabels.length) {
          _selectedCategoryIndex = 0;
          _selectedCategory = 'Semua';
        } else if (_selectedCategoryIndex > 0) {
          _selectedCategory =
              activeCategories[_selectedCategoryIndex - 1].name;
        } else {
          _selectedCategory = 'Semua';
        }

        final totalAll = _items.length;
        final totalAktif =
            _items.where((item) => item.status == 'Aktif').length;
        final totalNonAktif =
            _items.where((item) => item.status == 'Non-Aktif').length;

        final filteredItems = _filteredItems();

        final isFiltering = _searchQuery.isNotEmpty ||
            _selectedCategory != 'Semua' ||
            _selectedStatusIndex != 0;

        return AdminScreen(
          children: [
            HeroBanner(
              children: [
                Row(
                  children: [
                    const Pill(
                      'Tahun Ajaran 2024/2025',
                      Color(0x33FFFFFF),
                      Colors.white,
                      dot: true,
                    ),
                    const Spacer(),
                    Text(
                      'Total $totalAll Cabang',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Kelola Ekstrakurikuler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pusat pengaturan pembina, kuota siswa, kategori filter, dan jadwal dari Supabase.',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 16),
                Btn.white(
                  'Tambah Ekstrakurikuler Baru',
                  icon: Icons.add_circle_outline,
                  expand: true,
                  h: 52,
                  onTap: _isSaving ? null : () => _openAddEkstra(context),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      push(context, const AdminKategoriFilterScreen()),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kelola Isi Sliding Filter (${activeCategories.length} Kategori Aktif)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SearchBox(
              'Cari ekstrakurikuler, pembina, atau lokasi...',
              filter: true,
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              onClear: () {
                setState(() => _searchQuery = '');
              },
              onFilterTap: () =>
                  push(context, const AdminKategoriFilterScreen()),
            ),

            Chips(
              chipLabels,
              selectedIndex: _selectedCategoryIndex,
              onChanged: (index) {
                setState(() {
                  _selectedCategoryIndex = index;
                  _selectedCategory = index == 0
                      ? 'Semua'
                      : activeCategories[index - 1].name;
                });
              },
              trailing: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () =>
                      push(context, const AdminKategoriFilterScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: C.soft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: C.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.tune, size: 15, color: C.primary),
                        SizedBox(width: 5),
                        Text(
                          '+ Kelola Filter',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: C.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SegTabs(
              [
                'Semua ($totalAll)',
                'Aktif ($totalAktif)',
                'Non-Aktif ($totalNonAktif)',
              ],
              selectedIndex: _selectedStatusIndex,
              onChanged: (index) {
                setState(() => _selectedStatusIndex = index);
              },
            ),

            if (_errorMessage != null)
              SCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: C.red,
                      size: 35,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gagal mengambil data dari Supabase',
                      style: T.h2,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage!,
                      style: T.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Btn(
                      'Coba Lagi',
                      icon: Icons.refresh,
                      onTap: _loadData,
                    ),
                  ],
                ),
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 45),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage == null) ...[
              if (isFiltering)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: C.line),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          size: 18,
                          color: C.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Menampilkan ${filteredItems.length} dari $totalAll ekstrakurikuler',
                            style: T.body.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: _resetAllFilters,
                          child: const Text(
                            'Reset Filter',
                            style: TextStyle(
                              color: C.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (filteredItems.isEmpty)
                SCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: C.field,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            size: 36,
                            color: C.muted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Tidak ada ekstrakurikuler ditemukan',
                          style: T.h2,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada hasil yang cocok dengan kata kunci "$_searchQuery".'
                              : 'Belum ada data ekstrakurikuler atau tidak ada data yang cocok dengan filter.',
                          style: T.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Btn.gray(
                          'Reset Semua Filter',
                          h: 42,
                          onTap: _resetAllFilters,
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final item in filteredItems)
                  _buildStandardCard(context, item),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStandardCard(BuildContext context, EkstraItem item) {
    return SCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBox(
                item.icon,
                bg: item.iconBg,
                fg: item.iconFg,
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Pill(item.category, item.iconBg, item.iconFg),
                        Pill(
                          item.status,
                          item.status == 'Aktif'
                              ? C.greenSoft
                              : C.redSoft,
                          item.status == 'Aktif' ? C.green : C.red,
                          dot: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.name, style: T.h2),
                    Text(
                      item.pembina,
                      style: T.body.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              _buildMoreMenu(context, item),
            ],
          ),
          const SizedBox(height: 12),
          Panel(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Anggota', style: T.body),
                      const SizedBox(height: 4),
                      Text(item.totalAnggota, style: T.h2),
                      Text(
                        'Kuota: ${item.quota} siswa',
                        style: T.body.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jadwal Rutin', style: T.body),
                      const SizedBox(height: 4),
                      Text(
                        item.jadwal,
                        style: T.h2.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 4,
                backgroundColor:
                    item.status == 'Aktif' ? C.green : C.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.lokasi,
                  style: T.body.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Btn.gray(
                'Edit',
                icon: Icons.edit_outlined,
                h: 40,
                onTap: () => _openEditEkstra(context, item),
              ),
              const SizedBox(width: 8),
              Btn(
                'Detail',
                h: 40,
                onTap: () => _openDetail(context, item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context, EkstraItem item) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: C.muted),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (value) async {
        if (value == 'status') {
          await _toggleStatus(item);
        } else if (value == 'delete') {
          _confirmDeleteEkstra(context, item);
        } else if (value == 'edit') {
          _openEditEkstra(context, item);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: C.ink),
              SizedBox(width: 10),
              Text('Edit Data'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'status',
          child: Row(
            children: [
              Icon(
                item.status == 'Aktif'
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                size: 18,
                color: item.status == 'Aktif' ? C.orange : C.green,
              ),
              const SizedBox(width: 10),
              Text(
                item.status == 'Aktif'
                    ? 'Jadikan Non-Aktif'
                    : 'Aktifkan Kembali',
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: C.red),
              SizedBox(width: 10),
              Text(
                'Hapus Ekstra',
                style: TextStyle(color: C.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _toggleStatus(EkstraItem item) async {
    if (!_rowsById.containsKey(item.id)) return;

    final newStatus = item.status != 'Aktif';

    try {
      await _repo.toggleExtracurricularStatus(item.id, newStatus);

      if (!mounted) return;

      toast(
        context,
        'Status ${item.name} berhasil diubah menjadi ${newStatus ? "Aktif" : "Non-Aktif"}',
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      toast(context, 'Gagal mengubah status: $e');
    }
  }

  void _openDetail(BuildContext context, EkstraItem item) {
    push(
      context,
      AdminDetailScreen(
        category: 'Ekstrakurikuler',
        name: item.name,
        subtitle: item.category,
        status: item.status,
        icon: item.icon,
        fields: [
          AdminDetailField(
            'Kategori Filter',
            item.category,
            Icons.tune,
          ),
          AdminDetailField(
            'Pembina',
            item.pembina,
            Icons.school_outlined,
          ),
          AdminDetailField(
            'Jumlah Anggota',
            item.totalAnggota,
            Icons.groups_outlined,
          ),
          AdminDetailField(
            'Kuota Anggota',
            '${item.quota} siswa',
            Icons.people_outline,
          ),
          AdminDetailField(
            'Jadwal Latihan',
            item.jadwal,
            Icons.calendar_month_outlined,
          ),
          AdminDetailField(
            'Lokasi Latihan',
            item.lokasi,
            Icons.place_outlined,
          ),
          AdminDetailField(
            'Status Aktif',
            item.status,
            Icons.fact_check_outlined,
          ),
        ],
        onEdit: () {
          Navigator.of(context).pop();
          _openEditEkstra(context, item);
        },
      ),
    );
  }

  List<String> _categoryOptions() {
    final set = <String>{};
    for (final c in ekstraStore.categories) {
      set.add(c.name);
    }
    for (final c in _categories) {
      final name = c['name']?.toString();
      if (name != null && name.isNotEmpty) set.add(name);
    }
    for (final item in _items) {
      if (item.category.isNotEmpty) set.add(item.category);
    }

    if (set.isEmpty) {
      return [
        'Olahraga',
        'Teknologi & IT',
        'Kemanusiaan / PMR',
        'Bela Negara',
        'Seni & Budaya',
        'Keagamaan',
        'Bahasa & Komunikasi',
      ];
    }

    return set.toList();
  }

  List<String> _coachOptions({String? currentEkstraId}) {
    final names = <String>['Belum ditugaskan'];

    // 1 Pembina hanya mengurus 1 ekstrakulikuler: lewati jika sudah ditugaskan ke ekskul lain
    final assignedCoachIds = <String>{};
    for (final entry in _rowsById.entries) {
      if (currentEkstraId != null && entry.key == currentEkstraId) continue;
      final cid = entry.value['coach_id']?.toString();
      if (cid != null && cid.isNotEmpty) {
        assignedCoachIds.add(cid);
      }
    }

    for (final coach in _coaches) {
      final coachId = coach['id']?.toString() ?? '';
      if (assignedCoachIds.contains(coachId)) {
        continue;
      }

      final name = coach['full_name']?.toString() ?? '';
      final email = coach['email']?.toString() ?? '';

      if (name.isNotEmpty) {
        final label = names.contains(name) && email.isNotEmpty
            ? '$name ($email)'
            : name;

        if (!names.contains(label)) {
          names.add(label);
        }
      }
    }

    return names;
  }

  Map<String, dynamic>? _findCoachByName(String name) {
    if (name == 'Belum ditugaskan' || name.isEmpty) {
      return null;
    }

    for (final coach in _coaches) {
      final fullName = coach['full_name']?.toString() ?? '';
      final email = coach['email']?.toString() ?? '';

      if (name == fullName || name == '$fullName ($email)') {
        return coach;
      }
    }

    return null;
  }

  Future<void> _openAddEkstra(BuildContext context) async {
    if (_isSaving) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminRecordFormScreen(
          title: 'Tambah Ekstrakurikuler',
          description:
              'Masukkan informasi cabang ekstrakurikuler baru untuk siswa ke Supabase.',
          fields: const [
            'Nama ekstrakurikuler',
            'Kategori',
            'Nama pembina',
            'Kuota anggota',
            'Hari dan jam latihan',
            'Lokasi',
          ],
          fieldOptions: {
            'Kategori': _categoryOptions(),
            'Nama pembina': _coachOptions(),
          },
          submitLabel: 'Simpan Ekstrakurikuler',
        ),
      ),
    );

    if (result is! Map<String, String>) return;

    final name = result['Nama ekstrakurikuler']?.trim() ?? '';
    final category = result['Kategori'] ?? 'Umum';
    final coachName = result['Nama pembina'] ?? 'Belum ditugaskan';
    final quota = int.tryParse(result['Kuota anggota'] ?? '') ?? 30;
    final schedule = result['Hari dan jam latihan']?.trim() ?? '';
    final location = result['Lokasi']?.trim() ?? '';

    if (name.isEmpty) {
      if (mounted) toast(context, 'Nama ekstrakurikuler wajib diisi');
      return;
    }

    final coach = _findCoachByName(coachName);
    if (coach != null) {
      final coachId = coach['id']?.toString() ?? '';
      final alreadyAssigned = _rowsById.values.any(
        (row) => row['coach_id']?.toString() == coachId,
      );
      if (alreadyAssigned) {
        final existingEkskul = _rowsById.values.firstWhere(
          (row) => row['coach_id']?.toString() == coachId,
        )['name'];
        if (mounted) {
          toast(
            context,
            'Pembina "$coachName" sudah membina "$existingEkskul". 1 Pembina hanya boleh mengurus 1 ekstrakurikuler.',
          );
        }
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      await _repo.createExtracurricular(
        name: name,
        category: category,
        description: '',
        location: location.isEmpty ? 'SMKN 8 Malang' : location,
        quota: quota,
        coachId: coach?['id']?.toString(),
        coachName: coach?['full_name']?.toString(),
        scheduleSummary:
            schedule.isEmpty ? 'Jadwal belum ditentukan' : schedule,
        isOpen: true,
      );

      if (!mounted) return;

      toast(context, 'Ekstrakurikuler "$name" berhasil ditambahkan ke Supabase');
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      toast(context, 'Gagal menyimpan ekstrakurikuler: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openEditEkstra(
    BuildContext context,
    EkstraItem item,
  ) async {
    if (_isSaving) return;

    if (!_rowsById.containsKey(item.id)) {
      toast(context, 'Data ekstrakurikuler tidak ditemukan');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminRecordFormScreen(
          title: 'Edit Ekstrakurikuler',
          description:
              'Perbarui informasi cabang ekstrakurikuler ${item.name}.',
          fields: const [
            'Nama ekstrakurikuler',
            'Kategori',
            'Nama pembina',
            'Kuota anggota',
            'Hari dan jam latihan',
            'Lokasi',
            'Status',
          ],
          initialValues: {
            'Nama ekstrakurikuler': item.name,
            'Kategori': item.category,
            'Nama pembina': _coachLabelForItem(item),
            'Kuota anggota': item.quota.toString(),
            'Hari dan jam latihan': item.jadwal,
            'Lokasi': item.lokasi,
            'Status': item.status,
          },
          fieldOptions: {
            'Kategori': _categoryOptions(),
            'Nama pembina': _coachOptions(currentEkstraId: item.id),
            'Status': const ['Aktif', 'Non-Aktif'],
          },
          submitLabel: 'Simpan Perubahan',
        ),
      ),
    );

    if (result is! Map<String, String>) return;

    final name = result['Nama ekstrakurikuler']?.trim() ?? item.name;
    final category = result['Kategori'] ?? item.category;
    final coachName = result['Nama pembina'] ?? 'Belum ditugaskan';
    final quota =
        int.tryParse(result['Kuota anggota'] ?? '') ?? item.quota;
    final schedule =
        result['Hari dan jam latihan']?.trim() ?? item.jadwal;
    final location = result['Lokasi']?.trim() ?? item.lokasi;
    final status = result['Status'] ?? item.status;

    if (name.isEmpty) {
      if (mounted) toast(context, 'Nama ekstrakurikuler wajib diisi');
      return;
    }

    final coach = _findCoachByName(coachName);
    if (coach != null) {
      final coachId = coach['id']?.toString() ?? '';
      final alreadyAssigned = _rowsById.entries.any(
        (entry) =>
            entry.key != item.id &&
            entry.value['coach_id']?.toString() == coachId,
      );
      if (alreadyAssigned) {
        final existingEkskul = _rowsById.entries
            .firstWhere(
              (entry) =>
                  entry.key != item.id &&
                  entry.value['coach_id']?.toString() == coachId,
            )
            .value['name'];
        if (mounted) {
          toast(
            context,
            'Pembina "$coachName" sudah membina "$existingEkskul". 1 Pembina hanya boleh mengurus 1 ekstrakurikuler.',
          );
        }
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      await _repo.updateExtracurricular(
        item.id,
        name: name,
        category: category,
        location: location,
        quota: quota,
        coachId: coach?['id']?.toString(),
        coachName: coach?['full_name']?.toString(),
        scheduleSummary: schedule,
        isOpen: status == 'Aktif',
      );

      if (!mounted) return;

      toast(context, 'Data "$name" berhasil diperbarui di Supabase');
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      toast(context, 'Gagal memperbarui data: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _coachLabelForItem(EkstraItem item) {
    final row = _rowsById[item.id];
    final coachId = row?['coach_id']?.toString();

    if (coachId == null || coachId.isEmpty) {
      return 'Belum ditugaskan';
    }

    for (final coach in _coaches) {
      if (coach['id']?.toString() == coachId) {
        final name = coach['full_name']?.toString() ?? '';
        final email = coach['email']?.toString() ?? '';
        final duplicate = _coaches
                .where((c) => c['full_name']?.toString() == name)
                .length >
            1;

        return duplicate && email.isNotEmpty ? '$name ($email)' : name;
      }
    }

    return item.pembina;
  }

  void _confirmDeleteEkstra(
    BuildContext context,
    EkstraItem item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Hapus Ekstrakurikuler?'),
        content: Text(
          'Yakin ingin menghapus ekstrakurikuler "${item.name}" dari sistem?',
          style: T.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: C.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: C.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteEkstra(item);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEkstra(EkstraItem item) async {
    try {
      await _repo.deleteExtracurricular(item.id);

      if (!mounted) return;

      toast(context, 'Ekstrakurikuler "${item.name}" telah dihapus dari Supabase');
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      toast(context, 'Gagal menghapus ekstrakurikuler: $e');
    }
  }

  IconData _pickIconForCategory(String category) {
    final value = category.toLowerCase();

    if (value.contains('olahraga') ||
        value.contains('futsal') ||
        value.contains('volly')) {
      return Icons.sports_soccer;
    }

    if (value.contains('it') ||
        value.contains('teknologi') ||
        value.contains('robotik') ||
        value.contains('rpl')) {
      return Icons.computer;
    }

    if (value.contains('pmr') ||
        value.contains('kemanusiaan') ||
        value.contains('medis')) {
      return Icons.medical_services_outlined;
    }

    if (value.contains('bela negara') ||
        value.contains('paskibra') ||
        value.contains('pramuka')) {
      return Icons.flag;
    }

    if (value.contains('seni') ||
        value.contains('budaya') ||
        value.contains('tari') ||
        value.contains('musik')) {
      return Icons.palette_outlined;
    }

    if (value.contains('keagamaan') ||
        value.contains('islam') ||
        value.contains('dakwah')) {
      return Icons.mosque_outlined;
    }

    return Icons.star_border;
  }
}

class EkstraCategoryFilterHelper {
  static bool matchesCategory(
    String itemCategory,
    String filterCategory,
  ) {
    if (filterCategory == 'Semua') return true;

    final first = itemCategory.toLowerCase().trim();
    final second = filterCategory.toLowerCase().trim();

    if (first == second ||
        first.contains(second) ||
        second.contains(first)) {
      return true;
    }

    if (second.contains('olahraga') && first.contains('olahraga')) {
      return true;
    }

    if ((second.contains('pmr') || second.contains('kemanusiaan')) &&
        (first.contains('pmr') ||
            first.contains('kemanusiaan') ||
            first.contains('relawan'))) {
      return true;
    }

    if ((second.contains('it') || second.contains('teknologi')) &&
        (first.contains('it') ||
            first.contains('teknologi') ||
            first.contains('rpl') ||
            first.contains('robotik'))) {
      return true;
    }

    if ((second.contains('bela negara') || second.contains('paskibra')) &&
        (first.contains('bela negara') ||
            first.contains('paskibra') ||
            first.contains('pramuka'))) {
      return true;
    }

    if ((second.contains('seni') || second.contains('budaya')) &&
        (first.contains('seni') ||
            first.contains('budaya') ||
            first.contains('tari') ||
            first.contains('teater') ||
            first.contains('musik'))) {
      return true;
    }

    if (second.contains('keagamaan') &&
        (first.contains('keagamaan') ||
            first.contains('islam') ||
            first.contains('dakwah'))) {
      return true;
    }

    if ((second.contains('bahasa') || second.contains('komunikasi')) &&
        (first.contains('bahasa') ||
            first.contains('english') ||
            first.contains('debat') ||
            first.contains('komunikasi'))) {
      return true;
    }

    return false;
  }
}
