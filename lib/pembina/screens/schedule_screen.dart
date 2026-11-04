import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'schedule_form_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int sel = 1;
  static const days = [
    ['SEN', '21', AppColors.orange],
    ['SEL', '22', AppColors.orange],
    ['RAB', '23', AppColors.orange],
    ['KAM', '24', null],
    ['JUM', '25', AppColors.orange],
    ['SAB', '26', Color(0xFFF43F5E)],
    ['MIN', '27', Color(0xFF818CF8)],
  ];
  final List<List<Object>> events = [
    ['RABU', '15:00', 'Latihan Rutin: Tandu & Bidai', 'Ruang UKS & Lapangan Utama', true],
    ['JUMAT', '15:30', 'Simulasi Pertolongan Pertama', 'Halaman & Koridor Sekolah', false],
    ['SABTU', '07:30', 'Lomba PP Tingkat Kota', 'Markas PMI Kota', false],
    ['MINGGU', '08:00', 'Diklat Calon Anggota PMR', 'Aula Serbaguna', true],
  ];

  @override
  Widget build(BuildContext context) {
    return Screen(
      tag: 'PMR',
      title: 'Jadwal Ekskul',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Text('Okt 2024', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
          Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
        ]),
      ),
      children: [
        SCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            for (var i = 0; i < days.length; i++)
              GestureDetector(
                onTap: () => setState(() => sel = i),
                child: Container(
                  width: 42,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: sel == i ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(18)),
                  child: Column(children: [
                    Text(days[i][0] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: sel == i ? Colors.white : AppColors.muted)),
                    const SizedBox(height: 6),
                    Text(days[i][1] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: sel == i ? Colors.white : AppColors.ink)),
                    const SizedBox(height: 6),
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: days[i][2] as Color? ?? Colors.transparent, shape: BoxShape.circle)),
                  ]),
                ),
              ),
          ]),
        ),
        const Chips(['Semua Agenda', 'Latihan Rutin', 'Kegiatan & Lomba']),
        Row(children: [
          const CircleAvatar(radius: 6, backgroundColor: AppColors.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Selasa, 22 Oktober 2024', style: T.title)),
          Pill('${events.length} Agenda', AppColors.soft, AppColors.primary),
        ]),
        const SizedBox(height: 14),
        Btn('Tambah Jadwal', icon: Icons.add, expand: true, h: 52, onTap: () => push(context, const ScheduleFormScreen())),
        const SizedBox(height: 14),
        for (var i = 0; i < events.length; i++) _eventCard(i),
      ],
    );
  }

  Widget _eventCard(int i) {
    final e = events[i];
    final blue = e[4] as bool;
    final c = blue ? AppColors.primary : AppColors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Container(height: 6, color: c),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: blue ? const Color(0xFFEFF4FF) : const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                Text(e[0] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: blue ? AppColors.primary : AppColors.amber)),
                Text(e[1] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const Text('WIB', style: T.body),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e[2] as String, style: T.title),
                const SizedBox(height: 4),
                Text(e[3] as String, style: T.body.copyWith(fontSize: 14)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              GestureDetector(
                  onTap: () => push(context, const ScheduleFormScreen()),
                  child: const Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => events.removeAt(i)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Hapus', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
