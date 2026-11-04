import 'package:flutter/material.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class RegistrationFormScreen extends StatefulWidget {
  final Ekskul ekskul;
  const RegistrationFormScreen({super.key, required this.ekskul});
  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final alasan = TextEditingController();
  bool commit = false;

  @override
  void dispose() {
    alasan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.ekskul;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        titleSpacing: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          BrandLogo(size: 28),
          const SizedBox(width: 10),
          tx('Formulir Pendaftaran', size: 16, w: FontWeight.w800),
        ]),
        actions: [Padding(padding: const EdgeInsets.only(right: 14), child: AvatarDot())],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        StepBar(const ['1. Data Diri', '2. Ekskul', '3. Konfirmasi'], 1),
        const SizedBox(height: 14),
        AppCard(
          color: const Color(0xFFEEF2FF),
          child: Row(children: [
            IconBox(e.icon, color: C.primary, bg: Colors.white, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Pill('Teknologi & Riset', size: 9.5),
                  const Spacer(),
                  Pill(e.quota == 0 ? 'Tanpa kuota' : 'Sisa ${e.quota - e.filled} Kursi', fg: C.brown, bg: C.amberBg, size: 9.5),
                ]),
                const SizedBox(height: 6),
                tx(e.name, size: 15, w: FontWeight.w800),
                Row(children: [
                  Icon(Icons.schedule, size: 12, color: C.muted),
                  const SizedBox(width: 4),
                  tx('Ruang ${e.place} • SMKN 8 Malang', size: 11, color: C.muted),
                ]),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 4),
        LabeledField('Nama Lengkap Siswa', initial: 'Muhamad Dimas Ibrahimovic', suffix: Icons.lock_outline, readOnly: true, helper: 'Data sinkron otomatis dari Dapodik SMKN 8 Malang'),
        LabeledField('Nomor Induk Siswa (NIS)', initial: '0099770068', suffix: Icons.verified, readOnly: true),
        LabeledField('Kelas & Jurusan', initial: 'XII RPL (Rekayasa Perangkat Lunak)', suffix: Icons.keyboard_arrow_down, readOnly: true),
        LabeledField('Nomor WhatsApp Siswa', initial: '0812-3456-7890', suffix: Icons.phone_outlined, trailingLabel: 'Wajib Aktif', helper: 'Digunakan oleh pembina ekskul untuk undangan ke grup koordinasi resmi.'),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: tx('Alasan & Motivasi Bergabung', size: 12.5, w: FontWeight.w700)),
              ValueListenableBuilder(valueListenable: alasan, builder: (_, v, __) => tx('${v.text.length}/250', size: 11, color: C.muted)),
            ]),
            const SizedBox(height: 6),
            TextField(
              controller: alasan,
              maxLength: 250,
              maxLines: 4,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Ceritakan minat Anda pada coding atau elektronika...',
                hintStyle: const TextStyle(fontSize: 12.5, color: C.muted),
                filled: true,
                fillColor: const Color(0xFFF1F4FC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ]),
        ),
        AppCard(
          padding: const EdgeInsets.all(8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(value: commit, activeColor: C.primary, onChanged: (v) => setState(() => commit = v ?? false)),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 12, right: 8), child: tx('Saya berkomitmen mengikuti kegiatan rutin dan mematuhi tata tertib SMKN 8 Malang.', size: 11.5, color: C.muted, height: 1.4))),
          ]),
        ),
        Row(children: [
          SizedBox(
            width: 50,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, side: const BorderSide(color: C.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Icon(Icons.arrow_back, color: C.text),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PrimaryButton('Submit', color: C.brown, onPressed: commit
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pendaftaran berhasil dikirim')));
                    Navigator.pop(context);
                  }
                : null),
          ),
        ]),
      ]),
    );
  }
}
