import 'package:flutter/material.dart';
import '../../app/backend.dart';
import '../../data/siekstra_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class EkskulFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const EkskulFormScreen({super.key, this.initial});

  @override
  State<EkskulFormScreen> createState() => _EkskulFormScreenState();
}

class _EkskulFormScreenState extends State<EkskulFormScreen> {
  final SiekstraRepository _repo = SiekstraRepository();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _locationController = TextEditingController();
  final _quotaController = TextEditingController();

  String? _extraId;
  String? _coachId;
  String? _coachName;
  bool _isOpen = true;

  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _coachExtras = [];
  List<String> _categoryOptions = [
    'Kepalangmerahan & Kemanusiaan',
    'Teknologi & IT',
    'Olahraga',
    'Bela Negara',
    'Seni & Budaya',
    'Keagamaan',
    'Vokasi & Keahlian',
    'Bahasa & Komunikasi',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _populateFromData(widget.initial!);
    }
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _scheduleController.dispose();
    _locationController.dispose();
    _quotaController.dispose();
    super.dispose();
  }

  void _populateFromData(Map<String, dynamic> data) {
    _extraId = data['id']?.toString();
    _nameController.text = data['name']?.toString() ?? '';
    _categoryController.text = data['category']?.toString() ?? 'Kepalangmerahan & Kemanusiaan';
    _descController.text = data['description']?.toString() ?? '';
    _scheduleController.text = data['schedule_summary']?.toString() ?? '';
    _locationController.text = data['location']?.toString() ?? '';
    _quotaController.text = (data['quota'] ?? '60').toString();
    _coachId = data['coach_id']?.toString();
    _coachName = data['coach_name']?.toString();
    _isOpen = data['is_open'] != false;
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await Backend.ensureInitialized();

      // Muat kategori dari Supabase jika tersedia
      try {
        final catRows = await _repo.getCategories(activeOnly: true);
        if (catRows.isNotEmpty) {
          final names = catRows.map((c) => c['name'].toString()).toSet().toList();
          _categoryOptions = names;
        }
      } catch (_) {}

      final extras = await _repo.getCoachExtracurriculars();

      if (!mounted) return;

      if (extras.isNotEmpty) {
        _coachExtras = extras;
        _populateFromData(extras.first);
      } else {
        // Fallback jika belum tertaut ke profil
        final allExtras = await _repo.getExtracurriculars();
        if (!mounted) return;
        _coachExtras = allExtras;
        if (allExtras.isNotEmpty) {
          _populateFromData(allExtras.first);
        }
      }

      setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_extraId == null || _extraId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Ekstrakurikuler tidak valid atau belum ditemukan.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final name = _nameController.text.trim();
      final category = _categoryController.text.trim();
      final description = _descController.text.trim();
      final scheduleSummary = _scheduleController.text.trim();
      final location = _locationController.text.trim();
      final quota = int.tryParse(_quotaController.text.trim()) ?? 0;

      await _repo.updateExtracurricular(
        _extraId!,
        name: name,
        category: category,
        description: description,
        location: location,
        quota: quota,
        coachId: _coachId,
        scheduleSummary: scheduleSummary,
        isOpen: _isOpen,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data ekstrakurikuler berhasil diperbarui di Supabase!'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal memperbarui ekstrakurikuler: $e'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showExtraPicker() {
    if (_coachExtras.length <= 1) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Ekstrakurikuler Binaan', style: T.h2),
            const SizedBox(height: 12),
            for (final ex in _coachExtras)
              ListTile(
                title: Text(
                  ex['name']?.toString() ?? '',
                  style: TextStyle(
                    fontWeight: _extraId == ex['id']?.toString() ? FontWeight.w800 : FontWeight.w600,
                    color: _extraId == ex['id']?.toString() ? AppColors.primary : AppColors.ink,
                  ),
                ),
                subtitle: Text(ex['category']?.toString() ?? 'Ekstrakurikuler'),
                trailing: _extraId == ex['id']?.toString()
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _populateFromData(ex));
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ekskulName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Ekstrakurikuler';

    return Screen(
      back: true,
      tag: ekskulName.length > 14 ? ekskulName.substring(0, 14) : ekskulName,
      title: 'Form Detail Ekskul',
      subtitle: 'Kelola informasi profil, jadwal, lokasi & kuota ekstrakurikuler di Supabase',
      bottom: Row(children: [
        Expanded(
          flex: 2,
          child: Btn(
            'Batal',
            h: 54,
            expand: true,
            bg: Colors.white,
            fg: AppColors.ink,
            onTap: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Btn(
            _saving ? 'Menyimpan...' : 'Simpan Perubahan',
            icon: Icons.check,
            h: 54,
            expand: true,
            onTap: _saving || _loading ? null : _save,
          ),
        ),
      ]),
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          SCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: AppColors.red, size: 40),
                const SizedBox(height: 10),
                Text('Gagal Memuat Data', style: T.h2.copyWith(color: AppColors.red)),
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Btn.soft('Coba Lagi', icon: Icons.refresh, onTap: _loadData),
              ],
            ),
          )
        else ...[
          if (_coachExtras.length > 1) ...[
            GestureDetector(
              onTap: _showExtraPicker,
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDDE3FF)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PILIH EKSTRAKURIKULER BINAAN',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            ekskulName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],

          SCard(
            color: const Color(0xFFEFF4FF),
            child: Row(children: [
              const IconBox(Icons.edit_note_rounded, bg: Colors.white, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text(
                    'FORM INFORMASI PEMBINA',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Perubahan pada form ini langsung tersinkron ke profil ekskul di sisi siswa dan admin.',
                    style: TextStyle(fontSize: 13.5, color: AppColors.muted),
                  ),
                ]),
              ),
            ]),
          ),

          SCard(
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('INFORMASI UMUM', style: T.label),
                const SizedBox(height: 14),

                // Nama Ekskul
                _buildFieldLabel('NAMA EKSTRAKURIKULER', Icons.menu_book_outlined),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration('Contoh: PMR Wira SMKN 8 Malang'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama ekskul wajib diisi' : null,
                ),
                const SizedBox(height: 14),

                // Kategori
                _buildFieldLabel('KATEGORI EKSTRAKURIKULER', Icons.inventory_2_outlined),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _categoryOptions.contains(_categoryController.text.trim())
                      ? _categoryController.text.trim()
                      : (_categoryOptions.isNotEmpty ? _categoryOptions.first : null),
                  isExpanded: true,
                  decoration: _inputDecoration('Pilih kategori'),
                  items: _categoryOptions
                      .map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 14))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _categoryController.text = val);
                  },
                ),
                const SizedBox(height: 14),

                // Pembina (Read-only info)
                _buildFieldLabel('PEMBINA / PEMBIMBING', Icons.person_outline),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.green, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _coachName ?? 'Akun Pembina Terautentikasi',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      const Pill('Tersambung', AppColors.greenSoft, AppColors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Jadwal Rutin
                _buildFieldLabel('JADWAL RUTIN LATIHAN', Icons.calendar_month_outlined),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _scheduleController,
                  decoration: _inputDecoration('Contoh: Rabu & Jumat • 15:00 WIB'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Jadwal rutin wajib diisi' : null,
                ),
                const SizedBox(height: 14),

                // Lokasi
                _buildFieldLabel('LOKASI / TEMPAT KEGIATAN', Icons.place_outlined),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  decoration: _inputDecoration('Contoh: Ruang UKS / Lab PMR Gedung B'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Lokasi wajib diisi' : null,
                ),
                const SizedBox(height: 14),

                // Kapasitas Kuota
                _buildFieldLabel('KAPASITAS KUOTA SISWA', Icons.groups_outlined),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _quotaController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Contoh: 60 (Masukkan angka)'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Kapasitas anggota wajib diisi';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 0) return 'Masukkan angka kuota yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Deskripsi / Visi Misi
                _buildFieldLabel('DESKRIPSI & PROGRAM KERJA', Icons.description_outlined),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration('Tuliskan ringkasan kegiatan, tujuan, atau visi ekstrakurikuler...'),
                ),
                const SizedBox(height: 14),

                // Switch Buka Pendaftaran
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isOpen ? const Color(0xFFE9FBF1) : const Color(0xFFF1F4FD),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isOpen ? const Color(0xFFB7EBCB) : AppColors.line,
                    ),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _isOpen ? 'Pendaftaran Dibuka untuk Siswa' : 'Pendaftaran Ditutup Sementara',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: _isOpen ? AppColors.green : AppColors.muted,
                      ),
                    ),
                    subtitle: Text(
                      _isOpen
                          ? 'Siswa dapat mengajukan pendaftaran ekstrakurikuler ini di aplikasi.'
                          : 'Siswa tidak dapat mendaftar ekstrakurikuler ini sampai pendaftaran dibuka kembali.',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _isOpen,
                    activeColor: AppColors.green,
                    onChanged: (val) => setState(() => _isOpen = val),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(label, style: T.label.copyWith(fontSize: 11.5)),
    ]);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13.5),
      filled: true,
      fillColor: const Color(0xFFF1F4FD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
