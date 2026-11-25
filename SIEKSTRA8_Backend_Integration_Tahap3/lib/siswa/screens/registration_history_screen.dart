import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'registration_status_screen.dart';
import '../../data/siekstra_repository.dart';
import '../../app/supabase_config.dart';

class RegistrationHistoryScreen extends StatefulWidget {
  const RegistrationHistoryScreen({super.key});

  @override
  State<RegistrationHistoryScreen> createState() => _RegistrationHistoryScreenState();
}

class _RegistrationHistoryScreenState extends State<RegistrationHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: Semua, 1: Menunggu, 2: Diterima, 3: Ditolak

  final List<Map<String, dynamic>> _registrations = [];
  final _repository = SiekstraRepository();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  Future<void> _loadRegistrations() async {
    if (!SupabaseConfig.isConfigured) {
      setState(() { _loading = false; _error = 'Supabase belum dikonfigurasi.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final rows = await _repository.getMyMemberships();
      if (!mounted) return;
      setState(() {
        _registrations
          ..clear()
          ..addAll(rows.map((row) {
            final status = row['status'] == 'approved' ? 'Diterima'
                : row['status'] == 'rejected' ? 'Ditolak'
                : row['status'] == 'resigned' ? 'Mengundurkan Diri' : 'Menunggu';
            final date = DateTime.tryParse(row['created_at']?.toString() ?? '');
            return {
              'title': (row['extracurriculars'] as Map?)?['name']?.toString() ?? 'Ekstrakurikuler',
              'date': date == null ? '-' : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              'status': status,
              'color': status == 'Diterima' ? C.green : status == 'Ditolak' ? C.red : C.amber,
              'bg': status == 'Diterima' ? C.greenBg : status == 'Ditolak' ? C.redBg : C.amberBg,
            };
          }));
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredRegistrations {
    return _registrations.where((r) {
      final status = r['status'] as String;

      if (_selectedFilter == 1 && status != 'Menunggu') return false;
      if (_selectedFilter == 2 && status != 'Diterima') return false;
      if (_selectedFilter == 3 && status != 'Ditolak') return false;

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final title = (r['title'] as String).toLowerCase();
        final date = (r['date'] as String).toLowerCase();
        final statusLower = status.toLowerCase();
        if (!title.contains(q) && !date.contains(q) && !statusLower.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allCount = _registrations.length;
    final waitingCount = _registrations.where((r) => r['status'] == 'Menunggu').length;
    final acceptedCount = _registrations.where((r) => r['status'] == 'Diterima').length;
    final rejectedCount = _registrations.where((r) => r['status'] == 'Ditolak').length;

    final filtered = _filteredRegistrations;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pendaftaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            color: C.soft,
            child: Row(children: [
              const Icon(Icons.info_outline, color: C.primary),
              const SizedBox(width: 10),
              Expanded(
                child: tx('Pantau status semua pengajuan pendaftaran ekstrakurikuler yang pernah kamu kirim.', size: 12, color: C.primary),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          // Search Box
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari riwayat pendaftaran ekskul...',
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
          const SizedBox(height: 12),
          if (_loading) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          if (_error != null) AppCard(child: Column(children: [
            tx('Gagal memuat riwayat: $_error', size: 12, color: C.red),
            TextButton.icon(onPressed: _loadRegistrations, icon: const Icon(Icons.refresh), label: const Text('Coba lagi')),
          ])),
          // Filter Chips
          FilterChips(
            [
              'Semua ($allCount)',
              'Menunggu ($waitingCount)',
              'Diterima ($acceptedCount)',
              'Ditolak ($rejectedCount)',
            ],
            onChanged: (idx) => setState(() => _selectedFilter = idx),
          ),
          const SizedBox(height: 14),
          const SectionTitle('Daftar Pengajuan'),
          if (!_loading && _error == null && filtered.isEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Column(
                children: [
                  const Icon(Icons.history_toggle_off, size: 40, color: C.muted),
                  const SizedBox(height: 10),
                  tx('Tidak Ada Riwayat Ditemukan', size: 14, w: FontWeight.w800),
                  const SizedBox(height: 4),
                  tx('Tidak ada pendaftaran yang cocok dengan pencarian atau filter saat ini.', size: 12, color: C.muted, align: TextAlign.center),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _selectedFilter = 0;
                      });
                    },
                    child: const Text('Reset Pencarian & Filter'),
                  ),
                ],
              ),
            )
          else if (!_loading && _error == null)
            for (final r in filtered)
              _RegistrationCard(
                title: r['title'] as String,
                date: r['date'] as String,
                status: r['status'] as String,
                color: r['color'] as Color,
                bg: r['bg'] as Color,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistrationStatusScreen()),
                ),
              ),
          const SizedBox(height: 12),
          tx('Status pendaftaran otomatis tersinkronisasi langsung dari keputusan Pembina dan Admin Kesiswaan.', size: 11, color: C.muted, align: TextAlign.center),
        ],
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final String title, date, status;
  final Color color, bg;
  final VoidCallback onTap;
  const _RegistrationCard({
    required this.title,
    required this.date,
    required this.status,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        child: Row(children: [
          const IconBox(Icons.groups_2_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tx(title, size: 14, w: FontWeight.w800),
              tx('Diajukan $date', size: 11, color: C.muted),
            ]),
          ),
          Pill(status, fg: color, bg: bg),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: C.muted),
        ]),
      );
}
