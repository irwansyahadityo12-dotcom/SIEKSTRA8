import 'package:flutter/material.dart';
import '../../data/siekstra_repository.dart';
import '../../app/supabase_config.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});
  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  final _repository = SiekstraRepository();
  late Future<List<Map<String, dynamic>>> _future;
  @override
  void initState() { super.initState(); _future = _repository.getAttendanceSessions(); }
  void _reload() => setState(() => _future = _repository.getAttendanceSessions());

  @override
  Widget build(BuildContext context) => AdminScreen(
    title: 'Presensi Ekstrakurikuler',
    subtitle: 'Rekap sesi dan catatan kehadiran yang tersimpan di Supabase.',
    children: [
      Row(children: [const Expanded(child: SectionTitle('Riwayat Sesi Presensi')), IconButton(onPressed: _reload, icon: const Icon(Icons.refresh, color: C.primary))]),
      if (!SupabaseConfig.isConfigured) const SCard(child: Text('Supabase belum dikonfigurasi.')),
      if (SupabaseConfig.isConfigured) FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator()));
          if (snapshot.hasError) return SCard(child: Column(children: [Text('Gagal memuat sesi: ${snapshot.error}', style: T.body), Btn('Coba Lagi', icon: Icons.refresh, onTap: _reload)]));
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) return const SCard(child: Column(children: [Icon(Icons.fact_check_outlined, size: 42, color: C.muted), SizedBox(height: 8), Text('Belum Ada Sesi Presensi', style: T.h2), Text('Sesi akan muncul setelah Pembina membuat presensi.', style: T.body)]));
          return Column(children: sessions.map((session) => _sessionCard(session)).toList());
        },
      ),
    ],
  );

  Widget _sessionCard(Map<String, dynamic> session) => FutureBuilder<List<Map<String, dynamic>>>(
    future: _repository.getSessionAttendance(session['id'].toString()),
    builder: (context, snapshot) {
      final records = snapshot.data ?? [];
      final present = records.where((r) => r['status'] == 'Hadir').length;
      final absent = records.where((r) => r['status'] == 'Alfa').length;
      final excused = records.where((r) => r['status'] == 'Izin' || r['status'] == 'Sakit').length;
      final pct = records.isEmpty ? 0 : (present * 100 / records.length).round();
      final extra = session['extracurriculars'] as Map? ?? {};
      final date = session['session_date']?.toString() ?? '-';
      return SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(session['title']?.toString() ?? 'Sesi Presensi', style: T.title)), Pill(snapshot.connectionState == ConnectionState.waiting ? 'Memuat' : '$pct% Hadir', C.greenSoft, C.green)]),
        const SizedBox(height: 5),
        Text(extra['name']?.toString() ?? 'Ekstrakurikuler', style: T.body),
        Text('Tanggal: $date', style: T.body),
        const Divider(height: 20),
        if (snapshot.connectionState == ConnectionState.waiting) const LinearProgressIndicator(),
        if (snapshot.hasError) Text('Gagal memuat catatan: ${snapshot.error}', style: const TextStyle(color: C.red, fontSize: 12)),
        if (!snapshot.hasError && snapshot.connectionState != ConnectionState.waiting) Wrap(spacing: 8, runSpacing: 8, children: [
          Pill('Hadir $present', C.greenSoft, C.green),
          Pill('Izin/Sakit $excused', C.soft, C.primary),
          Pill('Alfa $absent', C.redSoft, C.red),
          Pill('Total ${records.length}', C.field, C.muted),
        ]),
      ]));
    },
  );
}
