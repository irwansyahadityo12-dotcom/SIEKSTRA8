import 'package:flutter/material.dart';
import '../../app/supabase_config.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});
  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedChip = 0; // 0: Menunggu, 1: Disetujui, 2: Ditolak

  final List<Map<String, dynamic>> _waitingItems = [];
  final List<Map<String, dynamic>> _approvedItems = [];
  final List<Map<String, dynamic>> _rejectedItems = [];

  final _repository = SiekstraRepository();
  List<Map<String, dynamic>> _remoteItems = [];
  bool _loadingRemote = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    if (SupabaseConfig.isConfigured) _loadRemote();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRemote() async {
    setState(() {
      _loadingRemote = true;
      _loadError = null;
    });
    try {
      final rows = await _repository.getMembershipsForCoach();
      if (!mounted) return;
      setState(() => _remoteItems = rows);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingRemote = false);
    }
  }

  Future<void> _decideRemote(String id, bool approve, String name) async {
    try {
      await _repository.reviewMembership(id, approve: approve);
      if (!mounted) return;
      toast(context, '$name ${approve ? 'disetujui' : 'ditolak'}');
      await _loadRemote();
    } catch (e) {
      if (mounted) toast(context, 'Gagal menyimpan keputusan: $e');
    }
  }

  void _decideLocal(int index, bool ok) {
    final item = _waitingItems[index];
    final name = item['name'] as String;
    setState(() {
      _waitingItems.removeAt(index);
      if (ok) {
        _approvedItems.insert(0, {
          ...item,
          'date': 'Baru saja • Disetujui Pembina',
        });
      } else {
        _rejectedItems.insert(0, {
          ...item,
          'date': 'Baru saja • Ditolak Pembina',
        });
      }
    });
    toast(context, '$name berhasil ${ok ? 'disetujui' : 'ditolak'}');
  }

  List<Map<String, dynamic>> get _currentList {
    final baseList = <Map<String, dynamic>>[];

    if (_searchQuery.trim().isEmpty) return baseList;

    final q = _searchQuery.toLowerCase().trim();
    return baseList.where((item) {
      final name = (item['name'] as String? ?? '').toLowerCase();
      final cls = (item['cls'] as String? ?? '').toLowerCase();
      final ekskul = (item['ekskul'] as String? ?? '').toLowerCase();
      final note = (item['note'] as String? ?? '').toLowerCase();
      return name.contains(q) || cls.contains(q) || ekskul.contains(q) || note.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _remoteItems.where((r) => r['status'] == 'pending').length;
    final approved = _remoteItems.where((r) => r['status'] == 'approved').length;
    final rejected = _remoteItems.where((r) => r['status'] == 'rejected').length;

    final displayItems = _currentList;

    return Screen(
      title: 'Persetujuan Anggota',
      subtitle: 'Tinjau pendaftaran siswa, berikan keputusan, dan pantau status klub pembimbing Anda.',
      trailing: Pill('$waiting menunggu', Colors.white, AppColors.primary, icon: Icons.groups_rounded),
      children: [
        SCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const IconBox(Icons.assignment_turned_in_outlined, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pendaftaran Siswa', style: T.h2),
                  Text('$waiting permintaan menunggu keputusan anda.', style: T.body.copyWith(fontSize: 14)),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              Pill('$approved disetujui', AppColors.greenSoft, AppColors.green, icon: Icons.check_circle),
              Pill('$rejected ditolak', AppColors.redSoft, AppColors.red, icon: Icons.cancel),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Sum('Menunggu', '$waiting', 'permintaan aktif')),
              const SizedBox(width: 8),
              Expanded(child: _Sum('Disetujui', '$approved', 'anggota baru')),
              const SizedBox(width: 8),
              Expanded(child: _Sum('Ditolak', '$rejected', 'ditolak / revisi')),
            ]),
          ]),
        ),
        SearchField(
          'Cari nama siswa, kelas, atau ekskul...',
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),
        Chips(
          [
            'Menunggu ($waiting)',
            'Disetujui ($approved)',
            'Ditolak ($rejected)',
          ],
          selectedIndex: _selectedChip,
          onChanged: (idx) => setState(() => _selectedChip = idx),
        ),
        if (SupabaseConfig.isConfigured && _loadingRemote)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
        if (SupabaseConfig.isConfigured && _loadError != null)
          SCard(
            child: Column(children: [
              Text('Gagal memuat pendaftaran dari server: $_loadError'),
              TextButton(onPressed: _loadRemote, child: const Text('Coba lagi')),
            ]),
          ),
        if (SupabaseConfig.isConfigured && _remoteItems.where((item) => item['status'] == ['pending', 'approved', 'rejected'][_selectedChip]).isNotEmpty)
          for (final item in _remoteItems.where((item) => item['status'] == ['pending', 'approved', 'rejected'][_selectedChip]))
            SCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.person_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (item['profiles']?['full_name'] ?? 'Siswa').toString(),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Pill(item['status'] == 'pending' ? 'Menunggu' : item['status'] == 'approved' ? 'Disetujui' : 'Ditolak', item['status'] == 'approved' ? AppColors.greenSoft : item['status'] == 'rejected' ? AppColors.redSoft : AppColors.soft, item['status'] == 'approved' ? AppColors.green : item['status'] == 'rejected' ? AppColors.red : AppColors.primary, icon: item['status'] == 'approved' ? Icons.check_circle : item['status'] == 'rejected' ? Icons.cancel : Icons.schedule),
                ]),
                Text((item['profiles']?['identifier'] ?? '-').toString(), style: T.body.copyWith(fontSize: 14)),
                const SizedBox(height: 6),
                Pill((item['extracurriculars']?['name'] ?? 'Ekstrakurikuler').toString(), AppColors.soft, AppColors.primary),
                const SizedBox(height: 14),
                if (item['status'] == 'pending') Row(children: [
                  const Spacer(),
                  Btn.success('ACC', icon: Icons.check, onTap: () => _decideRemote(item['id'].toString(), true, (item['profiles']?['full_name'] ?? 'Siswa').toString())),
                  const SizedBox(width: 10),
                  Btn.danger('Tolak', icon: Icons.close, onTap: () => _decideRemote(item['id'].toString(), false, (item['profiles']?['full_name'] ?? 'Siswa').toString())),
                ]),
              ]),
            ),
        if (displayItems.isEmpty && !_remoteItems.any((item) => item['status'] == ['pending', 'approved', 'rejected'][_selectedChip]))
          SCard(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              children: [
                Icon(
                  _selectedChip == 0 ? Icons.done_all : Icons.search_off,
                  size: 46,
                  color: AppColors.muted,
                ),
                const SizedBox(height: 10),
                Text(
                  _selectedChip == 0
                      ? 'Semua Permintaan Sudah Diproses 🎉'
                      : 'Tidak Ada Pendaftaran Ditemukan',
                  style: T.h2,
                ),
                const SizedBox(height: 4),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Tidak ada siswa yang cocok dengan "$_searchQuery".'
                      : _selectedChip == 0
                          ? 'Tidak ada pengajuan anggota baru yang menunggu persetujuan.'
                          : 'Belum ada pendaftaran pada kategori ini.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < displayItems.length; i++)
            SCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.person_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayItems[i]['name'] as String,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Pill(
                    _selectedChip == 0
                        ? 'Menunggu'
                        : _selectedChip == 1
                            ? 'Disetujui'
                            : 'Ditolak',
                    _selectedChip == 0
                        ? AppColors.soft
                        : _selectedChip == 1
                            ? AppColors.greenSoft
                            : AppColors.redSoft,
                    _selectedChip == 0
                        ? AppColors.primary
                        : _selectedChip == 1
                            ? AppColors.green
                            : AppColors.red,
                    icon: _selectedChip == 0
                        ? Icons.schedule
                        : _selectedChip == 1
                            ? Icons.check_circle
                            : Icons.cancel,
                  ),
                ]),
                Text(displayItems[i]['cls'] as String, style: T.body.copyWith(fontSize: 13.5)),
                const SizedBox(height: 6),
                Row(children: [
                  Pill(displayItems[i]['ekskul'] as String, AppColors.soft, AppColors.primary),
                  const Spacer(),
                  Text(displayItems[i]['date'] as String, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ]),
                if ((displayItems[i]['note'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFF3F5FA), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      displayItems[i]['note'] as String,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.ink),
                    ),
                  ),
                ],
                if (_selectedChip == 0) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    const Spacer(),
                    Btn.success('ACC', icon: Icons.check, onTap: () => _decideLocal(i, true)),
                    const SizedBox(width: 10),
                    Btn.danger('Tolak', icon: Icons.close, onTap: () => _decideLocal(i, false)),
                  ]),
                ],
              ]),
            ),
      ],
    );
  }
}

class _Sum extends StatelessWidget {
  final String l, v, s;
  const _Sum(this.l, this.v, this.s);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF7F8FC), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: T.body.copyWith(fontSize: 12)),
          Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(s, style: T.body.copyWith(fontSize: 11)),
        ]),
      );
}
