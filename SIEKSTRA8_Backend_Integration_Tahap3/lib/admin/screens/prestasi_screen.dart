import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/backend.dart';
import '../../data/siekstra_repository.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';
import 'record_form_screen.dart';

class PrestasiScreen extends StatefulWidget {
  const PrestasiScreen({super.key});

  @override
  State<PrestasiScreen> createState() => _PrestasiScreenState();
}

class _PrestasiScreenState extends State<PrestasiScreen> {
  final SiekstraRepository _repo = SiekstraRepository();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  int _selectedChip = 0; // 0: Semua, 1: Verifikasi, 2: Kota Malang, 3: Jawa Timur, 4: Nasional

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _prestasiList = [];
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

      await _fetchPrestasi();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchPrestasi() async {
    try {
      final rows = await _repo.getAchievements();
      final List<Map<String, dynamic>> mapped = [];

      for (final r in rows) {
        final id = r['id']?.toString() ?? '';
        final title = (r['title'] ?? 'Prestasi Tanpa Judul').toString().trim();
        final award = (r['award'] ?? 'Penghargaan').toString().trim();
        final comp = (r['competition_name'] ?? '').toString().trim();
        final desc = (r['description'] ?? '').toString().trim();
        final date = (r['achievement_date'] ?? '').toString().trim();
        final extraMap = r['extracurriculars'] as Map<String, dynamic>?;
        final ekskulName = extraMap?['name']?.toString() ?? 'Ekstrakurikuler';

        // Deteksi tingkat kejuaraan
        final combined = '$title $comp $desc'.toLowerCase();
        String tingkat = 'Kota Malang';
        if (combined.contains('nasional') || combined.contains('indonesia')) {
          tingkat = 'Nasional';
        } else if (combined.contains('jawa timur') ||
            combined.contains('jatim') ||
            combined.contains('provinsi')) {
          tingkat = 'Jawa Timur';
        } else if (combined.contains('kota') || combined.contains('malang')) {
          tingkat = 'Kota Malang';
        }

        // Cek status verifikasi SKPI
        final imgUrl = r['image_url']?.toString() ?? '';
        final isVerified = imgUrl == 'verified' ||
            award.toLowerCase().contains('terverifikasi') ||
            desc.contains('[SKPI Terverifikasi]');

        final status = isVerified ? 'Terverifikasi' : 'Perlu Verifikasi';

        String dateFormatted = date;
        if (date.isNotEmpty) {
          final dt = DateTime.tryParse(date);
          if (dt != null) {
            dateFormatted = '${dt.day}/${dt.month}/${dt.year}';
          }
        } else {
          dateFormatted = 'Terkini';
        }

        final datePlace = comp.isNotEmpty ? '$dateFormatted • $comp' : dateFormatted;

        mapped.add({
          'id': id,
          'title': title,
          'sub': award.isNotEmpty ? award : 'Piagam / Medali Resmi',
          'ekskul': ekskulName,
          'ekskulTag': ekskulName.toUpperCase(),
          'tingkat': tingkat,
          'tingkatTag': 'Tk. $tingkat',
          'status': status,
          'isVerified': isVerified,
          'delegasi': desc.isNotEmpty ? desc.replaceAll('[SKPI Terverifikasi]', '').trim() : 'Delegasi Siswa SMKN 8',
          'pembina': 'Pembina $ekskulName',
          'datePlace': datePlace,
          'icon': isVerified ? Icons.emoji_events_outlined : Icons.military_tech_outlined,
          'iconBg': isVerified ? C.amberSoft : C.orangeSoft,
          'iconFg': isVerified ? C.amber : C.orange,
          'raw': r,
        });
      }

      if (mounted) {
        setState(() {
          _prestasiList = mapped;
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

  List<Map<String, dynamic>> get _filteredPrestasi {
    return _prestasiList.where((item) {
      final isVerified = item['isVerified'] as bool;
      final tingkat = item['tingkat'] as String;

      // Filter chips: 0: Semua, 1: Verifikasi, 2: Kota Malang, 3: Jawa Timur, 4: Nasional
      if (_selectedChip == 1 && isVerified) return false;
      if (_selectedChip == 2 && tingkat != 'Kota Malang') return false;
      if (_selectedChip == 3 && tingkat != 'Jawa Timur') return false;
      if (_selectedChip == 4 && tingkat != 'Nasional') return false;

      // Search real-time
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final title = (item['title'] as String).toLowerCase();
        final ekskul = (item['ekskul'] as String).toLowerCase();
        final delegasi = (item['delegasi'] as String).toLowerCase();
        final pembina = (item['pembina'] as String).toLowerCase();
        final tingkatLower = tingkat.toLowerCase();

        if (!title.contains(q) &&
            !ekskul.contains(q) &&
            !delegasi.contains(q) &&
            !pembina.contains(q) &&
            !tingkatLower.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _verifyPrestasi(Map<String, dynamic> item) async {
    final id = item['id'].toString();
    try {
      await _repo.updateAchievement(id, {
        'image_url': 'verified',
        'description': '${item['delegasi']} [SKPI Terverifikasi]',
      });

      setState(() {
        item['status'] = 'Terverifikasi';
        item['isVerified'] = true;
        item['iconBg'] = C.amberSoft;
        item['iconFg'] = C.amber;
      });

      if (mounted) {
        toast(context, '✅ Prestasi "${item['title']}" berhasil diverifikasi dan masuk SKPI siswa');
      }
    } catch (e) {
      if (mounted) {
        toast(context, '❌ Gagal memverifikasi: $e');
      }
    }
  }

  Future<void> _handleCreatePrestasi() async {
    final extraOptions = _allExtras.isNotEmpty
        ? _allExtras.map((e) => e['name'].toString()).toList()
        : ['PMR Wira Unit 8', 'RPL Club & Cyber Security', 'Futsal SMKN 8', 'Paskibra SATYA BHAKTI', 'Robotik & IoT'];

    final res = await push<Map<String, String>>(
      context,
      AdminRecordFormScreen(
        title: 'Tambah Prestasi Baru',
        description: 'Masukkan informasi prestasi dan capaian siswa ke database Supabase.',
        fields: const [
          'Nama prestasi / kejuaraan',
          'Peringkat / Penghargaan (cth: Juara 1)',
          'Ekstrakurikuler',
          'Tingkat kejuaraan',
          'Nama siswa / tim delegasi',
          'Tanggal dan tempat pelaksanaan',
        ],
        fieldOptions: {
          'Tingkat kejuaraan': const ['Kota Malang', 'Jawa Timur', 'Nasional'],
          'Ekstrakurikuler': extraOptions,
        },
        initialValues: {
          'Tingkat kejuaraan': 'Kota Malang',
          'Ekstrakurikuler': extraOptions.first,
          'Tanggal dan tempat pelaksanaan': 'Malang',
        },
      ),
    );

    if (res != null && res.isNotEmpty && mounted) {
      final title = res['Nama prestasi / kejuaraan']?.trim() ?? '';
      if (title.isEmpty) {
        toast(context, 'Nama prestasi wajib diisi.');
        return;
      }

      final award = res['Peringkat / Penghargaan (cth: Juara 1)']?.trim();
      final ekskulName = res['Ekstrakurikuler']?.trim();
      final tingkat = res['Tingkat kejuaraan']?.trim() ?? 'Kota Malang';
      final delegasi = res['Nama siswa / tim delegasi']?.trim();
      final datePlace = res['Tanggal dan tempat pelaksanaan']?.trim();

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
        await _repo.createAchievement(
          extracurricularId: extraId,
          title: title,
          competitionName: datePlace != null && datePlace.isNotEmpty
              ? '$datePlace ($tingkat)'
              : tingkat,
          award: award ?? 'Juara',
          date: DateTime.now(),
          description: delegasi,
        );

        if (mounted) {
          toast(context, '✅ Prestasi baru berhasil disimpan ke Supabase!');
          await _fetchPrestasi();
        }
      } catch (e) {
        if (mounted) {
          toast(context, '❌ Gagal menyimpan prestasi ke Supabase: $e');
        }
      }
    }
  }

  Future<void> _handleEditPrestasi(Map<String, dynamic> item) async {
    final title = item['title'] as String;
    final delegasi = item['delegasi'] as String;
    final datePlace = item['datePlace'] as String;
    final sub = item['sub'] as String;
    final id = item['id'].toString();

    final res = await push<Map<String, String>>(
      context,
      AdminRecordFormScreen(
        title: 'Edit Prestasi',
        description: 'Perbarui data kejuaraan siswa di Supabase.',
        fields: const [
          'Nama prestasi',
          'Nama siswa / tim',
          'Ekstrakurikuler',
          'Tingkat kejuaraan',
          'Tanggal / Tempat',
          'Keterangan',
        ],
        fieldOptions: {
          'Tingkat kejuaraan': const ['Kota Malang', 'Jawa Timur', 'Nasional'],
          if (_allExtras.isNotEmpty)
            'Ekstrakurikuler': _allExtras.map((e) => e['name'].toString()).toList(),
        },
        initialValues: {
          'Nama prestasi': title,
          'Nama siswa / tim': delegasi,
          'Ekstrakurikuler': item['ekskul'] as String,
          'Tingkat kejuaraan': item['tingkat'] as String,
          'Tanggal / Tempat': datePlace,
          'Keterangan': sub,
        },
        submitLabel: 'Simpan Perubahan',
      ),
    );

    if (res != null && res.isNotEmpty && mounted) {
      try {
        await _repo.updateAchievement(id, {
          'title': res['Nama prestasi'] ?? title,
          'description': res['Nama siswa / tim'] ?? delegasi,
          'competition_name': res['Tanggal / Tempat'] ?? datePlace,
          'award': res['Keterangan'] ?? sub,
        });

        if (mounted) {
          toast(context, '✅ Data prestasi berhasil diperbarui di Supabase!');
          await _fetchPrestasi();
        }
      } catch (e) {
        if (mounted) toast(context, '❌ Gagal memperbarui: $e');
      }
    }
  }

  void _exportPrestasi() {
    final list = _filteredPrestasi.isNotEmpty ? _filteredPrestasi : _prestasiList;
    if (list.isEmpty) {
      toast(context, 'Belum ada data prestasi untuk diekspor.');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('REKAPITULASI PRESTASI & KEJUARAAN SISWA SMKN 8 MALANG');
    buffer.writeln('Tanggal Unduh: ${DateTime.now().toLocal().toString().substring(0, 16)}');
    buffer.writeln('Total Capaian: ${list.length} Prestasi');
    buffer.writeln('');
    buffer.writeln('No,Nama Prestasi,Penghargaan,Ekstrakurikuler,Tingkat,Delegasi Siswa,Status SKPI');

    for (var i = 0; i < list.length; i++) {
      final p = list[i];
      final t = p['title'].replaceAll('"', '""');
      final s = p['sub'].replaceAll('"', '""');
      final eks = p['ekskul'].replaceAll('"', '""');
      final del = p['delegasi'].replaceAll('"', '""');
      buffer.writeln('${i + 1},"$t","$s","$eks","${p['tingkat']}","$del","${p['status']}"');
    }

    final csv = buffer.toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(children: [
                const IconBox(Icons.download_done_rounded, bg: C.amberSoft, fg: C.amber, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Ekspor Rekap Prestasi', style: T.h2),
                    Text('${list.length} prestasi terdata dari Supabase', style: T.body),
                  ]),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ]),
              const Divider(height: 24),
              const Text('Format CSV (Siap Impor ke Excel):', style: T.label),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: C.field,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: C.line),
                ),
                child: SelectableText(
                  csv,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              Btn(
                'Salin Data CSV ke Clipboard',
                icon: Icons.copy_rounded,
                expand: true,
                h: 50,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: csv));
                  Navigator.pop(ctx);
                  toast(context, '✅ Data rekap prestasi format CSV disalin ke clipboard!');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCount = _prestasiList.length;
    final needVerifyCount = _prestasiList.where((p) => !p['isVerified']).length;
    final malangCount = _prestasiList.where((p) => p['tingkat'] == 'Kota Malang').length;
    final jatimCount = _prestasiList.where((p) => p['tingkat'] == 'Jawa Timur').length;
    final nasionalCount = _prestasiList.where((p) => p['tingkat'] == 'Nasional').length;

    final filtered = _filteredPrestasi;

    return AdminScreen(
      back: 'Kembali ke Beranda & Sistem',
      title: 'Bank Prestasi & Kejuaraan',
      subtitle: 'Pusat data capaian lomba, kejuaraan, dan rekam jejak prestasi siswa SMKN 8 Malang.',
      trailing: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: C.primary),
        tooltip: 'Muat Ulang',
        onPressed: _loadData,
      ),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFF0F2F8), borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Row(children: const [
              Expanded(child: Text('REKAPITULASI CAPAIAN PRESTASI DARI DATABASE', style: T.label)),
              Pill('Online Supabase', C.greenSoft, C.green),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: StatBox('🏆 Total', '$allCount', 'Juara terdata')),
              const SizedBox(width: 8),
              Expanded(child: StatBox('🏅 Prov/Nas', '${jatimCount + nasionalCount}', 'Tingkat tinggi', valueColor: C.amber)),
              const SizedBox(width: 8),
              Expanded(
                child: StatBox(
                  '📋 Review',
                  '$needVerifyCount ●',
                  'Perlu verifikasi',
                  valueColor: needVerifyCount > 0 ? C.orange : C.primary,
                  subColor: needVerifyCount > 0 ? C.orange : C.primary,
                ),
              ),
            ]),
          ]),
        ),

        Row(children: [
          Btn(
            '+ Tambah Prestasi',
            icon: Icons.add_circle_outline,
            h: 54,
            onTap: _handleCreatePrestasi,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Btn.gray(
              'Unduh Rekap',
              icon: Icons.download_rounded,
              expand: true,
              h: 54,
              onTap: _exportPrestasi,
            ),
          ),
        ]),
        const SizedBox(height: 14),

        SearchBox(
          'Cari nama lomba, ekskul, atau siswa juara...',
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),

        Chips(
          [
            'Semua ($allCount)',
            'Verifikasi ($needVerifyCount)',
            'Kota Malang ($malangCount)',
            'Jawa Timur ($jatimCount)',
            'Nasional ($nasionalCount)',
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
                    'Menampilkan ${filtered.length} dari $allCount prestasi',
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
                Text('Gagal Memuat Prestasi', style: T.h2.copyWith(color: C.red)),
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
                const Text('Tidak Ada Prestasi Ditemukan', style: T.h2),
                const SizedBox(height: 4),
                Text(
                  _prestasiList.isEmpty
                      ? 'Belum ada data prestasi siswa yang tersimpan di Supabase.'
                      : 'Coba gunakan kata kunci pencarian nama lomba, siswa, atau ganti filter tingkat.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: C.muted),
                ),
                const SizedBox(height: 14),
                if (_prestasiList.isNotEmpty)
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
                    'Tambah Prestasi Pertama',
                    icon: Icons.add,
                    onTap: _handleCreatePrestasi,
                  ),
              ],
            ),
          )
        else
          for (final item in filtered) _buildCard(item),

        const InfoCard(
          Icons.menu_book_outlined,
          'Integrasi Otomatis Buku SKPI',
          'Setiap sertifikat yang telah disetujui Admin Kesiswaan secara otomatis diakumulasikan ke Surat Keterangan Pendamping Ijazah (SKPI) siswa bersangkutan.',
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final title = item['title'] as String;
    final sub = item['sub'] as String;
    final ekskulTag = item['ekskulTag'] as String;
    final tingkatTag = item['tingkatTag'] as String;
    final isVerified = item['isVerified'] as bool;
    final status = item['status'] as String;
    final delegasi = item['delegasi'] as String;
    final pembina = item['pembina'] as String;
    final datePlace = item['datePlace'] as String;
    final icon = item['icon'] as IconData;
    final iconBg = item['iconBg'] as Color;
    final iconFg = item['iconFg'] as Color;

    return SCard(
      border: isVerified ? null : C.orange,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(ekskulTag, C.amberSoft, C.amber),
          const SizedBox(width: 6),
          Pill(tingkatTag, C.soft, C.primary),
          const Spacer(),
          Pill(
            status,
            isVerified ? C.greenSoft : C.orangeSoft,
            isVerified ? C.green : C.orange,
            dot: !isVerified,
            icon: isVerified ? Icons.verified_outlined : null,
          ),
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(icon, bg: iconBg, fg: iconFg, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: T.h2.copyWith(fontSize: 15.5)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(color: C.amber, fontWeight: FontWeight.w700, fontSize: 13.5)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Panel(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('👥 Delegasi: $delegasi', style: T.body.copyWith(fontSize: 13)),
            const SizedBox(height: 5),
            Text('🪪 Pembina: $pembina', style: T.body.copyWith(fontSize: 13)),
            const SizedBox(height: 5),
            Text('📍 $datePlace', style: T.body.copyWith(fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 10),
        if (!isVerified) ...[
          Btn(
            'Verifikasi & Terbitkan SKPI',
            icon: Icons.how_to_reg_outlined,
            expand: true,
            h: 48,
            onTap: () => _verifyPrestasi(item),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: Btn.gray(
                'Cek Lampiran',
                icon: Icons.visibility_outlined,
                expand: true,
                h: 44,
                onTap: () => toast(context, 'Membuka piagam lampiran $title'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Btn.warn(
                'Minta Revisi',
                icon: Icons.cancel_outlined,
                expand: true,
                h: 44,
                onTap: () => toast(context, 'Permintaan revisi dikirim ke pembina'),
              ),
            ),
          ]),
        ] else ...[
          Row(children: [
            Expanded(
              child: Btn.gray(
                'Detail',
                icon: Icons.visibility_outlined,
                h: 44,
                onTap: () => push(
                  context,
                  AdminDetailScreen(
                    category: 'Bank Prestasi',
                    name: title,
                    subtitle: sub,
                    status: 'Terverifikasi',
                    icon: icon,
                    fields: [
                      AdminDetailField('Tingkat', tingkatTag, Icons.emoji_events_outlined),
                      AdminDetailField('Delegasi', delegasi, Icons.groups_outlined),
                      AdminDetailField('Pembina', pembina, Icons.school_outlined),
                      AdminDetailField('Waktu / Tempat', datePlace, Icons.location_on_outlined),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Btn.gray(
                'Edit',
                icon: Icons.edit_outlined,
                h: 44,
                onTap: () => _handleEditPrestasi(item),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Btn.soft(
                'Cetak SKPI',
                icon: Icons.print_outlined,
                h: 44,
                onTap: () => toast(context, 'Mencetak dokumen SKPI untuk $delegasi'),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}
