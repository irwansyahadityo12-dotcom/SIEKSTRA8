import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});
  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  final List<List<String>> _items = [
    ['Fajar Aditya', 'XII RPL D', 'Robotik Club', 'Hari ini, 09:12'],
    ['Siti Aulia', 'XI RPL A', 'Paskibra', 'Hari ini, 08:45'],
  ];
  int _approved = 18, _rejected = 3;

  void _decide(int i, bool ok) {
    final name = _items[i][0];
    setState(() {
      _items.removeAt(i);
      ok ? _approved++ : _rejected++;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name ${ok ? 'disetujui' : 'ditolak'}')));
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _items.length + 10;
    return Screen(
      title: 'Persetujuan Anggota',
      subtitle: 'Tinjau pendaftaran siswa, berikan keputusan, dan pantau status klub pembimbing Anda.',
      trailing: Pill('$waiting menunggu', Colors.white, AppColors.primary, icon: Icons.groups_rounded),
      children: [
        SCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const IconBox(Icons.assignment_turned_in_outlined, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pendaftaran hari ini', style: T.h2),
                  Text('$waiting permintaan menunggu keputusan anda.', style: T.body.copyWith(fontSize: 14)),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              Pill('$_approved disetujui', AppColors.greenSoft, AppColors.green, icon: Icons.check_circle),
              Pill('$_rejected ditolak', AppColors.redSoft, AppColors.red, icon: Icons.cancel),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Sum('Menunggu', '$waiting', 'permintaan aktif')),
              const SizedBox(width: 8),
              Expanded(child: _Sum('Disetujui', '$_approved', 'anggota baru')),
              const SizedBox(width: 8),
              Expanded(child: _Sum('Ditolak', '$_rejected', 'butuh revisi')),
            ]),
          ]),
        ),
        Chips(['Menunggu $waiting', 'Disetujui', 'Ditolak']),
        for (var i = 0; i < _items.length; i++)
          SCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.person_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(_items[i][0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                const Pill('Menunggu', AppColors.soft, AppColors.primary, icon: Icons.schedule),
              ]),
              Text(_items[i][1], style: T.body.copyWith(fontSize: 14)),
              const SizedBox(height: 6),
              Pill(_items[i][2], AppColors.soft, AppColors.primary),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: Text(_items[i][3], style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600))),
                Btn.success('ACC', icon: Icons.check, onTap: () => _decide(i, true)),
                const SizedBox(width: 10),
                Btn.danger('Tolak', icon: Icons.close, onTap: () => _decide(i, false)),
              ]),
            ]),
          ),
        if (_items.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Semua permintaan sudah diproses 🎉', style: T.body))),
      ],
    );
  }
}

class _Sum extends StatelessWidget {
  final String l, v, s;
  const _Sum(this.l, this.v, this.s);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF7F8FC), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: T.body),
          Text(v, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text(s, style: T.body.copyWith(fontSize: 12)),
        ]),
      );
}
