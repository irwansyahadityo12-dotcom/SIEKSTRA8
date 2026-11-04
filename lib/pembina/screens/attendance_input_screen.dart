import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'attendance_recap_screen.dart';

class _S {
  final String ini, name, cls, level, role, pct, note;
  String status;
  final Color avBg, avFg;
  _S(this.ini, this.name, this.cls, this.level, this.role, this.pct, this.status, this.note, this.avBg, this.avFg);
}

class AttendanceInputScreen extends StatefulWidget {
  const AttendanceInputScreen({super.key});
  @override
  State<AttendanceInputScreen> createState() => _State();
}

class _State extends State<AttendanceInputScreen> {
  static const opts = ['Hadir', 'Izin', 'Sakit', 'Alfa'];
  final students = [
    _S('AF', 'Ahmad Fikri', 'XI RPL 2 • NIS 221005', 'Wira', 'Ketua Regu Pertolongan Pertama', '96%', 'Hadir', 'Hadir tepat waktu di Ruang UKS', const Color(0xFFE0E7FF), AppColors.primary),
    _S('NP', 'Nabila Putri', 'X TKJ 1 • NIS 231120', 'Madya', 'Bidang Tandu & Evakuasi', '91%', 'Izin', 'Izin susulan ekskul OSIS (Rapat Pleno SMK)', const Color(0xFFF3E8FF), const Color(0xFF7E22CE)),
    _S('DI', 'Dimas Ibrahim', 'XI RPL 1 • NIS 221080', 'Wira', 'Logistik & Perlengkapan Darurat', '88%', 'Sakit', 'Surat dokter terlampir (Demam)', const Color(0xFFCFFAFE), const Color(0xFF0E7490)),
    _S('RM', 'Rizky Maulana', 'X DKV 2 • NIS 231155', 'Madya', 'Anggota Baru (Junior)', '100%', 'Hadir', 'Hadir tepat waktu & membawa seragam lengkap', const Color(0xFFFFEDD5), AppColors.red),
    _S('SA', 'Siti Aisyah', 'XI RPL 1 • NIS 221012', 'Wira', 'Koordinator Medis UKS', '82%', 'Alfa', 'Tanpa konfirmasi / tidak ada kabar', AppColors.redSoft, AppColors.red),
  ];

  int count(String s) => students.where((e) => e.status == s).length;
  Color color(String s) => {'Hadir': AppColors.green, 'Izin': AppColors.primary, 'Sakit': AppColors.orange, 'Alfa': AppColors.red}[s]!;
  IconData icon(String s) => {'Hadir': Icons.check, 'Izin': Icons.event_available, 'Sakit': Icons.healing, 'Alfa': Icons.close}[s]!;

  @override
  Widget build(BuildContext context) {
    final total = students.length;
    return Screen(
      back: true,
      title: 'Presensi Kehadiran',
      subtitle: 'Catat absensi pertemuan rutin PMR SMKN 8 Malang',
      trailing: Btn.soft('Rekap', icon: Icons.bar_chart_rounded, h: 36, onTap: () => push(context, const AttendanceRecapScreen())),
      bottom: Row(children: [
        Expanded(
            child: Btn('Simpan Presensi', icon: Icons.check_circle_outline, expand: true, h: 56, onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Presensi tersimpan: ${count('Hadir')} hadir dari $total')));
        })),
        const SizedBox(width: 10),
        Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.description_outlined, color: AppColors.primary)),
      ]),
      children: [
        const Align(alignment: Alignment.centerLeft, child: Pill('Latihan Rutin', AppColors.red, Colors.white, icon: Icons.circle)),
        const SizedBox(height: 10),
        SCard(
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFEFF2FD), borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                const IconBox(Icons.medical_services_outlined, bg: AppColors.soft, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('TOPIK MATERI', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12)),
                    Text('Latihan Rutin: Tandu & Bidai', style: T.h2),
                    SizedBox(height: 6),
                    Text('📅 Rabu, 23 Oktober 2024   🕒 15:30 - 17:30 WIB', style: T.body),
                    Text('📍 Ruang UKS Gedung B', style: T.body),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            const SearchField('Cari nama siswa atau NIS...'),
            const Chips(['Semua Kelas', 'X RPL', 'XI TKJ', 'XII MM', 'X DKV', 'XI RPL']),
          ]),
        ),
        Row(children: [
          for (final s in opts) ...[
            Expanded(
              child: SCard(
                padding: const EdgeInsets.symmetric(vertical: 12),
                bottom: 0,
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 4, backgroundColor: color(s)), const SizedBox(width: 5), Text(s, style: TextStyle(fontWeight: FontWeight.w700, color: color(s)))]),
                  Text('${count(s)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  Text(s == 'Hadir' ? '${(count(s) * 100 / total).round()}% total' : {'Izin': 'Tersurat', 'Sakit': 'UKS/Rumah', 'Alfa': 'Tanpa Ket'}[s]!, style: T.body.copyWith(fontSize: 11)),
                ]),
              ),
            ),
            if (s != 'Alfa') const SizedBox(width: 8),
          ],
        ]),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Daftar Anggota PMR', style: T.h2),
          const SizedBox(width: 8),
          Pill('$total Siswa', AppColors.soft, AppColors.muted),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() {
              for (final s in students) {
                s.status = 'Hadir';
              }
            }),
            child: const Text('Tandai Semua Hadir ✓✓', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 12),
        for (final s in students) _card(s),
      ],
    );
  }

  Widget _card(_S s) {
    final c = color(s.status);
    final noteBg = {'Hadir': const Color(0xFFDDFBE8), 'Izin': const Color(0xFFEEF2FF), 'Sakit': AppColors.amberSoft, 'Alfa': AppColors.redSoft}[s.status]!;
    return SCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Avatar(s.ini, bg: s.avBg, fg: s.avFg, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Flexible(child: Text(s.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))), const SizedBox(width: 6), Pill(s.level, AppColors.soft, AppColors.primary)]),
              Text(s.cls, style: T.body),
              Text(s.role, style: T.body.copyWith(fontWeight: FontWeight.w600)),
            ]),
          ),
          Pill('${s.pct} Kehadiran', const Color(0xFFF0F1F5), AppColors.green),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          for (final o in opts)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => s.status = o),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: s.status == o ? color(o) : const Color(0xFFF0F2FA), borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      if (s.status == o) ...[Icon(icon(o), size: 14, color: Colors.white), const SizedBox(width: 3)],
                      Text(o, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: s.status == o ? Colors.white : AppColors.muted)),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: noteBg, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(s.status == 'Alfa' ? Icons.warning_amber_rounded : s.status == 'Hadir' ? Icons.check_circle_outline : Icons.info_outline, size: 18, color: c),
            const SizedBox(width: 8),
            Expanded(child: Text(s.status == 'Hadir' && s.note.contains('Tanpa') ? 'Hadir' : 'Keterangan: ${s.note}', style: TextStyle(fontSize: 13, color: s.status == 'Hadir' ? AppColors.green : s.status == 'Alfa' ? AppColors.red : AppColors.ink))),
            if (s.status == 'Sakit') const Text('Lihat Foto', style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.w800, fontSize: 12, decoration: TextDecoration.underline)),
          ]),
        ),
      ]),
    );
  }
}
