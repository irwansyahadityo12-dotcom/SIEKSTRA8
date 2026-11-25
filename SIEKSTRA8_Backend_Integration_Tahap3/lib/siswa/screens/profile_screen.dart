import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../../data/siekstra_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'competition_info_screen.dart';
import 'resignation_form_screen.dart';
import 'membership_detail_screen.dart';
import 'registration_status_screen.dart';
import 'registration_history_screen.dart';
import 'permission_history_screen.dart';
import 'permission_form_screen.dart';
import 'achievement_detail_screen.dart';
import 'account_settings_screen.dart';
import 'help_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repository = SiekstraRepository();
  int _activeEkskulCount = 0;
  List<Map<String, dynamic>> _myMemberships = [];
  bool _loadingEkskul = false;

  @override
  void initState() {
    super.initState();
    loadCurrentProfile();
    _loadMembershipsCount();
  }

  Future<void> _loadMembershipsCount() async {
    try {
      setState(() => _loadingEkskul = true);
      final memberships = await _repository.getMyMemberships();
      final approved = memberships.where((m) => m['status'] == 'approved').toList();
      if (mounted) {
        setState(() {
          _activeEkskulCount = approved.length;
          _myMemberships = memberships;
          _loadingEkskul = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingEkskul = false);
      }
    }
  }

  void _go(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

  Widget _stat(IconData i, Color c, Color bg, String big, String l, {Color? bigColor}) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(children: [
            IconBox(i, color: c, bg: bg, size: 36),
            const SizedBox(height: 8),
            tx(big, size: 19, w: FontWeight.w800, color: bigColor ?? C.text),
            tx(l, size: 10.5, color: C.muted),
          ]),
        ),
      );

  Widget _menu(IconData i, Color c, Color bg, String title, String sub, {Pill? tag, Pill? status, VoidCallback? onTap}) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          IconBox(i, color: c, bg: bg, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: tx(title, size: 13.5, w: FontWeight.w800)),
                if (tag != null) ...[const SizedBox(width: 6), tag],
              ]),
              const SizedBox(height: 2),
              tx(sub, size: 11, color: C.muted),
            ]),
          ),
          if (status != null) ...[status, const SizedBox(width: 4)],
          const Icon(Icons.chevron_right, color: C.muted, size: 20),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: currentUserProfile,
      builder: (context, profile, _) {
        final name = currentUserName;
        final id = currentIdentifier;
        final className = currentClassName;
        final email = currentUserEmail;
        final initials = userInitials;

        final subInfo = [
          if (id != '-') 'NIS: $id',
          if (className.isNotEmpty) className,
        ].join('  •  ');

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 64,
            titleSpacing: 16,
            title: Row(children: [
              const BrandLogo(size: 38),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tx('SIEKSTRA-8', size: 16, w: FontWeight.w800, color: C.primary),
                  tx('SMKN 8 Malang', size: 11, color: C.muted),
                ],
              ),
            ]),
            actions: const [
              Padding(padding: EdgeInsets.only(right: 16), child: AvatarDot()),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Kartu Profil Utama Siswa
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD9E5FF), Color(0xFFF1F5FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(children: [
                  Stack(children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: C.soft,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: C.primary,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: C.primary,
                        child: Icon(Icons.check, size: 15, color: Colors.white),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Nama Siswa Sesuai Akun Database
                  tx(name, size: 20, w: FontWeight.w800, align: TextAlign.center),
                  const SizedBox(height: 4),
                  // NIS / Kelas / Email Siswa
                  tx(
                    subInfo.isNotEmpty ? subInfo : email,
                    size: 12,
                    color: C.muted,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, size: 8, color: C.primary),
                        const SizedBox(width: 6),
                        tx('Siswa Aktif SMKN 8 Malang', size: 11.5, w: FontWeight.w700, color: C.primary),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // Kotak Statistik
              Row(children: [
                _stat(
                  Icons.groups_2_outlined,
                  C.primary,
                  C.soft,
                  _loadingEkskul ? '...' : '$_activeEkskulCount',
                  'Ekskul Aktif',
                  bigColor: C.primary,
                ),
                const SizedBox(width: 8),
                _stat(Icons.fact_check_outlined, C.primary, C.soft, '95%', 'Kehadiran'),
                const SizedBox(width: 8),
                _stat(Icons.card_giftcard, C.amber, C.amberBg, '3', 'Sertifikat', bigColor: C.amber),
              ]),
              const SizedBox(height: 10),

              Row(children: [
                Expanded(child: tx('MENU PROFIL & EKSKUL', size: 11, w: FontWeight.w800, color: C.muted)),
                tx('Aktivitas Siswa', size: 12, w: FontWeight.w700, color: C.primary),
              ]),
              const SizedBox(height: 10),

              _menu(
                Icons.contact_page_outlined,
                C.primary,
                C.soft,
                'Data Diri Siswa',
                email.isNotEmpty ? '$email • $className' : 'NIS, email sekolah, kontak wali, kelas',
                onTap: () => _go(context, const AccountSettingsScreen()),
              ),
              // Daftar Ekskul Aktif Siswa (Real-time dari Supabase)
              if (_loadingEkskul)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              else if (_myMemberships.where((m) => m['status'] == 'approved').isEmpty)
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    const IconBox(Icons.info_outline, color: C.muted, bg: Color(0xFFEFF1F7), size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        tx('Belum Bergabung Ekskul', size: 13, w: FontWeight.w700),
                        const SizedBox(height: 2),
                        tx('Daftar ekskul pilihanmu sekarang melalui menu Pendaftaran.', size: 11, color: C.muted),
                      ]),
                    ),
                  ]),
                )
              else
                ..._myMemberships.where((m) => m['status'] == 'approved').map((m) {
                  final extra = m['extracurriculars'] is Map ? m['extracurriculars'] as Map<String, dynamic> : <String, dynamic>{};
                  final name = (extra['name'] ?? 'Ekstrakurikuler').toString();
                  final category = (extra['category'] ?? '').toString();
                  final coach = (extra['coach_name'] ?? '').toString();
                  final sub = [
                    if (coach.isNotEmpty) 'Pembina: $coach',
                    if (category.isNotEmpty) category,
                  ].join(' • ');

                  final catLower = category.toLowerCase();
                  final icon = catLower.contains('olahraga')
                      ? Icons.sports_basketball
                      : (catLower.contains('sosial') || catLower.contains('pmr') || catLower.contains('pramuka'))
                          ? Icons.volunteer_activism
                          : catLower.contains('seni') || catLower.contains('musik')
                              ? Icons.palette
                              : Icons.groups_2_outlined;

                  final color = catLower.contains('olahraga')
                      ? C.brown
                      : (catLower.contains('sosial') || catLower.contains('pmr'))
                          ? C.red
                          : catLower.contains('seni')
                              ? C.purple
                              : C.primary;

                  final bg = catLower.contains('olahraga')
                      ? const Color(0xFFFFE9B0)
                      : (catLower.contains('sosial') || catLower.contains('pmr'))
                          ? C.redBg
                          : catLower.contains('seni')
                              ? C.purpleBg
                              : C.soft;

                  return _menu(
                    icon,
                    color,
                    bg,
                    name,
                    sub.isNotEmpty ? sub : 'Anggota Aktif',
                    status: Pill('Aktif', size: 10),
                    onTap: () => _go(context, MembershipDetailScreen(membership: m)),
                  );
                }),
              _menu(
                Icons.verified_outlined,
                C.purple,
                C.purpleBg,
                'Riwayat Seleksi, Lomba & Diklat',
                'Juara 1 PP Jatim, Diklat XXIV Lulus',
                status: Pill('Disetujui', fg: C.green, bg: C.greenBg, size: 10),
                onTap: () => _go(context, const CompetitionInfoScreen()),
              ),
              _menu(
                Icons.assignment_turned_in_outlined,
                C.amber,
                C.amberBg,
                'Status Pendaftaran',
                'Pantau pengajuan ekskul yang sedang diproses',
                onTap: () => _go(context, const RegistrationStatusScreen()),
              ),
              _menu(
                Icons.history,
                C.primary,
                C.soft,
                'Riwayat Pendaftaran',
                'Daftar pengajuan ekstrakurikuler sebelumnya',
                onTap: () => _go(context, const RegistrationHistoryScreen()),
              ),
              _menu(
                Icons.edit_calendar_outlined,
                C.primary,
                C.soft,
                'Pengajuan Izin',
                'Ajukan surat izin sakit atau dispensasi kegiatan ekskul',
                tag: Pill('Formulir', fg: C.primary, bg: C.soft, size: 9),
                onTap: () => _go(context, const PermissionFormScreen()),
              ),
              _menu(
                Icons.event_busy_outlined,
                C.amber,
                C.amberBg,
                'Riwayat Pengajuan Izin',
                'Lihat status permohonan izin kegiatan',
                onTap: () => _go(context, const PermissionHistoryScreen()),
              ),
              _menu(
                Icons.workspace_premium_outlined,
                C.purple,
                C.purpleBg,
                'Detail Prestasi',
                'Informasi penghargaan dan verifikasi',
                onTap: () => _go(context, const AchievementDetailScreen()),
              ),
              _menu(
                Icons.tune,
                C.muted,
                const Color(0xFFEFF1F7),
                'Pengaturan Notifikasi & Akun',
                'Jadwal latihan, pengumuman, dan preferensi',
                onTap: () => _go(context, const AccountSettingsScreen()),
              ),
              _menu(
                Icons.help_outline,
                C.teal,
                const Color(0xFFE0F2F7),
                'Pusat Bantuan',
                'Panduan penggunaan dan informasi sekolah',
                onTap: () => _go(context, const HelpScreen())),
              AppCard(
                color: const Color(0xFFFFF8E1),
                borderColor: const Color(0xFFF5E2A0),
                onTap: () => _go(context, const ResignationFormScreen()),
                child: Row(children: [
                  const IconBox(
                    Icons.assignment_late_outlined,
                    color: C.brown,
                    bg: Color(0xFFFFE9B0),
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Flexible(child: tx('Pengajuan Pengunduran Diri Ekskul', size: 12.5, w: FontWeight.w800)),
                        const SizedBox(width: 6),
                        Pill('RESMI', fg: C.brown, bg: const Color(0xFFFFE9B0), size: 9),
                      ]),
                      tx('Formulir keluar ekskul, validasi pembina & kesiswaan', size: 11, color: C.muted),
                    ]),
                  ),
                  const Icon(Icons.chevron_right, color: C.muted),
                ]),
              ),
              const SizedBox(height: 8),

              // Tombol Keluar dari Akun (memanggil logout session)
              SizedBox(
                height: 50,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFDE2E2),
                    foregroundColor: C.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => logout(context),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 14),
              Center(child: tx('SIEKSTRA-8 v2.4.0', size: 11, w: FontWeight.w700, color: C.muted)),
              Center(child: tx('Hak Cipta SMKN 8 Malang', size: 10.5, color: C.muted)),
            ],
          ),
        );
      },
    );
  }
}
