import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'proposal_detail_screen.dart';
import 'dispensasi_screen.dart';

class ProposalListScreen extends StatefulWidget {
  const ProposalListScreen({super.key});

  @override
  State<ProposalListScreen> createState() => _ProposalListScreenState();
}

class _ProposalListScreenState extends State<ProposalListScreen> {
  final _repository = SiekstraRepository();
  int _selectedFilterChip = 0; // 0: Semua, 1: Menunggu Kesiswaan, 2: Disetujui, 3: Revisi
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  List<Map<String, dynamic>> _proposals = [];

  static const List<Map<String, dynamic>> _defaultProposals = [
    {
      'id': '#PROP-8-092',
      'rawId': '092',
      'title': 'Keikutsertaan Lomba Kompetensi Siswa (LKS) Cyber Security Tingkat Jawa Timur',
      'ekskul': 'RPL Club & Cyber Sec',
      'total': 'Rp 4.500.000',
      'status': 'Menunggu Kesiswaan',
      'date': '20 Nov 2024',
      'location': 'POLINEMA Malang',
      'delegates': '6 Siswa',
      'submitter': 'Bpk. Ahmad Fauzi, S.Kom',
      'notes': 'Proposal baru masuk, membutuhkan verifikasi kelayakan anggaran kesiswaan.',
    },
    {
      'id': '#PROP-8-091',
      'rawId': '091',
      'title': 'Pengadaan Komponen Robotik & Sensor IoT Kontes Robot Indonesia (KRI)',
      'ekskul': 'Robotik Club SMKN 8',
      'total': 'Rp 7.850.000',
      'status': 'Menunggu Kesiswaan',
      'date': '19 Nov 2024',
      'location': 'Bengkel IoT SMKN 8',
      'delegates': '8 Siswa',
      'submitter': 'Ibu Ratna Dewi, M.T',
      'notes': 'Menunggu telaah rincian RAB komponen mikrokontroler dan sensor.',
    },
    {
      'id': '#PROP-8-088',
      'rawId': '088',
      'title': 'Lomba Futsal Walikota Cup Malang 2024 Antar SMA/SMK se-Jawa Timur',
      'ekskul': 'Futsal SMKN 8',
      'total': 'Rp 3.200.000',
      'status': 'Disetujui',
      'date': '15 Nov 2024',
      'location': 'GOR Ken Arok Malang',
      'delegates': '12 Siswa',
      'submitter': 'Dedi Wahyudi, S.Pd',
      'notes': 'Telah disetujui Kepala Sekolah & Waka Kesiswaan. Dana siap dicairkan.',
    },
    {
      'id': '#PROP-8-085',
      'rawId': '085',
      'title': 'Pentas Seni Budaya & Festival Tari Tradisional Pelajar Nusantara',
      'ekskul': 'Tari Tradisional & Karawitan',
      'total': 'Rp 5.100.000',
      'status': 'Disetujui',
      'date': '12 Nov 2024',
      'location': 'Gedung Kesenian Gajayana',
      'delegates': '10 Siswi',
      'submitter': 'Endang Sulastri, S.Sn',
      'notes': 'Disetujui. Berkas dispensasi dan jadwal gladi bersih telah diverifikasi.',
    },
    {
      'id': '#PROP-8-084',
      'rawId': '084',
      'title': 'Latihan Gabungan & Pelantikan Anggota Madya PMR Wira Tingkat Kota Malang',
      'ekskul': 'PMR Wira Unit 8',
      'total': 'Rp 3.800.000',
      'status': 'Disetujui',
      'date': '8 Nov 2024',
      'location': 'Bumi Perkemahan Coban Rondo',
      'delegates': '35 Siswa',
      'submitter': 'Drs. Hj. Meita Juwita',
      'notes': 'Disetujui penuh. Dilengkapi izin orang tua dan asuransi kegiatan.',
    },
    {
      'id': '#PROP-8-081',
      'rawId': '081',
      'title': 'Jumbara PMR & Temu Relawan Palang Merah Remaja Se-Jawa Timur',
      'ekskul': 'PMR Wira Unit 8',
      'total': 'Rp 6.750.000',
      'status': 'Revisi',
      'date': '2 Nov 2024',
      'location': 'Kwarda Jawa Timur',
      'delegates': '16 Siswa',
      'submitter': 'Drs. Hj. Meita Juwita',
      'notes': 'Catatan Kesiswaan: RAB konsumsi dan akomodasi perlu disesuaikan dengan pagu anggaran BOS.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    setState(() => _isLoading = true);
    try {
      final rows = await _repository.getProposals();
      if (mounted) {
        if (rows.isNotEmpty) {
          setState(() {
            _proposals = rows.map(_formatProposalItem).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _proposals = List.from(_defaultProposals);
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _proposals = List.from(_defaultProposals);
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _formatProposalItem(Map<String, dynamic> raw) {
    final idRaw = (raw['id'] ?? '').toString();
    final shortId = idRaw.length >= 8 ? idRaw.substring(0, 8).toUpperCase() : idRaw;
    final title = (raw['title'] ?? 'Proposal Kegiatan Ekstrakurikuler').toString();
    final extra = raw['extracurriculars'] is Map ? raw['extracurriculars'] as Map<String, dynamic> : <String, dynamic>{};
    final ekskul = (extra['name'] ?? 'Ekstrakurikuler').toString();

    final dbStatus = (raw['status'] ?? 'pending').toString().toLowerCase();
    String displayStatus;
    switch (dbStatus) {
      case 'approved':
        displayStatus = 'Disetujui';
        break;
      case 'forwarded':
        displayStatus = 'Diteruskan';
        break;
      case 'rejected':
        displayStatus = 'Revisi';
        break;
      default:
        displayStatus = 'Menunggu Kesiswaan';
    }

    final budgetNum = num.tryParse(raw['budget']?.toString() ?? '0') ?? 0;
    final total = 'Rp ${budgetNum.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    final eventDate = raw['event_date']?.toString();
    final createdAt = raw['created_at']?.toString();
    final dateStr = eventDate ?? (createdAt != null && createdAt.length >= 10 ? createdAt.substring(0, 10) : '20 Nov 2024');

    final profiles = raw['profiles'] is Map ? raw['profiles'] as Map<String, dynamic> : <String, dynamic>{};
    final submitter = (profiles['full_name'] ?? 'Pembina Ekstra').toString();

    return {
      'id': '#PROP-$shortId',
      'rawId': idRaw,
      'title': title,
      'ekskul': ekskul,
      'total': total,
      'budget': budgetNum,
      'status': displayStatus,
      'dbStatus': dbStatus,
      'date': dateStr,
      'location': raw['location'] ?? 'SMKN 8 Malang',
      'delegates': raw['delegates'] ?? 'Delegasi Ekstra',
      'notes': raw['description'] ?? '',
      'submitter': submitter,
      'raw': raw,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hitung jumlah item per kategori
  int get _countWaiting => _proposals.where((p) => p['status'] == 'Menunggu Kesiswaan' || p['status'] == 'Diteruskan').length;
  int get _countApproved => _proposals.where((p) => p['status'] == 'Disetujui').length;
  int get _countRevision => _proposals.where((p) => p['status'] == 'Revisi' || p['status'] == 'Ditolak').length;

  // Filter list proposal berdasarkan chip dan search query
  List<Map<String, dynamic>> get _filteredProposals {
    return _proposals.where((p) {
      final title = (p['title'] as String).toLowerCase();
      final id = (p['id'] as String).toLowerCase();
      final ekskul = (p['ekskul'] as String).toLowerCase();
      final status = p['status'] as String;

      // 1. Filter Chip
      bool matchChip = true;
      if (_selectedFilterChip == 1) {
        matchChip = status == 'Menunggu Kesiswaan' || status == 'Diteruskan';
      } else if (_selectedFilterChip == 2) {
        matchChip = status == 'Disetujui';
      } else if (_selectedFilterChip == 3) {
        matchChip = status == 'Revisi' || status == 'Ditolak';
      }

      // 2. Filter Search Query
      bool matchSearch = true;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        matchSearch = title.contains(q) || id.contains(q) || ekskul.contains(q);
      }

      return matchChip && matchSearch;
    }).toList();
  }

  Widget _buildStatusPill(String status) {
    switch (status) {
      case 'Menunggu Kesiswaan':
        return const Pill('Menunggu Kesiswaan', C.amberSoft, C.amber, dot: true);
      case 'Disetujui':
        return const Pill('Disetujui', C.greenSoft, C.green, dot: true);
      case 'Diteruskan':
        return const Pill('Diteruskan', C.soft, C.primary, dot: true);
      case 'Revisi':
      case 'Ditolak':
        return const Pill('Revisi', C.orangeSoft, C.orange, dot: true);
      default:
        return Pill(status, C.soft, C.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProposals;

    return AdminScreen(
      eyebrow: 'LAYANAN PROPOSAL & SURAT',
      title: 'Proposal & Surat',
      subtitle: 'Kelola pengajuan proposal kegiatan dan surat tugas ekstrakurikuler.',
      children: [
        // Tombol Navigasi Layanan Surat Tugas & Dispensasi
        Row(children: [
          Expanded(
            child: Btn(
              'Dispensasi & Surat Tugas',
              icon: Icons.mark_email_read_outlined,
              expand: true,
              h: 48,
              onTap: () => push(context, const DispensasiScreen()),
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // SearchBox yang Berfungsi Real-Time
        SearchBox(
          'Cari proposal atau ekstra...',
          filter: true,
          controller: _searchController,
          onChanged: (q) => setState(() => _searchQuery = q),
          onClear: () => setState(() => _searchQuery = ''),
          onFilterTap: () => toast(context, 'Gunakan chip filter status di bawah'),
        ),

        // Sliding Chips Filter Status (Interaktif & Dinamis)
        Chips(
          [
            'Semua (${_proposals.length})',
            'Menunggu Kesiswaan ($_countWaiting)',
            'Disetujui ($_countApproved)',
            'Revisi ($_countRevision)',
          ],
          selectedIndex: _selectedFilterChip,
          onChanged: (idx) => setState(() => _selectedFilterChip = idx),
        ),

        // Ringkasan Jumlah Hasil
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(
                'Menampilkan ${filtered.length} dari ${_proposals.length} proposal',
                style: T.body.copyWith(fontSize: 12),
              ),
              const Spacer(),
              if (_searchQuery.isNotEmpty || _selectedFilterChip != 0)
                InkWell(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedFilterChip = 0;
                    });
                  },
                  child: const Text(
                    'Reset Filter',
                    style: TextStyle(color: C.primary, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),

        // Indikator Loading atau Daftar Proposal
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filtered.isEmpty)
          SCard(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              children: [
                const Icon(Icons.description_outlined, size: 52, color: C.muted),
                const SizedBox(height: 12),
                const Text('Tidak ada proposal ditemukan', style: T.h2),
                const SizedBox(height: 4),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Tidak ada proposal yang sesuai dengan kata kunci "$_searchQuery".'
                      : 'Belum ada proposal dengan status tersebut.',
                  style: T.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Btn.gray(
                  'Tampilkan Semua Proposal',
                  h: 40,
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedFilterChip = 0;
                    });
                  },
                ),
              ],
            ),
          )
        else
          for (final p in filtered) ...[
            _buildProposalCard(context, p),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _buildProposalCard(BuildContext context, Map<String, dynamic> p) {
    final isRevisi = p['status'] == 'Revisi' || p['status'] == 'Ditolak';
    final isWaiting = p['status'] == 'Menunggu Kesiswaan' || p['status'] == 'Diteruskan';

    return SCard(
      onTap: () async {
        final refreshed = await push(context, ProposalDetailScreen(proposal: p));
        if (refreshed == true) {
          _loadProposals();
        }
      },
      border: isWaiting
          ? const Color(0xFFFDE68A)
          : isRevisi
              ? const Color(0xFFFBC4C4)
              : null,
      color: isWaiting
          ? const Color(0xFFFFFDF5)
          : isRevisi
              ? const Color(0xFFFFF8F8)
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID & Status
          Row(
            children: [
              Text(p['id'] as String, style: T.label.copyWith(fontSize: 12)),
              const SizedBox(width: 8),
              Text('• ${p['date']}', style: T.body.copyWith(fontSize: 12)),
              const Spacer(),
              _buildStatusPill(p['status'] as String),
            ],
          ),
          const SizedBox(height: 8),

          // Judul Proposal
          Text(
            p['title'] as String,
            style: T.title.copyWith(fontSize: 16, height: 1.3),
          ),
          const SizedBox(height: 10),

          // Baris Info: Ekskul, Lokasi, dan Anggaran
          Row(
            children: [
              Pill(p['ekskul'] as String, C.soft, C.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 14, color: C.muted),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        p['location'] as String,
                        style: T.body.copyWith(fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                p['total'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: C.ink,
                ),
              ),
            ],
          ),

          // Jika ada catatan revisi / info khusus
          if (isRevisi && p['notes'] != null && (p['notes'] as String).isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, size: 15, color: C.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      p['notes'] as String,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: C.line),
          const SizedBox(height: 8),

          // Footer: Delegasi & Tombol Aksi
          Row(
            children: [
              const Icon(Icons.groups_outlined, size: 16, color: C.muted),
              const SizedBox(width: 4),
              Text(
                'Delegasi: ${p['delegates']}',
                style: T.body.copyWith(fontSize: 12),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Detail & Validasi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: C.primary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: C.primary),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
