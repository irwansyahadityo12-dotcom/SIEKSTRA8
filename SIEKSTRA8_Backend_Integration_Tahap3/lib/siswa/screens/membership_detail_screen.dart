import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'permission_form_screen.dart';
import 'schedule_screen.dart';

class MembershipDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? membership;
  const MembershipDetailScreen({super.key, this.membership});

  @override
  Widget build(BuildContext context) {
    final extra = membership?['extracurriculars'] is Map
        ? membership!['extracurriculars'] as Map<String, dynamic>
        : <String, dynamic>{};

    final name = (extra['name'] ?? 'Ekstrakurikuler').toString();
    final category = (extra['category'] ?? 'Umum').toString();
    final coach = (extra['coach_name'] ?? 'Pembina belum ditentukan').toString();
    final schedule = (extra['schedule_summary'] ?? 'Jadwal menyusul').toString();
    final location = (extra['location'] ?? 'SMKN 8 Malang').toString();

    final status = (membership?['status'] ?? 'approved').toString().toLowerCase();
    final isApproved = status == 'approved';
    final statusText = isApproved ? 'Aktif' : status == 'pending' ? 'Menunggu' : 'Selesai';

    final createdStr = membership?['created_at']?.toString();
    final joinDate = createdStr != null && createdStr.length >= 10
        ? createdStr.substring(0, 10)
        : '-';

    final categoryLower = category.toLowerCase();
    final color = categoryLower.contains('olahraga')
        ? C.brown
        : categoryLower.contains('sosial')
            ? C.red
            : categoryLower.contains('keagamaan')
                ? C.teal
                : C.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Keanggotaan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: .75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pill(
                  isApproved ? 'ANGGOTA AKTIF' : statusText.toUpperCase(),
                  fg: Colors.white,
                  bg: Colors.white24,
                  icon: isApproved ? Icons.verified : Icons.hourglass_top,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white24,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'E',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            category,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'SMKN 8 Malang • Terverifikasi di SIEKSTRA-8',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Info Keanggotaan
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tx('Informasi Keanggotaan', size: 14, w: FontWeight.w800),
                const SizedBox(height: 12),
                _row('Status Keanggotaan', statusText),
                _row('Tanggal Terdaftar', joinDate),
                _row('Pembina / Pelatih', coach),
                _row('Jadwal Kegiatan', schedule),
                _row('Lokasi Latihan', location),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: C.soft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, color: C.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: tx(
                    'Keanggotaan ini resmi terdaftar di database kesiswaan SMKN 8 Malang. Pastikan hadir tepat waktu pada setiap sesi kegiatan.',
                    size: 11.5,
                    color: C.primary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: C.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.calendar_month_outlined, size: 18, color: C.primary),
                  label: const Text('Jadwal Sesi', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScheduleScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: C.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                  label: const Text('Ajukan Izin', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PermissionFormScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: tx(label, size: 12, color: C.muted)),
          Flexible(child: tx(value, size: 12, w: FontWeight.w700, align: TextAlign.right)),
        ],
      ),
    );
  }
}
