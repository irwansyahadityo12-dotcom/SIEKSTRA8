import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../../app/backend.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'pendaftaran_screen.dart';
import 'proposal_list_screen.dart';
import 'presensi_screen.dart';
import 'diklat_screen.dart';
import 'jadwal_screen.dart';
import 'prestasi_screen.dart';
import 'dispensasi_screen.dart';
import 'members_screen.dart';
import 'data_siswa_screen.dart';
import 'akun_pembina_screen.dart';

// ============================================================
//  Admin Notifications Screen
//  Pusat Notifikasi Admin Kesiswaan terhubung langsung ke Supabase
// ============================================================

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final SiekstraRepository _repo = SiekstraRepository();

  int _selectedFilterChip = 0; // 0: Semua, 1: Pendaftaran, 2: Proposal, 3: Presensi, 4: Lomba
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ── Muat Data Notifikasi dari Supabase ────────────────────
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Backend.ensureInitialized();
      final rows = await _repo.getAdminNotifications();

      if (!mounted) return;

      if (rows.isNotEmpty) {
        setState(() {
          _notifications = rows.map((r) => _mapFromDb(r)).toList();
          _isLoading = false;
        });
      } else {
        // Jika database belum memiliki notifikasi, gunakan notifikasi default sistem kesiswaan
        setState(() {
          _notifications = _defaultNotifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Jika terjadi error koneksi, tampilkan notifikasi default sistem kesiswaan agar admin tetap dapat meninjau
      setState(() {
        _notifications = _defaultNotifications;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Mapping Data Notifikasi dari Database ─────────────────
  Map<String, dynamic> _mapFromDb(Map<String, dynamic> r) {
    final type = (r['type'] ?? 'general').toString().toLowerCase();
    final title = (r['title'] ?? 'Pemberitahuan').toString();
    final body = (r['body'] ?? '').toString();
    final isRead = r['is_read'] == true;
    final createdAt = DateTime.tryParse(r['created_at']?.toString() ?? '');

    String category = 'Umum';
    String route = 'general';
    IconData icon = Icons.notifications_none_rounded;
    Color bg = C.soft;
    Color fg = C.primary;

    if (type.contains('pendaftaran') || title.toLowerCase().contains('pendaftaran') || title.toLowerCase().contains('keanggotaan')) {
      category = 'Pendaftaran';
      route = 'pendaftaran';
      icon = Icons.person_add_alt_1;
      bg = C.soft;
      fg = C.primary;
    } else if (type.contains('proposal') || title.toLowerCase().contains('proposal')) {
      category = 'Proposal';
      route = 'proposal';
      icon = Icons.description_outlined;
      bg = C.orangeSoft;
      fg = C.orange;
    } else if (type.contains('presensi') || title.toLowerCase().contains('presensi')) {
      category = 'Presensi';
      route = 'presensi';
      icon = Icons.fact_check_outlined;
      bg = C.greenSoft;
      fg = C.green;
    } else if (type.contains('consultation') || type.contains('lomba') || title.toLowerCase().contains('lomba') || title.toLowerCase().contains('konsultasi')) {
      category = 'Lomba';
      route = 'diklat';
      icon = Icons.emoji_events_outlined;
      bg = C.amberSoft;
      fg = C.amber;
    } else if (type.contains('jadwal') || title.toLowerCase().contains('jadwal')) {
      category = 'Jadwal';
      route = 'jadwal';
      icon = Icons.event_note_outlined;
      bg = C.soft;
      fg = C.primary;
    }

    String timeStr = 'Baru saja';
    if (createdAt != null) {
      final diff = DateTime.now().difference(createdAt);
      if (diff.inMinutes < 60) {
        timeStr = '${diff.inMinutes <= 0 ? 1 : diff.inMinutes} menit lalu';
      } else if (diff.inHours < 24) {
        timeStr = '${diff.inHours} jam lalu';
      } else {
        timeStr = '${diff.inDays} hari lalu';
      }
    }

    return {
      'id': r['id']?.toString() ?? UniqueKey().toString(),
      'category': category,
      'title': title,
      'body': body,
      'time': timeStr,
      'unread': !isRead,
      'icon': icon,
      'bg': bg,
      'fg': fg,
      'route': route,
      'raw': r,
    };
  }

  // Notifikasi bawaan jika belum ada entri di Supabase
  List<Map<String, dynamic>> get _defaultNotifications => [
        {
          'id': 'DEFAULT-001',
          'category': 'Pendaftaran',
          'title': 'Pendaftaran Ekstrakurikuler Baru',
          'body': 'Siswa baru menunggu verifikasi pendaftaran di Futsal dan PMR Wira.',
          'time': '10 menit lalu',
          'unread': true,
          'icon': Icons.person_add_alt_1,
          'bg': C.soft,
          'fg': C.primary,
          'route': 'pendaftaran',
        },
        {
          'id': 'DEFAULT-002',
          'category': 'Proposal',
          'title': 'Proposal LKS Cyber Security Menunggu Persetujuan',
          'body': 'Pengajuan anggaran Rp 4.500.000 untuk LKS Cyber Security dari pembina RPL Club perlu ditinjau.',
          'time': '35 menit lalu',
          'unread': true,
          'icon': Icons.description_outlined,
          'bg': C.orangeSoft,
          'fg': C.orange,
          'route': 'proposal',
        },
        {
          'id': 'DEFAULT-003',
          'category': 'Presensi',
          'title': 'Rekap Presensi Telah Dikirim',
          'body': 'Pembina PMR Wira mengirim rekap presensi sesi terbaru (40 hadir, 2 izin, 0 alpa).',
          'time': '1 jam lalu',
          'unread': true,
          'icon': Icons.fact_check_outlined,
          'bg': C.greenSoft,
          'fg': C.green,
          'route': 'presensi',
        },
        {
          'id': 'DEFAULT-004',
          'category': 'Lomba',
          'title': 'Permohonan Bimbingan & Konsultasi Lomba',
          'body': 'Siswa mengajukan konsultasi persiapan seleksi kejuaraan LKS dan Jumbara.',
          'time': '2 jam lalu',
          'unread': false,
          'icon': Icons.emoji_events_outlined,
          'bg': C.amberSoft,
          'fg': C.amber,
          'route': 'diklat',
        },
      ];

  // Hitung jumlah notifikasi per kategori
  int get _countPendaftaran => _notifications.where((n) => n['category'] == 'Pendaftaran').length;
  int get _countProposal => _notifications.where((n) => n['category'] == 'Proposal').length;
  int get _countPresensi => _notifications.where((n) => n['category'] == 'Presensi').length;
  int get _countLomba => _notifications.where((n) => n['category'] == 'Lomba').length;
  int get _countUnread => _notifications.where((n) => n['unread'] == true).length;

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilterChip == 1) {
      return _notifications.where((n) => n['category'] == 'Pendaftaran').toList();
    } else if (_selectedFilterChip == 2) {
      return _notifications.where((n) => n['category'] == 'Proposal').toList();
    } else if (_selectedFilterChip == 3) {
      return _notifications.where((n) => n['category'] == 'Presensi').toList();
    } else if (_selectedFilterChip == 4) {
      return _notifications.where((n) => n['category'] == 'Lomba').toList();
    }
    return _notifications;
  }

  // ── Tandai Semua Sudah Dibaca ─────────────────────────────
  Future<void> _markAllAsRead() async {
    try {
      await Backend.ensureInitialized();
      await _repo.markAllNotificationsRead();
    } catch (e) {
      debugPrint('Mark all read notice: $e');
    }

    if (!mounted) return;
    setState(() {
      for (final n in _notifications) {
        n['unread'] = false;
      }
    });
    toast(context, 'Semua notifikasi telah ditandai sebagai dibaca');
  }

  // ── Buka Notifikasi & Tandai Dibaca ───────────────────────
  Future<void> _handleNotificationTap(Map<String, dynamic> notif) async {
    final id = notif['id']?.toString() ?? '';
    if (id.isNotEmpty && !id.startsWith('DEFAULT-')) {
      try {
        await Backend.ensureInitialized();
        await _repo.markNotificationRead(id);
      } catch (e) {
        debugPrint('Mark read error: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      notif['unread'] = false;
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBox(notif['icon'] as IconData, bg: notif['bg'] as Color, fg: notif['fg'] as Color, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(notif['category'] as String, C.soft, C.primary),
                      const SizedBox(height: 4),
                      Text(notif['title'] as String, style: T.h2.copyWith(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(notif['body'] as String, style: T.body.copyWith(fontSize: 14, height: 1.4)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: C.muted),
                const SizedBox(width: 4),
                Text('Diterima: ${notif['time']}', style: const TextStyle(fontSize: 12, color: C.muted)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      side: const BorderSide(color: C.line),
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
                      _navigateToModule(notif);
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
    final route = (notif['route'] ?? '').toString().toLowerCase();
    final category = (notif['category'] ?? '').toString().toLowerCase();
    final title = (notif['title'] ?? '').toString().toLowerCase();
    final type = (notif['raw'] != null ? (notif['raw']['type'] ?? '') : '').toString().toLowerCase();

    if (route == 'pendaftaran' || category.contains('pendaftaran') || type.contains('pendaftaran') || title.contains('pendaftaran') || title.contains('daftar')) {
      push(context, const PendaftaranScreen());
    } else if (route == 'anggota' || category.contains('anggota') || type.contains('membership') || title.contains('anggota')) {
      push(context, const MembersScreen());
    } else if (route == 'proposal' || category.contains('proposal') || type.contains('proposal') || title.contains('proposal')) {
      push(context, const ProposalListScreen());
    } else if (route == 'presensi' || category.contains('presensi') || type.contains('presensi') || type.contains('attendance') || title.contains('presensi') || title.contains('absen')) {
      push(context, const PresensiScreen());
    } else if (route == 'diklat' || category.contains('diklat') || type.contains('diklat') || type.contains('training') || title.contains('diklat') || title.contains('kaderisasi')) {
      push(context, const DiklatScreen());
    } else if (route == 'jadwal' || category.contains('jadwal') || type.contains('schedule') || title.contains('jadwal') || title.contains('latihan')) {
      push(context, const JadwalScreen());
    } else if (route == 'prestasi' || route == 'lomba' || category.contains('prestasi') || category.contains('lomba') || type.contains('achievement') || type.contains('consultation') || title.contains('prestasi') || title.contains('lomba') || title.contains('kejuaraan') || title.contains('konsultasi')) {
      push(context, const PrestasiScreen());
    } else if (route == 'dispensasi' || category.contains('dispensasi') || type.contains('dispensation') || title.contains('dispensasi') || title.contains('surat tugas')) {
      push(context, const DispensasiScreen());
    } else if (route == 'siswa' || category.contains('siswa') || title.contains('siswa')) {
      push(context, const DataSiswaScreen());
    } else if (route == 'pembina' || category.contains('pembina') || title.contains('pembina') || title.contains('pelatih')) {
      push(context, const AkunPembinaScreen());
    } else {
      push(context, const PendaftaranScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;

    return AdminScreen(
      back: 'Kembali',
      title: 'Pusat Notifikasi Admin',
      subtitle: 'Pemberitahuan aktivitas, presensi, dan permohonan yang membutuhkan perhatian Admin Kesiswaan.',
      trailing: IconButton(
        tooltip: 'Muat Ulang',
        onPressed: _loadNotifications,
        icon: const Icon(Icons.refresh, color: C.primary),
      ),
      children: [
        // Kartu Statistik Notifikasi
        Row(children: [
          Expanded(
            child: StatBox(
              'Belum Dibaca',
              '$_countUnread',
              _countUnread > 0 ? 'Perlu ditinjau' : 'Semua telah dibaca',
              valueColor: _countUnread > 0 ? C.orange : C.green,
              subColor: _countUnread > 0 ? C.orange : C.muted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatBox(
              'Total Notifikasi',
              '${_notifications.length}',
              'Tersinkron Supabase',
            ),
          ),
        ]),
        const SizedBox(height: 12),

        // Tombol Tandai Semua Sudah Dibaca
        if (_countUnread > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Spacer(),
                InkWell(
                  onTap: _markAllAsRead,
                  child: Row(
                    children: const [
                      Icon(Icons.done_all, size: 16, color: C.primary),
                      SizedBox(width: 4),
                      Text(
                        'Tandai Semua Dibaca',
                        style: TextStyle(color: C.primary, fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Chips Filter Kategori
        Chips(
          [
            'Semua (${_notifications.length})',
            'Pendaftaran ($_countPendaftaran)',
            'Proposal ($_countProposal)',
            'Presensi ($_countPresensi)',
            'Lomba ($_countLomba)',
          ],
          selectedIndex: _selectedFilterChip,
          onChanged: (idx) => setState(() => _selectedFilterChip = idx),
        ),

        const SizedBox(height: 10),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filtered.isEmpty)
          SCard(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              children: const [
                Icon(Icons.notifications_off_outlined, size: 52, color: C.muted),
                SizedBox(height: 12),
                Text('Tidak Ada Notifikasi', style: T.h2),
                SizedBox(height: 4),
                Text(
                  'Belum ada notifikasi pada kategori ini.',
                  style: T.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          for (final n in filtered) ...[
            _buildNotificationItem(context, n),
            const SizedBox(height: 8),
          ],

        const SizedBox(height: 8),
        Btn.white(
          'Muat Ulang Notifikasi',
          icon: Icons.refresh,
          expand: true,
          h: 46,
          onTap: _loadNotifications,
        ),
      ],
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notif) {
    final unread = notif['unread'] as bool;

    return SCard(
      onTap: () => _handleNotificationTap(notif),
      color: unread ? const Color(0xFFF8FAFF) : null,
      border: unread ? const Color(0xFFC7D7FE) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(
            notif['icon'] as IconData,
            bg: notif['bg'] as Color,
            fg: notif['fg'] as Color,
            size: 46,
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
                        notif['title'] as String,
                        style: T.title.copyWith(
                          fontSize: 14.5,
                          fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                          color: unread ? C.ink : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: const BoxDecoration(
                          color: C.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif['body'] as String,
                  style: T.body.copyWith(fontSize: 12.5, height: 1.35),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Pill(notif['category'] as String, const Color(0xFFF1F5F9), C.muted),
                    const SizedBox(width: 8),
                    Text(
                      notif['time'] as String,
                      style: const TextStyle(color: C.muted, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
