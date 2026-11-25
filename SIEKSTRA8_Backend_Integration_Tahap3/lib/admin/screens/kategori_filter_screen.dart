import 'package:flutter/material.dart';
import '../data/ekstra_store.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Halaman untuk mengisi dan mengelola item pada sliding filter ekstrakurikuler.
class AdminKategoriFilterScreen extends StatefulWidget {
  const AdminKategoriFilterScreen({super.key});

  @override
  State<AdminKategoriFilterScreen> createState() => _AdminKategoriFilterScreenState();
}

class _AdminKategoriFilterScreenState extends State<AdminKategoriFilterScreen> {
  // Rekomendasi emoji cepat untuk kategori ekstrakurikuler
  static const List<String> _emojiRecommendations = [
    '⚽', '💻', '🩺', '🇮🇩', '🎭', '🕌', '🗣️', '♟️',
    '🌿', '🧪', '🎨', '📸', '🎵', '🥋', '🤖', '📚',
    '🏊', '🏸', '🏹', '🤝', '🏕️', '🍳', '📊', '🎸',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ekstraStore,
      builder: (context, _) {
        final allCategories = ekstraStore.categories;
        final activeCategories = ekstraStore.activeCategories;
        final totalEkstras = ekstraStore.ekstras.length;

        return AdminScreen(
          back: 'Kembali ke Ekstrakurikuler',
          eyebrow: 'MANAJEMEN DATA FILTER',
          title: 'Kelola Isi Sliding Filter',
          subtitle:
              'Tambah, ubah, dan atur kategori yang tampil pada baris chip geser (sliding filter) ekstrakurikuler.',
          trailing: Btn.soft(
            '',
            icon: Icons.add_circle_outline,
            h: 52,
            onTap: () => _showCategoryDialog(context),
          ),
          children: [
            // Stat ringkasan
            Row(children: [
              Expanded(
                child: StatBox(
                  'Total Kategori',
                  '${allCategories.length}',
                  'Kategori terdaftar',
                  icon: Icons.category_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatBox(
                  'Aktif di Filter',
                  '${activeCategories.length}',
                  'Muncul di sliding bar',
                  valueColor: C.primary,
                  subColor: C.primary,
                  icon: Icons.tune,
                  iconBg: C.soft,
                  iconFg: C.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatBox(
                  'Total Ekstra',
                  '$totalEkstras',
                  'Cabang aktif & non',
                  valueColor: C.green,
                  subColor: C.green,
                  icon: Icons.sports_soccer_outlined,
                  iconBg: C.greenSoft,
                  iconFg: C.green,
                ),
              ),
            ]),
            const SizedBox(height: 14),

            // Tombol tambah kategori utama
            Btn(
              'Tambah Kategori Baru ke Sliding Filter',
              icon: Icons.add_circle_outline,
              expand: true,
              h: 52,
              onTap: () => _showCategoryDialog(context),
            ),
            const SizedBox(height: 12),

            // Info Panduan
            const InfoCard(
              Icons.touch_app_outlined,
              'Cara Kerja Sliding Filter',
              'Kategori yang diaktifkan di halaman ini akan langsung muncul sebagai opsi pada sliding filter di halaman Ekstrakurikuler. Siswa & Admin dapat menggeser dan menekan kategori untuk memfilter data secara instan.',
              bg: Color(0xFFEFF4FF),
              border: Color(0xFFD6E2FF),
            ),
            const SizedBox(height: 8),

            // Header Daftar Kategori
            SectionTitle(
              'Daftar Kategori Sliding Filter',
              icon: Icons.view_carousel_outlined,
              action: 'Reset Default',
              onAction: () => _confirmReset(context),
            ),

            if (allCategories.isEmpty)
              SCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(children: [
                    const Icon(Icons.category_outlined, size: 48, color: C.muted),
                    const SizedBox(height: 12),
                    const Text('Belum ada kategori filter', style: T.h2),
                    const SizedBox(height: 6),
                    const Text(
                      'Tekan tombol "Tambah Kategori Baru" untuk menambahkan opsi filter.',
                      style: T.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Btn('Tambah Kategori', onTap: () => _showCategoryDialog(context)),
                  ]),
                ),
              )
            else
              for (final cat in allCategories) _buildCategoryCard(context, cat),

            const SizedBox(height: 8),
            // Tombol reset bawah
            Btn.white(
              'Kembalikan ke Kategori Default Sistem',
              icon: Icons.restore,
              expand: true,
              h: 48,
              onTap: () => _confirmReset(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, EkstraCategory cat) {
    final count = ekstraStore.countEkstrasInCategory(cat.name);

    return SCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cat.isActive ? C.soft : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cat.isActive ? C.line : Colors.transparent),
            ),
            child: Text(cat.icon, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 6, runSpacing: 6, children: [
                Pill(
                  cat.isActive ? 'Tampil di Sliding Filter' : 'Disembunyikan',
                  cat.isActive ? C.greenSoft : const Color(0xFFF1F5F9),
                  cat.isActive ? C.green : C.muted,
                  dot: true,
                ),
                Pill('$count Cabang Ekstra', C.soft, C.primary),
              ]),
              const SizedBox(height: 6),
              Text(cat.name, style: T.h2.copyWith(fontSize: 17)),
              if (cat.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(cat.description, style: T.body),
              ],
            ]),
          ),
        ]),
        const Divider(height: 22),
        Row(children: [
          // Switch Tampilkan
          Row(children: [
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: cat.isActive,
                activeColor: C.primary,
                onChanged: (_) {
                  ekstraStore.toggleCategoryStatus(cat.id);
                  toast(
                    context,
                    cat.isActive
                        ? 'Kategori disembunyikan dari sliding filter'
                        : 'Kategori sekarang tampil di sliding filter',
                  );
                },
              ),
            ),
            Text(
              cat.isActive ? 'Aktif' : 'Nonaktif',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cat.isActive ? C.ink : C.muted,
              ),
            ),
          ]),
          const Spacer(),
          Btn.gray(
            'Edit',
            icon: Icons.edit_outlined,
            h: 38,
            onTap: () => _showCategoryDialog(context, existing: cat),
          ),
          const SizedBox(width: 8),
          Btn.danger(
            'Hapus',
            icon: Icons.delete_outline,
            h: 38,
            onTap: () => _confirmDelete(context, cat, count),
          ),
        ]),
      ]),
    );
  }

  void _showCategoryDialog(BuildContext context, {EkstraCategory? existing}) {
    final isEdit = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    final emojiController = TextEditingController(text: existing?.icon ?? '📌');
    bool isActive = existing?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Modal
                      Row(children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: C.soft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEdit ? Icons.edit_note : Icons.add_circle_outline,
                            color: C.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit ? 'Edit Kategori Sliding Filter' : 'Tambah Kategori Baru',
                                style: T.h2,
                              ),
                              const Text(
                                'Kategori ini akan muncul di baris sliding filter.',
                                style: T.body,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: C.muted),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ]),
                      const Divider(height: 24),

                      // Pilih Emoji Cepat
                      const Text('PILIH IKON / EMOJI KATEGORI', style: T.label),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 46,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _emojiRecommendations.length,
                          itemBuilder: (context, i) {
                            final em = _emojiRecommendations[i];
                            final isSelected = emojiController.text == em;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    emojiController.text = em;
                                  });
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? C.primary : const Color(0xFFF1F4FD),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? C.primary : C.line,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(em, style: const TextStyle(fontSize: 20)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Input Emoji Kustom & Nama
                      Row(children: [
                        SizedBox(
                          width: 72,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Emoji', style: T.title),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: emojiController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 22),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: C.field,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nama Kategori', style: T.title),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  hintText: 'Contoh: Olahraga, Robotik, Seni Musik...',
                                  filled: true,
                                  fillColor: C.field,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: C.line),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: C.primary, width: 1.5),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Nama kategori wajib diisi' : null,
                              ),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),

                      // Deskripsi Kategori
                      const Text('Deskripsi / Cakupan Kategori', style: T.title),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Penjelasan singkat cabang atau kegiatan kategori ini...',
                          filled: true,
                          fillColor: C.field,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: C.line),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Toggle Tampilkan di Sliding Filter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: C.line),
                        ),
                        child: Row(children: [
                          const Icon(Icons.visibility_outlined, color: C.primary, size: 22),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tampilkan di Sliding Filter', style: T.title),
                                Text(
                                  'Kategori akan muncul sebagai chip yang dapat digeser dan ditekan.',
                                  style: T.body,
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isActive,
                            activeColor: C.primary,
                            onChanged: (val) {
                              setModalState(() {
                                isActive = val;
                              });
                            },
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),

                      // Tombol Simpan
                      Btn(
                        isEdit ? 'Simpan Perubahan' : 'Tambahkan Kategori ke Filter',
                        icon: Icons.check,
                        expand: true,
                        h: 52,
                        onTap: () {
                          if (!formKey.currentState!.validate()) return;
                          final name = nameController.text.trim();
                          final icon = emojiController.text.trim().isEmpty
                              ? '📌'
                              : emojiController.text.trim();
                          final desc = descController.text.trim();

                          if (isEdit) {
                            ekstraStore.updateCategory(
                              existing.id,
                              name: name,
                              icon: icon,
                              description: desc,
                              isActive: isActive,
                            );
                            toast(context, 'Kategori "$name" berhasil diperbarui');
                          } else {
                            ekstraStore.addCategory(
                              name: name,
                              icon: icon,
                              description: desc,
                              isActive: isActive,
                            );
                            toast(context, 'Kategori "$name" berhasil ditambahkan ke sliding filter');
                          }
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, EkstraCategory cat, int count) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: C.red, size: 28),
          const SizedBox(width: 8),
          const Text('Hapus Kategori?'),
        ]),
        content: Text(
          count > 0
              ? 'Kategori "${cat.icon} ${cat.name}" saat ini memiliki $count ekstrakurikuler terdaftar. Yakin ingin menghapus kategori ini dari sliding filter?'
              : 'Yakin ingin menghapus kategori "${cat.icon} ${cat.name}" dari sliding filter?',
          style: T.body.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: C.muted, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: C.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ekstraStore.deleteCategory(cat.id);
              toast(context, 'Kategori "${cat.name}" dihapus.');
            },
            child: const Text('Hapus Kategori'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Kategori Default?'),
        content: const Text(
          'Tindakan ini akan mengembalikan daftar kategori sliding filter ke kategori bawaan standar SMKN 8 Malang.',
          style: T.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: C.muted, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: C.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ekstraStore.resetCategoriesToDefaults();
              toast(context, 'Kategori berhasil direset ke bawaan.');
            },
            child: const Text('Reset Sekarang'),
          ),
        ],
      ),
    );
  }
}
