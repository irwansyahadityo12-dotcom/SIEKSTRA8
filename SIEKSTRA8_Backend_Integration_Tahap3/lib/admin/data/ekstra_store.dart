import 'package:flutter/material.dart';
import '../theme.dart';

/// Model kategori ekstrakurikuler untuk sliding filter.
class EkstraCategory {
  final String id;
  final String name;
  final String icon; // Emoji atau simbol ikon
  final String description;
  final bool isActive;

  const EkstraCategory({
    required this.id,
    required this.name,
    this.icon = '📌',
    this.description = '',
    this.isActive = true,
  });

  String get label => '$icon $name';

  EkstraCategory copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    bool? isActive,
  }) {
    return EkstraCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Model data ekstrakurikuler di Admin.
class EkstraItem {
  final String id;
  final String name;
  final String category;
  final String pembina;
  final String pelatih;
  final String totalAnggota;
  final int quota;
  final String jadwal;
  final String lokasi;
  final String presensi;
  final String status; // 'Aktif' atau 'Non-Aktif'
  final bool isUnggulan;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String achievement;

  const EkstraItem({
    required this.id,
    required this.name,
    required this.category,
    required this.pembina,
    this.pelatih = '',
    required this.totalAnggota,
    this.quota = 0,
    required this.jadwal,
    this.lokasi = 'SMKN 8 Malang',
    this.presensi = '90% Kehadiran',
    this.status = 'Aktif',
    this.isUnggulan = false,
    this.icon = Icons.star_border,
    this.iconBg = const Color(0xFFEAF0FF),
    this.iconFg = const Color(0xFF1F5BD6),
    this.achievement = '',
  });

  EkstraItem copyWith({
    String? id,
    String? name,
    String? category,
    String? pembina,
    String? pelatih,
    String? totalAnggota,
    int? quota,
    String? jadwal,
    String? lokasi,
    String? presensi,
    String? status,
    bool? isUnggulan,
    IconData? icon,
    Color? iconBg,
    Color? iconFg,
    String? achievement,
  }) {
    return EkstraItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      pembina: pembina ?? this.pembina,
      pelatih: pelatih ?? this.pelatih,
      totalAnggota: totalAnggota ?? this.totalAnggota,
      quota: quota ?? this.quota,
      jadwal: jadwal ?? this.jadwal,
      lokasi: lokasi ?? this.lokasi,
      presensi: presensi ?? this.presensi,
      status: status ?? this.status,
      isUnggulan: isUnggulan ?? this.isUnggulan,
      icon: icon ?? this.icon,
      iconBg: iconBg ?? this.iconBg,
      iconFg: iconFg ?? this.iconFg,
      achievement: achievement ?? this.achievement,
    );
  }
}

/// Store terpusat untuk mengelola Ekstrakurikuler dan Kategori Sliding Filter di Dashboard Admin.
class EkstraStore extends ChangeNotifier {
  static final EkstraStore _instance = EkstraStore._internal();
  factory EkstraStore() => _instance;
  EkstraStore._internal() {
    _initDefaults();
  }

  final List<EkstraCategory> _categories = [];
  final List<EkstraItem> _ekstras = [];

  List<EkstraCategory> get categories => List.unmodifiable(_categories);
  List<EkstraCategory> get activeCategories =>
      List.unmodifiable(_categories.where((c) => c.isActive));
  List<EkstraItem> get ekstras => List.unmodifiable(_ekstras);

  void _initDefaults() {
    _categories.clear();
    _categories.addAll([
      const EkstraCategory(
        id: 'cat_olahraga',
        name: 'Olahraga',
        icon: '⚽',
        description: 'Cabang keolahragaan fisik, permainan bola, dan atletik prestasi.',
      ),
      const EkstraCategory(
        id: 'cat_pmr',
        name: 'Kemanusiaan / PMR',
        icon: '🩺',
        description: 'Kesiapsiagaan medis, pertolongan pertama, donor darah, dan relawan.',
      ),
      const EkstraCategory(
        id: 'cat_it',
        name: 'Teknologi & IT',
        icon: '💻',
        description: 'Pemrograman software, keamanan siber, robotika, dan inovasi IoT.',
      ),
      const EkstraCategory(
        id: 'cat_bela_negara',
        name: 'Bela Negara',
        icon: '🇮🇩',
        description: 'Paskibra, pramuka, kedisiplinan dan pembentukan jiwa nasionalisme.',
      ),
      const EkstraCategory(
        id: 'cat_seni',
        name: 'Seni & Budaya',
        icon: '🎭',
        description: 'Seni musik akustik/band, teater, tari tradisional, dan kreasi seni rupa.',
      ),
      const EkstraCategory(
        id: 'cat_keagamaan',
        name: 'Keagamaan',
        icon: '🕌',
        description: 'Pembinaan kerohanian Islam, kajian dakwah, dan pembentukan akhlak mulia.',
      ),
      const EkstraCategory(
        id: 'cat_bahasa',
        name: 'Bahasa & Komunikasi',
        icon: '🗣️',
        description: 'English club, public speaking, debat, dan jurnalistik sekolah.',
      ),
    ]);

    _ekstras.clear();
    _ekstras.addAll([
      const EkstraItem(
        id: 'eks_pmr',
        name: 'PMR Wira (Palang Merah Remaja)',
        category: 'Kemanusiaan / PMR',
        pembina: 'Dra. Hj. Ratna Juwita, M.Pd (NIP. 19780412...)',
        pelatih: 'Kak Farhan Maulana (KSR PMI Kota Malang)',
        totalAnggota: '48 Siswa',
        jadwal: 'Sab 08:00 & Rab 15:30',
        lokasi: 'UKS / Lapangan Utama',
        presensi: '98% Kehadiran Rata-rata',
        status: 'Aktif',
        isUnggulan: true,
        icon: Icons.add,
        iconBg: C.redSoft,
        iconFg: C.red,
        achievement: '🏆 Juara 1 Jumbara Prov',
      ),
      const EkstraItem(
        id: 'eks_rpl',
        name: 'RPL Club & Cyber Security',
        category: 'Teknologi & IT',
        pembina: '👨‍🏫 Bpk. Ahmad Fauzi, S.Kom',
        pelatih: 'Kak Rizky (Alumni Praktisi DevOps)',
        totalAnggota: '64 Siswa',
        jadwal: 'Kamis 15:30',
        lokasi: 'Lab RPL & Komputer 3',
        presensi: '94% Kehadiran',
        status: 'Aktif',
        isUnggulan: false,
        icon: Icons.code,
        iconBg: C.soft,
        iconFg: C.primary,
        achievement: '🥇 Juara 1 LKS Web Tech',
      ),
      const EkstraItem(
        id: 'eks_futsal',
        name: 'Futsal SMKN 8 Malang',
        category: 'Olahraga',
        pembina: '👨‍🏫 Bpk. Didik Wahyudi, S.Pd',
        pelatih: 'Coach Jurgen Ibra (Lisensi C AFC)',
        totalAnggota: '82 Siswa',
        jadwal: 'Sel & Jum 15:30',
        lokasi: 'Lapangan Futsal Semi-Indoor',
        presensi: '85% Kehadiran',
        status: 'Aktif',
        isUnggulan: false,
        icon: Icons.sports_soccer,
        iconBg: Color(0xFFE8E9FF),
        iconFg: Color(0xFF4F46E5),
        achievement: '🥈 Juara 2 Kota Malang',
      ),
      const EkstraItem(
        id: 'eks_paskibra',
        name: 'Paskibra SATYA BHAKTI',
        category: 'Bela Negara',
        pembina: '👩‍🏫 Ibu Sri Rahayu, M.Pd',
        pelatih: 'Serka Bambang (Purna PPI)',
        totalAnggota: '55 Siswa',
        jadwal: 'Rab & Sab 07:00',
        lokasi: 'Lapangan Utama',
        presensi: '97% Kehadiran',
        status: 'Aktif',
        isUnggulan: false,
        icon: Icons.flag,
        iconBg: C.redSoft,
        iconFg: C.red,
        achievement: '🎖️ Paskibraka Terbaik Kota',
      ),
      const EkstraItem(
        id: 'eks_robotik',
        name: 'Robotik & IoT SMKN 8',
        category: 'Teknologi & IT',
        pembina: 'Bpk. Bambang, S.T.',
        pelatih: 'M. Rafi Haryo Putra',
        totalAnggota: '85 Siswa',
        jadwal: 'Rabu & Sabtu 15:00',
        lokasi: 'Lab Robotik Terpadu',
        presensi: '92% Kehadiran',
        status: 'Aktif',
        isUnggulan: false,
        icon: Icons.smart_toy_outlined,
        iconBg: C.soft,
        iconFg: C.primary,
        achievement: '💡 Best Innovation Nasional',
      ),
      const EkstraItem(
        id: 'eks_volly',
        name: 'Volly Ball SMKN 8 Malang',
        category: 'Olahraga',
        pembina: 'Soni Subakti, S.Pd',
        pelatih: 'Coach Agus Suparno',
        totalAnggota: '48 Siswa',
        jadwal: 'Selasa & Jumat 15:30',
        lokasi: 'Lapangan Volly Timur',
        presensi: '88% Kehadiran',
        status: 'Aktif',
        isUnggulan: false,
        icon: Icons.sports_volleyball_outlined,
        iconBg: C.amberSoft,
        iconFg: C.amber,
      ),
      const EkstraItem(
        id: 'eks_bdi',
        name: 'Badan Dakwah Islam (BDI)',
        category: 'Keagamaan',
        pembina: 'Muzakki, S.Pd',
        pelatih: 'Ust. Fahruddin',
        totalAnggota: '35 Siswa',
        jadwal: 'Kamis & Sabtu 15:30',
        lokasi: 'Masjid Ulil Albab SMKN 8',
        presensi: '95% Kehadiran',
        status: 'Aktif',
        isUnggulan: false,
        icon: Icons.mosque_outlined,
        iconBg: Color(0xFFD1FAE5),
        iconFg: Color(0xFF059669),
      ),
      const EkstraItem(
        id: 'eks_teater',
        name: 'Teater & Tari Graha Bhakti',
        category: 'Seni & Budaya',
        pembina: 'Ibu Nurul Aini, S.Sn',
        pelatih: 'Kak Dimas Prayoga',
        totalAnggota: '24 Siswa',
        jadwal: 'Senin 15:30',
        lokasi: 'Aula Graha Bhakti',
        presensi: '89% Kehadiran',
        status: 'Non-Aktif',
        isUnggulan: false,
        icon: Icons.theater_comedy_outlined,
        iconBg: Color(0xFFFDE8E8),
        iconFg: Color(0xFFDC2626),
      ),
      const EkstraItem(
        id: 'eks_english',
        name: 'English Debate & Literacy Club',
        category: 'Bahasa & Komunikasi',
        pembina: 'Bpk. Hendra Wijaya, M.Pd',
        pelatih: 'Ms. Sarah Melinda',
        totalAnggota: '18 Siswa',
        jadwal: 'Jumat 13:30',
        lokasi: 'Lab Bahasa 2',
        presensi: '80% Kehadiran',
        status: 'Non-Aktif',
        isUnggulan: false,
        icon: Icons.record_voice_over_outlined,
        iconBg: Color(0xFFEDE9FE),
        iconFg: Color(0xFF7C3AED),
      ),
    ]);
  }

  // --- Operasi Kategori (Sliding Filter) ---

  void addCategory({
    required String name,
    required String icon,
    String description = '',
    bool isActive = true,
  }) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    _categories.add(EkstraCategory(
      id: id,
      name: cleanName,
      icon: icon.trim().isEmpty ? '📌' : icon.trim(),
      description: description.trim(),
      isActive: isActive,
    ));
    notifyListeners();
  }

  void updateCategory(
    String id, {
    required String name,
    required String icon,
    String description = '',
    bool? isActive,
  }) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final old = _categories[index];
    final cleanName = name.trim();
    final updated = old.copyWith(
      name: cleanName.isEmpty ? old.name : cleanName,
      icon: icon.trim().isEmpty ? old.icon : icon.trim(),
      description: description.trim(),
      isActive: isActive ?? old.isActive,
    );

    // Perbarui kategori pada ekstrakurikuler jika nama kategori berubah
    if (old.name != updated.name) {
      for (var i = 0; i < _ekstras.length; i++) {
        if (_ekstras[i].category == old.name) {
          _ekstras[i] = _ekstras[i].copyWith(category: updated.name);
        }
      }
    }

    _categories[index] = updated;
    notifyListeners();
  }

  void toggleCategoryStatus(String id) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return;
    _categories[index] = _categories[index].copyWith(
      isActive: !_categories[index].isActive,
    );
    notifyListeners();
  }

  bool deleteCategory(String id) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return false;
    _categories.removeAt(index);
    notifyListeners();
    return true;
  }

  void resetCategoriesToDefaults() {
    _initDefaults();
    notifyListeners();
  }

  int countEkstrasInCategory(String categoryName) {
    return _ekstras.where((e) => _matchesCategory(e.category, categoryName)).length;
  }

  // --- Operasi Ekstrakurikuler ---

  void addEkstra(EkstraItem item) {
    _ekstras.insert(0, item);
    notifyListeners();
  }

  void updateEkstra(String id, EkstraItem updated) {
    final index = _ekstras.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _ekstras[index] = updated;
    notifyListeners();
  }

  void deleteEkstra(String id) {
    _ekstras.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // --- Filter Helper ---

  static bool _matchesCategory(String itemCategory, String filterCategory) {
    if (filterCategory == 'Semua') return true;
    final c1 = itemCategory.toLowerCase().trim();
    final c2 = filterCategory.toLowerCase().trim();
    if (c1 == c2) return true;
    if (c1.contains(c2) || c2.contains(c1)) return true;
    // Cek kata kunci umum
    if (c2.contains('olahraga') && c1.contains('olahraga')) return true;
    if ((c2.contains('pmr') || c2.contains('kemanusiaan')) &&
        (c1.contains('pmr') || c1.contains('kemanusiaan') || c1.contains('relawan'))) {
      return true;
    }
    if ((c2.contains('it') || c2.contains('teknologi')) &&
        (c1.contains('it') || c1.contains('teknologi') || c1.contains('rpl') || c1.contains('robotik'))) {
      return true;
    }
    if ((c2.contains('bela negara') || c2.contains('paskibra')) &&
        (c1.contains('bela negara') || c1.contains('paskibra') || c1.contains('pramuka'))) {
      return true;
    }
    if ((c2.contains('seni') || c2.contains('budaya')) &&
        (c1.contains('seni') || c1.contains('budaya') || c1.contains('tari') || c1.contains('teater') || c1.contains('musik'))) {
      return true;
    }
    if (c2.contains('keagamaan') && (c1.contains('keagamaan') || c1.contains('islam') || c1.contains('dakwah'))) {
      return true;
    }
    if ((c2.contains('bahasa') || c2.contains('komunikasi')) &&
        (c1.contains('bahasa') || c1.contains('english') || c1.contains('debat') || c1.contains('komunikasi'))) {
      return true;
    }
    return false;
  }

  List<EkstraItem> filterEkstras({
    String query = '',
    String category = 'Semua',
    String status = 'Semua', // 'Semua', 'Aktif', 'Non-Aktif'
  }) {
    final q = query.toLowerCase().trim();
    return _ekstras.where((item) {
      // 1. Status filter
      if (status != 'Semua' && item.status.toLowerCase() != status.toLowerCase()) {
        return false;
      }

      // 2. Category filter
      if (category != 'Semua' && !_matchesCategory(item.category, category)) {
        return false;
      }

      // 3. Search query filter
      if (q.isNotEmpty) {
        final matchName = item.name.toLowerCase().contains(q);
        final matchPembina = item.pembina.toLowerCase().contains(q);
        final matchPelatih = item.pelatih.toLowerCase().contains(q);
        final matchCat = item.category.toLowerCase().contains(q);
        final matchLokasi = item.lokasi.toLowerCase().contains(q);
        final matchAchievement = item.achievement.toLowerCase().contains(q);
        if (!matchName && !matchPembina && !matchPelatih && !matchCat && !matchLokasi && !matchAchievement) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}

final ekstraStore = EkstraStore();
