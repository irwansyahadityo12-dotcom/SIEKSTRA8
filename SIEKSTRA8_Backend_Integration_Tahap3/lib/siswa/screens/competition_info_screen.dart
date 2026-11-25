import 'package:flutter/material.dart';
import '../../app/backend.dart';
import '../../data/siekstra_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

// ============================================================
//  Siswa Competition Info Screen
//  Menampilkan informasi lomba, galeri prestasi, agenda mendatang,
//  serta kartu lomba & tombol Konsultasi Lomba yang aktif & interaktif
//  terhubung ke Supabase.
// ============================================================

class CompetitionInfoScreen extends StatefulWidget {
  final String? extracurricularId;
  final Map<String, dynamic>? extracurricular;

  const CompetitionInfoScreen({
    super.key,
    this.extracurricularId,
    this.extracurricular,
  });

  @override
  State<CompetitionInfoScreen> createState() => _CompetitionInfoScreenState();
}

class _CompetitionInfoScreenState extends State<CompetitionInfoScreen> {
  final SiekstraRepository _repo = SiekstraRepository();

  int tab = 0; // 0: Prestasi & Penghargaan, 1: Lomba Mendatang
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _currentExtra;
  Map<String, dynamic>? _myProfile;
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _upcomingTrainings = [];
  List<Map<String, dynamic>> _myMemberships = [];
  List<Map<String, dynamic>> _allExtras = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Load Data dari Supabase ───────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Backend.ensureInitialized();

      final results = await Future.wait([
        _repo.getMyProfile(),
        _repo.getMyMemberships(),
        _repo.getExtracurriculars(onlyOpen: false),
      ]);

      if (!mounted) return;

      _myProfile = results[0] as Map<String, dynamic>?;
      _myMemberships = List<Map<String, dynamic>>.from(results[1] as List);
      _allExtras = List<Map<String, dynamic>>.from(results[2] as List);

      // Tentukan ekskul yang sedang aktif
      if (widget.extracurricular != null) {
        _currentExtra = widget.extracurricular;
      } else if (widget.extracurricularId != null) {
        _currentExtra = _allExtras.firstWhere(
          (e) => e['id']?.toString() == widget.extracurricularId,
          orElse: () => _allExtras.isNotEmpty ? _allExtras.first : {},
        );
      } else if (_myMemberships.isNotEmpty) {
        final firstApproved = _myMemberships.firstWhere(
          (m) => m['status'] == 'approved',
          orElse: () => _myMemberships.first,
        );
        final extraId = firstApproved['extracurricular_id']?.toString();
        _currentExtra = _allExtras.firstWhere(
          (e) => e['id']?.toString() == extraId,
          orElse: () => _allExtras.isNotEmpty ? _allExtras.first : {},
        );
      } else if (_allExtras.isNotEmpty) {
        _currentExtra = _allExtras.first;
      }

      final extraId = _currentExtra?['id']?.toString();

      // Ambil data prestasi dan pelatihan/agenda dari Supabase
      final detailResults = await Future.wait([
        _repo.getAchievements(extracurricularId: extraId),
        _repo.getTrainings(extracurricularId: extraId),
      ]);

      if (!mounted) return;

      setState(() {
        _achievements = List<Map<String, dynamic>>.from(detailResults[0]);
        _upcomingTrainings = List<Map<String, dynamic>>.from(detailResults[1]);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Dialog Interaktif Konsultasi Lomba ────────────────────
  Future<void> _openConsultationDialog({
    bool isScheduling = false,
    String? initialTopic,
    String? initialNote,
  }) async {
    final extraName = _currentExtra?['name']?.toString() ?? 'PMR Wira';
    final coachName = _currentExtra?['coach_name']?.toString() ??
        'Raudlatul Hakiki Fadila, S.Pd';
    final coachId = _currentExtra?['coach_id']?.toString();

    final topics = [
      if (initialTopic != null && initialTopic.isNotEmpty) initialTopic,
      'Seleksi Delegasi Lomba / LKS',
      'Bimbingan Materi & Taktik Kompetisi',
      'Pengajuan Ide / Karya Lomba',
      'Penyusunan Berkas & Administrasi Lomba',
      'Konsultasi Jadwal Latihan Khusus',
      'Lainnya',
    ];

    String selectedTopic = initialTopic ??
        (isScheduling
            ? 'Konsultasi Jadwal Latihan Khusus'
            : 'Seleksi Delegasi Lomba / LKS');

    final notesCtrl = TextEditingController(text: initialNote ?? '');
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 15, minute: 30);
    bool isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: C.soft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.forum_outlined,
                        color: C.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tx(
                            'Konsultasi & Bimbingan Lomba',
                            size: 16,
                            w: FontWeight.w800,
                          ),
                          const SizedBox(height: 2),
                          tx(
                            '$extraName • Pembina: $coachName',
                            size: 12,
                            color: C.muted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Pilihan Topik
                tx('Topik Konsultasi', size: 12.5, w: FontWeight.w700),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedTopic,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F4FC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: topics
                      .toSet()
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t, style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setModalState(() => selectedTopic = v);
                  },
                ),
                const SizedBox(height: 12),

                // Pilihan Tanggal & Waktu Diajukan
                tx('Rencana Tanggal & Jam Konsultasi',
                    size: 12.5, w: FontWeight.w700),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 60)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4FC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: C.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: C.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() => selectedTime = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4FC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: C.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: C.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedTime.format(ctx),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Detail Pertanyaan
                tx('Pesan / Catatan ke Pembina', size: 12.5, w: FontWeight.w700),
                const SizedBox(height: 6),
                TextFormField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Tuliskan hal yang ingin dikonsultasikan, delegasi yang diajukan, atau persiapan lomba...',
                    hintStyle: const TextStyle(fontSize: 12, color: C.muted),
                    filled: true,
                    fillColor: const Color(0xFFF1F4FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Tombol Submit Aktif
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: isSubmitting
                      ? null
                      : () async {
                          final text = notesCtrl.text.trim();
                          if (text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan masukkan pesan konsultasi.'),
                              ),
                            );
                            return;
                          }

                          setModalState(() => isSubmitting = true);

                          try {
                            await Backend.ensureInitialized();

                            final studentName =
                                _myProfile?['full_name']?.toString() ?? 'Siswa';
                            final studentClass =
                                _myProfile?['class_name']?.toString() ?? '-';
                            final dateStr =
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} pukul ${selectedTime.format(context)}';

                            String? rlsNotice;

                            // 1. Kirim notifikasi ke Pembina jika ada coach_id
                            if (coachId != null && coachId.isNotEmpty) {
                              try {
                                await _repo.createNotification(
                                  userId: coachId,
                                  title: 'Permintaan Konsultasi Lomba: $selectedTopic',
                                  body:
                                      '$studentName ($studentClass) mengajukan konsultasi lomba untuk $extraName ($dateStr): "$text"',
                                  type: 'competition_consultation',
                                );
                              } catch (err) {
                                debugPrint('Notice: Gagal kirim notifikasi pembina (RLS/Koneksi): $err');
                                if (err.toString().contains('42501') ||
                                    err.toString().contains('row-level security')) {
                                  rlsNotice = 'Jalankan supabase/fix_notifications_rls.sql di SQL Editor Supabase.';
                                }
                              }
                            }

                            // 2. Notifikasi konfirmasi ke Siswa
                            final myId = _myProfile?['id']?.toString() ??
                                (Backend.user?.id ?? Backend.client.auth.currentUser?.id);
                            if (myId != null && myId.isNotEmpty) {
                              try {
                                await _repo.createNotification(
                                  userId: myId,
                                  title: 'Permintaan Konsultasi Lomba Terkirim',
                                  body:
                                      'Permintaan konsultasi "$selectedTopic" untuk $extraName telah diteruskan ke $coachName. Pantau jadwal dan pesan tindak lanjut.',
                                  type: 'competition_consultation',
                                );
                              } catch (err) {
                                debugPrint('Notice: Gagal kirim konfirmasi notifikasi siswa: $err');
                              }
                            }

                            if (!mounted) return;
                            Navigator.pop(ctx);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: C.primary,
                                duration: const Duration(seconds: 4),
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        rlsNotice != null
                                            ? 'Permohonan konsultasi diajukan. (Catatan: $rlsNotice)'
                                            : 'Permohonan konsultasi lomba ke $coachName berhasil diajukan!',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: C.red,
                                  content: Text(
                                    'Gagal mengirim permohonan konsultasi: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x331D4ED8),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Kirim Permohonan Konsultasi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Modal Detail Prestasi / Kartu Terpencet ───────────────
  void _showAchievementDetail({
    required String title,
    required String badge,
    required String date,
    required String delegate,
    required String desc,
    required String tag,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Pill(badge, fg: Colors.white, bg: C.amber, size: 11),
                const Spacer(),
                DarkChip(date, icon: Icons.calendar_today_outlined),
              ],
            ),
            const SizedBox(height: 12),
            tx(title, size: 18, w: FontWeight.w800, height: 1.3),
            const SizedBox(height: 8),
            tx(desc, size: 13, color: C.muted, height: 1.45),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.groups_2_outlined, color: C.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tx('Delegasi Terdaftar', size: 11, color: C.muted),
                        tx(delegate, size: 13, w: FontWeight.w700),
                      ],
                    ),
                  ),
                  Pill(tag, fg: C.brown, bg: C.amberBg, size: 10.5),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openConsultationDialog(
                        initialTopic: 'Konsultasi Terkait: $title',
                        initialNote:
                            'Saya ingin konsultasi mengenai seleksi dan persiapan untuk $title.',
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: C.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.chat_outlined, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Konsultasi Lomba Ini',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Modal Detail Agenda Lomba Mendatang ───────────────────
  void _showUpcomingDetail({
    required String title,
    required String date,
    required String location,
    required String desc,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Pill('AGENDA MENDATANG', fg: C.primary, bg: C.soft, size: 11),
                const Spacer(),
                DarkChip(date, icon: Icons.calendar_month_outlined),
              ],
            ),
            const SizedBox(height: 12),
            tx(title, size: 18, w: FontWeight.w800, height: 1.3),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16, color: C.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: tx(location, size: 13, color: C.muted),
                ),
              ],
            ),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 10),
              tx(desc, size: 13, color: C.text, height: 1.45),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openConsultationDialog(
                        initialTopic: 'Daftar Delegasi: $title',
                        initialNote:
                            'Saya mengajukan diri untuk ikut seleksi / bimbingan pada $title bertempat di $location ($date).',
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: C.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.how_to_reg_outlined,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Daftar / Konsultasi Seleksi',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    try {
                      await Backend.ensureInitialized();
                      final myId = _myProfile?['id']?.toString() ??
                          (Backend.user?.id ?? Backend.client.auth.currentUser?.id);
                      if (myId != null) {
                        try {
                          await _repo.createNotification(
                            userId: myId,
                            title: 'Pengingat Agenda Lomba',
                            body: 'Pengingat: Agenda "$title" pada tanggal $date di $location telah disimpan ke agenda notifikasi Anda.',
                            type: 'competition_reminder',
                          );
                        } catch (err) {
                          debugPrint('Notice: Gagal menyimpan pengingat notifikasi (RLS): $err');
                        }
                      }
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Agenda lomba disimpan ke pengingat notifikasi!'),
                        ),
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan pengingat: $e')),
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4FC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: C.border),
                    ),
                    child: const Icon(
                      Icons.bookmark_add_outlined,
                      color: C.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Stats ──────────────────────────────────────────
  Widget _stat(String big, String label, {VoidCallback? onTap}) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                tx(big, size: 18, w: FontWeight.w800, color: Colors.white),
                tx(label, size: 10, color: Colors.white70),
              ],
            ),
          ),
        ),
      );

  // ── Helper Prestasi Card dengan onTap ─────────────────────
  Widget _prestasiCard({
    required String badge,
    required Color badgeBg,
    required String date,
    required List<Color> colors,
    required String title,
    required String desc,
    required IconData fIcon,
    required String fTop,
    required String fMain,
    required String fTag,
    VoidCallback? onTap,
  }) =>
      InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap ??
            () => _showAchievementDetail(
                  title: title,
                  badge: badge,
                  date: date,
                  delegate: fMain,
                  desc: desc,
                  tag: fTag,
                ),
        child: AppCard(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhotoBox(
                height: 130,
                colors: colors,
                icon: Icons.emoji_events_outlined,
                overlays: [
                  Overlay1(
                    Alignment.topLeft,
                    Pill(badge, fg: Colors.white, bg: badgeBg, size: 10),
                  ),
                  Overlay1(
                    Alignment.bottomRight,
                    InkWell(
                      onTap: () => _openConsultationDialog(
                        initialTopic: 'Konsultasi Prestasi: $title',
                      ),
                      child: DarkChip(date, icon: Icons.calendar_today_outlined),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    tx(title, size: 15, w: FontWeight.w800, height: 1.3),
                    const SizedBox(height: 4),
                    tx(desc, size: 11.5, color: C.muted, lines: 2, height: 1.4),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(fIcon, size: 18, color: C.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                tx(fTop, size: 10, color: C.muted),
                                tx(fMain, size: 12, w: FontWeight.w800, lines: 1),
                              ],
                            ),
                          ),
                          Pill(fTag, fg: C.brown, bg: C.amberBg, size: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final extraName = _currentExtra?['name']?.toString() ?? 'PMR Wira';
    final coachName = _currentExtra?['coach_name']?.toString() ??
        'Raudlatul Hakiki Fadila, S.Pd';

    final totalAchievementsCount = _achievements.isNotEmpty
        ? _achievements.length
        : 14;

    return Scaffold(
      appBar: subAppBar(context, 'Info Lomba', badge: extraName),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Banner Hero Ekstrakurikuler
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: kBlueGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Pill(
                          'PRESTASI & SELEKSI KEJUARAAN RESMI',
                          fg: const Color(0xFFFFD27D),
                          bg: Colors.white12,
                          icon: Icons.emoji_events_outlined,
                          size: 9.5,
                        ),
                        const SizedBox(height: 12),
                        tx(
                          '$extraName SMKN 8 Malang',
                          size: 20,
                          w: FontWeight.w800,
                          color: Colors.white,
                        ),
                        tx(
                          'Pusat Prestasi Kejuruan, Bakat, Seni, dan Olahraga SMKN 8 Malang',
                          size: 11.5,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _stat(
                              '$totalAchievementsCount',
                              'Trofi Juara',
                              onTap: () => setState(() => tab = 0),
                            ),
                            _stat(
                              '2024/2025',
                              'Periode Aktif',
                              onTap: () => setState(() => tab = 1),
                            ),
                            _stat(
                              'Grade A',
                              'Akreditasi',
                              onTap: () => _openConsultationDialog(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tab Pilihan: Prestasi vs Lomba Mendatang
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEFFC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        for (final t in [
                          (Icons.emoji_events_outlined, 'Prestasi & Penghargaan'),
                          (Icons.flag_outlined, 'Lomba Mendatang'),
                        ].asMap().entries)
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => tab = t.key),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: tab == t.key
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                  boxShadow: tab == t.key
                                      ? const [
                                          BoxShadow(
                                            color: Color(0x121D4ED8),
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      t.value.$1,
                                      size: 16,
                                      color: tab == t.key ? C.primary : C.muted,
                                    ),
                                    const SizedBox(width: 6),
                                    tx(
                                      t.value.$2,
                                      size: 11.5,
                                      w: FontWeight.w700,
                                      color: tab == t.key ? C.primary : C.muted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Isi Tab
                  if (tab == 0) ...[
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: C.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: tx(
                            'Galeri Prestasi Unggulan',
                            size: 15,
                            w: FontWeight.w800,
                          ),
                        ),
                        tx(
                          'Total $totalAchievementsCount Gelar',
                          size: 11,
                          color: C.muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Render Data dari Supabase jika ada
                    if (_achievements.isNotEmpty)
                      ..._achievements.map((a) {
                        final title =
                            a['title']?.toString() ?? 'Prestasi Lomba';
                        final comp = a['competition_name']?.toString() ??
                            'Kompetisi Resmi';
                        final award =
                            a['award']?.toString() ?? 'Penghargaan Resmi';
                        final desc = a['description']?.toString() ??
                            'Pencapaian siswa SMKN 8 Malang dalam kompetisi resmi.';
                        final dateStr =
                            a['achievement_date']?.toString() ?? '2024';

                        return _prestasiCard(
                          badge: award,
                          badgeBg: C.amber,
                          date: dateStr,
                          colors: const [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                          title: title,
                          desc: desc,
                          fIcon: Icons.emoji_events_outlined,
                          fTop: 'Tingkat Kompetisi',
                          fMain: comp,
                          fTag: award,
                          onTap: () => _showAchievementDetail(
                            title: title,
                            badge: award,
                            date: dateStr,
                            delegate: comp,
                            desc: desc,
                            tag: award,
                          ),
                        );
                      })
                    else ...[
                      // Tampilan contoh terpadu (semua kartu dapat dipencet)
                      _prestasiCard(
                        badge: 'Juara 1 Tingkat Provinsi',
                        badgeBg: C.amber,
                        date: 'Oktober 2024',
                        colors: const [Color(0xFF7F1D1D), Color(0xFFEF4444)],
                        title:
                            'LKS Tandu Darurat & Pertolongan Pertama Jawa Timur 2024',
                        desc:
                            'Simulasi rintangan evakuasi korban bencana lapangan berkecepatan 3 menit 12 detik dengan teknik balut bidai presisi.',
                        fIcon: Icons.groups_2_outlined,
                        fTop: 'Delegasi',
                        fMain: 'Tim PMR Wira Inti (Regu Alpha)',
                        fTag: 'Emas & Piagam Gub.',
                      ),
                      _prestasiCard(
                        badge: 'Piala Bergilir',
                        badgeBg: C.brown,
                        date: 'Agustus 2024',
                        colors: const [Color(0xFF78350F), Color(0xFFF59E0B)],
                        title:
                            'Juara Umum Jumbara PMR Wira Tingkat Kota Malang 2024',
                        desc:
                            'Kemenangan mutlak pada divisi Madya-Wira Terpadu yang mencakup kepemimpinan, donor darah sukarela, sanitasi kesehatan.',
                        fIcon: Icons.apartment_outlined,
                        fTop: 'Apresiasi Tertinggi',
                        fMain: 'Piala Bergilir Walikota Malang',
                        fTag: 'Juara Umum I',
                      ),
                      _prestasiCard(
                        badge: 'Penghargaan Khusus',
                        badgeBg: C.primary,
                        date: 'Juli 2024',
                        colors: const [Color(0xFF14532D), Color(0xFF3B82F6)],
                        title:
                            'Best Field First Aid Team & Fast Response Triage',
                        desc:
                            'Simulasi tanggap darurat massal bencana gempa bumi garapan PMI Kota Malang dengan akurasi penentuan kode triage tertinggi.',
                        fIcon: Icons.health_and_safety_outlined,
                        fTop: 'Kategori Kecepatan Reaksi Klinis',
                        fMain: 'Kategori Kecepatan Reaksi Klinis',
                        fTag: 'Terbaik I',
                      ),
                    ],
                  ] else ...[
                    // Tab 1: Lomba & Agenda Mendatang (semua kartu dapat dipencet)
                    if (_upcomingTrainings.isNotEmpty)
                      ..._upcomingTrainings.map((tr) {
                        final title = tr['title']?.toString() ?? 'Agenda Lomba';
                        final loc = tr['location']?.toString() ?? 'Malang';
                        final startDate = tr['start_date']?.toString() ?? '-';
                        final desc = tr['description']?.toString() ?? '';

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _showUpcomingDetail(
                            title: title,
                            date: startDate,
                            location: loc,
                            desc: desc,
                          ),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.flag_outlined,
                                      size: 24,
                                      color: C.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: tx(
                                        title,
                                        size: 14,
                                        w: FontWeight.w800,
                                      ),
                                    ),
                                    Pill('Mendatang', fg: C.primary, bg: C.soft),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 14,
                                      color: C.muted,
                                    ),
                                    const SizedBox(width: 4),
                                    tx(startDate, size: 11.5, color: C.muted),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: C.muted,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: tx(loc, size: 11.5, color: C.muted),
                                    ),
                                  ],
                                ),
                                if (desc.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  tx(desc, size: 11.5, color: C.text),
                                ],
                              ],
                            ),
                          ),
                        );
                      })
                    else
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _showUpcomingDetail(
                          title:
                              'Lomba PP & Kesiapsiagaan Bencana Jumbara PMI Jatim',
                          date: '2 – 3 Des 2024',
                          location: 'Gedung Diklat PMI Malang & Rampal',
                          desc:
                              'Seleksi terbuka delegasi SMKN 8 Malang untuk divisi evakuasi tandu, pertolongan pertama, dan pemetaan tanggap darurat.',
                        ),
                        child: AppCard(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.flag_outlined,
                                size: 36,
                                color: C.primary,
                              ),
                              const SizedBox(height: 8),
                              tx(
                                'Lomba PP & Kesiapsiagaan Bencana Jumbara PMI Jatim',
                                size: 14,
                                w: FontWeight.w800,
                                align: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 14,
                                    color: C.muted,
                                  ),
                                  const SizedBox(width: 4),
                                  tx(
                                    '2 – 3 Des 2024 • Gedung Diklat PMI Malang & Rampal',
                                    size: 11.5,
                                    color: C.muted,
                                    align: TextAlign.center,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Pill('Ketuk untuk Detail & Pendaftaran',
                                  fg: C.primary, bg: C.soft, size: 10),
                            ],
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 10),

                  // Card Kontak Pembina & Tombol Konsultasi Interaktif Aktif
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.support_agent,
                              size: 20,
                              color: C.primary,
                            ),
                            const SizedBox(width: 8),
                            tx(
                              'Kontak Pembina & Seleksi',
                              size: 14,
                              w: FontWeight.w800,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4FC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: C.soft,
                                child: const Icon(Icons.person, color: C.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    tx(
                                      coachName,
                                      size: 13,
                                      w: FontWeight.w800,
                                    ),
                                    tx(
                                      'Pembina Teknis & Pelatih $extraName',
                                      size: 11,
                                      color: C.muted,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 7,
                                          color: C.green,
                                        ),
                                        const SizedBox(width: 4),
                                        tx(
                                          'Tersedia untuk Bimbingan',
                                          size: 10.5,
                                          color: C.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Tombol Aksi Konsultasi Aktif (Warna biru mencolok, responsif terhadap klik)
                        Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => _openConsultationDialog(),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: C.primary,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x331D4ED8),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.chat_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Konsultasi Lomba',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.5,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () =>
                                    _openConsultationDialog(isScheduling: true),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF1F7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: C.border),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month_outlined,
                                    color: C.primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
