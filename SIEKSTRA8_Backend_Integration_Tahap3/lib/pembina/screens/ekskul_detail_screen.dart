import 'package:flutter/material.dart';
import '../../app/backend.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'ekskul_form_screen.dart';

class EkskulDetailScreen extends StatefulWidget {
  const EkskulDetailScreen({super.key});

  @override
  State<EkskulDetailScreen> createState() => _EkskulDetailScreenState();
}

class _EkskulDetailScreenState extends State<EkskulDetailScreen> {
  final SiekstraRepository _repo = SiekstraRepository();
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _extra;
  int _memberCount = 0;
  int _pendingCount = 0;
  int _scheduleCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await Backend.ensureInitialized();
      final extras = await _repo.getCoachExtracurriculars();
      if (!mounted) return;

      Map<String, dynamic>? target;
      if (extras.isNotEmpty) {
        target = extras.first;
      } else {
        final all = await _repo.getExtracurriculars();
        if (!mounted) return;
        if (all.isNotEmpty) target = all.first;
      }

      _extra = target;

      if (target != null) {
        final extraId = target['id'].toString();
        final results = await Future.wait([
          _repo.getMembers(extraId),
          _repo.getPendingMembershipsForCoach(),
          _repo.getCoachSchedules(),
        ]);

        if (!mounted) return;

        final members = results[0];
        final pending = results[1];
        final schedules = results[2];

        _memberCount = members.length;
        _pendingCount = pending.length;
        _scheduleCount = schedules.length;
      }

      setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _extra?['name']?.toString() ?? 'Ekstrakurikuler';
    final category = _extra?['category']?.toString() ?? 'Kategori Ekstrakurikuler';
    final schedule = _extra?['schedule_summary']?.toString() ?? 'Jadwal belum diatur';
    final location = _extra?['location']?.toString() ?? 'Lokasi belum diatur';
    final quota = _extra?['quota']?.toString() ?? '0';
    final isOpen = _extra?['is_open'] != false;

    return Screen(
      title: 'Detail Ekskul',
      trailing: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
        tooltip: 'Muat Ulang',
        onPressed: _load,
      ),
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          SCard(
            child: Column(children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 36),
              const SizedBox(height: 8),
              Text('Gagal memuat detail ekskul: $_error', style: T.body),
              const SizedBox(height: 10),
              Btn.soft('Coba Lagi', onTap: _load),
            ]),
          )
        else ...[
          SCard(
            color: const Color(0xFFF3F7FF),
            border: const Color(0xFFDDE7FF),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                  ),
                ),
                const IconBox(Icons.groups_rounded, size: 40),
              ]),
              const SizedBox(height: 6),
              Text(
                '$category • ${isOpen ? 'Pendaftaran Dibuka' : 'Ditutup'}',
                style: const TextStyle(fontSize: 15, color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              Text(
                '$_memberCount anggota aktif • 1 pembimbing • $_scheduleCount jadwal aktif',
                style: T.body,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Pill(
                  isOpen ? 'Aktif' : 'Tutup',
                  isOpen ? AppColors.greenSoft : AppColors.soft,
                  isOpen ? AppColors.green : AppColors.muted,
                ),
                const Spacer(),
                Btn(
                  'Edit Ekskul',
                  h: 40,
                  onTap: () async {
                    final res = await push(
                      context,
                      EkskulFormScreen(initial: _extra),
                    );
                    if (res == true) _load();
                  },
                ),
              ]),
            ]),
          ),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: _Mini(
                Icons.groups_rounded,
                'Anggota',
                '$_memberCount siswa',
                'Kelola anggota →',
                () => goTab(context, 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Mini(
                Icons.calendar_month_rounded,
                'Jadwal',
                schedule,
                'Kelola jadwal →',
                () => goTab(context, 4),
              ),
            ),
          ]),
          SCard(
            onTap: () => goTab(context, 3),
            child: Row(children: [
              const IconBox(
                Icons.description_rounded,
                bg: AppColors.amberSoft,
                fg: AppColors.amber,
                size: 64,
              ),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Pendaftaran Siswa', style: T.h2),
                Text('$_pendingCount menunggu persetujuan', style: T.body),
                const SizedBox(height: 6),
                const Text('Tinjau Sekarang →', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
          SCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Expanded(child: Text('Ringkasan Ekskul', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                Pill('Supabase Live', AppColors.greenSoft, AppColors.green),
              ]),
              const Text('Informasi utama tersinkronisasi database', style: T.body),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _Sum('Anggota Aktif', '$_memberCount siswa')),
                const SizedBox(width: 10),
                Expanded(child: _Sum('Target Kuota', '$quota kursi')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _Sum('Jadwal Rutin', schedule)),
                const SizedBox(width: 10),
                Expanded(child: _Sum('Lokasi Latihan', location)),
              ]),
            ]),
          ),
        ],
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  final IconData icon;
  final String t, s, link;
  final VoidCallback onTap;
  const _Mini(this.icon, this.t, this.s, this.link, this.onTap);

  @override
  Widget build(BuildContext context) => SCard(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(icon, size: 44),
          const SizedBox(height: 12),
          Text(t, style: T.h2),
          Text(s, style: T.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 14),
          Text(link, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Sum extends StatelessWidget {
  final String l, v;
  const _Sum(this.l, this.v);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: T.body),
          const SizedBox(height: 6),
          Text(v, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      );
}
