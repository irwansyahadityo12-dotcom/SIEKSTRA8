import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class PermissionFormScreen extends StatefulWidget {
  const PermissionFormScreen({super.key});
  @override
  State<PermissionFormScreen> createState() => _PermissionFormScreenState();
}

class _PermissionFormScreenState extends State<PermissionFormScreen> {
  int jenis = 0;
  bool agree = false;
  final alasan = TextEditingController();

  @override
  void dispose() {
    alasan.dispose();
    super.dispose();
  }

  Widget _readonly(String label, String value, {Widget? lead}) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          tx(label, size: 10, color: C.muted),
          const SizedBox(height: 2),
          Row(children: [if (lead != null) ...[lead, const SizedBox(width: 6)], Expanded(child: tx(value, size: 13, w: FontWeight.w800))]),
        ]),
      );

  Widget _sec(IconData i, String t, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [Icon(i, size: 19, color: C.primary), const SizedBox(width: 8), Expanded(child: tx(t, size: 14, w: FontWeight.w800)), if (trailing != null) trailing]),
      );

  @override
  Widget build(BuildContext context) {
    final jenisList = [
      ('Tugas Sekolah / LKS / Lomba', 'Mewakili sekolah pada kompetisi eksternal atau bimbel prioritas.', 'Akademik', C.primary, C.soft),
      ('Kondisi Sakit', 'Memerlukan istirahat medis dengan lampiran verifikasi resmi.', 'Surat Dokter', C.red, C.redBg),
      ('Keperluan Mendesak Keluarga', 'Urusan kedukaan, keluarga mendesak, atau agenda primer tak terelakkan.', 'Personal', C.amber, C.amberBg),
    ];
    return Scaffold(
      appBar: subAppBar(context, 'Form Perizinan', badge: 'PMR Wira'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        StepBar(const ['Isi Izin', 'Verifikasi', 'Selesai'], 0),
        const SizedBox(height: 12),
        AppCard(
          child: Row(children: [
            IconBox(Icons.medical_services_outlined, size: 42),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Flexible(child: tx('PMR WIRA SMKN 8', size: 14, w: FontWeight.w800)), const SizedBox(width: 6), Pill('Wira Utama', size: 9)]),
              tx('Unit Pertolongan Pertama & Kemanusiaan', size: 11, color: C.muted, lines: 1),
            ])),
            Pill('Terdaftar', fg: C.green, bg: C.greenBg, size: 10),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sec(Icons.badge_outlined, 'Data Pemohon', trailing: Pill('Otomatis', fg: C.muted, bg: const Color(0xFFEFF1F7), size: 10)),
            Row(children: [
              Expanded(child: _readonly('Nama Siswa', 'Muhamad Dimas Ibrahimovic')),
              const SizedBox(width: 8),
              Expanded(child: _readonly('NISN', '0099370068')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _readonly('Kelas / Jurusan', 'XII RPL 2 (RPL)')),
              const SizedBox(width: 8),
              Expanded(child: _readonly('Status Keanggotaan', 'Aktif Reguler', lead: Icon(Icons.circle, size: 8, color: C.green))),
            ]),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sec(Icons.event_available_outlined, 'Detail Agenda Yang Diizinkan'),
            tx('Pilih Agenda Kegiatan *', size: 12, w: FontWeight.w700),
            const SizedBox(height: 6),
            _readonly('', 'Simulasi Pertolongan Pertama (PP) & Tandu Darurat', lead: Icon(Icons.list, size: 18, color: C.muted)),
            const SizedBox(height: 12),
            tx('Tanggal Pelaksanaan Izin *', size: 12, w: FontWeight.w700),
            const SizedBox(height: 6),
            _readonly('', 'Jumat, 01 November 2024', lead: Icon(Icons.calendar_today_outlined, size: 17, color: C.muted)),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sec(Icons.rule_folder_outlined, 'Jenis Izin Ketidakhadiran', trailing: tx('*Wajib pilih', size: 10.5, color: C.red)),
            for (int i = 0; i < jenisList.length; i++)
              GestureDetector(
                onTap: () => setState(() => jenis = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: jenis == i ? C.soft : const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12), border: jenis == i ? Border.all(color: C.primary.withValues(alpha: .4)) : null),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(jenis == i ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: jenis == i ? C.primary : C.muted),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Expanded(child: tx(jenisList[i].$1, size: 12.5, w: FontWeight.w800)), Pill(jenisList[i].$3, fg: jenisList[i].$4, bg: jenisList[i].$5, size: 9.5)]),
                      const SizedBox(height: 3),
                      tx(jenisList[i].$2, size: 11, color: C.muted, height: 1.4),
                    ])),
                  ]),
                ),
              ),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: tx('Rincian Alasan Perizinan *', size: 12, w: FontWeight.w700)),
              ValueListenableBuilder(valueListenable: alasan, builder: (_, v, __) => tx('${v.text.length}/250', size: 10.5, color: C.muted)),
            ]),
            const SizedBox(height: 6),
            TextField(
              controller: alasan,
              maxLines: 4,
              maxLength: 250,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Tuliskan alasan izin secara terperinci dan jelas agar dapat ditelaah oleh Pembina...',
                hintStyle: const TextStyle(fontSize: 12, color: C.muted),
                filled: true,
                fillColor: const Color(0xFFF1F4FC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sec(Icons.attach_file, 'Dokumen Bukti / Surat Izin', trailing: tx('*Wajib', size: 10.5, color: C.red)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                CircleAvatar(radius: 24, backgroundColor: C.soft, child: Icon(Icons.cloud_upload_outlined, color: C.primary)),
                const SizedBox(height: 8),
                tx('Ketuk untuk Mengunggah File', size: 13, w: FontWeight.w800),
                tx('Surat Dispensasi / Surat Keterangan Dokter (PDF, JPG, Maks. 2MB)', size: 10.5, color: C.muted, align: TextAlign.center),
              ]),
            ),
          ]),
        ),
        AppCard(
          padding: const EdgeInsets.all(8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(value: agree, activeColor: C.primary, onChanged: (v) => setState(() => agree = v ?? false)),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 12, right: 8), child: tx('Saya menyatakan dengan sadar bahwa permohonan izin ini benar, sah, dan dapat dipertanggungjawabkan kepada Pembina PMR Wira SMKN 8 Malang.', size: 11.5, color: C.muted, height: 1.4))),
          ]),
        ),
        AppCard(
          color: const Color(0xFFFFF1DC),
          borderColor: const Color(0xFFFAD9A6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBox(Icons.verified_user_outlined, color: C.brown, bg: Colors.white54, size: 38),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tx('Verifikasi Pembina Ekskul', size: 12.5, w: FontWeight.w800),
              Text.rich(TextSpan(style: const TextStyle(fontSize: 11, color: C.muted, height: 1.45), children: const [
                TextSpan(text: 'Pengajuan diteruskan ke Pembina '),
                TextSpan(text: 'Raudlatul Hakiki Fadila, S.Pd.', style: TextStyle(fontWeight: FontWeight.w800, color: C.text)),
                TextSpan(text: ' Riwayat persetujuan dapat dipantau langsung di menu Notifikasi SIEKSTRA-8.'),
              ])),
            ])),
          ]),
        ),
        PrimaryButton('Kirim Pengajuan Izin', icon: Icons.send_outlined, onPressed: agree ? () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan izin terkirim ke Pembina')));
          Navigator.pop(context);
        } : null),
        const SizedBox(height: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), side: const BorderSide(color: C.border), backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: () => Navigator.pop(context),
          child: tx('Batal & Kembali', size: 13, w: FontWeight.w700),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }
}
