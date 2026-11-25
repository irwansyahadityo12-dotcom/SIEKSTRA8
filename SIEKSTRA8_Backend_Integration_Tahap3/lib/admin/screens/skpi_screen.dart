import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AdminSkpiScreen extends StatefulWidget {
  const AdminSkpiScreen({super.key});

  @override
  State<AdminSkpiScreen> createState() => _AdminSkpiScreenState();
}

class _AdminSkpiScreenState extends State<AdminSkpiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: Semua, 1: Siap Terbit, 2: Terverifikasi, 3: Menunggu

  final List<Map<String, dynamic>> _skpiList = [
    {
      'nis': '10842',
      'name': 'Muhammad Rizky Pratama',
      'class': 'XII RPL 1',
      'ekskul': 'RPL Club & Robotik',
      'points': 140,
      'status': 'Siap Terbit',
      'achievements': 'Juara 1 LKS Cyber Security Jatim 2024',
      'roleInEkskul': 'Ketua Tim Kompetisi',
    },
    {
      'nis': '10855',
      'name': 'Siti Nurhaliza',
      'class': 'XII DKV 2',
      'ekskul': 'PMR Wira & Karawitan',
      'points': 125,
      'status': 'Terverifikasi',
      'achievements': 'Anggota Madya Berprestasi PMR Jatim',
      'roleInEkskul': 'Sekretaris PMR Wira Unit 8',
    },
    {
      'nis': '10870',
      'name': 'Dimas Arya Kusuma',
      'class': 'XII TKJ 2',
      'ekskul': 'Futsal SMKN 8',
      'points': 95,
      'status': 'Menunggu Validasi',
      'achievements': 'Pemain Inti Walikota Cup 2024',
      'roleInEkskul': 'Kapten Tim Futsal',
    },
    {
      'nis': '10892',
      'name': 'Nabila Putri Syahrani',
      'class': 'XII RPL 2',
      'ekskul': 'Paskibra SMKN 8',
      'points': 115,
      'status': 'Siap Terbit',
      'achievements': 'Danton Terbaik LKBB Se-Jawa Timur',
      'roleInEkskul': 'Danton Utama',
    },
    {
      'nis': '10911',
      'name': 'Kevin Sanjaya Pratama',
      'class': 'XII TKJ 1',
      'ekskul': 'Bulutangkis Club',
      'points': 88,
      'status': 'Menunggu Validasi',
      'achievements': 'Semi Finalis O2SN Kota Malang',
      'roleInEkskul': 'Anggota Aktif',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredList {
    return _skpiList.where((item) {
      final status = item['status'] as String;
      if (_selectedFilter == 1 && status != 'Siap Terbit') return false;
      if (_selectedFilter == 2 && status != 'Terverifikasi') return false;
      if (_selectedFilter == 3 && status != 'Menunggu Validasi') return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name = (item['name'] as String).toLowerCase();
        final nis = (item['nis'] as String).toLowerCase();
        final cls = (item['class'] as String).toLowerCase();
        final ekskul = (item['ekskul'] as String).toLowerCase();
        if (!name.contains(q) && !nis.contains(q) && !cls.contains(q) && !ekskul.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _verifySkpi(Map<String, dynamic> item) {
    setState(() {
      item['status'] = 'Terverifikasi';
    });
    toast(context, 'SKPI siswa ${item['name']} berhasil diverifikasi kesiswaan');
  }

  void _publishSkpi(Map<String, dynamic> item) {
    setState(() {
      item['status'] = 'Terverifikasi';
    });
    toast(context, 'Surat Keterangan Pendamping Ijazah (SKPI) resmi diterbitkan.');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;
    final readyCount = _skpiList.where((s) => s['status'] == 'Siap Terbit').length;
    final verifiedCount = _skpiList.where((s) => s['status'] == 'Terverifikasi').length;
    final waitingCount = _skpiList.where((s) => s['status'] == 'Menunggu Validasi').length;

    return AdminScreen(
      back: 'Kembali ke Sistem & Akun',
      title: 'Sertifikat SKPI Ekskul',
      subtitle: 'Penerbitan Surat Keterangan Pendamping Ijazah (SKPI) bidang ekstrakurikuler & prestasi Kelas XII SMKN 8 Malang.',
      children: [
        // Ringkasan Statistik
        Row(
          children: [
            Expanded(child: StatBox('Total Siswa XII', '${_skpiList.length}', 'Calon Lulusan', icon: Icons.school_outlined)),
            const SizedBox(width: 8),
            Expanded(child: StatBox('Siap Terbit', '$readyCount', 'Lengkap Verifikasi', icon: Icons.verified_outlined, valueColor: C.primary, subColor: C.primary)),
            const SizedBox(width: 8),
            Expanded(child: StatBox('Menunggu', '$waitingCount', 'Validasi Pembina', icon: Icons.hourglass_top, valueColor: C.amber, subColor: C.amber)),
          ],
        ),

        const SizedBox(height: 14),

        // Pencarian
        SearchBox(
          'Cari nama siswa, NIS, kelas, atau ekskul...',
          controller: _searchController,
          onChanged: (q) => setState(() => _searchQuery = q),
          onClear: () => setState(() => _searchQuery = ''),
        ),

        // Filter Chips
        Chips(
          [
            'Semua (${_skpiList.length})',
            'Siap Terbit ($readyCount)',
            'Terverifikasi ($verifiedCount)',
            'Menunggu ($waitingCount)',
          ],
          selectedIndex: _selectedFilter,
          onChanged: (idx) => setState(() => _selectedFilter = idx),
        ),

        // List Siswa SKPI
        if (filtered.isEmpty)
          SCard(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            child: Column(
              children: const [
                Icon(Icons.search_off, size: 48, color: C.muted),
                SizedBox(height: 10),
                Text('Data SKPI Tidak Ditemukan', style: T.h2),
                SizedBox(height: 4),
                Text('Tidak ada data siswa yang cocok dengan filter atau kata kunci.', style: T.body, textAlign: TextAlign.center),
              ],
            ),
          )
        else
          for (final item in filtered) ...[
            _buildSkpiCard(item),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _buildSkpiCard(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final isReady = status == 'Siap Terbit';
    final isVerified = status == 'Terverifikasi';

    return SCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(item['name'].toString().substring(0, 2).toUpperCase(), size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: C.ink)),
                    const SizedBox(height: 2),
                    Text('NIS: ${item['nis']} • ${item['class']}', style: T.body.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              if (isVerified)
                const Pill('Terverifikasi', C.greenSoft, C.green, icon: Icons.check_circle_outline)
              else if (isReady)
                const Pill('Siap Terbit', C.soft, C.primary, icon: Icons.stars_outlined)
              else
                const Pill('Menunggu Validasi', C.amberSoft, C.amber, dot: true),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.field,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups_outlined, size: 16, color: C.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(item['ekskul'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: C.ink))),
                    Text('${item['points']} Poin SKPI', style: const TextStyle(color: C.primary, fontWeight: FontWeight.w800, fontSize: 12.5)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.military_tech_outlined, size: 16, color: C.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item['achievements']} (${item['roleInEkskul']})',
                        style: T.body.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Btn.gray(
                'Lihat Draft SKPI',
                icon: Icons.description_outlined,
                h: 38,
                onTap: () => toast(context, 'Membuka pratinjau SKPI ${item['name']}'),
              ),
              const Spacer(),
              if (!isVerified)
                Btn(
                  'Validasi & Terbitkan',
                  icon: Icons.check,
                  h: 38,
                  onTap: () => _publishSkpi(item),
                )
              else
                Btn.soft(
                  'Cetak PDF',
                  icon: Icons.print_outlined,
                  h: 38,
                  onTap: () => toast(context, 'Menyiapkan berkas cetak SKPI PDF...'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

