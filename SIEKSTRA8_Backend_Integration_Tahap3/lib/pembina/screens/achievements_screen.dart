import 'package:flutter/material.dart';
import '../../app/backend.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'record_form_screen.dart';
import 'record_detail_screen.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final SiekstraRepository _repo = SiekstraRepository();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  int _selectedTingkatChip = 0; // 0: Semua Tingkat, 1: Kota Malang, 2: Jawa Timur, 3: Nasional
  int _statusTab = 0; // 0: Semua, 1: Juara & Selesai, 2: Aktif / Mendatang

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _coachExtras = [];
  Map<String, dynamic>? _selectedExtra;
  List<Map<String, dynamic>> _achievements = [];

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

      await _fetchAchievements();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAchievements() async {
    try {
      final extraId = _selectedExtra?['id']?.toString();
      final rows = await _repo.getAchievements(extracurricularId: extraId);

      final List<Map<String, dynamic>> mapped = [];
      for (final r in rows) {
        final title = (r['title'] ?? 'Prestasi Tanpa Nama').toString().trim();
        final award = (r['award'] ?? 'Penghargaan').toString().trim();
        final comp = (r['competition_name'] ?? '').toString().trim();
        final desc = (r['description'] ?? '').toString().trim();
        final date = (r['achievement_date'] ?? '').toString().trim();
        final extraMap = r['extracurriculars'] as Map<String, dynamic>?;
        final extraName = extraMap?['name']?.toString() ?? (_selectedExtra?['name'] ?? 'Ekstrakurikuler');

        // Deteksi tingkat kejuaraan
        final combinedText = '$title $comp $desc'.toLowerCase();
        String tingkat = 'Kota Malang';
        if (combinedText.contains('nasional') || combinedText.contains('indonesia')) {
          tingkat = 'Nasional';
        } else if (combinedText.contains('jawa timur') ||
            combinedText.contains('jatim') ||
            combinedText.contains('provinsi')) {
          tingkat = 'Jawa Timur';
        } else if (combinedText.contains('kota') || combinedText.contains('malang')) {
          tingkat = 'Kota Malang';
        }

        final isJuara = award.toLowerCase().contains('juara') ||
            award.toLowerCase().contains('emas') ||
            award.toLowerCase().contains('perak') ||
            award.toLowerCase().contains('perunggu') ||
            award.toLowerCase().contains('best');

        String dateFormatted = date;
        if (date.isNotEmpty) {
          final dt = DateTime.tryParse(date);
          if (dt != null) {
            dateFormatted = '${dt.day}/${dt.month}/${dt.year}';
          }
        } else {
          dateFormatted = 'Terkini';
        }

        mapped.add({
          'id': r['id']?.toString() ?? '',
          'title': title,
          'achievement': award.isNotEmpty ? award : 'Peserta Berprestasi',
          'tingkat': tingkat,
          'tingkatTag': 'Tingkat $tingkat',
          'date': dateFormatted,
          'dateTag': isJuara ? 'Juara' : 'Partisipasi',
          'place': comp.isNotEmpty ? comp : 'Malang Raya',
          'team': desc.isNotEmpty ? desc : 'Delegasi $extraName SMKN 8',
          'isJuara': isJuara,
          'status': 'Terverifikasi di Supabase',
          'raw': r,
        });
      }

      if (mounted) {
        setState(() {
          _achievements = mapped;
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

  List<Map<String, dynamic>> get _filteredList {
    return _achievements.where((item) {
      final tingkat = item['tingkat'] as String;
      final isJuara = item['isJuara'] as bool;

      // 1. Filter Tingkat: 0: Semua, 1: Kota Malang, 2: Jawa Timur, 3: Nasional
      if (_selectedTingkatChip == 1 && tingkat != 'Kota Malang') return false;
      if (_selectedTingkatChip == 2 && tingkat != 'Jawa Timur') return false;
      if (_selectedTingkatChip == 3 && tingkat != 'Nasional') return false;

      // 2. Filter Status Tab: 0: Semua, 1: Juara & Selesai, 2: Aktif / Mendatang
      if (_statusTab == 1 && !isJuara) return false;
      if (_statusTab == 2 && isJuara) return false;

      // 3. Search Query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final title = (item['title'] as String).toLowerCase();
        final team = (item['team'] as String).toLowerCase();
        final place = (item['place'] as String).toLowerCase();
        final ach = (item['achievement'] as String).toLowerCase();
        final tingkatLower = tingkat.toLowerCase();
        if (!title.contains(q) &&
            !team.contains(q) &&
            !place.contains(q) &&
            !ach.contains(q) &&
            !tingkatLower.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _handleCreateAchievement() async {
    final ekskulName = _selectedExtra?['name'] ?? 'Ekstrakurikuler';
    final res = await push<Map<String, String>>(
      context,
      PembinaRecordFormScreen(
        title: 'Tambah Prestasi Baru',
        subtitle: 'Catat pencapaian lomba atau kejuaraan ke Supabase.',
        fields: const [
          'Nama prestasi / lomba',
          'Peringkat / Penghargaan (cth: Juara 1 / Medali Emas)',
          'Nama kompetisi / penyelenggara',
          'Tingkat (Kota Malang / Jawa Timur / Nasional)',
          'Tanggal (YYYY-MM-DD)',
          'Nama siswa / tim delegasi',
        ],
        initialValues: {
          'Tingkat (Kota Malang / Jawa Timur / Nasional)': 'Kota Malang',
          'Tanggal (YYYY-MM-DD)': DateTime.now().toIso8601String().substring(0, 10),
          'Nama siswa / tim delegasi': 'Tim $ekskulName SMKN 8 Malang',
        },
      ),
    );

    if (res != null && res.isNotEmpty && mounted) {
      final title = res['Nama prestasi / lomba']?.trim() ?? '';
      if (title.isEmpty) {
        toast(context, 'Nama prestasi tidak boleh kosong.');
        return;
      }

      final award = res['Peringkat / Penghargaan (cth: Juara 1 / Medali Emas)']?.trim();
      final comp = res['Nama kompetisi / penyelenggara']?.trim();
      final tingkat = res['Tingkat (Kota Malang / Jawa Timur / Nasional)']?.trim();
      final dateStr = res['Tanggal (YYYY-MM-DD)']?.trim();
      final team = res['Nama siswa / tim delegasi']?.trim();

      DateTime? date;
      if (dateStr != null && dateStr.isNotEmpty) {
        date = DateTime.tryParse(dateStr);
      }
      date ??= DateTime.now();

      final fullCompetition = [comp, tingkat].where((s) => s != null && s.isNotEmpty).join(' • ');

      try {
        await _repo.createAchievement(
          extracurricularId: _selectedExtra?['id']?.toString(),
          title: title,
          competitionName: fullCompetition.isNotEmpty ? fullCompetition : tingkat,
          award: award ?? 'Juara',
          date: date,
          description: team,
        );

        if (!mounted) return;
        toast(context, '✅ Data prestasi berhasil disimpan ke Supabase!');
        await _fetchAchievements();
      } catch (e) {
        if (mounted) {
          toast(context, '❌ Gagal menyimpan prestasi ke Supabase: $e');
        }
      }
    }
  }

  Future<void> _handleEditAchievement(Map<String, dynamic> item) async {
    final raw = item['raw'] as Map<String, dynamic>? ?? {};
    final title = item['title'] as String;
    final award = item['achievement'] as String;
    final comp = item['place'] as String;
    final team = item['team'] as String;
    final id = item['id'].toString();

    final res = await push<Map<String, String>>(
      context,
      PembinaRecordFormScreen(
        title: 'Edit Prestasi',
        subtitle: 'Perbarui data prestasi di database Supabase.',
        fields: const [
          'Nama prestasi / lomba',
          'Peringkat / Penghargaan',
          'Nama kejuaraan / penyelenggara',
          'Keterangan / Delegasi siswa',
        ],
        initialValues: {
          'Nama prestasi / lomba': title,
          'Peringkat / Penghargaan': award,
          'Nama kejuaraan / penyelenggara': comp,
          'Keterangan / Delegasi siswa': team,
        },
      ),
    );

    if (res != null && res.isNotEmpty && mounted) {
      try {
        await _repo.updateAchievement(id, {
          'title': res['Nama prestasi / lomba']?.trim() ?? title,
          'award': res['Peringkat / Penghargaan']?.trim() ?? award,
          'competition_name': res['Nama kejuaraan / penyelenggara']?.trim() ?? comp,
          'description': res['Keterangan / Delegasi siswa']?.trim() ?? team,
        });

        if (!mounted) return;
        toast(context, '✅ Prestasi berhasil diperbarui di Supabase');
        await _fetchAchievements();
      } catch (e) {
        if (mounted) {
          toast(context, '❌ Gagal memperbarui prestasi: $e');
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
                  _fetchAchievements();
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
    final allCount = _achievements.length;
    final selesaiCount = _achievements.where((a) => a['isJuara'] == true).length;
    final upcomingCount = _achievements.where((a) => a['isJuara'] == false).length;

    final filtered = _filteredList;
    final topAchievement = _achievements.isNotEmpty ? _achievements.first : null;

    return Screen(
      back: true,
      tag: ekskulName.length > 12 ? ekskulName.substring(0, 12) : ekskulName,
      title: 'Lomba & Prestasi',
      subtitle: 'Kelola capaian prestasi $ekskulName SMKN 8 Malang',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Muat Ulang',
            onPressed: _loadData,
          ),
          Btn(
            'Tambah',
            icon: Icons.add,
            h: 42,
            onTap: _handleCreateAchievement,
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

        // Banner Prestasi Unggulan Terkini
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.red,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.star_rounded, color: Color(0xFF86EFAC), size: 16),
              const SizedBox(width: 4),
              const Text(
                'PRESTASI TERBARU',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Pill(
                topAchievement != null ? topAchievement['tingkatTag'] : 'SMKN 8 Malang',
                const Color(0x33FFFFFF),
                Colors.white,
              ),
            ]),
            const SizedBox(height: 10),
            Text(
              topAchievement != null
                  ? topAchievement['title']
                  : 'Belum Ada Data Prestasi Tercatat',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              topAchievement != null
                  ? '${topAchievement['place']} • ${topAchievement['team']}'
                  : 'Tekan tombol "Tambah" di kanan atas untuk menambahkan capaian juara baru.',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(children: [
              const Icon(Icons.cloud_done_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Tersimpan di Supabase',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              if (topAchievement != null)
                Btn(
                  'Lihat Detail →',
                  bg: Colors.white,
                  fg: AppColors.red,
                  h: 36,
                  onTap: () => push(
                    context,
                    PembinaRecordDetailScreen(
                      category: 'Sertifikat Prestasi',
                      title: topAchievement['title'],
                      subtitle: topAchievement['team'],
                      status: topAchievement['achievement'],
                      icon: Icons.workspace_premium_outlined,
                      fields: [
                        PembinaDetailField('Tingkat', topAchievement['tingkatTag'], Icons.emoji_events_outlined),
                        PembinaDetailField('Penghargaan', topAchievement['achievement'], Icons.star_outline),
                        PembinaDetailField('Tanggal', topAchievement['date'], Icons.calendar_month_outlined),
                        PembinaDetailField('Penyelenggara / Tempat', topAchievement['place'], Icons.place_outlined),
                        PembinaDetailField('Delegasi', topAchievement['team'], Icons.groups_outlined),
                      ],
                    ),
                  ),
                ),
            ]),
          ]),
        ),

        SearchField(
          'Cari nama lomba atau kejuaraan...',
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),

        Chips(
          ['Semua Tingkat', 'Kota Malang', 'Jawa Timur', 'Nasional'],
          selectedIndex: _selectedTingkatChip,
          onChanged: (idx) => setState(() => _selectedTingkatChip = idx),
        ),

        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _statusTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _statusTab == 0 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Semua ($allCount)',
                      style: TextStyle(
                        color: _statusTab == 0 ? AppColors.primary : AppColors.muted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _statusTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _statusTab == 1 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Juara & Selesai ($selesaiCount)',
                      style: TextStyle(
                        color: _statusTab == 1 ? AppColors.primary : AppColors.muted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _statusTab = 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _statusTab == 2 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Partisipasi ($upcomingCount)',
                      style: TextStyle(
                        color: _statusTab == 2 ? AppColors.primary : AppColors.muted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
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
                Text('Gagal Memuat Prestasi', style: T.h2.copyWith(color: AppColors.red)),
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
                const Icon(Icons.emoji_events_outlined, size: 44, color: AppColors.muted),
                const SizedBox(height: 10),
                const Text('Tidak Ada Prestasi Ditemukan', style: T.h2),
                const SizedBox(height: 4),
                Text(
                  _achievements.isEmpty
                      ? 'Belum ada data prestasi yang disimpan untuk $ekskulName di Supabase.'
                      : 'Coba gunakan kata kunci lain atau pilih filter tingkat / status yang berbeda.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                if (_achievements.isNotEmpty)
                  Btn.soft(
                    'Tampilkan Semua',
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _selectedTingkatChip = 0;
                        _statusTab = 0;
                      });
                    },
                  )
                else
                  Btn(
                    'Tambah Prestasi Pertama',
                    icon: Icons.add,
                    onTap: _handleCreateAchievement,
                  ),
              ],
            ),
          )
        else
          for (final item in filtered) _buildAchievementCard(item),

        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Row(children: const [
            IconBox(Icons.sync_rounded, bg: AppColors.greenSoft, fg: AppColors.green, size: 40),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Data prestasi tersambung ke tabel "achievements" Supabase dan otomatis tampil di feed siswa serta portofolio SKPI.',
                style: T.body,
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> item) {
    final title = item['title'] as String;
    final achievement = item['achievement'] as String;
    final tingkatTag = item['tingkatTag'] as String;
    final date = item['date'] as String;
    final dateTag = item['dateTag'] as String;
    final place = item['place'] as String;
    final team = item['team'] as String;
    final isJuara = item['isJuara'] as bool;
    final status = item['status'] as String;

    return SCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(
            achievement,
            isJuara ? AppColors.green : AppColors.soft,
            isJuara ? Colors.white : AppColors.primary,
            icon: isJuara ? Icons.emoji_events_outlined : Icons.how_to_reg_outlined,
          ),
          const SizedBox(width: 6),
          Flexible(child: Pill(tingkatTag, AppColors.soft, AppColors.primary)),
          const Spacer(),
          Text(
            dateTag,
            style: TextStyle(
              color: isJuara ? AppColors.green : AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('📅 $date', style: T.body),
        if (place.isNotEmpty) Text('📍 $place', style: T.body),
        if (team.isNotEmpty) Text('👥 $team', style: T.body),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            const Icon(Icons.verified_outlined, color: AppColors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: Btn.soft(
              'Detail & Arsip',
              icon: Icons.visibility_outlined,
              expand: true,
              h: 44,
              onTap: () => push(
                context,
                PembinaRecordDetailScreen(
                  category: 'Prestasi Anggota',
                  title: title,
                  subtitle: team,
                  status: achievement,
                  icon: isJuara ? Icons.emoji_events_outlined : Icons.event_available,
                  fields: [
                    PembinaDetailField('Tingkat', tingkatTag, Icons.emoji_events_outlined),
                    PembinaDetailField('Penghargaan', achievement, Icons.star_outline),
                    PembinaDetailField('Tanggal', date, Icons.calendar_month_outlined),
                    PembinaDetailField('Penyelenggara / Lokasi', place, Icons.place_outlined),
                    PembinaDetailField('Tim / Peserta', team, Icons.groups_outlined),
                    PembinaDetailField('Status', status, Icons.check_circle_outline),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              tooltip: 'Edit Prestasi',
              onPressed: () => _handleEditAchievement(item),
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            ),
          ),
        ]),
      ]),
    );
  }
}
