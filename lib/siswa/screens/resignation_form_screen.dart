import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class ResignationFormScreen extends StatefulWidget {
  const ResignationFormScreen({super.key});
  @override
  State<ResignationFormScreen> createState() => _ResignationFormScreenState();
}

class _ResignationFormScreenState extends State<ResignationFormScreen> {
  bool agree = false;
  String reason = 'Fokus Praktik Kerja Lapangan (PKL) / Industri';
  final alasan = TextEditingController();

  @override
  void dispose() {
    alasan.dispose();
    super.dispose();
  }

  Widget _box(String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx(label, size: 9.5, w: FontWeight.w700, color: C.muted), const SizedBox(height: 2), tx(value, size: 12, w: FontWeight.w800)]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subAppBar(context, 'Form Pengunduran Diri', badge: 'PMR Wira'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: kBlueGradient, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Pill('Formulir Resmi Kesiswaan', fg: Colors.white, bg: Colors.white24, icon: Icons.description_outlined, size: 10),
            const SizedBox(height: 10),
            tx('Pengunduran Diri Anggota', size: 21, w: FontWeight.w800, color: Colors.white),
            const SizedBox(height: 4),
            tx('Proses terminasi keanggotaan ekstrakurikuler PMR Wira Unit SMKN 8 Malang Tahun Ajaran 2024/2025.', size: 11.5, color: Colors.white70, height: 1.4),
          ]),
        ),
        const SizedBox(height: 12),
        AppCard(
          color: const Color(0xFFFFF1E6),
          borderColor: const Color(0xFFFAD9B8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBox(Icons.warning_amber_rounded, color: C.brown, bg: const Color(0xFFFFD9A8), size: 40),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tx('Peringatan Regulasi Ekstrakurikuler', size: 13, w: FontWeight.w800),
              const SizedBox(height: 4),
              Text.rich(TextSpan(style: const TextStyle(fontSize: 11.5, color: C.brown, height: 1.45), children: const [
                TextSpan(text: 'Pengunduran diri dari keanggotaan '),
                TextSpan(text: 'PMR Wira SMKN 8 Malang', style: TextStyle(fontWeight: FontWeight.w800)),
                TextSpan(text: ' memerlukan persetujuan Pembina Ekstrakurikuler, Kesiswaan, dan Orang Tua/Wali Siswa. Siswa yang mengundurkan diri wajib mengembalikan seluruh inventaris unit dan tidak berhak memperoleh sertifikat poin ekstrakurikuler semester berjalan.'),
              ])),
            ])),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.badge_outlined, size: 19, color: C.primary), const SizedBox(width: 8), Expanded(child: tx('Data Keanggotaan Aktif', size: 14, w: FontWeight.w800)), Pill('Aktif (Juli 2023)', fg: C.green, bg: C.greenBg, size: 9.5)]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                CircleAvatar(radius: 24, backgroundColor: C.soft, child: Icon(Icons.person, color: C.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx('Muhamad Dimas Ibrahimovic', size: 13, w: FontWeight.w800), tx('NIS: 0099370068 • XII RPL 2', size: 11, color: C.muted)])),
              ]),
            ),
            const SizedBox(height: 8),
            Row(children: [_box('KOMPETENSI KEAHLIAN', 'Rekayasa Perangkat Lunak'), const SizedBox(width: 8), _box('UNIT ORGANISASI', 'PMR Wira Bhakti 08')]),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.edit_note, size: 20, color: C.primary), const SizedBox(width: 8), tx('Formulir Pernyataan Resmi', size: 14, w: FontWeight.w800)]),
            const SizedBox(height: 14),
            tx('Tanggal Pengajuan', size: 12, w: FontWeight.w700),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [Icon(Icons.calendar_today_outlined, size: 17, color: C.muted), const SizedBox(width: 10), Expanded(child: tx('28 Oktober 2024', size: 13, w: FontWeight.w800)), tx('(Tercatat Otomatis)', size: 10.5, color: C.muted)]),
            ),
            const SizedBox(height: 14),
            Row(children: [Expanded(child: tx('Alasan Utama Pengunduran Diri', size: 12, w: FontWeight.w700)), tx('*Wajib', size: 10.5, color: C.red)]),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: reason,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.text),
              decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF1F4FC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              items: const [
                'Fokus Praktik Kerja Lapangan (PKL) / Industri',
                'Fokus Ujian Kelulusan',
                'Kendala Kesehatan',
                'Jadwal Bentrok',
                'Lainnya',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setState(() => reason = v ?? reason),
            ),
            const SizedBox(height: 14),
            Row(children: [Expanded(child: tx('Rincian Alasan Tertulis', size: 12, w: FontWeight.w700)), tx('*Wajib', size: 10.5, color: C.red)]),
            const SizedBox(height: 6),
            TextField(
              controller: alasan,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tuliskan penjelasan lengkap alasan pengunduran diri...',
                hintStyle: const TextStyle(fontSize: 12, color: C.muted),
                filled: true,
                fillColor: const Color(0xFFF1F4FC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, size: 13, color: C.muted), const SizedBox(width: 4), Expanded(child: tx('Jelaskan jadwal industri atau kendala yang mendasari keputusan Anda secara transparan.', size: 10.5, color: C.muted))]),
            const SizedBox(height: 14),
            Row(children: [Expanded(child: tx('Unggah Surat Pernyataan Orang Tua / Wali', size: 12, w: FontWeight.w700)), tx('*Bermaterai', size: 10.5, color: C.red)]),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                CircleAvatar(radius: 22, backgroundColor: C.soft, child: Icon(Icons.upload_file, color: C.primary)),
                const SizedBox(height: 8),
                tx('Pilih Berkas atau Tarik ke Sini', size: 13, w: FontWeight.w800),
                tx('Format PDF atau JPG (Maks. 2MB)', size: 10.5, color: C.muted),
              ]),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Icons.description_outlined, size: 22, color: C.amber),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tx('Template Surat Pengunduran Diri', size: 12, w: FontWeight.w800), tx('Format standar SMKN 8 Malang (.docx)', size: 10.5, color: C.muted)])),
                Pill('Unduh', icon: Icons.download_outlined, size: 10.5),
              ]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFFFF1DC), borderRadius: BorderRadius.circular(12)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Checkbox(value: agree, activeColor: C.primary, onChanged: (v) => setState(() => agree = v ?? false)),
                Expanded(child: Padding(padding: const EdgeInsets.only(top: 12, right: 8), child: tx('Saya memahami bahwa setelah pengunduran diri disetujui, saya akan kehilangan status keanggotaan aktif PMR dan seluruh fasilitas kegiatan ekstrakurikuler SMKN 8 Malang.', size: 11.5, color: C.text, height: 1.4))),
              ]),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.send_outlined, size: 15, color: C.muted),
                const SizedBox(width: 8),
                Expanded(child: tx('Pengajuan Anda akan diproses dalam 3–5 hari kerja. Anda dapat memantau status persetujuan secara real-time pada menu Notifikasi akun SIEKSTRA-8.', size: 10.5, color: C.muted, height: 1.45)),
              ]),
            ),
            const SizedBox(height: 16),
            PrimaryButton('Ajukan Pengunduran Diri', icon: Icons.person_remove_outlined, trailingIcon: false, color: C.red, onPressed: agree ? () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan pengunduran diri terkirim')));
              Navigator.pop(context);
            } : null),
            const SizedBox(height: 8),
            SoftButton('Batalkan & Kembali ke Profil', icon: Icons.arrow_back, bg: const Color(0xFFEFF1F7), onPressed: () => Navigator.pop(context)),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.account_tree_outlined, size: 19, color: C.primary), const SizedBox(width: 8), tx('Tahapan Verifikasi Pengunduran Diri', size: 13.5, w: FontWeight.w800)]),
            const SizedBox(height: 12),
            Row(children: [
              for (final s in const [('1', 'Pengajuan', 'Formulir Siswa'), ('2', 'Verifikasi', 'Pembina & BK'), ('3', 'Penerbitan', 'SK Kesiswaan')])
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFF1F4FC), borderRadius: BorderRadius.circular(12)),
                    child: Column(children: [
                      CircleAvatar(radius: 11, backgroundColor: s.$1 == '1' ? C.primary : const Color(0xFFDDE3F3), child: tx(s.$1, size: 10, w: FontWeight.w800, color: s.$1 == '1' ? Colors.white : C.muted)),
                      const SizedBox(height: 4),
                      tx(s.$2, size: 11, w: FontWeight.w800),
                      tx(s.$3, size: 9.5, color: C.muted),
                    ]),
                  ),
                ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
