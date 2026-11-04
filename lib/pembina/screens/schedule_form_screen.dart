import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ScheduleFormScreen extends StatelessWidget {
  const ScheduleFormScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      title: 'Tambah / Edit Jadwal',
      children: [
        SCard(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const FieldTile(Icons.event_note_rounded, 'Ekskul', 'Robotik Club'),
            const FieldTile(Icons.calendar_month_rounded, 'Hari', 'Rabu'),
            const FieldTile(Icons.schedule_rounded, 'Jam', '15:30 - 17:30 WIB'),
            const FieldTile(Icons.place_outlined, 'Lokasi', 'Lab IoT Gedung C'),
            const FieldTile(Icons.groups_outlined, 'Peserta Maksimal', '100 siswa'),
            const FieldTile(Icons.description_rounded, 'Catatan', 'Praktik mikrokontroler'),
            Row(children: [
              Expanded(
                flex: 3,
                child: Btn('Simpan Jadwal', h: 56, expand: true, onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal disimpan')));
                  Navigator.pop(context);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: Btn('Batal', h: 56, expand: true, bg: Colors.white, fg: AppColors.primary, onTap: () => Navigator.pop(context))),
            ]),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFE3E9FA), borderRadius: BorderRadius.circular(20)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const IconBox(Icons.info_outline_rounded, bg: Color(0xFFCFD9F5), size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Tips Pembimbing', style: T.h2),
                SizedBox(height: 4),
                Text('Pastikan jadwal, lokasi, dan kapasitas sudah sesuai sebelum disimpan agar anggota ekskul tidak kebingungan.', style: T.body),
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}
