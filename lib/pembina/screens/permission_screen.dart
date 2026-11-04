import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Screen(
      back: true,
      tag: 'PMR',
      title: 'Persetujuan Izin Anggota',
      subtitle: 'Kelola surat izin & permohonan dispensasi kegiatan PMR',
      trailing: const Pill('4 Menunggu', AppColors.redSoft, AppColors.red, icon: Icons.circle),
      children: [
        const SearchField('Cari nama, NIS, atau kelas...', trailing: Icons.tune),
        const Chips(['Semua Pengajuan', 'Menunggu 4', 'Disetujui 14']),
        _Req(
          ini: 'AF', name: 'Ahmad Fikri', unit: 'PMR WIRA', cls: 'XI RPL 2 • NIS 221005', icon: Icons.event_outlined, kegLabel: 'KEGIATAN & WAKTU',
          keg: 'Latihan Rutin Tandu & Bidai', time: 'Rabu, 23 Okt 2024 • 15:00 - 17:00 WIB',
          reason: 'Dispensasi persiapan LKS Tingkat Kota Malang (Bidang IT Network System Administration) di Lab Komputer 2.',
          file: 'Surat_Dispensasi_SMKN8.pdf', sent: 'Hari ini, 08:30 WIB', fileIcon: Icons.attach_file,
        ),
        _Req(
          ini: 'NP', name: 'Nabila Putri', unit: 'PMR MADYA', cls: 'X TKJ 1 • NIS 231120', icon: Icons.campaign_outlined, kegLabel: 'KEGIATAN',
          keg: 'Diklat Lapangan Pertolongan Pertama', time: 'Senin, 28 Okt 2024 • 07:30 WIB',
          reason: 'Izin sakit (gejala tifus), instruksi istirahat rawat jalan dari dokter selama 3 hari.',
          file: 'Surat_Dokter_Medika.jpg', sent: 'Kemarin, 19:40 WIB', fileIcon: Icons.image_outlined,
        ),
        SCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            Container(height: 5, decoration: const BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.vertical(top: Radius.circular(20)))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Avatar('DI', size: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: const [Flexible(child: Text('Dimas Ibrahim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), SizedBox(width: 6), Pill('PMR WIRA', AppColors.soft, AppColors.primary)]),
                      const Text('XI RPL 1 • NIS 221080', style: T.body),
                    ]),
                  ),
                  const Pill('Disetujui', AppColors.greenSoft, AppColors.green, icon: Icons.check_circle_outline),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFEFF2FD), borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: const [Expanded(child: Text('Simulasi Dapur Umum & Posko', style: T.title)), Text('21 Okt 2024', style: T.body)]),
                    const SizedBox(height: 4),
                    const Text('Alasan: Tugas dinas kepengurusan OSIS SMKN 8 Malang.', style: T.body),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                        Text('Disetujui oleh Dimas Pratama, S.Pd. (21 Okt, 14:10)', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800, fontSize: 13)),
                        SizedBox(height: 4),
                        Text('"Disetujui dengan syarat mempelajari modul susulan materi posko di e-learning."', style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.ink)),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                const Align(alignment: Alignment.centerRight, child: Text('⟲ Lihat Log Riwayat', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))),
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}

class _Req extends StatelessWidget {
  final String ini, name, unit, cls, kegLabel, keg, time, reason, file, sent;
  final IconData icon, fileIcon;
  const _Req({required this.ini, required this.name, required this.unit, required this.cls, required this.icon, required this.kegLabel, required this.keg, required this.time, required this.reason, required this.file, required this.sent, required this.fileIcon});
  @override
  Widget build(BuildContext context) => SCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          Container(height: 5, decoration: const BoxDecoration(color: Color(0xFFFBBF24), borderRadius: BorderRadius.vertical(top: Radius.circular(20)))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Avatar(ini, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Flexible(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), const SizedBox(width: 6), Pill(unit, AppColors.soft, AppColors.primary)]),
                    Text(cls, style: T.body),
                  ]),
                ),
                const Pill('Menunggu', AppColors.amberSoft, AppColors.amber, icon: Icons.hourglass_empty),
              ]),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFEFF2FD), borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(kegLabel, style: T.label),
                  Text(keg, style: T.title.copyWith(fontSize: 16)),
                  Text(time, style: T.body),
                  const SizedBox(height: 10),
                  const Text('ALASAN IZIN', style: T.label),
                  Text(reason, style: const TextStyle(fontSize: 14, color: AppColors.ink, height: 1.4)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(fileIcon, size: 16, color: AppColors.primary), const SizedBox(width: 4), Text(file, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))]),
                    ),
                    const Spacer(),
                    Text(sent, style: T.body.copyWith(fontSize: 11, fontWeight: FontWeight.w700)),
                  ]),
                ]),
              ),
              const SizedBox(height: 10),
              const TextField(decoration: InputDecoration(hintText: 'Tambahkan catatan pembina (opsional)...', filled: true, fillColor: Color(0xFFEFF2FD), border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))), hintStyle: TextStyle(fontSize: 13, color: AppColors.muted))),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(flex: 3, child: Btn.success('Setujui', icon: Icons.check_circle_outline, expand: true, h: 50)),
                const SizedBox(width: 8),
                Expanded(flex: 3, child: Btn.danger('Tolak', icon: Icons.cancel_outlined, expand: true, h: 50)),
                const SizedBox(width: 8),
                Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.visibility_outlined, color: AppColors.primary)),
              ]),
            ]),
          ),
        ]),
      );
}
