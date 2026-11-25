import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Akses Supabase terpusat dengan lazy initialization otomatis.
class Backend {
  static bool get isInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Memastikan Supabase terinisialisasi sebelum melakukan operasi database/auth.
  /// Mencegah assertion error jika aplikasi di-hot reload tanpa restart main().
  static Future<void> ensureInitialized() async {
    if (isInitialized) return;
    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.initialize(
          url: SupabaseConfig.url,
          publishableKey: SupabaseConfig.publishableKey,
        );
      } catch (e) {
        debugPrint('Backend.ensureInitialized error: $e');
      }
    }
  }

  static SupabaseClient get client {
    if (!isInitialized) {
      throw const AuthException(
        'Supabase belum diinisialisasi. Lakukan Hot Restart (R) atau muat ulang aplikasi.',
      );
    }
    return Supabase.instance.client;
  }

  static User? get user {
    if (!isInitialized) return null;
    return Supabase.instance.client.auth.currentUser;
  }

  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    final cleanInput = email.trim();
    final cleanPass = password;
    if (cleanInput.isEmpty || cleanPass.isEmpty) {
      throw const AuthException('Email/username dan kata sandi wajib diisi.');
    }

    final emailToTry = cleanInput.contains('@')
        ? cleanInput
        : '$cleanInput@smkn8malang.sch.id';

    await ensureInitialized();
    final result = await client.auth.signInWithPassword(
      email: emailToTry,
      password: cleanPass,
    );
    final user = result.user;
    if (user == null) {
      throw const AuthException('Autentikasi tidak mengembalikan akun pengguna.');
    }

    final profile = await client
        .from('profiles')
        .select('id, full_name, identifier, role, email, class_name, major, phone, is_active')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      await client.auth.signOut();
      throw const AuthException('Profil akun belum tersedia. Hubungi administrator.');
    }
    if (profile['role'] != expectedRole) {
      await client.auth.signOut();
      throw AuthException('Akun ini tidak memiliki hak akses ${roleLabel(expectedRole)}.');
    }
    if (profile['is_active'] == false) {
      await client.auth.signOut();
      throw const AuthException('Akun sedang dinonaktifkan. Hubungi administrator.');
    }
    return Map<String, dynamic>.from(profile);
  }

  static Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String identifier,
  }) async {
    await ensureInitialized();
    await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'identifier': identifier.trim(),
        // Registrasi publik selalu menjadi siswa; role staf hanya boleh diberikan
        // melalui proses administrasi tepercaya di server.
        'role': 'siswa',
      },
    );
  }

  static Future<Map<String, dynamic>> createPembinaAccount({
    required String nama,
    required String nip,
    required String emailOrUsername,
    String? password,
    required String cabang,
    required String jenis,
  }) async {
    await ensureInitialized();
    final response = await client.functions.invoke(
      'admin-create-user',
      body: {
        'action': 'create_coach',
        'full_name': nama.trim(),
        'identifier': nip.trim(),
        'email': emailOrUsername.trim().contains('@')
            ? emailOrUsername.trim().toLowerCase()
            : '${emailOrUsername.trim().toLowerCase()}@smkn8malang.sch.id',
        'password': password,
        'class_name': cabang.trim(),
        'major': jenis.trim(),
      },
    );
    if (response.status < 200 || response.status >= 300) {
      throw AuthException('Gagal membuat akun Pembina: ${response.data}');
    }
    return Map<String, dynamic>.from(response.data as Map);
  }

  static Future<void> updateCoachAccount({
    required String userId,
    required String fullName,
    required String identifier,
    required String email,
    required String extracurricular,
    required String coachType,
  }) async {
    await ensureInitialized();
    final response = await client.functions.invoke('admin-create-user', body: {
      'action': 'update_coach_profile',
      'user_id': userId,
      'full_name': fullName,
      'identifier': identifier,
      'email': email,
      'class_name': extracurricular,
      'major': coachType,
    });
    if (response.status < 200 || response.status >= 300) {
      throw AuthException('Gagal memperbarui akun Pembina: ${response.data}');
    }
  }

  static Future<void> setAccountActive(String userId, bool active) async {
    await ensureInitialized();
    final response = await client.functions.invoke('admin-create-user', body: {
      'action': 'set_active', 'user_id': userId, 'is_active': active,
    });
    if (response.status < 200 || response.status >= 300) {
      throw AuthException('Gagal mengubah status akun: ${response.data}');
    }
  }

  static Future<void> resetAccountPassword(String userId, String password) async {
    await ensureInitialized();
    final response = await client.functions.invoke('admin-create-user', body: {
      'action': 'reset_password', 'user_id': userId, 'password': password,
    });
    if (response.status < 200 || response.status >= 300) {
      throw AuthException('Gagal mereset password: ${response.data}');
    }
  }

  static Future<void> signOut() async {
    await ensureInitialized();
    await client.auth.signOut();
  }

  static String roleLabel(String role) => switch (role) {
    'admin' => 'Admin',
    'pembina' => 'Pembina',
    _ => 'Siswa',
  };
}
