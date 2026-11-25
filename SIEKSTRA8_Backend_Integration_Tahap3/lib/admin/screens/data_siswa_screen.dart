import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';
import 'record_form_screen.dart';
import '../../data/siekstra_repository.dart';
import '../../app/supabase_config.dart';

class DataSiswaScreen extends StatefulWidget {
  const DataSiswaScreen({super.key});

  @override
  State<DataSiswaScreen> createState() => _DataSiswaScreenState();
}

class _DataSiswaScreenState extends State<DataSiswaScreen> {
  int _selectedTab = 0; // 0: Semua, 1: Aktif, 2: Belum
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _selectedTingkat = 'Semua';
  String _selectedJurusan = 'Semua';
  String _selectedEkskul = 'Semua';

  final List<String> _tingkatOptions = [
    'Semua',
    'Kelas X',
    'Kelas XI',
    'Kelas XII',
  ];

  final List<String> _jurusanOptions = [
    'Semua',
    'Rekayasa Perangkat Lunak',
    'Teknik Komputer & Jaringan',
    'Desain Komunikasi Visual',
    'Mekatronika',
  ];

  final List<String> _ekskulOptions = [
    'Semua',
    'RPL Club & Cyber Security',
    'Paskibra SATYA BHAKTI',
    'Futsal SMKN 8',
    'PMR Wira Unit 8',
    'Robotik Club SMKN 8',
    'Tari Tradisional & Karawitan',
    'English Club (E-Club)',
    'Belum Memilih Ekskul',
  ];

  final _repository = SiekstraRepository();
  final List<Map<String, dynamic>> _allStudents = [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    if (!SupabaseConfig.isConfigured) {
      setState(() { _loading = false; _loadError = 'Konfigurasi Supabase belum tersedia.'; });
      return;
    }
    setState(() { _loading = true; _loadError = null; });
    try {
      final rows = await _repository.getAdminStudents();
      if (!mounted) return;
      setState(() {
        _allStudents
          ..clear()
          ..addAll(rows.map((row) => {
            ...row,
            'icon': row['status'] == 'Aktif' ? Icons.school_outlined : Icons.hourglass_bottom,
          }));
      });
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hitung jumlah siswa per status
  int get _countActive => _allStudents.where((s) => s['status'] == 'Aktif').length;
  int get _countPending => _allStudents.where((s) => s['status'] == 'Belum').length;

  // Filter siswa berdasarkan Tab, Tingkat, Jurusan, Ekskul, dan Search Query
  List<Map<String, dynamic>> get _filteredStudents {
    return _allStudents.where((s) {
      final name = (s['name'] as String).toLowerCase();
      final nisn = (s['nisn'] as String).toLowerCase();
      final cls = (s['class'] as String).toLowerCase();
      final status = s['status'] as String;
      final tingkat = s['tingkat'] as String;
      final jurusan = s['jurusan'] as String;
      final ekskul = s['ekskul'] as String;

      // 1. Filter Tab (Semua, Aktif, Belum)
      if (_selectedTab == 1 && status != 'Aktif') return false;
      if (_selectedTab == 2 && status != 'Belum') return false;

      // 2. Filter Tingkat
      if (_selectedTingkat != 'Semua' && tingkat != _selectedTingkat) {
        return false;
      }

      // 3. Filter Jurusan
      if (_selectedJurusan != 'Semua' && jurusan != _selectedJurusan) {
        return false;
      }

      // 4. Filter Ekskul
      if (_selectedEkskul != 'Semua' && ekskul != _selectedEkskul) {
        return false;
      }

      // 5. Search Query (Nama, NISN, Kelas)
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = name.contains(q) || nisn.contains(q) || cls.contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();
  }

  void _showPicker({
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: T.h2),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: C.line),
                itemBuilder: (context, idx) {
                  final opt = options[idx];
                  final isSel = opt == current;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    title: Text(
                      opt,
                      style: TextStyle(
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                        color: isSel ? C.primary : C.ink,
                        fontSize: 14,
                      ),
                    ),
                    trailing: isSel
                        ? const Icon(Icons.check_circle, color: C.primary, size: 20)
                        : null,
                    onTap: () {
                      onSelected(opt);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredStudents;
    final hasActiveFilter = _selectedTingkat != 'Semua' ||
        _selectedJurusan != 'Semua' ||
        _selectedEkskul != 'Semua' ||
        _searchQuery.isNotEmpty ||
        _selectedTab != 0;

    return AdminScreen(
      back: 'Kembali ke Sistem & Akun',
      title: 'Kelola Data Siswa & Anggota',
      subtitle: 'Master database anggota aktif ekstrakurikuler SMKN 8 Malang.',
      trailing: Btn.soft('', icon: Icons.refresh, h: 52, onTap: _loadStudents),
      children: [
        // Kartu Statistik Siswa
        Row(children: [
          Expanded(child: StatBox('Total Siswa', '${_allStudents.length}', 'Dari database')),
          const SizedBox(width: 8),
          Expanded(child: StatBox('Tergabung', '$_countActive', 'Anggota disetujui', valueColor: C.primary, subColor: C.primary)),
          const SizedBox(width: 8),
          Expanded(child: StatBox('Belum Ekskul', '$_countPending', 'Belum bergabung', valueColor: C.orange, subColor: C.orange)),
        ]),
        const SizedBox(height: 14),

        // SearchBox yang Berfungsi Real-Time
        SearchBox(
          'Cari nama siswa, NISN, atau kelas...',
          controller: _searchController,
          onChanged: (q) => setState(() => _searchQuery = q),
          onClear: () => setState(() => _searchQuery = ''),
        ),

        // Tiga Dropdown Filter Interaktif: Tingkat, Jurusan, Ekskul
        Row(
          children: [
            Expanded(
              child: DropField(
                'Tingkat: $_selectedTingkat',
                onTap: () => _showPicker(
                  title: 'Filter Berdasarkan Tingkat',
                  options: _tingkatOptions,
                  current: _selectedTingkat,
                  onSelected: (val) => setState(() => _selectedTingkat = val),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: DropField(
                'Jurusan: ${_selectedJurusan == "Semua" ? "Semua" : _selectedJurusan.split(" ").map((w) => w.isNotEmpty ? w[0] : "").join("")}',
                onTap: () => _showPicker(
                  title: 'Filter Berdasarkan Jurusan',
                  options: _jurusanOptions,
                  current: _selectedJurusan,
                  onSelected: (val) => setState(() => _selectedJurusan = val),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: DropField(
                'Ekskul: ${_selectedEkskul == "Semua" ? "Semua" : _selectedEkskul.split(" ").first}',
                onTap: () => _showPicker(
                  title: 'Filter Berdasarkan Ekstrakurikuler',
                  options: _ekskulOptions,
                  current: _selectedEkskul,
                  onSelected: (val) => setState(() => _selectedEkskul = val),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // SegTabs: Semua (1.240), Aktif (1.185), Belum (55)
        SegTabs(
          [
            'Semua (${_allStudents.length})',
            'Aktif ($_countActive)',
            'Belum ($_countPending)',
          ],
          selectedIndex: _selectedTab,
          onChanged: (idx) => setState(() => _selectedTab = idx),
        ),

        // Ringkasan Filter & Tombol Reset
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(
                'Menampilkan ${filtered.length} siswa',
                style: T.body.copyWith(fontSize: 12),
              ),
              const Spacer(),
              if (hasActiveFilter)
                InkWell(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedTingkat = 'Semua';
                      _selectedJurusan = 'Semua';
                      _selectedEkskul = 'Semua';
                      _selectedTab = 0;
                    });
                  },
                  child: const Text(
                    'Reset Filter',
                    style: TextStyle(color: C.primary, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),

        if (_loading)
          const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator()))
        else if (_loadError != null)
          SCard(child: Column(children: [
            const Icon(Icons.cloud_off_outlined, color: C.red, size: 34),
            const SizedBox(height: 8),
            Text('Gagal memuat data siswa', style: T.h2),
            Text(_loadError!, style: T.body, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Btn('Coba Lagi', icon: Icons.refresh, onTap: _loadStudents),
          ]))
        // Tampilan Hasil atau Empty State
        else if (filtered.isEmpty)
          SCard(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              children: [
                const Icon(Icons.person_search_outlined, size: 52, color: C.muted),
                const SizedBox(height: 12),
                Text(_allStudents.isEmpty ? 'Belum Ada Siswa Terdaftar' : 'Data Siswa Tidak Ditemukan', style: T.h2),
                const SizedBox(height: 4),
                Text(
                  _allStudents.isEmpty
                      ? 'Data akan muncul di sini setelah siswa mendaftar dan profil tersimpan di Supabase.'
                      : (_searchQuery.isNotEmpty
                          ? 'Tidak ada siswa yang sesuai dengan kata kunci "$_searchQuery".'
                          : 'Tidak ada siswa untuk kriteria filter yang dipilih.'),
                  style: T.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Btn.gray(
                  'Tampilkan Semua Siswa',
                  h: 40,
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedTingkat = 'Semua';
                      _selectedJurusan = 'Semua';
                      _selectedEkskul = 'Semua';
                      _selectedTab = 0;
                    });
                  },
                ),
              ],
            ),
          )
        else
          for (final s in filtered)
            if (s['status'] == 'Aktif')
              _buildActiveStudentCard(context, s)
            else
              _buildPendingStudentCard(context, s),

        const SizedBox(height: 8),

        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: C.muted, fontSize: 13),
              children: [
                const TextSpan(text: 'Menampilkan '),
                TextSpan(
                  text: '${filtered.length}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: C.ink),
                ),
                const TextSpan(text: ' dari '),
                TextSpan(
                  text: '${_allStudents.length}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: C.ink),
                ),
                const TextSpan(text: ' data siswa terdaftar'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        Btn.white('Muat Ulang Data Siswa', icon: Icons.refresh, expand: true, h: 50, onTap: _loadStudents),
      ],
    );
  }

  // Kartu untuk Siswa yang Sudah Aktif di Ekskul
  Widget _buildActiveStudentCard(BuildContext context, Map<String, dynamic> s) {
    return SCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Photo(icon: Icons.person, w: 60, h: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name'] as String, style: T.h2.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('NISN: ${s['nisn']} • ${s['class']}', style: T.body),
                    const SizedBox(height: 2),
                    Text(
                      s['jurusan'] as String,
                      style: const TextStyle(color: C.amber, fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const Pill('Aktif', C.soft, C.primary, dot: true),
            ],
          ),
          const SizedBox(height: 12),
          Panel(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconBox(s['icon'] as IconData, bg: C.amberSoft, fg: C.amber, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EKSTRAKURIKULER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: C.amber,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(s['ekskul'] as String, style: T.title.copyWith(fontSize: 15)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Kehadiran', style: T.body),
                    Text(
                      s['kehadiran'] as String,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.amber),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Btn.gray(
                  'Detail Profil',
                  icon: Icons.visibility_outlined,
                  expand: true,
                  h: 46,
                  onTap: () => push(
                    context,
                    AdminDetailScreen(
                      category: 'Siswa',
                      name: s['name'] as String,
                      subtitle: 'NISN: ${s['nisn']} • ${s['class']}',
                      status: 'Aktif',
                      icon: Icons.person,
                      fields: [
                        AdminDetailField('Jurusan', s['jurusan'] as String, Icons.school_outlined),
                        AdminDetailField('Tingkat', s['tingkat'] as String, Icons.grade_outlined),
                        AdminDetailField('Ekstrakurikuler', s['ekskul'] as String, Icons.groups_outlined),
                        AdminDetailField('Kehadiran', s['kehadiran'] as String, Icons.fact_check_outlined),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: Btn(
                  'Edit Data',
                  icon: Icons.edit_note,
                  expand: true,
                  h: 46,
                  onTap: () async {
                    final result = await push<Map<String, String>>(context, AdminRecordFormScreen(
                      title: 'Edit Data Siswa',
                      description: 'Perbarui informasi profil siswa di database.',
                      fields: const ['Nama lengkap', 'NISN', 'Kelas', 'Jurusan'],
                      initialValues: {
                        'Nama lengkap': s['name'] as String,
                        'NISN': s['nisn'] as String,
                        'Kelas': s['class'] as String,
                        'Jurusan': s['jurusan'] as String,
                      },
                      submitLabel: 'Simpan Perubahan',
                    ));
                    if (result == null || !mounted) return;
                    try {
                      await _repository.updateStudentProfile(
                        studentId: s['id'].toString(),
                        fullName: result['Nama lengkap'] ?? s['name'].toString(),
                        identifier: result['NISN'] ?? s['nisn'].toString(),
                        className: result['Kelas'] ?? s['class'].toString(),
                        major: result['Jurusan'] ?? s['jurusan'].toString(),
                      );
                      toast(context, 'Profil siswa berhasil diperbarui.');
                      await _loadStudents();
                    } catch (e) { toast(context, 'Gagal memperbarui profil: $e'); }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Kartu untuk Siswa yang Belum Terdaftar di Ekskul
  Widget _buildPendingStudentCard(BuildContext context, Map<String, dynamic> s) {
    return SCard(
      border: const Color(0xFFFDE68A),
      color: const Color(0xFFFFFDF5),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Photo(icon: Icons.person, w: 60, h: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name'] as String, style: T.h2.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('NISN: ${s['nisn']} • ${s['class']}', style: T.body),
                    const SizedBox(height: 2),
                    Text(
                      s['jurusan'] as String,
                      style: const TextStyle(color: C.orange, fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const Pill('Belum Terdaftar', C.orangeSoft, C.orange, dot: true),
            ],
          ),
          const SizedBox(height: 12),
          Panel(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const IconBox(Icons.hourglass_bottom, bg: C.orangeSoft, fg: C.orange, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('STATUS PEMILIHAN', style: T.label),
                      Text(
                        'Belum Memilih Ekskul',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: C.orange),
                      ),
                    ],
                  ),
                ),
                const Pill('T.A. 2024/2025', Color(0xFFE5E8EF), C.muted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Btn(
            'Tetapkan Ekskul Siswa',
            icon: Icons.add_circle_outline,
            expand: true,
            h: 48,
            onTap: () async {
              try {
                final extras = await _repository.getExtracurriculars();
                if (!mounted || extras.isEmpty) { if (mounted) toast(context, 'Belum ada ekstrakurikuler aktif di database.'); return; }
                final selected = await showModalBottomSheet<String>(context: context, builder: (ctx) => ListView(
                  shrinkWrap: true,
                  children: [for (final extra in extras) ListTile(
                    title: Text(extra['name']?.toString() ?? 'Ekstrakurikuler'),
                    subtitle: Text(extra['category']?.toString() ?? ''),
                    onTap: () => Navigator.pop(ctx, extra['id'].toString()),
                  )],
                ));
                if (selected == null || !mounted) return;
                await _repository.assignStudentToExtracurricular(studentId: s['id'].toString(), extracurricularId: selected);
                toast(context, 'Siswa berhasil ditetapkan ke ekstrakurikuler.');
                await _loadStudents();
              } catch (e) { if (mounted) toast(context, 'Gagal menetapkan ekstrakurikuler: $e'); }
            },
          ),
        ],
      ),
    );
  }
}
