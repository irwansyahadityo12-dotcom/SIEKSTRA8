import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/backend.dart';
import '../../data/siekstra_repository.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'record_form_screen.dart';

class DispensasiScreen extends StatefulWidget {
  const DispensasiScreen({super.key});

  @override
  State<DispensasiScreen> createState() => _DispensasiScreenState();
}

class _DispensasiScreenState extends State<DispensasiScreen> {
  final SiekstraRepository _repo = SiekstraRepository();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  int _selectedChip = 0; // 0: Semua, 1: Menunggu Admin, 2: Disetujui KS, 3: Ditolak

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _letters = [];
  List<Map<String, dynamic>> _allExtras = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Backend.ensureInitialized();

      // Muat daftar ekstrakurikuler untuk opsi form
      try {
        final extras = await _repo.getExtracurriculars();
        _allExtras = extras;
      } catch (_) {}

      await _fetchDispensations();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDispensations() async {
    try {
      final rows = await _repo.getDispensations();
      final List<Map<String, dynamic>> mapped = [];

      for (var i = 0; i < rows.length; i++) {
        final r = rows[i];
        final id = r['id']?.toString() ?? '';
        final reason = (r['reason'] ?? 'Surat Dispensasi Siswa').toString().trim();
        final start = (r['start_date'] ?? '').toString().trim();
        final end = (r['end_date'] ?? '').toString().trim();
        final statusRaw = (r['status'] ?? 'pending').toString().toLowerCase();

        final profile = r['profiles'] as Map<String, dynamic>?;
        final studentName = profile?['full_name']?.toString() ?? 'Siswa SMKN 8';
        final nis = profile?['identifier']?.toString() ?? '-';
        final delegasi = nis != '-' ? '$studentName ($nis)' : studentName;

        final extraMap = r['extracurriculars'] as Map<String, dynamic>?;
        final ekskulName = extraMap?['name']?.toString() ?? 'Ekstrakurikuler SMKN 8';

        // Tentukan status tampilan
        String statusLabel = 'Menunggu Admin';
        int step = 2;
        String stepText = 'Tahap 2 dari 3 • Verifikasi Kesiswaan';

        if (statusRaw == 'approved') {
          statusLabel = 'Disetujui KS';
          step = 3;
          stepText = 'Tahap 3 dari 3 • Resmi Diterbitkan & Disetujui KS';
        } else if (statusRaw == 'rejected') {
          statusLabel = 'Ditolak';
          step = 0;
          stepText = 'Ditolak oleh Admin Kesiswaan';
        }

        // Format nomor surat resmi
        final shortId = id.length >= 4 ? id.substring(0, 4).toUpperCase() : '${800 + i}';
        final noSurat = '421.5/$shortId/DISP/SMKN8/${DateTime.now().year}';

        // Format durasi
        String duration = '1 Hari';
        if (start.isNotEmpty) {
          final dtStart = DateTime.tryParse(start);
          if (dtStart != null) {
            final startFmt = '${dtStart.day}/${dtStart.month}/${dtStart.year}';
            if (end.isNotEmpty && end != start) {
              final dtEnd = DateTime.tryParse(end);
              if (dtEnd != null) {
                final endFmt = '${dtEnd.day}/${dtEnd.month}/${dtEnd.year}';
                duration = '$startFmt s.d $endFmt';
              } else {
                duration = startFmt;
              }
            } else {
              duration = '$startFmt (1 Hari)';
            }
          }
        }

        mapped.add({
          'id': id,
          'noSurat': noSurat,
          'title': reason,
          'delegasi': delegasi,
          'ekskul': ekskulName,
          'event': 'Kegiatan Resmi Ekstrakurikuler',
          'duration': duration,
          'status': statusLabel,
          'step': step,
          'stepText': stepText,
          'attachment_url': r['attachment_url'],
          'raw': r,
        });
      }

      if (mounted) {
        setState(() {
          _letters = mapped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredLetters {
    return _letters.where((item) {
      final status = item['status'] as String;

      if (_selectedChip == 1 && status != 'Menunggu Admin') return false;
      if (_selectedChip == 2 && status != 'Disetujui KS') return false;
      if (_selectedChip == 3 && status != 'Ditolak') return false;

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final noSurat = (item['noSurat'] as String).toLowerCase();
        final title = (item['title'] as String).toLowerCase();
        final delegasi = (item['delegasi'] as String).toLowerCase();
        final ekskul = (item['ekskul'] as String).toLowerCase();
        final event = (item['event'] as String).toLowerCase();
        if (!noSurat.contains(q) &&
            !title.contains(q) &&
            !delegasi.contains(q) &&
            !ekskul.contains(q) &&
            !event.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _verify(Map<String, dynamic> item, bool approve) async {
    final id = item['id'].toString();
    final title = item['title'] as String;

    try {
      await _repo.reviewDispensation(id, approve: approve);

      setState(() {
        item['status'] = approve ? 'Disetujui KS' : 'Ditolak';
        item['step'] = approve ? 3 : 0;
        item['stepText'] = approve
            ? 'Tahap 3 dari 3 • Disetujui & Diterbitkan'
            : 'Ditolak oleh Admin Kesiswaan';
      });

      if (mounted) {
        toast(
          context,
          '✅ Surat "$title" ${approve ? "berhasil disetujui & diterbitkan" : "telah ditolak"}',
        );
      }
    } catch (e) {
      if (mounted) {
        toast(context, '❌ Gagal memproses keputusan dispensasi: $e');
      }
    }
  }

  Future<void> _handleCreateDispensation() async {
    final extraOptions = _allExtras.isNotEmpty
        ? _allExtras.map((e) => e['name'].toString()).toList()
        : ['RPL Club & Cyber Security', 'Futsal SMKN 8', 'PMR Wira Unit 8', 'Paskibra SATYA BHAKTI', 'Robotik & IoT'];

    final res = await push<Map<String, String>>(
      context,
      AdminRecordFormScreen(
        title: 'Buat Surat Tugas / Dispensasi',
        description: 'Lengkapi informasi surat tugas atau dispensasi siswa ke Supabase.',
        fields: const [
          'Nama kegiatan / Alasan izin',
          'Ekstrakurikuler',
          'Tanggal mulai (YYYY-MM-DD)',
          'Tanggal selesai (YYYY-MM-DD)',
          'Keterangan / Delegasi siswa',
        ],
        fieldOptions: {
          'Ekstrakurikuler': extraOptions,
        },
        initialValues: {
          'Ekstrakurikuler': extraOptions.first,
          'Tanggal mulai (YYYY-MM-DD)': DateTime.now().toIso8601String().substring(0, 10),
          'Tanggal selesai (YYYY-MM-DD)': DateTime.now().add(const Duration(days: 1)).toIso8601String().substring(0, 10),
        },
      ),
    );

    if (res != null && res.isNotEmpty && mounted) {
      final reason = res['Nama kegiatan / Alasan izin']?.trim() ?? '';
      if (reason.isEmpty) {
        toast(context, 'Nama kegiatan / alasan izin wajib diisi.');
        return;
      }

      final ekskulName = res['Ekstrakurikuler']?.trim();
      final startStr = res['Tanggal mulai (YYYY-MM-DD)']?.trim();
      final endStr = res['Tanggal selesai (YYYY-MM-DD)']?.trim();

      DateTime? start;
      if (startStr != null && startStr.isNotEmpty) {
        start = DateTime.tryParse(startStr);
      }
      start ??= DateTime.now();

      DateTime? end;
      if (endStr != null && endStr.isNotEmpty) {
        end = DateTime.tryParse(endStr);
      }

      String? extraId;
      if (ekskulName != null && ekskulName.isNotEmpty && _allExtras.isNotEmpty) {
        final match = _allExtras.firstWhere(
          (e) => e['name']?.toString().toLowerCase() == ekskulName.toLowerCase(),
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          extraId = match['id']?.toString();
        }
      }

      try {
        await _repo.submitDispensation(
          extracurricularId: extraId,
          reason: reason,
          startDate: start,
          endDate: end,
        );

        if (mounted) {
          toast(context, '✅ Surat tugas / dispensasi berhasil dibuat di Supabase!');
          await _fetchDispensations();
        }
      } catch (e) {
        if (mounted) {
          toast(context, '❌ Gagal membuat dispensasi: $e');
        }
      }
    }
  }

  void _showDocumentPreview(Map<String, dynamic> item) {
    final noSurat = item['noSurat'] as String;
    final title = item['title'] as String;
    final delegasi = item['delegasi'] as String;
    final ekskul = item['ekskul'] as String;
    final duration = item['duration'] as String;
    final status = item['status'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const IconBox(Icons.description_outlined, bg: C.soft, fg: C.primary, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Berkas Surat Resmi', style: T.h2),
                  Text(noSurat, style: T.body.copyWith(fontWeight: FontWeight.w700)),
                ]),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
            ]),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: C.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'PEMERINTAH PROVINSI JAWA TIMUR\nDINAS PENDIDIKAN\nSMK NEGERI 8 MALANG',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, height: 1.3),
                    ),
                  ),
                  const Divider(thickness: 1.5, height: 20),
                  Text('Perihal: $title', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Delegasi Siswa: $delegasi', style: T.body),
                  Text('Ekstrakurikuler: $ekskul', style: T.body),
                  Text('Durasi Pelaksanaan: $duration', style: T.body),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Text('Status Pengesahan: ', style: T.body),
                    Pill(status, status == 'Disetujui KS' ? C.greenSoft : C.orangeSoft, status == 'Disetujui KS' ? C.green : C.orange),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Btn(
              'Salin Nomor Surat Resmi',
              icon: Icons.copy,
              expand: true,
              h: 48,
              onTap: () {
                Clipboard.setData(ClipboardData(text: noSurat));
                Navigator.pop(ctx);
                toast(context, 'Nomor surat $noSurat disalin ke clipboard');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCount = _letters.length;
    final pendingCount = _letters.where((l) => l['status'] == 'Menunggu Admin').length;
    final approvedCount = _letters.where((l) => l['status'] == 'Disetujui KS').length;
    final rejectedCount = _letters.where((l) => l['status'] == 'Ditolak').length;

    final filtered = _filteredLetters;

    return AdminScreen(
      back: 'Kembali ke Proposal & Surat',
      eyebrow: 'LAYANAN RESMI  •  T.A. 2024/2025',
      title: 'Dispensasi & Surat Tugas',
      subtitle: 'Penerbitan surat tugas resmi delegasi lomba dan izin dispensasi KBM siswa dari database Supabase.',
      trailing: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: C.primary),
        tooltip: 'Muat Ulang',
        onPressed: _loadData,
      ),
      children: [
        Row(children: [
          Expanded(child: StatBox('Total Surat', '$allCount', 'Tersimpan di DB', icon: Icons.folder_outlined)),
          const SizedBox(width: 8),
          Expanded(
            child: StatBox(
              'Perlu Verifikasi',
              '$pendingCount',
              'Menunggu Admin',
              icon: Icons.hourglass_top,
              valueColor: pendingCount > 0 ? C.orange : C.primary,
              subColor: pendingCount > 0 ? C.orange : C.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatBox(
              'Diterbitkan',
              '$approvedCount',
              'Disetujui KS',
              icon: Icons.check_circle_outline,
              valueColor: C.primary,
              subColor: C.primary,
            ),
          ),
        ]),
        const SizedBox(height: 14),

        Btn(
          '+ Buat Surat Tugas / Dispensasi Baru',
          icon: Icons.add_task,
          expand: true,
          h: 56,
          onTap: _handleCreateDispensation,
        ),
        const SizedBox(height: 14),

        SearchBox(
          'Cari nomor surat, siswa, atau kegiatan...',
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),

        Chips(
          [
            'Semua ($allCount)',
            'Menunggu Admin ($pendingCount)',
            'Disetujui KS ($approvedCount)',
            'Ditolak ($rejectedCount)',
          ],
          selectedIndex: _selectedChip,
          onChanged: (i) => setState(() => _selectedChip = i),
        ),

        if (_searchQuery.isNotEmpty || _selectedChip != 0) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Menampilkan ${filtered.length} dari $allCount surat dispensasi',
                    style: const TextStyle(fontSize: 13, color: C.muted, fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedChip = 0;
                    });
                  },
                  child: const Text('Reset Filter', style: TextStyle(fontSize: 13, color: C.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          SCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: C.red, size: 40),
                const SizedBox(height: 10),
                Text('Gagal Memuat Dispensasi', style: T.h2.copyWith(color: C.red)),
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: C.muted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Btn.soft('Coba Lagi', icon: Icons.refresh, onTap: _loadData),
              ],
            ),
          )
        else if (filtered.isEmpty)
          SCard(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              children: [
                const Icon(Icons.search_off, size: 48, color: C.muted),
                const SizedBox(height: 12),
                const Text('Tidak Ada Surat Ditemukan', style: T.h2),
                const SizedBox(height: 4),
                Text(
                  _letters.isEmpty
                      ? 'Belum ada pengajuan surat tugas atau dispensasi yang tersimpan di Supabase.'
                      : 'Coba gunakan kata kunci nomor surat, siswa, atau pilih filter status lain.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: C.muted),
                ),
                const SizedBox(height: 14),
                if (_letters.isNotEmpty)
                  Btn.soft(
                    'Reset Pencarian & Filter',
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _selectedChip = 0;
                      });
                    },
                  )
                else
                  Btn(
                    'Buat Dispensasi Pertama',
                    icon: Icons.add,
                    onTap: _handleCreateDispensation,
                  ),
              ],
            ),
          )
        else
          for (final item in filtered) _card(item),
      ],
    );
  }

  Widget _card(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final isPending = status == 'Menunggu Admin';
    final isApproved = status == 'Disetujui KS';
    final noSurat = item['noSurat'] as String;
    final title = item['title'] as String;
    final delegasi = item['delegasi'] as String;
    final ekskul = item['ekskul'] as String;
    final event = item['event'] as String;
    final duration = item['duration'] as String;
    final stepText = item['stepText'] as String;

    return SCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Pill('SURAT TUGAS RESMI', C.amberSoft, C.amber),
          const SizedBox(width: 8),
          Flexible(child: Text('• $noSurat', style: T.body.copyWith(fontSize: 12))),
          const Spacer(),
          Pill(
            status,
            isPending
                ? C.orangeSoft
                : isApproved
                    ? C.soft
                    : C.redSoft,
            isPending
                ? C.orange
                : isApproved
                    ? C.primary
                    : C.red,
            dot: true,
          ),
        ]),
        const SizedBox(height: 8),
        Text(title, style: T.h2.copyWith(fontSize: 16)),
        const SizedBox(height: 10),
        Panel(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            KV(Icons.groups_outlined, 'Delegasi Siswa:', delegasi),
            KV(Icons.emoji_events_outlined, 'Ekskul / Event:', '$ekskul • $event'),
            KV(Icons.calendar_month_outlined, 'Durasi Izin:', duration, valueColor: C.primary),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          const Expanded(child: Text('Alur Persetujuan & Tanda Tangan:', style: T.body)),
          Text(
            stepText,
            style: TextStyle(
              color: isPending ? C.orange : isApproved ? C.primary : C.red,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Container(height: 6, decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(width: 6),
          Expanded(child: Container(height: 6, decoration: BoxDecoration(color: isPending ? C.orange : isApproved ? C.primary : C.red, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(width: 6),
          Expanded(child: Container(height: 6, decoration: BoxDecoration(color: isApproved ? C.primary : const Color(0xFFE5E9F5), borderRadius: BorderRadius.circular(4)))),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          Text('✓ Pembina OK', style: TextStyle(color: C.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          Text('⏱ Verif Admin', style: TextStyle(color: C.orange, fontSize: 11, fontWeight: FontWeight.w700)),
          Text('✍ TTD Kepala Sekolah', style: TextStyle(color: C.muted, fontSize: 11)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          if (isPending) ...[
            Expanded(
              child: Btn(
                'Verifikasi & Setujui',
                icon: Icons.check_circle_outline,
                expand: true,
                h: 46,
                onTap: () => _verify(item, true),
              ),
            ),
            const SizedBox(width: 8),
            Btn.danger(
              'Tolak',
              icon: Icons.close,
              h: 46,
              onTap: () => _verify(item, false),
            ),
            const SizedBox(width: 8),
          ],
          Btn.gray(
            isPending ? '' : 'Lihat Berkas Resmi',
            icon: Icons.visibility_outlined,
            expand: !isPending,
            h: 46,
            onTap: () => _showDocumentPreview(item),
          ),
        ]),
      ]),
    );
  }
}
