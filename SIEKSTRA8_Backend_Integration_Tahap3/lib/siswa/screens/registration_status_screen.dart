
import 'package:flutter/material.dart';
import '../../app/supabase_config.dart';
import '../../data/siekstra_repository.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class RegistrationStatusScreen extends StatefulWidget {
  const RegistrationStatusScreen({super.key});

  @override
  State<RegistrationStatusScreen> createState() =>
      _RegistrationStatusScreenState();
}

class _RegistrationStatusScreenState
    extends State<RegistrationStatusScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _future = SupabaseConfig.isConfigured
        ? SiekstraRepository().getMyMemberships()
        : Future.value([]);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pendaftaran'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: !SupabaseConfig.isConfigured
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Supabase belum dikonfigurasi. '
                  'Periksa koneksi backend terlebih dahulu.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            size: 48,
                            color: C.red,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Gagal memuat status pendaftaran.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: C.muted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              setState(_loadData);
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final rows = snapshot.data ?? [];

                if (rows.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 55,
                            color: C.muted,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum Ada Pendaftaran',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Kamu belum memiliki pengajuan ekstrakurikuler.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: C.muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final row in rows) _membershipCard(row),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _membershipCard(Map<String, dynamic> row) {
    final extra = (row['extracurriculars'] as Map?) ?? {};

    final status = (row['status'] ?? 'pending')
        .toString()
        .toLowerCase();

    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';
    final isResigned = status == 'resigned';

    final label = switch (status) {
      'approved' => 'Diterima',
      'rejected' => 'Ditolak',
      'resigned' => 'Mengundurkan diri',
      _ => 'Menunggu verifikasi',
    };

    final color = isApproved
        ? C.green
        : (isRejected || isResigned)
            ? C.red
            : C.amber;

    final bg = isApproved
        ? C.greenBg
        : (isRejected || isResigned)
            ? C.redBg
            : C.amberBg;

    final createdAt = row['created_at']?.toString() ?? '-';
    final date = createdAt.contains('T')
        ? createdAt.split('T').first
        : createdAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: tx(
                    (extra['name'] ?? 'Ekstrakurikuler').toString(),
                    size: 16,
                    w: FontWeight.w800,
                  ),
                ),
                Pill(label, fg: color, bg: bg),
              ],
            ),
            const SizedBox(height: 12),

            const Divider(),

            _InfoRow('Tanggal pengajuan', date),
            _InfoRow('Status', label),

            if ((row['motivation'] ?? '').toString().isNotEmpty)
              _InfoRow(
                'Motivasi',
                row['motivation'].toString(),
              ),

            const SizedBox(height: 12),

            tx(
              'Tahapan Pendaftaran',
              size: 14,
              w: FontWeight.w800,
            ),

            const SizedBox(height: 12),

            _StepTile(
              number: '1',
              title: 'Formulir dikirim',
              subtitle: 'Pengajuan diterima oleh sistem',
              done: true,
            ),

            _StepTile(
              number: '2',
              title: 'Verifikasi Pembina',
              subtitle: isApproved
                  ? 'Pengajuan telah diverifikasi'
                  : isRejected
                      ? 'Pengajuan tidak disetujui'
                      : isResigned
                          ? 'Pengajuan telah berakhir'
                          : 'Menunggu pemeriksaan pembina',
              done: isApproved || isRejected || isResigned,
              active: !isApproved && !isRejected && !isResigned,
            ),

            _StepTile(
              number: '3',
              title: 'Konfirmasi hasil',
              subtitle: isApproved
                  ? 'Selamat, pendaftaran kamu diterima'
                  : isRejected
                      ? 'Pendaftaran tidak diterima'
                      : isResigned
                          ? 'Kamu telah mengundurkan diri'
                          : 'Menunggu hasil verifikasi',
              done: isApproved,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool done;
  final bool active;

  const _StepTile({
    required this.number,
    required this.title,
    required this.subtitle,
    this.done = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: done
                ? C.greenBg
                : active
                    ? C.soft
                    : const Color(0xFFEFF1F7),
            child: done
                ? const Icon(
                    Icons.check,
                    size: 17,
                    color: C.green,
                  )
                : tx(
                    number,
                    size: 12,
                    w: FontWeight.w800,
                    color: active ? C.primary : C.muted,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tx(title, size: 13, w: FontWeight.w800),
                  tx(subtitle, size: 11, color: C.muted),
                ],
              ),
            ),
          ),
          if (active)
            const Pill(
              'Proses',
              fg: C.amber,
              bg: C.amberBg,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: tx(
              label,
              size: 11.5,
              color: C.muted,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: tx(
              value,
              size: 11.5,
              w: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
