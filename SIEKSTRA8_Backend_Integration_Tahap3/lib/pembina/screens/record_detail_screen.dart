import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class PembinaDetailField {
  final String label;
  final String value;
  final IconData icon;
  const PembinaDetailField(this.label, this.value, this.icon);
}

class PembinaRecordDetailScreen extends StatelessWidget {
  final String category;
  final String title;
  final String subtitle;
  final String status;
  final IconData icon;
  final List<PembinaDetailField> fields;
  const PembinaRecordDetailScreen({
    super.key,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) => Screen(
        back: true,
        tag: 'PMR',
        title: title,
        subtitle: subtitle,
        children: [
          SCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                IconBox(icon, size: 58),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(category.toUpperCase(), style: T.label),
                  const SizedBox(height: 4),
                  Text(title, style: T.h2),
                  const SizedBox(height: 6),
                  Pill(status, AppColors.soft, AppColors.primary),
                ])),
              ]),
              const Divider(height: 28),
              for (final field in fields)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(field.icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(field.label, style: T.body),
                      const SizedBox(height: 3),
                      Text(field.value, style: T.title),
                    ])),
                  ]),
                ),
            ]),
          ),
          const InfoRow(Icons.info_outline, 'Informasi data', 'Rincian ini menggunakan data contoh frontend. Integrasi penyimpanan dilakukan pada tahap backend.'),
        ],
      );
}
