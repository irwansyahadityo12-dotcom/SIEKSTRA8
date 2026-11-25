import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/pembina_auth_store.dart';
import '../../app/backend.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';
import 'record_form_screen.dart';

class AkunPembinaScreen extends StatefulWidget {
  const AkunPembinaScreen({super.key});

  @override
  State<AkunPembinaScreen> createState() => _AkunPembinaScreenState();
}

class _AkunPembinaScreenState extends State<AkunPembinaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterChip = 0; // 0: Semua, 1: Aktif, 2: Nonaktif, 3: Pembina ASN, 4: Pelatih Luar
  String _sortBy = 'default'; // 'default', 'name_asc', 'name_desc', 'cabang'

  // Backed by PembinaAuthStore so added accounts can immediately login on Role Pembina
  List<Map<String, dynamic>> get _data => PembinaAuthStore.accounts;

  @override
  void initState() {
    super.initState();
    PembinaAuthStore.syncFromSupabase().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter dan Pencarian Data
  List<Map<String, dynamic>> get _filteredData {
    return _data.where((item) {
      final aktif = item['aktif'] as bool;
      final jenis = item['jenis'] as String;

      // 1. Filter Chips
      switch (_selectedFilterChip) {
        case 1: // Aktif (48)
          if (!aktif) return false;
          break;
        case 2: // Nonaktif (4)
          if (aktif) return false;
          break;
        case 3: // Pembina ASN (34)
          if (jenis != 'ASN Guru') return false;
          break;
        case 4: // Pelatih Luar (18)
          if (jenis != 'Pelatih Luar') return false;
          break;
        case 0: // Semua (52)
        default:
          break;
      }

      // 2. Searching Real-Time
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final nama = (item['nama'] as String).toLowerCase();
        final id = (item['id'] as String).toLowerCase();
        final username = (item['username'] as String).toLowerCase();
        final cabang = (item['cabang'] as String).toLowerCase();
        final jenisText = jenis.toLowerCase();

        final match = nama.contains(q) ||
            id.contains(q) ||
            username.contains(q) ||
            cabang.contains(q) ||
            jenisText.contains(q);

        if (!match) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'name_asc') {
          return (a['nama'] as String).compareTo(b['nama'] as String);
        } else if (_sortBy == 'name_desc') {
          return (b['nama'] as String).compareTo(a['nama'] as String);
        } else if (_sortBy == 'cabang') {
          return (a['cabang'] as String).compareTo(b['cabang'] as String);
        }
        return 0;
      });
  }

  // Tampilkan Modal Filter Kategori & Urutan
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, color: C.primary, size: 22),
                  const SizedBox(width: 8),
                  const Text('Filter & Urutkan Akun', style: T.h2),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: C.muted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),
              const Text('KATEGORI FILTER', style: T.label),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _modalFilterChip('Semua (52)', 0, setModalState),
                  _modalFilterChip('Aktif (48)', 1, setModalState),
                  _modalFilterChip('Nonaktif (4)', 2, setModalState),
                  _modalFilterChip('Pembina ASN (34)', 3, setModalState),
                  _modalFilterChip('Pelatih Luar (18)', 4, setModalState),
                ],
              ),
              const SizedBox(height: 18),
              const Text('URUTKAN BERDASARKAN', style: T.label),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _modalSortChip('Default', 'default', setModalState),
                  _modalSortChip('Nama (A-Z)', 'name_asc', setModalState),
                  _modalSortChip('Nama (Z-A)', 'name_desc', setModalState),
                  _modalSortChip('Cabang Ekstrakurikuler', 'cabang', setModalState),
                ],
              ),
              const SizedBox(height: 24),
              Btn(
                'Terapkan Filter',
                expand: true,
                h: 48,
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalFilterChip(String label, int index, StateSetter setModalState) {
    final isSel = _selectedFilterChip == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      selectedColor: C.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSel ? Colors.white : C.ink,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      onSelected: (val) {
        if (val) {
          setModalState(() => _selectedFilterChip = index);
          setState(() => _selectedFilterChip = index);
        }
      },
    );
  }

  Widget _modalSortChip(String label, String value, StateSetter setModalState) {
    final isSel = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      selectedColor: C.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSel ? Colors.white : C.ink,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      onSelected: (val) {
        if (val) {
          setModalState(() => _sortBy = value);
          setState(() => _sortBy = value);
        }
      },
    );
  }

  Future<void> _tambahAkunPembina() async {
    final res = await push<Map<String, String>>(
      context,
      const AdminRecordFormScreen(
        title: 'Tambah Akun Pembina',
        description:
            'Buat akun pembina baru. Akun ini langsung dapat digunakan login pada Role Pembina.',
        fields: [
          'Nama lengkap',
          'NIP / ID Mitra',
          'Email / Username Login',
          'Kata Sandi / Password',
          'Ekstrakurikuler',
          'Jenis pembina',
        ],
        initialValues: {
          'Kata Sandi / Password': '',
        },
        fieldOptions: {
          'Jenis pembina': ['ASN Guru', 'Pelatih Luar'],
        },
        submitLabel: 'Buat & Daftarkan Akun',
      ),
    );

    if (res != null && res.isNotEmpty && mounted) {
      final nama = res['Nama lengkap']?.trim().isNotEmpty == true
          ? res['Nama lengkap']!
          : 'Pembina Baru';
      final nip = res['NIP / ID Mitra']?.trim().isNotEmpty == true
          ? res['NIP / ID Mitra']!
          : 'NIP: -';
      final emailOrUser = res['Email / Username Login']?.trim().isNotEmpty == true
          ? res['Email / Username Login']!
          : 'pembina.baru@smkn8malang.sch.id';
      final pass = res['Kata Sandi / Password']?.trim().isNotEmpty == true
          ? res['Kata Sandi / Password']!
          : '';
      final cabang = res['Ekstrakurikuler']?.trim().isNotEmpty == true
          ? res['Ekstrakurikuler']!
          : 'Ekstrakurikuler';
      final jenis = res['Jenis pembina'] ?? 'ASN Guru';

      Map<String, dynamic> created;
      try {
        created = await PembinaAuthStore.addAccountWithSupabase(
          nama: nama,
          nip: nip,
          emailOrUsername: emailOrUser,
          password: pass,
          cabang: cabang,
          jenis: jenis,
        );
      } catch (e) {
        if (mounted) toast(context, 'Gagal membuat akun Pembina: $e');
        return;
      }

      setState(() {});

      final hasSupabase = created['supabase_id'] != null;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: const [
            Icon(Icons.check_circle, color: C.green, size: 24),
            SizedBox(width: 8),
            Text('Akun Pembina Siap!'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Akun atas nama $nama telah berhasil dibuat, tersinkron ke database Supabase, dan langsung aktif untuk login role Pembina.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Pill(
                hasSupabase ? 'Tersimpan di Supabase DB' : 'Tersinkron ke Database',
                C.greenSoft,
                C.green,
                icon: Icons.cloud_done_outlined,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: C.soft, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📧 Email / Login: ${created['username']}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('🔑 Kata Sandi: $pass',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: C.primary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('⚽ Ekstrakurikuler: $cabang', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Gunakan email dan kata sandi di atas pada layar Login (pilih opsi role "Pembina").',
                style: TextStyle(fontSize: 12, color: C.muted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK, Mengerti', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allCount = _data.length;
    final aktifCount = _data.where((d) => d['aktif'] == true).length;
    final nonaktifCount = _data.where((d) => d['aktif'] == false).length;
    final asnCount = _data.where((d) => d['jenis'] == 'ASN Guru').length;
    final luarCount = _data.where((d) => d['jenis'] == 'Pelatih Luar').length;

    final filteredList = _filteredData;

    return AdminScreen(
      back: Navigator.of(context).canPop() ? 'Kembali' : null,
      title: 'Kelola Akun Pembina & Pelatih',
      subtitle:
          'Manajemen hak akses resmi, NIP/ID kerja, dan penambahan akun pembina ekstrakurikuler SMKN 8 Malang.',
      trailing: Btn(
        '+ Tambah',
        icon: Icons.person_add_alt_1,
        h: 38,
        onTap: _tambahAkunPembina,
      ),
      children: [
        // Ringkasan Statistik Dinamis (34 Guru, 18 Mitra, 48/52 Aktif)
        Row(children: [
          Expanded(
            child: StatBox(
              'Pembina ASN',
              '$asnCount Guru',
              '100% Terverifikasi',
              icon: Icons.school_outlined,
              subColor: C.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatBox(
              'Pelatih Luar',
              '$luarCount Mitra',
              'Kontrak Aktif',
              icon: Icons.sports,
              iconBg: C.amberSoft,
              iconFg: C.amber,
              subColor: C.amber,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatBox(
              'Akun Aktif',
              '$aktifCount / $allCount',
              '$nonaktifCount Nonaktif',
              icon: Icons.verified_user_outlined,
              subColor: nonaktifCount > 0 ? C.orange : C.primary,
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // Tombol Tambah Akun Baru Utama
        Btn(
          '+ Tambah Akun Pembina / Pelatih Baru',
          icon: Icons.person_add_alt,
          expand: true,
          h: 56,
          onTap: _tambahAkunPembina,
        ),
        const SizedBox(height: 14),

        // Searching Box yang Berfungsi Real-Time
        SearchBox(
          'Cari nama, NIP, atau username...',
          filter: true,
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          onClear: () => setState(() => _searchQuery = ''),
          onFilterTap: _showFilterSheet,
        ),

        // Sliding Filter Chips Interaktif dengan Counter Dinamis
        Chips(
          [
            'Semua ($allCount)',
            'Aktif ($aktifCount)',
            'Nonaktif ($nonaktifCount)',
            'Pembina ASN ($asnCount)',
            'Pelatih Luar ($luarCount)',
          ],
          selectedIndex: _selectedFilterChip,
          onChanged: (idx) => setState(() => _selectedFilterChip = idx),
        ),

        // Indikator filter aktif & tombol reset
        if (_searchQuery.isNotEmpty || _selectedFilterChip != 0 || _sortBy != 'default') ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Menampilkan ${filteredList.length} dari $allCount akun'
                    '${_searchQuery.isNotEmpty ? ' untuk "$_searchQuery"' : ''}',
                    style: const TextStyle(fontSize: 13, color: C.muted, fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedFilterChip = 0;
                      _sortBy = 'default';
                    });
                  },
                  child: const Text(
                    'Reset Filter',
                    style: TextStyle(fontSize: 13, color: C.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Daftar Kartu Akun Pembina / Pelatih
        if (filteredList.isEmpty)
          SCard(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: C.soft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_search_outlined, size: 36, color: C.primary),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tidak Ada Akun Ditemukan',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Tidak ditemukan akun yang cocok dengan kata kunci "$_searchQuery".'
                      : 'Tidak ada akun pembina/pelatih pada kategori filter yang dipilih.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: C.muted, height: 1.4),
                ),
                const SizedBox(height: 18),
                Btn.soft(
                  'Reset Pencarian & Filter',
                  icon: Icons.refresh,
                  h: 44,
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedFilterChip = 0;
                      _sortBy = 'default';
                    });
                  },
                ),
              ],
            ),
          )
        else
          for (final item in filteredList) _buildCard(item),

        // Info Card Kebijakan Akun Pembina SMKN 8 Malang
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: C.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, color: C.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Kebijakan Akun Pembina SMKN 8 Malang', style: T.title),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14, color: C.muted, height: 1.4),
                    children: [
                      TextSpan(text: 'Reset password akan mengembalikan kredensial ke default sekolah ('),
                      TextSpan(
                        text: 'smkn8malang2024',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: C.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '). Pembina diwajibkan mengganti sandi pada login sesi berikutnya.',
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final nama = item['nama'] as String;
    final id = item['id'] as String;
    final username = item['username'] as String;
    final cabang = item['cabang'] as String;
    final jenis = item['jenis'] as String;
    final aktif = item['aktif'] as bool;
    final luar = jenis == 'Pelatih Luar';

    return SCard(
      child: Column(children: [
        Row(children: [
          Stack(children: [
            Photo(
              icon: luar ? Icons.sports : Icons.school_outlined,
              bg: luar ? C.amberSoft : const Color(0xFFD6E0F5),
              w: 64,
              h: 64,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: aktif ? C.primary : C.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => push(
                    context,
                    AdminDetailScreen(
                      category: 'Pembina & Pelatih',
                      name: nama,
                      subtitle: id,
                      status: aktif ? 'Aktif' : 'Nonaktif',
                      icon: luar ? Icons.sports : Icons.school_outlined,
                      fields: [
                        AdminDetailField('Username', username, Icons.person_outline),
                        AdminDetailField('Cabang Ekstrakurikuler', cabang, Icons.groups_outlined),
                        AdminDetailField('Jenis Akun', jenis, Icons.badge_outlined),
                        AdminDetailField('Status Akses', aktif ? 'Aktif (Dapat Login)' : 'Nonaktif (Akses Dikunci)', Icons.lock_outline),
                      ],
                    ),
                  ),
                  child: Text(
                    nama,
                    style: T.h2.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Text(id, style: T.body.copyWith(fontSize: 13, color: C.muted)),
              ],
            ),
          ),
          Pill(
            aktif ? 'Aktif' : 'Nonaktif',
            aktif ? C.soft : C.orangeSoft,
            aktif ? C.primary : C.orange,
            dot: true,
          ),
        ]),
        const SizedBox(height: 12),

        Panel(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.person_outline, size: 18, color: C.primary),
              const SizedBox(width: 8),
              const Text('Username:', style: T.body),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  username,
                  textAlign: TextAlign.right,
                  style: T.title.copyWith(fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Icon(
                luar ? Icons.sports : Icons.emoji_events_outlined,
                size: 18,
                color: luar ? C.amber : C.primary,
              ),
              const SizedBox(width: 8),
              const Text('Cabang Tugas:', style: T.body),
              const Spacer(),
              Pill(cabang, Colors.white, C.ink),
              const SizedBox(width: 6),
              Pill(
                jenis,
                luar ? C.amberSoft : C.soft,
                luar ? C.amber : C.primary,
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(
            child: Btn.gray(
              'Edit',
              icon: Icons.edit_outlined,
              expand: true,
              h: 46,
              onTap: () async {
                final res = await push<Map<String, String>>(
                  context,
                  AdminRecordFormScreen(
                    title: 'Edit Akun Pembina',
                    description: 'Perbarui identitas dan penugasan pembina.',
                    fields: const [
                      'Nama lengkap',
                      'NIP / ID Mitra',
                      'Username',
                      'Ekstrakurikuler',
                      'Jenis pembina',
                    ],
                    initialValues: {
                      'Nama lengkap': nama,
                      'NIP / ID Mitra': id,
                      'Username': username,
                      'Ekstrakurikuler': cabang,
                      'Jenis pembina': jenis,
                    },
                    fieldOptions: const {
                      'Jenis pembina': ['ASN Guru', 'Pelatih Luar'],
                    },
                    submitLabel: 'Simpan Perubahan',
                  ),
                );

                if (res != null && res.isNotEmpty && mounted) {
                  try {
                    await Backend.updateCoachAccount(
                      userId: item['supabase_id'].toString(),
                      fullName: res['Nama lengkap'] ?? nama,
                      identifier: res['NIP / ID Mitra'] ?? id,
                      email: res['Username'] ?? username,
                      extracurricular: res['Ekstrakurikuler'] ?? cabang,
                      coachType: res['Jenis pembina'] ?? jenis,
                    );
                    await PembinaAuthStore.syncFromSupabase(force: true);
                    if (mounted) setState(() {});
                    toast(context, 'Data $nama berhasil diperbarui di database.');
                  } catch (e) { toast(context, 'Gagal memperbarui akun: $e'); }
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Btn.gray(
              'Reset Pass',
              icon: Icons.lock_reset,
              expand: true,
              h: 46,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset Password Akun?'),
                    content: Text(
                      'Password akun "$nama" akan diubah ke password sementara yang baru. Lanjutkan?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: C.primary),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset Sandi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#';
                  final random = math.Random.secure();
                  final temporaryPassword = List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
                  try {
                    await Backend.resetAccountPassword(item['supabase_id'].toString(), temporaryPassword);
                    if (!mounted) return;
                    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
                      title: const Text('Password berhasil direset'),
                      content: SelectableText('Password sementara untuk $nama:\n\n$temporaryPassword\n\nSampaikan kepada pemilik akun melalui kanal yang aman.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
                    ));
                  } catch (e) { toast(context, 'Gagal mereset password: $e'); }
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: aktif
                ? Btn.warn(
                    'Nonaktifkan',
                    icon: Icons.person_off_outlined,
                    expand: true,
                    h: 46,
                    onTap: () async {
                      try {
                        await Backend.setAccountActive(item['supabase_id'].toString(), false);
                        setState(() => item['aktif'] = false);
                        toast(context, 'Akun $nama dinonaktifkan');
                      } catch (e) { toast(context, 'Gagal mengubah status: $e'); }
                    },
                  )
                : Btn.soft(
                    'Aktifkan',
                    icon: Icons.how_to_reg_outlined,
                    expand: true,
                    h: 46,
                    onTap: () async {
                      try {
                        await Backend.setAccountActive(item['supabase_id'].toString(), true);
                        setState(() => item['aktif'] = true);
                        toast(context, 'Akun $nama diaktifkan kembali');
                      } catch (e) { toast(context, 'Gagal mengubah status: $e'); }
                    },
                  ),
          ),
        ]),
      ]),
    );
  }
}
