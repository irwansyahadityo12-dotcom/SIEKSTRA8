import 'package:flutter/material.dart';
import '../../app/supabase_config.dart';
import '../../data/siekstra_repository.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'registration_status_screen.dart';

class RegistrationFormScreen extends StatefulWidget {
  final Ekskul ekskul;
  const RegistrationFormScreen({super.key, required this.ekskul});
  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final nama = TextEditingController();
  final nis = TextEditingController();
  final kelas = TextEditingController();
  final telepon = TextEditingController();
  final alasan = TextEditingController();

  bool commit = false;
  bool loading = false;
  bool checking = true;
  Map<String, dynamic>? existingMembership;
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!SupabaseConfig.isConfigured || widget.ekskul.id == null) {
      if (mounted) setState(() => checking = false);
      return;
    }
    try {
      final repo = SiekstraRepository();
      final results = await Future.wait([
        repo.getMyMembershipForExtracurricular(widget.ekskul.id!),
        repo.getMyProfile(),
      ]);
      if (!mounted) return;
      final resMem = results[0];
      final resProf = results[1];

      if (resProf != null) {
        if (nama.text.isEmpty && resProf['full_name'] != null) {
          nama.text = resProf['full_name'].toString();
        }
        if (nis.text.isEmpty && resProf['identifier'] != null) {
          nis.text = resProf['identifier'].toString();
        }
        if (kelas.text.isEmpty) {
          final c = resProf['class_name']?.toString() ?? '';
          final m = resProf['major']?.toString() ?? '';
          if (c.isNotEmpty || m.isNotEmpty) {
            kelas.text = m.isNotEmpty ? '$c ($m)' : c;
          }
        }
        if (telepon.text.isEmpty && resProf['phone'] != null) {
          telepon.text = resProf['phone'].toString();
        }
      }

      setState(() {
        existingMembership = resMem;
        profile = resProf;
        checking = false;
      });
    } catch (_) {
      if (mounted) setState(() => checking = false);
    }
  }

  Future<void> _submit() async {
    if (!SupabaseConfig.isConfigured || widget.ekskul.id == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data ekstrakurikuler belum terhubung ke Supabase.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (nama.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap siswa wajib diisi.'), duration: Duration(seconds: 3)),
      );
      return;
    }
    if (nis.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor Induk Siswa (NIS) wajib diisi.'), duration: Duration(seconds: 3)),
      );
      return;
    }
    if (existingMembership != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          showCloseIcon: true,
          closeIconColor: Colors.white70,
          dismissDirection: DismissDirection.horizontal,
          content: const Text('Anda sudah pernah mendaftar pada ekstrakurikuler ini.'),
          action: SnackBarAction(
            label: 'Lihat Status',
            textColor: const Color(0xFFFFD27D),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationStatusScreen()));
            },
          ),
        ),
      );
      return;
    }
    setState(() => loading = true);
    try {
      // Simpan nomor telepon jika diisi
      if (telepon.text.trim().isNotEmpty) {
        try {
          await SiekstraRepository().updateMyProfile(
            fullName: nama.text.trim(),
            phone: telepon.text.trim(),
          );
        } catch (_) {}
      }

      await SiekstraRepository().applyExtracurricular(
        extracurricularId: widget.ekskul.id!,
        motivation: alasan.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil dikirim ke pembina.'),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationStatusScreen()));
    } catch (e) {
      final msg = e.toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('PostgrestException(message: ', '');
      if (mounted) {
        final isDuplicate = msg.contains('23505') ||
            msg.contains('memberships_extracurricular_id_student_id_key') ||
            msg.contains('duplicate key');
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFB91C1C),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            showCloseIcon: true,
            closeIconColor: Colors.white70,
            dismissDirection: DismissDirection.horizontal,
            content: Text(
              isDuplicate
                  ? 'Anda sudah pernah mendaftar pada ekstrakurikuler ini.'
                  : msg,
            ),
            action: SnackBarAction(
              label: 'Lihat Status',
              textColor: const Color(0xFFFFD27D),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationStatusScreen()));
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nama.dispose();
    nis.dispose();
    kelas.dispose();
    telepon.dispose();
    alasan.dispose();
    super.dispose();
  }

  Widget _buildExistingMembershipBanner() {
    if (existingMembership == null) return const SizedBox.shrink();
    final status = existingMembership!['status']?.toString();
    final isPending = status == 'pending';
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    final Color bgColor = isApproved
        ? const Color(0xFFECFDF5)
        : isPending
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFFEF2F2);
    final Color borderColor = isApproved
        ? const Color(0xFFA7F3D0)
        : isPending
            ? const Color(0xFFFDE68A)
            : const Color(0xFFFECACA);
    final Color textColor = isApproved
        ? const Color(0xFF065F46)
        : isPending
            ? const Color(0xFF92400E)
            : const Color(0xFF991B1B);
    final IconData icon = isApproved
        ? Icons.check_circle_rounded
        : isPending
            ? Icons.hourglass_top_rounded
            : Icons.info_outline_rounded;

    final String title = isApproved
        ? 'Anda Sudah Terdaftar'
        : isPending
            ? 'Pendaftaran Sedang Diproses'
            : isRejected
                ? 'Pendaftaran Ditolak'
                : 'Sudah Pernah Mendaftar';

    final String desc = isApproved
        ? 'Anda sudah menjadi anggota resmi ekstrakurikuler ini. Tidak perlu mendaftar ulang.'
        : isPending
            ? 'Formulir Anda sudah terkirim sebelumnya dan saat ini sedang menunggu persetujuan pembina.'
            : isRejected
                ? 'Pendaftaran Anda sebelumnya belum dapat disetujui oleh pembina ekskul.'
                : 'Anda sudah memiliki riwayat pendaftaran di ekstrakurikuler ini.';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.9), height: 1.4),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistrationStatusScreen()),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Buka Status Pendaftaran'),
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: textColor.withValues(alpha: 0.5)),
                backgroundColor: Colors.white.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.ekskul;
    final hasAlreadyRegistered = existingMembership != null;

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
        if (checking)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 3),
          ),
        _buildExistingMembershipBanner(),
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
        LabeledField(
          'Nama Lengkap Siswa',
          controller: nama,
          hint: 'Masukkan nama lengkap siswa',
          icon: Icons.person_outline,
          readOnly: false,
          helper: 'Isi sesuai nama lengkap yang terdaftar di sekolah',
        ),
        LabeledField(
          'Nomor Induk Siswa (NIS)',
          controller: nis,
          hint: 'Masukkan Nomor Induk Siswa (NIS)',
          icon: Icons.badge_outlined,
          readOnly: false,
        ),
        LabeledField(
          'Kelas & Jurusan',
          controller: kelas,
          hint: 'Contoh: XII RPL (Rekayasa Perangkat Lunak)',
          icon: Icons.school_outlined,
          readOnly: false,
        ),
        LabeledField(
          'Nomor WhatsApp Siswa',
          controller: telepon,
          hint: 'Contoh: 0812-3456-7890',
          icon: Icons.phone_outlined,
          trailingLabel: 'Wajib Aktif',
          readOnly: false,
          helper: 'Digunakan oleh pembina ekskul untuk undangan ke grup koordinasi resmi.',
        ),
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
              enabled: !hasAlreadyRegistered,
              decoration: InputDecoration(
                counterText: '',
                hintText: hasAlreadyRegistered ? 'Pendaftaran sudah dikirimkan sebelumnya.' : 'Ceritakan minat Anda pada coding atau elektronika...',
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
            Checkbox(
              value: hasAlreadyRegistered ? true : commit,
              activeColor: C.primary,
              onChanged: hasAlreadyRegistered ? null : (v) => setState(() => commit = v ?? false),
            ),
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
            child: PrimaryButton(
              hasAlreadyRegistered
                  ? (existingMembership!['status'] == 'approved'
                      ? 'Sudah Terdaftar'
                      : 'Menunggu Persetujuan')
                  : (loading ? 'Mengirim...' : 'Submit'),
              color: hasAlreadyRegistered ? const Color(0xFF0284C7) : C.brown,
              onPressed: hasAlreadyRegistered
                  ? () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationStatusScreen()))
                  : (commit && !loading ? _submit : null),
            ),
          ),
        ]),
      ]),
    );
  }
}
