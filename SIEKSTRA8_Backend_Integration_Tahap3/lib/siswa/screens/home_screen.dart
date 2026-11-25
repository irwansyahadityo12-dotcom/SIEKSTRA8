import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../../data/siekstra_repository.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'ekskul_detail_screen.dart';
import 'attendance_history_screen.dart';
import 'permission_form_screen.dart';
import 'permission_history_screen.dart';
import 'registration_form_screen.dart';
import 'registration_status_screen.dart';
import 'student_drawer.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> goTab;
  const HomeScreen({super.key, required this.goTab});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = SiekstraRepository();
  int _selectedCategory = 0;
  bool _loading = true;
  String? _error;
  List<Ekskul> _remoteEkskul = [];
  List<Map<String, dynamic>> _myMemberships = [];
  int _joined = 0;
  int _weeklySchedules = 0;
  String _studentStatus = 'Aktif';

  @override
  void initState() { super.initState(); _loadHome(); }

  Future<void> _loadHome() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _repository.getExtracurriculars(),
        _repository.getMyMemberships(),
        _repository.getMySchedules(from: DateTime.now()),
        _repository.getMyProfile(),
      ]);
      final extras = results[0] as List<Map<String, dynamic>>;
      final memberships = results[1] as List<Map<String, dynamic>>;
      final schedules = results[2] as List<Map<String, dynamic>>;
      final profile = results[3] as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _remoteEkskul = extras.map(_toEkskul).toList();
        _myMemberships = memberships;
        _joined = memberships.where((m) => m['status'] == 'approved').length;
        _weeklySchedules = schedules.length;
        _studentStatus = profile['is_active'] == false ? 'Nonaktif' : 'Aktif';
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Ekskul _toEkskul(Map<String, dynamic> row) {
    final category = row['category']?.toString() ?? 'Umum';
    final name = row['name']?.toString() ?? 'Ekstrakurikuler';
    final categoryLower = category.toLowerCase();
    final color = categoryLower.contains('olahraga') ? C.brown
        : categoryLower.contains('sosial') ? C.red
        : categoryLower.contains('keagamaan') ? C.teal : C.primary;
    final bg = categoryLower.contains('olahraga') ? C.amberBg
        : categoryLower.contains('sosial') ? C.redBg
        : categoryLower.contains('keagamaan') ? const Color(0xFFE0F2F7) : C.soft;
    final countData = row['memberships'];
    var filled = 0;
    if (countData is List && countData.isNotEmpty) filled = (countData.first['count'] as num?)?.toInt() ?? 0;
    return Ekskul(
      id: row['id']?.toString(), name: name, category: category,
      desc: row['description']?.toString() ?? 'Informasi ekstrakurikuler.',
      coach: row['coach_name']?.toString() ?? 'Pembina belum ditentukan',
      schedule: row['schedule_summary']?.toString() ?? 'Jadwal menyusul',
      place: row['location']?.toString() ?? 'Lokasi belum ditentukan',
      filled: filled, quota: (row['quota'] as num?)?.toInt() ?? 0,
      icon: categoryLower.contains('olahraga') ? Icons.sports_soccer_outlined : Icons.groups_outlined,
      color: color, colorBg: bg, photo: [color, color.withValues(alpha: .65)],
    );
  }

  List<Ekskul> get _popularList {
    Iterable<Ekskul> list = _remoteEkskul;
    if (_selectedCategory == 1) {
      list = list.where((e) => e.category.toLowerCase().contains('vokasi') || e.category.toLowerCase().contains('keahlian') || e.category.toLowerCase().contains('it'));
    } else if (_selectedCategory == 2) {
      list = list.where((e) => e.category.toLowerCase().contains('sosial') || e.name.toLowerCase().contains('pmr') || e.name.toLowerCase().contains('pramuka'));
    } else if (_selectedCategory == 3) {
      list = list.where((e) => e.category.toLowerCase().contains('olahraga'));
    }
    return list.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final popular = _popularList;
    return Scaffold(
      drawer: StudentDrawer(onSelectTab: widget.goTab),
      appBar: mainAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadHome,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: currentUserProfile,
            builder: (context, profile, _) {
              final sub = [if (currentClassName.isNotEmpty) currentClassName, if (currentIdentifier != '-') 'NIS ${currentIdentifier}', 'SMKN 8 Malang'].join(' • ');
              return Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  tx('Halo, ${currentUserName} 👋', size: 20, w: FontWeight.w800),
                  tx(sub, size: 11.5, color: C.muted),
                ])),
                const Pill('Dashboard Siswa', icon: Icons.school_outlined, size: 10),
              ]);
            },
          ),
          const SizedBox(height: 14),
          if (_loading) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
          else if (_error != null) AppCard(child: Column(children: [
            const Icon(Icons.cloud_off_outlined, color: C.red, size: 32),
            const SizedBox(height: 8),
            tx('Data belum dapat dimuat', size: 15, w: FontWeight.w800),
            tx(_error!, size: 11, color: C.muted),
            TextButton.icon(onPressed: _loadHome, icon: const Icon(Icons.refresh), label: const Text('Coba lagi')),
          ]))
          else Row(children: [
            _stat(Icons.workspace_premium_outlined, C.primary, C.soft, '$_joined', 'Ekskul Diikuti', onTap: () => widget.goTab(1)),
            const SizedBox(width: 8),
            _stat(Icons.event_note_outlined, C.amber, C.amberBg, '$_weeklySchedules', 'Jadwal Mendatang', onTap: () => widget.goTab(3)),
            const SizedBox(width: 8),
            _stat(Icons.check_circle_outline, C.green, C.greenBg, _studentStatus, 'Status Siswa', text: true),
          ]),
          const SizedBox(height: 14),
          // Quick Action: Layanan & Pengajuan Izin
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: C.amber, size: 20),
                    const SizedBox(width: 6),
                    tx('Layanan & Perizinan Siswa', size: 13, w: FontWeight.w800),
                    const Spacer(),
                    const Pill('Dispensasi & Izin', fg: C.primary, bg: C.soft, size: 9),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PermissionFormScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            color: C.soft,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD6E4FF)),
                          ),
                          child: Row(
                            children: [
                              const IconBox(Icons.edit_calendar_outlined, color: C.primary, bg: Colors.white, size: 34),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    tx('Pengajuan Izin', size: 12, w: FontWeight.w800, color: C.primary),
                                    tx('Sakit / Dispensasi', size: 10, color: C.muted),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PermissionHistoryScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: C.line),
                          ),
                          child: Row(
                            children: [
                              const IconBox(Icons.event_busy_outlined, color: C.amber, bg: C.amberBg, size: 34),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    tx('Riwayat Izin', size: 12, w: FontWeight.w800),
                                    tx('Cek status izin', size: 10, color: C.muted),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        const IconBox(Icons.fact_check_outlined, color: C.green, bg: Colors.white, size: 34),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              tx('Absen & Riwayat Kehadiran', size: 12, w: FontWeight.w800, color: C.green),
                              tx('Cek rekap kehadiran dan status presensi latihan', size: 10, color: C.muted),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: C.green),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            onTap: () => widget.goTab(2), color: const Color(0xFFF5F3FF), borderColor: const Color(0xFFDDD6FE),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                tx('Tanya Gemini AI', size: 13, w: FontWeight.w800, color: const Color(0xFF5B21B6)),
                tx('Tanya seputar kegiatan dan pengembangan ekstrakurikuler.', size: 11, color: C.muted),
              ])),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF7C3AED)),
            ]),
          ),
          SectionTitle('Kategori Bidang', action: 'Semua', onAction: () => setState(() => _selectedCategory = 0)),
          FilterChips(['Semua Bidang', 'Vokasi & IT', 'Kemanusiaan', 'Olahraga'], onChanged: (idx) => setState(() => _selectedCategory = idx)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: tx('Ekstrakurikuler Tersedia', size: 16, w: FontWeight.w800)),
            Pill('${popular.length}', fg: C.brown, bg: C.amberBg, size: 10),
            const SizedBox(width: 8),
            GestureDetector(onTap: () => widget.goTab(1), child: tx('Lihat Semua', size: 12, w: FontWeight.w700, color: C.primary)),
          ]),
          const SizedBox(height: 10),
          if (!_loading && _error == null && popular.isEmpty)
            AppCard(child: Column(children: [
              const Icon(Icons.groups_outlined, size: 36, color: C.muted),
              const SizedBox(height: 8),
              tx('Belum ada ekstrakurikuler tersedia.', size: 13, color: C.muted),
            ]))
          else for (final e in popular) _PopularCard(e, memberships: _myMemberships, onRefresh: _loadHome),
          AppCard(color: const Color(0xFFEAF0FF), child: Row(children: [
            IconBox(Icons.headset_mic_outlined, color: Colors.white, bg: C.primary, size: 40),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tx('Butuh Bantuan Pendaftaran?', size: 13, w: FontWeight.w800),
              tx('Hubungi Pembina atau Kesiswaan SMKN 8 Malang.', size: 11.5, color: C.muted),
            ])),
          ])),
        ]),
      ),
    );
  }

  Widget _stat(IconData icon, Color color, Color bg, String value, String label, {bool text = false, VoidCallback? onTap}) => Expanded(child: AppCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    child: Column(children: [IconBox(icon, color: color, bg: bg, size: 36), const SizedBox(height: 8),
      tx(value, size: text ? 15 : 22, w: FontWeight.w800, color: text ? color : C.text),
      tx(label, size: 10.5, color: C.muted, align: TextAlign.center),
    ]),
  ));
}

class _PopularCard extends StatelessWidget {
  final Ekskul e;
  final List<Map<String, dynamic>> memberships;
  final VoidCallback onRefresh;
  const _PopularCard(this.e, {required this.memberships, required this.onRefresh});
  @override
  Widget build(BuildContext context) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      IconBox(e.icon, color: e.color, bg: e.colorBg, size: 48), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Pill(e.category.toUpperCase(), fg: e.color, bg: e.colorBg, size: 9),
        const SizedBox(height: 4), tx(e.name, size: 15, w: FontWeight.w800, lines: 2),
        tx(e.desc, size: 11, color: C.muted, lines: 2),
      ])),
    ]),
    const SizedBox(height: 12),
    Row(children: [
      const Icon(Icons.calendar_today_outlined, size: 13, color: C.muted), const SizedBox(width: 6),
      Expanded(child: tx(e.schedule, size: 11.5, color: C.muted)),
      Icon(Icons.group_outlined, size: 14, color: e.full ? C.red : C.primary),
      tx(e.quota == 0 ? '${e.filled} anggota' : '${e.filled}/${e.quota}', size: 11, color: C.muted),
    ]),
    const SizedBox(height: 10),
    () {
      final mem = memberships.cast<Map<String, dynamic>?>().firstWhere(
        (m) => m?['extracurricular_id'] == e.id,
        orElse: () => null,
      );
      final status = mem?['status']?.toString();
      final isApproved = status == 'approved';
      final isPending = status == 'pending';

      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: e.id == null
              ? null
              : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EkskulDetailScreen(ekskul: e)),
                  );
                  onRefresh();
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: isApproved
                ? const Color(0xFF059669)
                : isPending
                    ? const Color(0xFFD97706)
                    : C.primary,
          ),
          child: Text(
            isApproved
                ? 'Sudah Terdaftar'
                : isPending
                    ? 'Menunggu Persetujuan'
                    : 'Lihat & Daftar',
          ),
        ),
      );
    }(),
  ]));
}
