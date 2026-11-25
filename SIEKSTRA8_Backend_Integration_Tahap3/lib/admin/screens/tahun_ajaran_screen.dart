import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AdminTahunAjaranScreen extends StatefulWidget {
  const AdminTahunAjaranScreen({super.key});

  @override
  State<AdminTahunAjaranScreen> createState() => _AdminTahunAjaranScreenState();
}

class _AdminTahunAjaranScreenState extends State<AdminTahunAjaranScreen> {
  String _activeYear = '2024/2025';
  String _activeSemester = 'Ganjil';
  bool _registrationOpen = true;

  final List<Map<String, dynamic>> _periods = [
    {
      'year': '2024/2025',
      'semester': 'Ganjil',
      'months': 'Juli 2024 - Desember 2024',
      'isActive': true,
      'regStatus': 'Pendaftaran Dibuka',
      'totalEkskul': 18,
      'totalMembers': 1240,
    },
    {
      'year': '2024/2025',
      'semester': 'Genap',
      'months': 'Januari 2025 - Juni 2025',
      'isActive': false,
      'regStatus': 'Belum Dimulai',
      'totalEkskul': 18,
      'totalMembers': 0,
    },
    {
      'year': '2023/2024',
      'semester': 'Genap',
      'months': 'Januari 2024 - Juni 2024',
      'isActive': false,
      'regStatus': 'Arsip Selesai',
      'totalEkskul': 16,
      'totalMembers': 1180,
    },
    {
      'year': '2023/2024',
      'semester': 'Ganjil',
      'months': 'Juli 2023 - Desember 2023',
      'isActive': false,
      'regStatus': 'Arsip Selesai',
      'totalEkskul': 16,
      'totalMembers': 1150,
    },
  ];

  void _showAddPeriodDialog() {
    final yearController = TextEditingController(text: '2025/2026');
    String semesterVal = 'Ganjil';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tambah Periode Tahun Ajaran', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tahun Ajaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.muted)),
              const SizedBox(height: 6),
              TextField(
                controller: yearController,
                decoration: InputDecoration(
                  hintText: 'Contoh: 2025/2026',
                  filled: true,
                  fillColor: C.field,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Semester', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.muted)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: semesterVal,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: C.field,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'Ganjil', child: Text('Semester Ganjil (Juli - Des)')),
                  DropdownMenuItem(value: 'Genap', child: Text('Semester Genap (Jan - Jun)')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => semesterVal = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: C.muted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final year = yearController.text.trim();
                if (year.isNotEmpty) {
                  setState(() {
                    _periods.insert(0, {
                      'year': year,
                      'semester': semesterVal,
                      'months': semesterVal == 'Ganjil' ? 'Juli - Desember' : 'Januari - Juni',
                      'isActive': false,
                      'regStatus': 'Persiapan',
                      'totalEkskul': 18,
                      'totalMembers': 0,
                    });
                  });
                  Navigator.pop(ctx);
                  toast(context, 'Periode $year ($semesterVal) berhasil ditambahkan.');
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _activatePeriod(Map<String, dynamic> item) {
    setState(() {
      for (var p in _periods) {
        p['isActive'] = false;
      }
      item['isActive'] = true;
      _activeYear = item['year'] as String;
      _activeSemester = item['semester'] as String;
    });
    toast(context, 'Periode aktif diubah ke $_activeYear ($_activeSemester)');
  }

  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      back: 'Kembali ke Sistem & Akun',
      title: 'Tahun Ajaran & Semester',
      subtitle: 'Atur kalender kegiatan ekstra, tahun ajaran aktif, dan timeline pendaftaran SMKN 8 Malang.',
      children: [
        // Kartu Utama Periode Aktif
        SCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [C.primary, Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Pill('PERIODE BERJALAN', Colors.white24, Colors.white, icon: Icons.stars_outlined),
                        Spacer(),
                        Pill('Online & Terkunci', Colors.white24, Colors.white, dot: true),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'T.A. $_activeYear ($_activeSemester)',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'SMKN 8 Malang • Semester Gasal Tahun Pelajaran 2024/2025',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.app_registration, color: C.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Status Pendaftaran Ekstrakurikuler', style: T.title),
                              Text('Izinkan siswa mendaftar ekskul baru di semester ini', style: T.body),
                            ],
                          ),
                        ),
                        Switch(
                          value: _registrationOpen,
                          onChanged: (val) {
                            setState(() => _registrationOpen = val);
                            toast(context, val ? 'Pendaftaran ekskul dibuka untuk siswa' : 'Pendaftaran ekskul ditutup');
                          },
                          activeColor: Colors.white,
                          activeTrackColor: C.primary,
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

        // Action Bar Tambah Periode
        Row(
          children: [
            const Expanded(child: Text('DAFTAR PERIODE TAHUN AJARAN', style: T.label)),
            Btn.soft(
              'Tambah Periode',
              icon: Icons.add,
              h: 36,
              onTap: _showAddPeriodDialog,
            ),
          ],
        ),

        const SizedBox(height: 10),

        // List Periode
        for (final p in _periods) ...[
          SCard(
            color: p['isActive'] == true ? const Color(0xFFF0F5FF) : null,
            border: p['isActive'] == true ? C.primary : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBox(
                      p['isActive'] == true ? Icons.check_circle : Icons.calendar_today_outlined,
                      bg: p['isActive'] == true ? C.soft : const Color(0xFFEEF1F7),
                      fg: p['isActive'] == true ? C.primary : C.muted,
                      size: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'T.A. ${p['year']} (${p['semester']})',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.ink),
                              ),
                              const SizedBox(width: 8),
                              if (p['isActive'] == true)
                                const Pill('AKTIF', C.soft, C.primary)
                              else
                                Pill(p['regStatus'] as String, const Color(0xFFEEF1F7), C.muted),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(p['months'] as String, style: T.body.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: C.line),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Total Ekskul: ${p['totalEkskul']} Cabang', style: T.body.copyWith(fontSize: 12)),
                    const SizedBox(width: 14),
                    Text('Siswa: ${p['totalMembers']}', style: T.body.copyWith(fontSize: 12)),
                    const Spacer(),
                    if (p['isActive'] != true)
                      Btn.soft(
                        'Set Aktif',
                        h: 32,
                        onTap: () => _activatePeriod(p),
                      )
                    else
                      const Text(
                        'Sedang Digunakan',
                        style: TextStyle(color: C.primary, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

