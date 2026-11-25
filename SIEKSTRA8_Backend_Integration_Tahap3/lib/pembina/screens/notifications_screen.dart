import 'package:flutter/material.dart';

import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'approval_screen.dart';
import 'permission_screen.dart';
import 'resignation_screen.dart';
import 'achievements_screen.dart';
import 'diklat_screen.dart';
import 'attendance_recap_screen.dart';

/// Notifikasi Pembina dibaca dan diperbarui langsung dari tabel `notifications`.
/// Kolom yang digunakan mengikuti schema.sql: id, user_id, title, body,
/// type, is_read, created_at.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final SiekstraRepository _repository = SiekstraRepository();
  int _selectedFilterChip = 0;
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final rows = await _repository.getMyNotifications();
      if (!mounted) return;
      setState(() => _notifications = rows);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _countUnread =>
      _notifications.where((n) => n['is_read'] != true).length;

  int get _countPendaftaran => _notifications.where((n) {
        final type = (n['type'] ?? '').toString().toLowerCase();
        return type.contains('pendaftaran') ||
            type.contains('membership') ||
            type.contains('registration');
      }).length;

  int get _countIzinMundur => _notifications.where((n) {
        final type = (n['type'] ?? '').toString().toLowerCase();
        return type.contains('izin') ||
            type.contains('permission') ||
            type.contains('mundur') ||
            type.contains('resignation');
      }).length;

  List<Map<String, dynamic>> get _filteredNotifications {
    switch (_selectedFilterChip) {
      case 1:
        return _notifications.where((n) => n['is_read'] != true).toList();
      case 2:
        return _notifications.where((n) {
          final type = (n['type'] ?? '').toString().toLowerCase();
          return type.contains('pendaftaran') ||
              type.contains('membership') ||
              type.contains('registration');
        }).toList();
      case 3:
        return _notifications.where((n) {
          final type = (n['type'] ?? '').toString().toLowerCase();
          return type.contains('izin') ||
              type.contains('permission') ||
              type.contains('mundur') ||
              type.contains('resignation');
        }).toList();
      default:
        return _notifications;
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _repository.markAllNotificationsRead();
      if (!mounted) return;
      setState(() {
        for (final notification in _notifications) {
          notification['is_read'] = true;
        }
      });
      toast(context, 'Semua notifikasi ditandai sudah dibaca.');
    } catch (e) {
      if (mounted) toast(context, 'Gagal memperbarui notifikasi: $e');
    }
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    if (notification['is_read'] == true) return;
    final id = notification['id']?.toString();
    if (id == null || id.isEmpty) return;
    try {
      await _repository.markNotificationRead(id);
      if (!mounted) return;
      setState(() => notification['is_read'] = true);
    } catch (e) {
      if (mounted) toast(context, 'Gagal menandai notifikasi: $e');
    }
  }

  Future<void> _openNotification(Map<String, dynamic> notification) async {
    await _markAsRead(notification);
    if (!mounted) return;
    final type = (notification['type'] ?? '').toString().toLowerCase();

    if (type.contains('pendaftaran') ||
        type.contains('membership') ||
        type.contains('registration')) {
      await push(context, const ApprovalScreen());
    } else if (type.contains('izin') || type.contains('permission')) {
      await push(context, const PermissionScreen());
    } else if (type.contains('mundur') || type.contains('resignation')) {
      await push(context, const ResignationScreen());
    } else if (type.contains('prestasi') || type.contains('achievement')) {
      await push(context, const AchievementsScreen());
    } else if (type.contains('diklat') || type.contains('training')) {
      await push(context, const DiklatScreen());
    } else if (type.contains('presensi') || type.contains('attendance')) {
      await push(context, const AttendanceRecapScreen());
    }
  }

  IconData _iconForType(String type) {
    final value = type.toLowerCase();
    if (value.contains('pendaftaran') || value.contains('membership')) {
      return Icons.person_add_alt_1_rounded;
    }
    if (value.contains('izin') || value.contains('permission')) {
      return Icons.event_busy_rounded;
    }
    if (value.contains('mundur') || value.contains('resignation')) {
      return Icons.exit_to_app_rounded;
    }
    if (value.contains('prestasi') || value.contains('achievement')) {
      return Icons.emoji_events_rounded;
    }
    if (value.contains('diklat') || value.contains('training')) {
      return Icons.school_rounded;
    }
    if (value.contains('presensi') || value.contains('attendance')) {
      return Icons.fact_check_rounded;
    }
    return Icons.notifications_active_rounded;
  }

  String _timeLabel(dynamic rawValue) {
    final date = DateTime.tryParse(rawValue?.toString() ?? '')?.toLocal();
    if (date == null) return 'Waktu tidak tersedia';
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 1 && !difference.isNegative) return 'Baru saja';
    if (difference.inMinutes < 60 && !difference.isNegative) {
      return '${difference.inMinutes} menit lalu';
    }
    if (difference.inHours < 24 && !difference.isNegative) {
      return '${difference.inHours} jam lalu';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;

    return Screen(
      back: true,
      tag: 'PMR',
      title: 'Notifikasi Pembina',
      subtitle: 'Pemberitahuan aktivitas, pendaftaran, izin, dan jadwal',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Pill('$_countUnread Baru', AppColors.primary, Colors.white),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh, color: AppColors.primary),
          ),
        ],
      ),
      children: [
        if (_countUnread > 0 && !_loading)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _markAllAsRead,
                icon: const Icon(Icons.done_all, size: 16),
                label: const Text('Tandai Semua Dibaca'),
              ),
            ),
          ),
        Chips(
          [
            'Semua (${_notifications.length})',
            'Belum Dibaca ($_countUnread)',
            'Pendaftaran ($_countPendaftaran)',
            'Izin & Mundur ($_countIzinMundur)',
          ],
          selectedIndex: _selectedFilterChip,
          onChanged: (idx) => setState(() => _selectedFilterChip = idx),
        ),
        const SizedBox(height: 10),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          SCard(
            child: Column(
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.red, size: 34),
                const SizedBox(height: 8),
                Text('Gagal memuat notifikasi Supabase.\n$_error', style: T.body),
                TextButton.icon(
                  onPressed: _loadNotifications,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          )
        else if (filtered.isEmpty)
          SCard(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            child: const Column(
              children: [
                Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.muted),
                SizedBox(height: 10),
                Text('Tidak ada notifikasi pada kategori ini.', style: T.body),
              ],
            ),
          )
        else
          for (final notification in filtered) ...[
            _buildNotificationCard(notification),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF1FC),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_done_outlined, color: AppColors.green, size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Data notifikasi tersimpan di Supabase. Gunakan tombol muat ulang untuk mengambil pembaruan.',
                  style: T.body,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['is_read'] == true;
    final type = (notification['type'] ?? 'general').toString();
    final title = (notification['title'] ?? 'Notifikasi').toString();
    final body = (notification['body'] ?? '').toString();

    return SCard(
      padding: EdgeInsets.zero,
      onTap: () => _openNotification(notification),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBox(
                  _iconForType(type),
                  bg: isRead ? AppColors.soft : const Color(0xFFE5EBFF),
                  fg: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: T.title.copyWith(
                                fontSize: 15,
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(body, style: T.body),
                      const SizedBox(height: 7),
                      Text(
                        _timeLabel(notification['created_at']),
                        style: const TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F8FC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    type.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                Text(
                  isRead ? 'Sudah dibaca' : 'Buka detail',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
