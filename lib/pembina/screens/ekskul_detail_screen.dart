import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'ekskul_form_screen.dart';

class EkskulDetailScreen extends StatelessWidget {
  const EkskulDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Detail Ekskul',
      children: [
        SCard(
          color: const Color(0xFFF3F7FF),
          border: const Color(0xFFDDE7FF),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Expanded(child: Text('PMR (Wira & Madya)', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
              const IconBox(Icons.groups_rounded, size: 40),
            ]),
            const SizedBox(height: 6),
            const Text('Kepalangmerahan & Kemanusiaan • Aktif', style: TextStyle(fontSize: 15, color: AppColors.muted)),
            const SizedBox(height: 8),
            const Text('48 anggota • 1 pembimbing • 2 jadwal', style: T.body),
            const SizedBox(height: 12),
            Row(children: [
              const Pill('Aktif', Colors.white, AppColors.primary),
              const Spacer(),
              Btn('Edit Ekskul', h: 40, onTap: () => push(context, const EkskulFormScreen())),
            ]),
          ]),
        ),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _Mini(Icons.groups_rounded, 'Anggota', '48 siswa', 'Kelola anggota →', () => goTab(context, 2))),
          const SizedBox(width: 12),
          Expanded(child: _Mini(Icons.calendar_month_rounded, 'Jadwal', 'Rabu & Jumat 15:00', 'Kelola jadwal →', () => goTab(context, 4))),
        ]),
        SCard(
          onTap: () => goTab(context, 3),
          child: Row(children: [
            const IconBox(Icons.description_rounded, bg: AppColors.amberSoft, fg: AppColors.amber, size: 64),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Pendaftaran', style: T.h2),
              Text('6 pending', style: T.body),
              SizedBox(height: 6),
              Text('Tinjau →', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
        SCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Ringkasan Ekskul', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
              const Pill('Aktif', AppColors.soft, AppColors.primary),
            ]),
            const Text('Informasi utama untuk pembimbing', style: T.body),
            const SizedBox(height: 14),
            Row(children: const [
              Expanded(child: _Sum('Anggota', '48 siswa')),
              SizedBox(width: 10),
              Expanded(child: _Sum('Pembimbing', '1 orang')),
            ]),
            const SizedBox(height: 10),
            Row(children: const [
              Expanded(child: _Sum('Jadwal', 'Rabu & Jumat')),
              SizedBox(width: 10),
              Expanded(child: _Sum('Pendaftaran', '6 pending')),
            ]),
          ]),
        ),
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  final IconData icon;
  final String t, s, link;
  final VoidCallback onTap;
  const _Mini(this.icon, this.t, this.s, this.link, this.onTap);
  @override
  Widget build(BuildContext context) => SCard(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(icon, size: 44),
          const SizedBox(height: 12),
          Text(t, style: T.h2),
          Text(s, style: T.body),
          const SizedBox(height: 14),
          Text(link, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Sum extends StatelessWidget {
  final String l, v;
  const _Sum(this.l, this.v);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF7F8FC), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: T.body),
          const SizedBox(height: 6),
          Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ]),
      );
}
