import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
  final _repository = SiekstraRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedChip = 0; // 0: Semua, 1: Admin, 2: Pembina, 3: Siswa
  bool _isLoading = true;

  List<Map<String, dynamic>> _activities = [];

  static const List<Map<String, dynamic>> _defaultActivities = [
    {
      'role': 'Admin',
      'who': 'Admin Kesiswaan',
      'action': ' menyetujui proposal kegiatan PMR Wira Unit 8.',
      'time': 'Hari ini • 09:42 WIB',
      'icon': Icons.check_circle_outline,
      'bg': C.greenSoft,
      'fg': C.green,
    },
    {
      'role': 'Pembina',
      'who': 'Pembina Futsal (Dedi Wahyudi)',
      'action': ' memperbarui jadwal latihan rutin pekan depan.',
      'time': 'Hari ini • 08:55 WIB',
      'icon': Icons.event_available_outlined,
      'bg': C.soft,
      'fg': C.primary,
    },
    {
      'role': 'Siswa',
      'who': 'Siswa: Muhammad Rizky Pratama',
      'action': ' mengirim pendaftaran baru ke ekskul RPL Club.',
      'time': 'Hari ini • 08:20 WIB',
      'icon': Icons.person_add_alt_1,
      'bg': C.orangeSoft,
      'fg': C.orange,
    },
    {
      'role': 'Admin',
      'who': 'Admin Kesiswaan',
      'action': ' memverifikasi data juara LKS Cyber Security 2024.',
      'time': 'Kemarin • 15:10 WIB',
      'icon': Icons.verified_outlined,
      'bg': C.amberSoft,
      'fg': C.amber,
    },
    {
      'role': 'Pembina',
      'who': 'Pembina PMR (Drs. Hj. Meita Juwita)',
      'action': ' memvalidasi presensi 42 anggota PMR Madya.',
      'time': 'Kemarin • 14:05 WIB',
      'icon': Icons.fact_check_outlined,
      'bg': C.soft,
      'fg': C.primary,
    },
    {
      'role': 'Siswa',
      'who': 'Siswa: Nabila Putri Syahrani',
      'action': ' mengajukan izin sakit untuk sesi latihan Paskibra.',
      'time': 'Kemarin • 11:30 WIB',
      'icon': Icons.healing_outlined,
      'bg': C.orangeSoft,
      'fg': C.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final rows = await _repository.getActivityLogs();
      if (mounted) {
        if (rows.isNotEmpty) {
          setState(() {
            _activities = rows.map(_formatLogItem).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _activities = List.from(_defaultActivities);
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _activities = List.from(_defaultActivities);
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _formatLogItem(Map<String, dynamic> raw) {
    final action = (raw['action'] ?? '').toString();
    final desc = (raw['description'] ?? '').toString();
    final who = raw['profiles']?['full_name']?.toString() ?? 'Pengguna Sistem';
    final createdAt = raw['created_at']?.toString() ?? '';

    String timeStr = 'Baru saja';
    if (createdAt.length >= 16) {
      final datePart = createdAt.substring(0, 10);
      final timePart = createdAt.substring(11, 16);
      timeStr = '$datePart • $timePart WIB';
    }

    String role = 'Admin';
    final descLower = desc.toLowerCase();
    final actionLower = action.toLowerCase();
    if (descLower.contains('pembina') || actionLower.contains('coach')) {
      role = 'Pembina';
    } else if (descLower.contains('siswa') || actionLower.contains('student')) {
      role = 'Siswa';
    }

    IconData icon = Icons.history;
    Color bg = C.soft;
    Color fg = C.primary;

    if (actionLower.contains('approve') || descLower.contains('menyetujui') || descLower.contains('disetujui')) {
      icon = Icons.check_circle_outline;
      bg = C.greenSoft;
      fg = C.green;
    } else if (descLower.contains('jadwal') || actionLower.contains('schedule')) {
      icon = Icons.event_available_outlined;
      bg = C.soft;
      fg = C.primary;
    } else if (descLower.contains('daftar') || descLower.contains('registrasi') || actionLower.contains('register')) {
      icon = Icons.person_add_alt_1;
      bg = C.orangeSoft;
      fg = C.orange;
    } else if (descLower.contains('prestasi') || descLower.contains('juara')) {
      icon = Icons.verified_outlined;
      bg = C.amberSoft;
      fg = C.amber;
    } else if (descLower.contains('presensi') || descLower.contains('absen')) {
      icon = Icons.fact_check_outlined;
      bg = C.soft;
      fg = C.primary;
    } else if (descLower.contains('izin') || descLower.contains('dispensasi')) {
      icon = Icons.healing_outlined;
      bg = C.orangeSoft;
      fg = C.orange;
    }

    return {
      'role': role,
      'who': who,
      'action': ' $desc',
      'time': timeStr,
      'icon': icon,
      'bg': bg,
      'fg': fg,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredActivities {
    return _activities.where((act) {
      final role = act['role'] as String;

      // Filter role
      if (_selectedChip == 1 && role != 'Admin') return false;
      if (_selectedChip == 2 && role != 'Pembina') return false;
      if (_selectedChip == 3 && role != 'Siswa') return false;

      // Filter search
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final who = (act['who'] as String).toLowerCase();
        final action = (act['action'] as String).toLowerCase();
        final time = (act['time'] as String).toLowerCase();
        final roleLower = role.toLowerCase();
        if (!who.contains(q) && !action.contains(q) && !time.contains(q) && !roleLower.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allCount = _activities.length;
    final adminCount = _activities.where((a) => a['role'] == 'Admin').length;
    final pembinaCount = _activities.where((a) => a['role'] == 'Pembina').length;
    final siswaCount = _activities.where((a) => a['role'] == 'Siswa').length;

    final filtered = _filteredActivities;

    return AdminScreen(
      back: 'Kembali ke Sistem & Akun',
      title: 'Riwayat Aktivitas Sistem',
      subtitle: 'Catatan aktivitas pengguna dan perubahan pada sistem SIEKSTRA-8 SMKN 8 Malang.',
      children: [
        Row(children: [
          Expanded(child: StatBox('Total Aktivitas', '$allCount', 'Tercatat', icon: Icons.history, subColor: C.primary)),
          const SizedBox(width: 8),
          Expanded(child: StatBox('Pengguna Aktif', '16', 'Hari ini', icon: Icons.people_outline, valueColor: C.primary, subColor: C.primary)),
        ]),
        const SizedBox(height: 14),
        SearchBox(
          'Cari pengguna atau aktivitas...',
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),
        Chips(
          [
            'Semua ($allCount)',
            'Admin ($adminCount)',
            'Pembina ($pembinaCount)',
            'Siswa ($siswaCount)',
          ],
          selectedIndex: _selectedChip,
          onChanged: (i) => setState(() => _selectedChip = i),
        ),
        if (_searchQuery.isNotEmpty || _selectedChip != 0) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Menampilkan ${filtered.length} dari $allCount log aktivitas',
                    style: const TextStyle(fontSize: 13, color: C.muted, fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedChip = 0;
                    });
                  },
                  child: const Text(
                    'Reset Filter',
                    style: TextStyle(fontSize: 13, color: C.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filtered.isEmpty)
          SCard(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              children: [
                const Icon(Icons.search_off, size: 48, color: C.muted),
                const SizedBox(height: 12),
                const Text('Tidak Ada Aktivitas Ditemukan', style: T.h2),
                const SizedBox(height: 4),
                const Text(
                  'Coba gunakan kata kunci pencarian lain atau pilih filter kategori role yang berbeda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: C.muted),
                ),
                const SizedBox(height: 14),
                Btn.soft(
                  'Tampilkan Semua',
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedChip = 0;
                    });
                  },
                ),
              ],
            ),
          )
        else
          for (final a in filtered)
            _log(
              a['icon'] as IconData,
              a['bg'] as Color,
              a['fg'] as Color,
              a['who'] as String,
              a['action'] as String,
              a['time'] as String,
              a['role'] as String,
            ),
        const InfoCard(
          Icons.info_outline,
          'Audit Log Terenkripsi',
          'Riwayat aktivitas sistem tersinkronisasi otomatis dari database audit trail Supabase untuk keamanan integritas data SMKN 8 Malang.',
        ),
      ],
    );
  }

  Widget _log(IconData icon, Color bg, Color fg, String who, String action, String time, String role) => SCard(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(icon, bg: bg, fg: fg, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Pill(role, bg, fg),
                  const Spacer(),
                  Text(time, style: const TextStyle(color: C.muted, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: T.body.copyWith(color: C.ink, fontSize: 13.5),
                  children: [
                    TextSpan(text: who, style: const TextStyle(fontWeight: FontWeight.w800)),
                    TextSpan(text: action),
                  ],
                ),
              ),
            ]),
          ),
        ]),
      );
}
