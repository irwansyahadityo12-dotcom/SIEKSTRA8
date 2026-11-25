import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../../data/siekstra_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});
  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool schedule = true, announcements = true, email = false;
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: currentUserName);
    emailController = TextEditingController(text: currentUserEmail);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final newName = nameController.text.trim();
      if (newName.isNotEmpty) {
        // Update local state
        final current = currentUserProfile.value ?? {};
        currentUserProfile.value = {
          ...current,
          'full_name': newName,
        };
        // Update di Supabase jika terkoneksi
        try {
          await SiekstraRepository().updateMyProfile(fullName: newName);
        } catch (_) {}
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan profil berhasil disimpan.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pengaturan Akun')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tx('Informasi Akun', size: 14, w: FontWeight.w800),
              const SizedBox(height: 12),
              tx('Nama lengkap', size: 11, color: C.muted),
              const SizedBox(height: 5),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: currentUserName,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              tx('Email akun', size: 11, color: C.muted),
              const SizedBox(height: 5),
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(),
                  isDense: true,
                  helperText: 'Email akun terdaftar di sistem autentikasi Supabase',
                ),
              ),
              const SizedBox(height: 12),
              tx('NIS: $currentIdentifier • Kelas: $currentClassName', size: 11, color: C.primary, w: FontWeight.w700),
              const SizedBox(height: 4),
              tx('NIS dan kelas dikelola oleh administrator kesiswaan SMKN 8 Malang.', size: 10.5, color: C.muted),
              const SizedBox(height: 14),
              PrimaryButton(
                _saving ? 'Menyimpan...' : 'Simpan Perubahan',
                icon: Icons.save_outlined,
                onPressed: _saving ? null : _save,
              ),
            ]),
          ),
          const SectionTitle('Preferensi Notifikasi'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: schedule,
                onChanged: (v) => setState(() => schedule = v),
                title: tx('Pengingat jadwal', size: 12.5, w: FontWeight.w700),
                subtitle: tx('Pengingat sebelum kegiatan dimulai', size: 10.5, color: C.muted),
              ),
              const Divider(height: 1, color: C.border),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: announcements,
                onChanged: (v) => setState(() => announcements = v),
                title: tx('Pengumuman sekolah', size: 12.5, w: FontWeight.w700),
                subtitle: tx('Informasi kegiatan dan pengumuman resmi', size: 10.5, color: C.muted),
              ),
              const Divider(height: 1, color: C.border),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: email,
                onChanged: (v) => setState(() => email = v),
                title: tx('Notifikasi email', size: 12.5, w: FontWeight.w700),
                subtitle: tx('Kirim salinan pemberitahuan ke email', size: 10.5, color: C.muted),
              ),
            ]),
          ),
          AppCard(
            color: C.soft,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lock_outline, color: C.primary),
              const SizedBox(width: 10),
              Expanded(
                child: tx(
                  'Akun terhubung aman dengan Supabase Auth SMKN 8 Malang. Sesi autentikasi aktif.',
                  size: 11,
                  color: C.primary,
                  height: 1.4,
                ),
              ),
            ]),
          ),
        ]),
      );
}
