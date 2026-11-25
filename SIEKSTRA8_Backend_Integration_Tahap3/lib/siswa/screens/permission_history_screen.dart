import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../../data/siekstra_repository.dart';

class PermissionHistoryScreen extends StatefulWidget {
  const PermissionHistoryScreen({super.key});
  @override
  State<PermissionHistoryScreen> createState() => _PermissionHistoryScreenState();
}

class _PermissionHistoryScreenState extends State<PermissionHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  @override
  void initState() {
    super.initState();
    _future = SiekstraRepository().getMyPermissionRequests();
  }

  void _reload() => setState(() => _future = SiekstraRepository().getMyPermissionRequests());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Riwayat Pengajuan Izin')),
        body: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return ListView(children: [const SizedBox(height: 100), Center(child: Text('Gagal memuat riwayat izin\n${snapshot.error}', textAlign: TextAlign.center)), TextButton(onPressed: _reload, child: const Text('Coba lagi'))]);
              final rows = snapshot.data ?? [];
              if (rows.isEmpty) return ListView(children: [const SizedBox(height: 100), const Icon(Icons.event_busy_outlined, size: 48, color: C.muted), const SizedBox(height: 12), Center(child: tx('Belum ada pengajuan izin.', color: C.muted))]);
              return ListView(padding: const EdgeInsets.all(16), children: [
                AppCard(color: C.soft, child: Row(children: [const Icon(Icons.fact_check_outlined, color: C.primary), const SizedBox(width: 10), Expanded(child: tx('Status pengajuan diperbarui berdasarkan data Supabase.', size: 12, color: C.primary))])),
                const SectionTitle('Pengajuan Izin'),
                for (final row in rows) _item(row),
              ]);
            },
          ),
        ),
      );

  Widget _item(Map<String, dynamic> row) {
    final status = (row['status'] ?? 'pending').toString();
    final color = status == 'approved' ? C.green : status == 'rejected' ? C.red : C.amber;
    final bg = status == 'approved' ? C.greenBg : status == 'rejected' ? C.redBg : C.amberBg;
    final date = (row['start_date'] ?? '-').toString();
    final extra = row['extracurriculars'];
    final extraName = extra is Map ? (extra['name'] ?? 'Ekstrakurikuler').toString() : 'Ekstrakurikuler';
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.event_note_outlined, color: C.primary, size: 20), const SizedBox(width: 8), Expanded(child: tx(date, size: 12, w: FontWeight.w800)), Pill(_label(status), fg: color, bg: bg)]),
      const SizedBox(height: 8),
      tx('${row['permission_type'] ?? 'Izin'} • $extraName', size: 12, color: C.muted),
      const SizedBox(height: 4),
      tx((row['reason'] ?? '').toString(), size: 12),
    ]));
  }

  String _label(String status) => status == 'approved' ? 'Disetujui' : status == 'rejected' ? 'Ditolak' : 'Menunggu';
}
