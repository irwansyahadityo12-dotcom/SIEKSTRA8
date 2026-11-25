import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'attendance_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = SiekstraRepository();
  late Future<Map<String, int>> _stats;
  late Future<List<Map<String, dynamic>>> _extras;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _stats = _repository.getCoachDashboardStats();
    _extras = _repository.getCoachExtracurriculars();
  }

  Future<void> _refresh() async => setState(_load);

  @override
  Widget build(BuildContext context) {
    final roleInfo = currentClassName.isNotEmpty && currentClassName != 'SMKN 8 Malang'
        ? '$currentClassName • Pembina Kegiatan'
        : 'Pembina Ekstrakurikuler • SMKN 8 Malang';
    return Screen(
      title: 'Beranda Pembimbing',
      trailing: IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh, color: AppColors.primary)),
      bottom: Btn('Lihat jadwal hari ini', icon: Icons.event_available_rounded, expand: true, h: 54, onTap: () => goTab(context, 4)),
      children: [
        Text('Halo, ${currentUserName}! 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        Text(roleInfo, style: const TextStyle(fontSize: 15, color: AppColors.muted)),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, int>>(
          future: _stats,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
            if (snapshot.hasError) return SCard(child: Text('Statistik belum dapat dimuat: ${snapshot.error}', style: T.body));
            final data = snapshot.data ?? const <String, int>{};
            return Column(children: [
              Row(children: [
                Expanded(child: _Stat('EKSKUL AKTIF', '${data['extracurriculars'] ?? 0}', Icons.layers_rounded, const Color(0xFFEFF4FF), AppColors.primary, AppColors.primary)),
                const SizedBox(width: 10),
                Expanded(child: _Stat('ANGGOTA', '${data['members'] ?? 0}', Icons.groups_rounded, Colors.white, AppColors.primary, AppColors.primary)),
                const SizedBox(width: 10),
                Expanded(child: _Stat('PENDAFTAR', '${data['pending'] ?? 0}', Icons.person_add_alt_1_rounded, const Color(0xFFFBEFDD), const Color(0xFF9A4A0A), AppColors.amber)),
              ]),
              const SizedBox(height: 12),
              SCard(child: Row(children: [
                const IconBox(Icons.event_available_rounded, bg: Color(0xFFE7F8EF), fg: AppColors.green),
                const SizedBox(width: 12),
                const Expanded(child: Text('Sesi presensi tersimpan', style: T.title)),
                Text('${data['sessions'] ?? 0}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.green)),
              ])),
            ]);
          },
        ),
        const SectionTitle('Aksi Cepat'),
        Row(children: [
          _Quick('Kelola', Icons.layers_rounded, true, () => goTab(context, 1)),
          _Quick('Anggota', Icons.groups_rounded, false, () => goTab(context, 2)),
          _Quick('Pendaftar', Icons.person_add_alt_1_rounded, false, () => goTab(context, 3)),
          _Quick('Presensi', Icons.assignment_turned_in_rounded, false, () => push(context, const AttendanceInputScreen())),
        ]),
        const SectionTitle('Ekstrakurikuler Binaan'),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _extras,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
            if (snapshot.hasError) return SCard(child: Text('Gagal memuat ekstrakurikuler: ${snapshot.error}', style: T.body));
            final rows = snapshot.data ?? [];
            if (rows.isEmpty) return SCard(child: Text('Belum ada ekstrakurikuler yang ditugaskan ke akun Pembina ini.', style: T.body));
            return Column(children: rows.map((row) => InfoRow(
              Icons.groups_rounded,
              row['name']?.toString() ?? 'Ekstrakurikuler',
              row['category']?.toString() ?? 'Kategori belum diisi',
              top: row['schedule_summary']?.toString() ?? 'Jadwal belum tersedia',
              bottom: row['location']?.toString() ?? 'Lokasi belum ditentukan',
            )).toList());
          },
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bg, fg, iconFg;
  const _Stat(this.label, this.value, this.icon, this.bg, this.fg, this.iconFg);
  @override
  Widget build(BuildContext context) => SCard(
    color: bg,
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: fg == AppColors.primary ? AppColors.muted : fg))),
        Container(width: 28, height: 28, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(icon, size: 15, color: iconFg)),
      ]),
      const SizedBox(height: 16),
      Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: fg)),
    ]),
  );
}

class _Quick extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _Quick(this.label, this.icon, this.active, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: GestureDetector(onTap: onTap, child: Container(
      height: 76,
      decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: active ? Colors.white : AppColors.primary),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.ink)),
      ]),
    )),
  ));
}
