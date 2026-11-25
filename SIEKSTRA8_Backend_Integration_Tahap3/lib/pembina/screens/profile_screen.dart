import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'notifications_screen.dart';
import 'diklat_screen.dart';
import 'achievements_screen.dart';
import 'permission_screen.dart';
import 'resignation_screen.dart';
import 'attendance_input_screen.dart';
import 'attendance_recap_screen.dart';
import 'ekskul_form_screen.dart';
import 'schedule_form_screen.dart';
import 'help_screen.dart';
import 'record_form_screen.dart';
import 'record_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SiekstraRepository _repo = SiekstraRepository();
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    setState(() => _refreshing = true);
    try {
      await loadCurrentProfile();
    } catch (_) {}
    if (mounted) setState(() => _refreshing = false);
  }

  Future<void> _handleEditProfile() async {
    final name = currentUserName;
    final phone = currentUserProfile.value?['phone']?.toString() ?? '';
    final ekskul = currentUserProfile.value?['class_name']?.toString() ?? '';

    final res = await push<Map<String, String>>(
      context,
      PembinaRecordFormScreen(
        title: 'Edit Profil Pembina',
        subtitle: 'Perbarui informasi profil pembina yang tersimpan di Supabase.',
        fields: const ['Nama lengkap', 'Nomor telepon', 'Ekstrakurikuler / Cabang'],
        initialValues: {
          'Nama lengkap': name,
          'Nomor telepon': phone,
          'Ekstrakurikuler / Cabang': ekskul,
        },
      ),
    );

    if (res != null && res.isNotEmpty && mounted) {
      final newName = res['Nama lengkap']?.trim() ?? name;
      final newPhone = res['Nomor telepon']?.trim() ?? phone;
      final newEkskul = res['Ekstrakurikuler / Cabang']?.trim() ?? ekskul;

      if (newName.isEmpty) {
        toast(context, 'Nama lengkap tidak boleh kosong.');
        return;
      }

      try {
        await _repo.updateMyProfile(
          fullName: newName,
          phone: newPhone,
          className: newEkskul,
        );

        // Muat ulang data session Supabase
        await loadCurrentProfile();

        if (mounted) {
          toast(context, '✅ Profil pembina berhasil diperbarui di Supabase!');
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          toast(context, '❌ Gagal memperbarui profil: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      title: 'Profil Pembimbing',
      trailing: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
        tooltip: 'Segarkan Profil',
        onPressed: _refreshProfile,
      ),
      children: [
        ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: currentUserProfile,
          builder: (context, profile, _) {
            final name = currentUserName;
            final initials = userInitials;
            final email = currentUserEmail;
            final phone = profile?['phone']?.toString() ?? '';
            final ekskul = profile?['class_name']?.toString() ?? '';

            return SCard(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email.isNotEmpty ? email : 'Pembina Ekstrakurikuler',
                      style: T.body.copyWith(fontSize: 13),
                    ),
                    if (ekskul.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Pembimbing: $ekskul',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '📞 $phone',
                        style: T.body.copyWith(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Btn.soft(
                      'Edit Profil',
                      icon: Icons.edit_outlined,
                      h: 36,
                      onTap: _handleEditProfile,
                    ),
                  ]),
                ),
              ]),
            );
          },
        ),

        InfoRow(
          Icons.notifications_none_rounded,
          'Notifikasi',
          'Kelola notifikasi pendaftaran & jadwal',
          onTap: () => push(context, const NotificationsScreen()),
        ),

        InfoRow(
          Icons.person_outline,
          'Data Akun',
          'NIP, email, nomor telepon & keamanan Supabase',
          onTap: () {
            final profile = currentUserProfile.value;
            final name = currentUserName;
            final nip = profile?['identifier']?.toString() ?? '-';
            final email = currentUserEmail.isNotEmpty ? currentUserEmail : 'Belum diatur';
            final phone = profile?['phone']?.toString().isNotEmpty == true
                ? profile!['phone'].toString()
                : 'Belum diatur';
            final ekskul = profile?['class_name']?.toString().isNotEmpty == true
                ? profile!['class_name'].toString()
                : 'Belum diatur';

            push(
              context,
              PembinaRecordDetailScreen(
                category: 'Data Akun Pembina',
                title: name,
                subtitle: 'Akun Terautentikasi SMKN 8 Malang',
                status: 'Aktif',
                icon: Icons.person_outline,
                fields: [
                  PembinaDetailField('NIP / Identifier', nip, Icons.badge_outlined),
                  PembinaDetailField('Email Akun', email, Icons.email_outlined),
                  PembinaDetailField('Nomor Telepon', phone, Icons.phone_outlined),
                  PembinaDetailField('Cabang Binaan', ekskul, Icons.military_tech_outlined),
                  const PembinaDetailField('Keamanan', 'Supabase Auth Berjalan', Icons.lock_outline),
                ],
              ),
            );
          },
        ),

        InfoRow(
          Icons.help_outline_rounded,
          'Bantuan',
          'Panduan penggunaan SIEKSTRA-8',
          onTap: () => push(context, const HelpScreen()),
        ),

        const SectionTitle('Menu Pembimbing'),
        InfoRow(
          Icons.assignment_turned_in_outlined,
          'Input Presensi',
          'Catat kehadiran pertemuan anggota',
          onTap: () => push(context, const AttendanceInputScreen()),
        ),
        InfoRow(
          Icons.bar_chart_rounded,
          'Rekap Kehadiran',
          'Laporan presensi per sesi dari database',
          onTap: () => push(context, const AttendanceRecapScreen()),
        ),
        InfoRow(
          Icons.campaign_outlined,
          'Kelola Diklat',
          'Pendidikan & pelatihan anggota',
          onTap: () => push(context, const DiklatScreen()),
        ),
        InfoRow(
          Icons.emoji_events_outlined,
          'Lomba & Prestasi',
          'Pendaftaran lomba & capaian juara',
          onTap: () => push(context, const AchievementsScreen()),
        ),
        InfoRow(
          Icons.mark_email_read_outlined,
          'Persetujuan Izin',
          'Surat izin & dispensasi anggota',
          onTap: () => push(context, const PermissionScreen()),
        ),
        InfoRow(
          Icons.logout_rounded,
          'Pengunduran Diri',
          'Verifikasi permohonan keluar anggota',
          onTap: () => push(context, const ResignationScreen()),
        ),
        InfoRow(
          Icons.edit_note_rounded,
          'Form Detail Ekskul',
          'Ubah profil & data ekstrakurikuler binaan',
          onTap: () => push(context, const EkskulFormScreen()),
        ),
        InfoRow(
          Icons.add_alarm_rounded,
          'Tambah Jadwal',
          'Buat jadwal kegiatan rutin & agenda baru',
          onTap: () => push(context, const ScheduleFormScreen()),
        ),

        const SectionTitle('Akun'),
        InfoRow(
          Icons.logout,
          'Keluar dari Akun',
          'Kembali ke halaman login',
          onTap: () => logout(context),
        ),
      ],
    );
  }
}
