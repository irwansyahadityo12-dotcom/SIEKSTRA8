import 'package:flutter/material.dart';
import '../../app/backend.dart';
import '../../app/supabase_config.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool agree = true;
  bool loading = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    identifierController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!SupabaseConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supabase belum dikonfigurasi.')));
      return;
    }
    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty ||
        identifierController.text.trim().isEmpty || passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi data. Password minimal 8 karakter.')));
      return;
    }
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfirmasi password tidak sama.')));
      return;
    }
    setState(() => loading = true);
    try {
      await Backend.ensureInitialized();
      await Backend.signUp(
        email: emailController.text,
        password: passwordController.text,
        fullName: nameController.text,
        identifier: identifierController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pendaftaran berhasil. Periksa email untuk verifikasi, lalu masuk sebagai Siswa.')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            child: Row(children: [
              BrandLogo(size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  tx('SIEKSTRA-8', size: 22, w: FontWeight.w800),
                  tx('SMKN 8 Malang', size: 13, color: C.muted),
                  const SizedBox(height: 8),
                  Pill('RESMI SMKN 8 MALANG', icon: Icons.verified_outlined, size: 9.5),
                ]),
              ),
            ]),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tx('Buat Akun Baru', size: 26, w: FontWeight.w800),
              const SizedBox(height: 6),
              tx('Daftar untuk mulai menggunakan SIEKSTRA-8.', size: 13, color: C.muted),
              const SizedBox(height: 20),
              LabeledField('Nama Lengkap', hint: 'Nama Lengkap', icon: Icons.person_outline, controller: nameController),
              LabeledField('Email', hint: 'Email aktif untuk verifikasi akun', icon: Icons.mail_outline, controller: emailController),
              LabeledField('NIS / NISN', hint: 'Nomor induk siswa', icon: Icons.badge_outlined, controller: identifierController),
              LabeledField('Password', hint: 'Minimal 8 karakter', icon: Icons.lock_outline, suffix: Icons.visibility_outlined, obscure: true, controller: passwordController),
              LabeledField('Konfirmasi Password', hint: 'Ulangi password', icon: Icons.lock_outline, suffix: Icons.visibility_outlined, obscure: true, controller: confirmController),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Checkbox(value: agree, activeColor: C.primary, onChanged: (v) => setState(() => agree = v ?? false)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text.rich(TextSpan(style: const TextStyle(fontSize: 12, color: C.muted, height: 1.4), children: const [
                      TextSpan(text: 'Saya menyetujui '),
                      TextSpan(text: 'Syarat dan Ketentuan', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
                      TextSpan(text: ' serta '),
                      TextSpan(text: 'Kebijakan Privasi', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
                      TextSpan(text: ' SIEKSTRA-8.'),
                    ])),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              PrimaryButton(loading ? 'Mendaftarkan...' : 'Daftar', onPressed: agree && !loading ? _register : null),
              const SizedBox(height: 18),
              Center(child: tx('Sudah punya akun?', size: 12, color: C.muted)),
              const SizedBox(height: 4),
              Center(
                child: GestureDetector(onTap: () => Navigator.pop(context), child: tx('Masuk', size: 14, w: FontWeight.w800, color: C.primary)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
