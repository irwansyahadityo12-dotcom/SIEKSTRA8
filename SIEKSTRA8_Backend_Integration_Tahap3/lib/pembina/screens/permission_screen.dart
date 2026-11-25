import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});
  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final _repository = SiekstraRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedChip = 0; // 0: Semua, 1: Menunggu, 2: Disetujui, 3: Ditolak

  late Future<List<Map<String, dynamic>>> _future;

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

  void _loadData() {
    _future = _repository.getPermissionRequestsForCoach();
  }

  void _reload() {
    setState(() {
      _loadData();
    });
  }

  Future<void> _review(String id, bool approve) async {
    try {
      await _repository.reviewPermission(id, approve: approve);
      if (!mounted) return;
      toast(context, approve ? 'Pengajuan izin berhasil disetujui.' : 'Pengajuan izin berhasil ditolak.');
      _reload();
    } catch (e) {
      if (mounted) toast(context, 'Gagal menyimpan keputusan: $e');
    }
  }

  List<Map<String, dynamic>> _filterList(List<Map<String, dynamic>> list) {
    return list.where((item) {
      final status = (item['status'] ?? 'pending').toString().toLowerCase();

      // Filter chips: 0: Semua, 1: Menunggu, 2: Disetujui, 3: Ditolak
      if (_selectedChip == 1 && status != 'pending') return false;
      if (_selectedChip == 2 && status != 'approved') return false;
      if (_selectedChip == 3 && status != 'rejected') return false;

      // Filter search query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final profile = item['profiles'] is Map ? item['profiles'] as Map : <String, dynamic>{};
        final extra = item['extracurriculars'] is Map ? item['extracurriculars'] as Map : <String, dynamic>{};

        final name = (profile['full_name'] ?? '').toString().toLowerCase();
        final nis = (profile['identifier'] ?? '').toString().toLowerCase();
        final className = (profile['class_name'] ?? '').toString().toLowerCase();
        final ekskul = (extra['name'] ?? '').toString().toLowerCase();
        final type = (item['permission_type'] ?? '').toString().toLowerCase();
        final reason = (item['reason'] ?? '').toString().toLowerCase();

        if (!name.contains(q) &&
            !nis.contains(q) &&
            !className.contains(q) &&
            !ekskul.contains(q) &&
            !type.contains(q) &&
            !reason.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      tag: 'PEMBINA',
      title: 'Persetujuan Izin Anggota',
      subtitle: 'Permohonan izin dan dispensasi kehadiran dari anggota ekstrakurikuler binaan',
      children: [
        SearchField(
          'Cari nama siswa, NIS, kelas, atau alasan izin...',
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SCard(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 40, color: AppColors.red),
                    const SizedBox(height: 10),
                    const Text('Gagal Memuat Data Izin', style: T.h2),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 12),
                    Btn.soft('Coba Lagi', onTap: _reload),
                  ],
                ),
              );
            }

            final allItems = snapshot.data ?? [];
            final waitingCount = allItems.where((r) => (r['status'] ?? '').toString().toLowerCase() == 'pending').length;
            final approvedCount = allItems.where((r) => (r['status'] ?? '').toString().toLowerCase() == 'approved').length;
            final rejectedCount = allItems.where((r) => (r['status'] ?? '').toString().toLowerCase() == 'rejected').length;

            final filtered = _filterList(allItems);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chips(
                  [
                    'Semua (${allItems.length})',
                    'Menunggu ($waitingCount)',
                    'Disetujui ($approvedCount)',
                    'Ditolak ($rejectedCount)',
                  ],
                  selectedIndex: _selectedChip,
                  onChanged: (idx) => setState(() => _selectedChip = idx),
                ),
                if (filtered.isEmpty)
                  SCard(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    child: Column(
                      children: [
                        const Icon(Icons.event_available, size: 44, color: AppColors.muted),
                        const SizedBox(height: 10),
                        const Text('Tidak Ada Pengajuan Izin', style: T.h2),
                        const SizedBox(height: 4),
                        const Text(
                          'Tidak ditemukan permohonan izin yang sesuai dengan filter atau kata kunci pencarian.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.muted),
                        ),
                        if (_selectedChip != 0 || _searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Btn.soft(
                            'Tampilkan Semua Izin',
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _selectedChip = 0;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  for (final row in filtered) _requestCard(row),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _requestCard(Map<String, dynamic> row) {
    final id = row['id']?.toString() ?? '';
    final profile = row['profiles'] is Map ? row['profiles'] as Map : <String, dynamic>{};
    final extra = row['extracurriculars'] is Map ? row['extracurriculars'] as Map : <String, dynamic>{};

    final name = (profile['full_name'] ?? 'Siswa').toString();
    final nis = (profile['identifier'] ?? '-').toString();
    final className = (profile['class_name'] ?? '').toString();
    final ekskulName = (extra['name'] ?? 'Ekstrakurikuler').toString();

    final subInfo = [
      if (nis.isNotEmpty && nis != '-') 'NIS $nis',
      if (className.isNotEmpty) className,
      ekskulName,
    ].join(' • ');

    final status = (row['status'] ?? 'pending').toString().toLowerCase();
    final isPending = status == 'pending';
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    final statusLabel = isPending ? 'Menunggu' : isApproved ? 'Disetujui' : 'Ditolak';
    final statusBg = isPending ? AppColors.soft : isApproved ? AppColors.greenSoft : AppColors.redSoft;
    final statusFg = isPending ? AppColors.primary : isApproved ? AppColors.green : AppColors.red;

    final type = (row['permission_type'] ?? 'Izin').toString();
    final date = (row['start_date'] ?? '-').toString();
    final reason = (row['reason'] ?? '-').toString();

    return SCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name, style: T.h2.copyWith(fontSize: 16.5)),
              ),
              Pill(
                statusLabel,
                statusBg,
                statusFg,
                dot: isPending,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subInfo.isNotEmpty ? subInfo : 'SMKN 8 Malang',
            style: T.body.copyWith(fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  '$type • $date',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alasan: $reason',
            style: T.body.copyWith(fontSize: 13, color: AppColors.ink),
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Btn(
                    'Setujui Izin',
                    icon: Icons.check,
                    bg: AppColors.green,
                    expand: true,
                    h: 42,
                    onTap: () => _review(id, true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Btn(
                    'Tolak Izin',
                    icon: Icons.close,
                    bg: AppColors.red,
                    expand: true,
                    h: 42,
                    onTap: () => _review(id, false),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isApproved ? Icons.check_circle_outline : Icons.highlight_off,
                  size: 15,
                  color: isApproved ? AppColors.green : AppColors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  isApproved ? 'Telah disetujui pembina' : 'Permohonan izin ditolak pembina',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isApproved ? AppColors.green : AppColors.red,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
