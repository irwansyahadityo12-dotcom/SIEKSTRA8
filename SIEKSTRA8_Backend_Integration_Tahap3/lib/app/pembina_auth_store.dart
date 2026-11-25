import 'package:flutter/foundation.dart';
import 'backend.dart';
import 'supabase_config.dart';

/// Cache tampilan akun Pembina. Sumber kebenaran tetap tabel profiles Supabase;
/// password tidak pernah disimpan di client.
class PembinaAuthStore {
  static final List<Map<String, dynamic>> _accounts = [];
  static bool _syncedWithSupabase = false;

  static List<Map<String, dynamic>> get accounts => _accounts;

  static Future<void> syncFromSupabase({bool force = false}) async {
    if (!SupabaseConfig.isConfigured || (_syncedWithSupabase && !force)) return;
    try {
      await Backend.ensureInitialized();
      final rows = await Backend.client
          .from('profiles')
          .select('id, full_name, identifier, role, email, class_name, major, is_active')
          .eq('role', 'pembina')
          .order('created_at', ascending: false);
      _accounts
        ..clear()
        ..addAll(rows.map((row) => {
          'nama': row['full_name'] ?? 'Pembina Ekstra',
          'id': row['identifier'] ?? '-',
          'username': row['email'] ?? '',
          'email': row['email'] ?? '',
          'cabang': row['class_name'] ?? 'SMKN 8 Malang',
          'jenis': row['major'] ?? 'Pembina',
          'aktif': row['is_active'] ?? true,
          'supabase_id': row['id'],
        }));
      _syncedWithSupabase = true;
    } catch (e) {
      debugPrint('PembinaAuthStore.syncFromSupabase error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> addAccountWithSupabase({
    required String nama,
    required String nip,
    required String emailOrUsername,
    String? password,
    required String cabang,
    required String jenis,
  }) async {
    final result = await Backend.createPembinaAccount(
      nama: nama,
      nip: nip,
      emailOrUsername: emailOrUsername,
      password: password,
      cabang: cabang,
      jenis: jenis,
    );
    await syncFromSupabase(force: true);
    return _accounts.firstWhere((account) => account['supabase_id'] == result['user_id']);
  }
}
