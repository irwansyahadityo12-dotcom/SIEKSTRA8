import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'permission_form_screen.dart';
import 'permission_history_screen.dart';
import 'registration_status_screen.dart';
import 'competition_info_screen.dart';
import 'attendance_history_screen.dart';
import 'help_screen.dart';

// ============================================================
//  Sidebar / Navigation Drawer Siswa (SIEKSTRA-8)
//  Menyediakan akses navigasi lengkap ke menu Pengajuan Izin,
//  Riwayat Izin, Status Pendaftaran, dan Layanan Siswa lainnya.
// ============================================================

class StudentDrawer extends StatelessWidget {
  final ValueChanged<int>? onSelectTab;
  const StudentDrawer({super.key, this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header Profil Siswa
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: currentUserProfile,
            builder: (context, profile, _) {
              final name = currentUserName.isNotEmpty ? currentUserName : 'Siswa SMKN 8';
              final sub = [
                if (currentClassName.isNotEmpty) currentClassName,
                if (currentIdentifier != '-') 'NIS $currentIdentifier',
              ].join(' • ');

              return Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 20,
                  20,
                  20,
                ),
                decoration: const BoxDecoration(
                  gradient: kBlueGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'S',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: C.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sub.isNotEmpty ? sub : 'SMKN 8 Malang',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Pill('PORTAL SISWA AKTIF', fg: Colors.white, bg: Colors.white24, size: 9.5),
                  ],
                ),
              );
            },
          ),

          // Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _item(
                  icon: Icons.home_outlined,
                  title: 'Beranda Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTab?.call(0);
                  },
                ),
                _item(
                  icon: Icons.explore_outlined,
                  title: 'Katalog Ekstrakurikuler',
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTab?.call(1);
                  },
                ),
                _item(
                  icon: Icons.calendar_today_outlined,
                  title: 'Jadwal Kegiatan',
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTab?.call(3);
                  },
                ),
                const Divider(height: 16, indent: 16, endIndent: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Text(
                    'LAYANAN & PERIZINAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: C.muted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _item(
                  icon: Icons.edit_calendar_outlined,
                  title: 'Pengajuan Izin',
                  subtitle: 'Surat izin sakit / dispensasi kegiatan',
                  color: C.primary,
                  isHighlighted: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PermissionFormScreen()),
                    );
                  },
                ),
                _item(
                  icon: Icons.event_busy_outlined,
                  title: 'Riwayat Pengajuan Izin',
                  subtitle: 'Pantau status izin & dispensasi',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PermissionHistoryScreen()),
                    );
                  },
                ),
                _item(
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'Status Pendaftaran',
                  subtitle: 'Pantau seleksi keanggotaan ekskul',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegistrationStatusScreen()),
                    );
                  },
                ),
                _item(
                  icon: Icons.emoji_events_outlined,
                  title: 'Info Lomba & Konsultasi',
                  subtitle: 'Seleksi kejuaraan & bimbingan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CompetitionInfoScreen()),
                    );
                  },
                ),
                _item(
                  icon: Icons.fact_check_outlined,
                  title: 'Riwayat Kehadiran (Presensi)',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
                    );
                  },
                ),
                const Divider(height: 16, indent: 16, endIndent: 16),
                _item(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi',
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTab?.call(4);
                  },
                ),
                _item(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Tanya Gemini AI',
                  color: const Color(0xFF6366F1),
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTab?.call(2);
                  },
                ),
                _item(
                  icon: Icons.help_outline,
                  title: 'Bantuan & FAQ',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: C.border)),
            ),
            child: Row(
              children: const [
                Icon(Icons.school, size: 16, color: C.muted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SIEKSTRA-8 • SMKN 8 Malang',
                    style: TextStyle(fontSize: 11, color: C.muted, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color color = C.primary,
    bool isHighlighted = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHighlighted ? C.soft : const Color(0xFFF1F4FC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isHighlighted ? C.primary : const Color(0xFF334155), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
          color: isHighlighted ? C.primary : C.text,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 11, color: C.muted))
          : null,
      dense: true,
      onTap: onTap,
    );
  }
}

