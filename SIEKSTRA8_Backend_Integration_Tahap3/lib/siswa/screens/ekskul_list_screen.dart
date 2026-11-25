import 'package:flutter/material.dart';
import '../../app/supabase_config.dart';
import '../../data/siekstra_repository.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'ekskul_detail_screen.dart';
import 'registration_form_screen.dart';

class EkskulListScreen extends StatefulWidget {
  const EkskulListScreen({super.key});
  @override
  State<EkskulListScreen> createState() => _EkskulListScreenState();
}

class _EkskulListScreenState extends State<EkskulListScreen> {
  late Future<List<Ekskul>> _future;
  final _repository = SiekstraRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  static const _categories = [
    'Semua',
    'Vokasi & Keahlian',
    'Olahraga',
    'Kemanusiaan',
    'Seni & Bahasa',
  ];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Ekskul>> _load() async {
    if (!SupabaseConfig.isConfigured) return <Ekskul>[];
    try {
      final rows = await _repository.getExtracurriculars();
      if (rows.isEmpty) return <Ekskul>[];
      return rows.map((row) {
        final category = (row['category'] ?? 'Umum').toString();
        final name = (row['name'] ?? 'Ekstrakurikuler').toString();
        return Ekskul(
          id: row['id']?.toString(),
          name: name,
          category: category,
          desc: (row['description'] ?? '').toString(),
          coach: (row['coach_name'] ?? '-').toString(),
          schedule: (row['schedule_summary'] ?? 'Jadwal belum ditentukan').toString(),
          place: (row['location'] ?? 'SMKN 8 Malang').toString(),
          filled: ((row['memberships'] as List?)?.isNotEmpty == true
              ? (((row['memberships'] as List).first as Map)['count'] as num?)?.toInt() ?? 0
              : 0),
          quota: (row['quota'] as num?)?.toInt() ?? 0,
          icon: category.toLowerCase().contains('olahraga')
              ? Icons.sports_soccer
              : category.toLowerCase().contains('teknologi') || category.toLowerCase().contains('vokasi')
                  ? Icons.computer
                  : Icons.groups_outlined,
          color: C.primary,
          colorBg: C.soft,
          photo: const [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        );
      }).toList();
    } catch (_) {
      rethrow;
    }
  }

  List<Ekskul> _filterList(List<Ekskul> all) {
    return all.where((e) {
      // 1. Filter Category
      if (_selectedCategoryIndex != 0) {
        final selectedCat = _categories[_selectedCategoryIndex].toLowerCase();
        final cat = e.category.toLowerCase();
        if (!cat.contains(selectedCat) && !selectedCat.contains(cat)) {
          // Special matching
          if (selectedCat.contains('vokasi') && (cat.contains('it') || cat.contains('teknologi') || cat.contains('keahlian'))) {
            // match
          } else if (selectedCat.contains('kemanusiaan') && (cat.contains('pmr') || cat.contains('paskibra') || cat.contains('pramuka') || cat.contains('sosial'))) {
            // match
          } else if (selectedCat.contains('seni') && (cat.contains('tari') || cat.contains('musik') || cat.contains('bahasa') || cat.contains('band'))) {
            // match
          } else {
            return false;
          }
        }
      }

      // 2. Filter Search Query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final name = e.name.toLowerCase();
        final desc = e.desc.toLowerCase();
        final coach = e.coach.toLowerCase();
        final place = e.place.toLowerCase();
        final category = e.category.toLowerCase();

        if (!name.contains(q) && !desc.contains(q) && !coach.contains(q) && !place.contains(q) && !category.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int _countForCategory(List<Ekskul> list, int catIdx) {
    if (catIdx == 0) return list.length;
    final catTarget = _categories[catIdx].toLowerCase();
    return list.where((e) {
      final cat = e.category.toLowerCase();
      if (cat.contains(catTarget) || catTarget.contains(cat)) return true;
      if (catTarget.contains('vokasi') && (cat.contains('it') || cat.contains('teknologi') || cat.contains('keahlian'))) return true;
      if (catTarget.contains('kemanusiaan') && (cat.contains('pmr') || cat.contains('paskibra') || cat.contains('pramuka') || cat.contains('sosial'))) return true;
      if (catTarget.contains('seni') && (cat.contains('tari') || cat.contains('musik') || cat.contains('bahasa') || cat.contains('band'))) return true;
      return false;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(),
      body: FutureBuilder<List<Ekskul>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppCard(
                  child: Column(children: [
                    const Icon(Icons.cloud_off_outlined, size: 36, color: C.red),
                    const SizedBox(height: 8),
                    tx('Gagal memuat data ekstrakurikuler.', size: 14, color: C.red),
                    TextButton(onPressed: () => setState(() => _future = _load()), child: const Text('Coba lagi')),
                  ]),
                ),
              ],
            );
          }

          final allList = snapshot.data ?? [];
          final filteredList = _filterList(allList);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Search Input Real-Time
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: C.border),
                  boxShadow: const [BoxShadow(color: Color(0x081E3A8A), blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Cari nama ekskul, pembina, atau lokasi...',
                    hintStyle: const TextStyle(color: C.muted, fontSize: 13.5),
                    prefixIcon: const Icon(Icons.search, color: C.primary, size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18, color: C.muted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ),

              // Category Sliding Filter Tabs
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final count = _countForCategory(allList, i);
                    final isSel = _selectedCategoryIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSel ? C.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSel ? C.primary : C.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : C.text,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.white24 : C.soft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: isSel ? Colors.white : C.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Banner Informasi Pendaftaran
              AppCard(
                color: const Color(0xFFEAF0FF),
                child: Row(children: [
                  const IconBox(Icons.campaign_outlined, color: C.primary, bg: Colors.white, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      tx('PENDAFTARAN EKSKUL TA 2024/2025', size: 11.5, w: FontWeight.w800, color: C.primary),
                      tx('Sisa 3 hari sebelum penutupan kuota resmi!', size: 12, color: C.text),
                    ]),
                  ),
                  const Icon(Icons.chevron_right, color: C.muted),
                ]),
              ),
              const SizedBox(height: 6),

              // Status Filter & Reset
              if (_searchQuery.isNotEmpty || _selectedCategoryIndex != 0) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Menampilkan ${filteredList.length} dari ${allList.length} ekskul',
                          style: const TextStyle(fontSize: 12.5, color: C.muted, fontWeight: FontWeight.w600),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _selectedCategoryIndex = 0;
                          });
                        },
                        child: const Text(
                          'Reset Filter',
                          style: TextStyle(fontSize: 12.5, color: C.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Daftar Ekskul Terfilter
              if (filteredList.isEmpty)
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 48, color: C.muted),
                      const SizedBox(height: 12),
                      tx('Tidak Ada Ekskul Ditemukan', size: 16, w: FontWeight.w800),
                      const SizedBox(height: 6),
                      tx(
                        'Tidak ditemukan ekstrakurikuler yang sesuai dengan pencarian "$_searchQuery" atau kategori yang dipilih.',
                        size: 12.5,
                        color: C.muted,
                        align: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset Pencarian & Filter'),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _selectedCategoryIndex = 0;
                          });
                        },
                      ),
                    ],
                  ),
                )
              else
                for (final e in filteredList) _EkskulCard(e),
            ],
          );
        },
      ),
    );
  }
}

class _EkskulCard extends StatelessWidget {
  final Ekskul e;
  const _EkskulCard(this.e);

  @override
  Widget build(BuildContext context) {
    final warn = e.almostFull;
    final accent = warn ? C.brown : C.primary;
    final noQuota = e.quota == 0;
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PhotoBox(height: 130, colors: e.photo, icon: e.icon, overlays: [
          Overlay1(Alignment.topLeft, Row(mainAxisSize: MainAxisSize.min, children: [
            DarkChip(e.category, icon: Icons.category_outlined),
            if (warn) ...[const SizedBox(width: 6), Pill(e.full ? 'Penuh' : 'Hampir Penuh', fg: C.brown, bg: C.amberBg, size: 10)],
          ])),
          Overlay1(Alignment.bottomLeft, DarkChip(e.schedule, icon: Icons.calendar_today_outlined)),
          Overlay1(Alignment.bottomRight, DarkChip(e.place)),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            tx(e.name, size: 17, w: FontWeight.w800),
            const SizedBox(height: 6),
            tx(e.desc, size: 12, color: C.muted, height: 1.45),
            const SizedBox(height: 10),
            Text.rich(TextSpan(style: const TextStyle(fontSize: 12, color: C.muted), children: [
              TextSpan(text: e.name.contains('Futsal') ? 'Pelatih: ' : 'Pembina: '),
              TextSpan(text: e.coach, style: const TextStyle(fontWeight: FontWeight.w800, color: C.text)),
            ])),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: tx(noQuota ? 'Jumlah Peserta Terdata' : 'Kapasitas Kuota', size: 12, color: C.text)),
              tx(
                noQuota ? '${e.filled} Siswa Terdaftar' : '${e.filled} / ${e.quota} Siswa (${(e.ratio * 100).toStringAsFixed(e.ratio * 1000 % 10 == 0 ? 0 : 1)}%)',
                size: 12,
                w: FontWeight.w700,
                color: noQuota ? C.text : accent,
              ),
            ]),
            const SizedBox(height: 6),
            QuotaBar(e.ratio, color: noQuota ? const Color(0xFF3F4A66) : accent, height: 7),
            const SizedBox(height: 14),
            if (noQuota)
              SoftButton(
                'Lihat Informasi & Presensi',
                icon: Icons.chevron_right,
                bg: C.soft,
                fg: C.primary,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EkskulDetailScreen(ekskul: e))),
              )
            else
              PrimaryButton(
                warn ? 'Daftar Segera' : 'Detail / Daftar',
                icon: warn ? Icons.bolt : Icons.arrow_forward,
                color: warn ? C.brown : C.primary,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => warn ? RegistrationFormScreen(ekskul: e) : EkskulDetailScreen(ekskul: e)),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}
