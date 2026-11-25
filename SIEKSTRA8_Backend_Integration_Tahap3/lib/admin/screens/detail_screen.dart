import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AdminDetailField {
  final String label;
  final String value;
  final IconData icon;
  const AdminDetailField(this.label, this.value, this.icon);
}

/// Halaman detail generik agar detail siswa, pembina, dan ekskul konsisten.
class AdminDetailScreen extends StatelessWidget {
  final String category;
  final String name;
  final String subtitle;
  final String status;
  final IconData icon;
  final List<AdminDetailField> fields;
  final VoidCallback? onEdit;

  const AdminDetailScreen({
    super.key,
    required this.category,
    required this.name,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.fields,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      back: 'Kembali',
      eyebrow: 'DETAIL $category',
      title: name,
      subtitle: subtitle,
      trailing: Pill(status, C.soft, C.primary, dot: true),
      children: [
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconBox(icon, size: 64, bg: C.soft, fg: C.primary),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(category, style: T.label),
              const SizedBox(height: 4),
              Text(name, style: T.h2),
              const SizedBox(height: 4),
              Text(subtitle, style: T.body),
            ])),
          ]),
          const Divider(height: 28),
          const Text('INFORMASI', style: T.label),
          const SizedBox(height: 10),
          for (final field in fields)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(field.icon, color: C.primary, size: 19),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(field.label, style: T.body),
                  const SizedBox(height: 3),
                  Text(field.value, style: T.title),
                ])),
              ]),
            ),
        ])),
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('CATATAN', style: T.label),
          const SizedBox(height: 8),
          const Text('Informasi pada halaman ini masih menggunakan data contoh frontend. Data akan dihubungkan ke Supabase pada tahap integrasi backend.', style: T.body),
        ])),
        if (onEdit != null)
          Btn('Edit $category', icon: Icons.edit_outlined, expand: true, h: 52, onTap: onEdit),
      ],
    );
  }
}
