import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool agree = true;
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
              LabeledField('Nama Lengkap', hint: 'Nama Lengkap', icon: Icons.person_outline),
              LabeledField('Email / NISN', hint: 'Email / NISN', icon: Icons.mail_outline),
              LabeledField('Password', hint: 'Password', icon: Icons.lock_outline, suffix: Icons.visibility_outlined, obscure: true),
              LabeledField('Konfirmasi Password', hint: 'Konfirmasi Password', icon: Icons.lock_outline, suffix: Icons.visibility_outlined, obscure: true),
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
              PrimaryButton('Daftar', onPressed: agree ? () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainShell()), (r) => false) : null),
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
