import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../../app/supabase_config.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = SiekstraRepository();
  late Future<Map<String, int>> _stats;

  @override
  void initState() {
    super.initState();
    _stats = _repository.getAdminDashboardStats();
  }

  void _reload() => setState(() => _stats = _repository.getAdminDashboardStats());

  @override
  Widget build(BuildContext context) {
    return AdminScreen(children: [
      HeroBanner(children: const [
        Pill('Dashboard Terhubung', Color(0x33FFFFFF), Colors.white, dot: true),
        SizedBox(height: 14),
        Text('Halo, Admin Kesiswaan!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
        SizedBox(height: 6),
        Text('Statistik ditampilkan berdasarkan data aktual Supabase.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
      ]),
      Row(children: [
        const Expanded(child: SectionTitle('Ringkasan Sistem')),
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh, color: C.primary), tooltip: 'Muat ulang'),
      ]),
      FutureBuilder<Map<String, int>>(
        future: _stats,
        builder: (context, snapshot) {
          if (!SupabaseConfig.isConfigured) {
            return const SCard(child: Text('Supabase belum dikonfigurasi. Periksa supabase_config.json.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SCard(child: Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())));
          }
          if (snapshot.hasError) {
            return SCard(child: Column(children: [
              const Icon(Icons.cloud_off_outlined, color: C.red, size: 34),
              const SizedBox(height: 8),
              const Text('Statistik belum dapat dimuat', style: T.h2),
              Text(snapshot.error.toString(), style: T.body, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Btn('Coba Lagi', icon: Icons.refresh, onTap: _reload),
            ]));
          }
          final data = snapshot.data ?? const <String, int>{};
          final students = data['students'] ?? 0;
          final members = data['memberships'] ?? 0;
          final percent = data['attendance_percent'] ?? 0;
          final sessions = data['sessions'] ?? 0;
          return Column(children: [
            Row(children: [
              Expanded(child: StatBox('Total Ekstra', '${data['extracurriculars'] ?? 0} Ekstra', 'Data ekstrakurikuler', icon: Icons.pie_chart_outline, badge: 'Database')),
              const SizedBox(width: 12),
              Expanded(child: StatBox('Siswa Terdaftar', '$students Siswa', 'Akun siswa aktif', icon: Icons.groups_outlined, badge: '$members Anggota', iconBg: const Color(0xFFE8E9FF), iconFg: const Color(0xFF4F46E5), badgeBg: const Color(0xFFE8E9FF), badgeFg: const Color(0xFF4F46E5))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: StatBox('Pembina & Pelatih', '${data['coaches'] ?? 0} Akun', 'Pembina aktif', icon: Icons.school_outlined, badge: 'Aktif', badgeBg: const Color(0xFFE0F2FE), badgeFg: const Color(0xFF0369A1))),
              const SizedBox(width: 12),
              Expanded(child: StatBox('Presensi Hari Ini', '$percent%', '$sessions sesi • ${data['attendance_records'] ?? 0} catatan', icon: Icons.speed_outlined, badge: 'Aktual', iconBg: C.greenSoft, iconFg: C.green, badgeBg: C.greenSoft, badgeFg: C.green)),
            ]),
            if (students == 0) const Padding(padding: EdgeInsets.only(top: 8), child: InfoCard(Icons.info_outline, 'Belum ada siswa', 'Angka nol berarti belum ada profil siswa aktif yang tersimpan di tabel profiles.', bg: Color(0xFFEFF4FF), border: Color(0xFFD6E2FF))),
          ]);
        },
      ),
      const SectionTitle('Aksi Cepat Admin', action: 'Pintasan Fitur'),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        Btn('+ Ekstra Baru', h: 46, onTap: () => goTab(context, 1)),
        const SizedBox(width: 10),
        Btn.white('+ Akun Pembina', icon: Icons.person_add_alt_1, h: 46, onTap: () => goTab(context, 5)),
        const SizedBox(width: 10),
        Btn.white('Pendaftaran', icon: Icons.person_outline, h: 46, onTap: () => goTab(context, 2)),
        const SizedBox(width: 10),
        Btn.white('Presensi', icon: Icons.fact_check_outlined, h: 46, onTap: () => goTab(context, 4)),
      ])),
      const SizedBox(height: 8),
      const InfoCard(Icons.verified_user_outlined, 'Data langsung dari Supabase', 'Dashboard tidak lagi menggunakan angka siswa, pembina, atau presensi yang ditulis manual. Jika database kosong, statistik akan menampilkan nol.', bg: Color(0xFFEFF4FF), border: Color(0xFFD6E2FF)),
    ]);
  }
}
