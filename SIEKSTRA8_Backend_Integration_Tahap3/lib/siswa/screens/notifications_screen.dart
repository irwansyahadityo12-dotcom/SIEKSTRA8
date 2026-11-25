import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../../data/siekstra_repository.dart';
import 'registration_status_screen.dart';
import 'schedule_screen.dart';
import 'attendance_history_screen.dart';
import 'competition_info_screen.dart';
import 'permission_history_screen.dart';
import 'ekskul_list_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  int _selectedFilterChip = 0; // 0: Semua, 1: Belum Dibaca, 2: Jadwal, 3: Pengumuman & Izin

  // Data Notifikasi Siswa SMKN 8 Malang (fallback lokal jika DB offline / kosong)
  final List<Map<String, dynamic>> _mockNotifications = [];

  @override
  void initState() {
    super.initState();
    _future = SiekstraRepository().getMyNotifications();
  }

  Future<void> _reload() async {
    setState(() => _future = SiekstraRepository().getMyNotifications());
    await _future;
  }

  Future<void> _markRead(String id) async {
    try {
      await SiekstraRepository().markNotificationRead(id);
    } catch (_) {}
    setState(() {
      for (final n in _mockNotifications) {
        if (n['id'] == id) n['is_read'] = true;
      }
    });
  }

  Future<void> _markAllRead() async {
    try {
      await SiekstraRepository().markAllNotificationsRead();
    } catch (_) {}
    setState(() {
      for (final n in _mockNotifications) {
        n['is_read'] = true;
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi ditandai sebagai dibaca.')),
      );
    }
  }

  void _showDetailModal(Map<String, dynamic> row) {
    _markRead(row['id'].toString());

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBox(
                  row['icon'] as IconData? ?? Icons.notifications_active_outlined,
                  color: row['color'] as Color? ?? C.primary,
                  bg: row['bg'] as Color? ?? C.soft,
                  size: 42,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(row['category']?.toString() ?? 'Pemberitahuan', size: 9),
                      const SizedBox(height: 4),
                      tx(row['title']?.toString() ?? 'Notifikasi', size: 15, w: FontWeight.w800),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              row['body']?.toString() ?? '',
              style: const TextStyle(fontSize: 13.5, height: 1.45, color: C.text),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: C.muted),
                const SizedBox(width: 4),
                Text(
                  row['created_at']?.toString() ?? row['time']?.toString() ?? '',
                  style: const TextStyle(fontSize: 11.5, color: C.muted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      side: const BorderSide(color: C.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tutup', style: TextStyle(color: C.muted, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Buka Modul', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToModule(row);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToModule(Map<String, dynamic> notif) {
    final type = (notif['type'] ?? '').toString().toLowerCase();
    final category = (notif['category'] ?? '').toString().toLowerCase();
    final title = (notif['title'] ?? '').toString().toLowerCase();

    if (type.contains('consultation') || type.contains('lomba') || title.contains('lomba') || title.contains('konsultasi') || title.contains('prestasi') || category.contains('lomba')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CompetitionInfoScreen()));
    } else if (type.contains('pendaftaran') || type.contains('membership') || title.contains('pendaftaran') || title.contains('keanggotaan') || category.contains('pendaftaran')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationStatusScreen()));
    } else if (type.contains('jadwal') || type.contains('schedule') || title.contains('jadwal') || title.contains('latihan') || category.contains('jadwal')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen()));
    } else if (type.contains('presensi') || type.contains('attendance') || title.contains('presensi') || title.contains('absen') || category.contains('presensi')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()));
    } else if (type.contains('izin') || type.contains('permission') || type.contains('dispensation') || title.contains('izin') || title.contains('dispensasi') || category.contains('izin')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PermissionHistoryScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const EkskulListScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        titleSpacing: 16,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            const BrandLogo(size: 34),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                tx('Pusat Notifikasi Siswa', size: 16, w: FontWeight.w800),
                tx('SIEKSTRA-8 • SMKN 8 Malang', size: 11, color: C.muted),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: AvatarDot()),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          // Hanya tampilkan notifikasi yang benar-benar tersimpan di Supabase.
          final List<Map<String, dynamic>> rows = snapshot.data ?? <Map<String, dynamic>>[];

          final unreadCount = rows.where((r) => r['is_read'] != true).length;
          final jadwalCount = rows.where((r) => r['category'] == 'Jadwal').length;
          final pengumumanCount = rows.where((r) => r['category'] == 'Pengumuman' || r['category'] == 'Izin').length;

          // Filter sesuai tab chip
          List<Map<String, dynamic>> displayed = rows;
          if (_selectedFilterChip == 1) {
            displayed = rows.where((r) => r['is_read'] != true).toList();
          } else if (_selectedFilterChip == 2) {
            displayed = rows.where((r) => r['category'] == 'Jadwal').toList();
          } else if (_selectedFilterChip == 3) {
            displayed = rows.where((r) => r['category'] == 'Pengumuman' || r['category'] == 'Izin').toList();
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Notifikasi & Tombol Tandai Dibaca
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          tx('Pemberitahuan', size: 20, w: FontWeight.w800),
                          const SizedBox(width: 8),
                          Pill('$unreadCount Baru', size: 10, bg: C.redBg, fg: C.red),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: unreadCount == 0 ? null : _markAllRead,
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Tandai dibaca', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Chips Filter Kategori
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('Semua (${rows.length})', 0),
                      const SizedBox(width: 8),
                      _buildChip('Belum Dibaca ($unreadCount)', 1),
                      const SizedBox(width: 8),
                      _buildChip('Jadwal & Latihan ($jadwalCount)', 2),
                      const SizedBox(width: 8),
                      _buildChip('Pengumuman & Izin ($pengumumanCount)', 3),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (displayed.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.notifications_none_rounded, size: 48, color: C.muted),
                          const SizedBox(height: 10),
                          tx('Tidak ada notifikasi pada kategori ini.', color: C.muted),
                        ],
                      ),
                    ),
                  )
                else
                  for (final row in displayed) _buildItem(row),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, int index) {
    final isSel = _selectedFilterChip == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterChip = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? C.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSel ? C.primary : C.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSel ? Colors.white : C.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> row) {
    final unread = row['is_read'] != true;
    final iconData = row['icon'] as IconData? ?? Icons.notifications_active_outlined;
    final iconColor = row['color'] as Color? ?? C.primary;
    final iconBg = row['bg'] as Color? ?? C.soft;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _showDetailModal(row),
        child: AppCard(
          color: unread ? const Color(0xFFF8FAFF) : Colors.white,
          borderColor: unread ? const Color(0xFFC7D7FE) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBox(iconData, color: iconColor, bg: iconBg, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: tx(
                            (row['title'] ?? 'Notifikasi').toString(),
                            size: 13.5,
                            w: unread ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(color: C.primary, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    tx((row['body'] ?? '').toString(), size: 12, color: C.muted, height: 1.4),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (row['category'] != null) ...[
                          Pill(row['category'].toString(), size: 9),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          (row['created_at'] ?? row['time'] ?? '').toString(),
                          style: const TextStyle(fontSize: 10.5, color: C.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
