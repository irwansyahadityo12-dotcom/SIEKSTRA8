import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/backend.dart';

/// Repository CRUD untuk modul utama SIEKSTRA-8.
/// Seluruh query tetap tunduk pada kebijakan RLS di Supabase.
class SiekstraRepository {
  SupabaseClient get _db => Backend.client;
  String get _uid {
    final id = Backend.user?.id;
    if (id == null) throw AuthException('Silakan login terlebih dahulu.');
    return id;
  }

  Future<List<Map<String, dynamic>>> getExtracurriculars({bool? onlyOpen}) async {
    await Backend.ensureInitialized();
    var query = _db.from('extracurriculars').select('*, memberships(count)');
    if (onlyOpen != false) {
      query = query.eq('is_open', true);
    }
    return await query.order('name');
  }

  Future<List<Map<String, dynamic>>> getActiveCoaches() async {
    await Backend.ensureInitialized();
    return await _db
        .from('profiles')
        .select('id, full_name, email, identifier, phone, is_active')
        .eq('role', 'pembina')
        .eq('is_active', true)
        .order('full_name');
  }

  Future<List<Map<String, dynamic>>> getMyMemberships() async =>
      await _db.from('memberships').select('*, extracurriculars(*)')
          .eq('student_id', _uid).order('created_at', ascending: false);

  Future<Map<String, dynamic>?> getMyMembershipForExtracurricular(String extracurricularId) async {
    final rows = await _db
        .from('memberships')
        .select('*, extracurriculars(*)')
        .eq('student_id', _uid)
        .eq('extracurricular_id', extracurricularId)
        .limit(1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> applyExtracurricular({
    required String extracurricularId,
    String? motivation,
  }) async {
    // 1. Validasi apakah siswa sudah pernah mendaftar ekskul ini
    final existing = await getMyMembershipForExtracurricular(extracurricularId);
    if (existing != null) {
      final status = existing['status']?.toString();
      if (status == 'pending') {
        throw Exception('Anda sudah mengajukan pendaftaran untuk ekstrakurikuler ini dan sedang menunggu persetujuan pembina.');
      } else if (status == 'approved') {
        throw Exception('Anda sudah terdaftar sebagai anggota aktif pada ekstrakurikuler ini.');
      } else if (status == 'rejected') {
        throw Exception('Pendaftaran Anda sebelumnya untuk ekstrakurikuler ini telah ditolak oleh pembina.');
      } else if (status == 'resigned') {
        throw Exception('Anda telah mengundurkan diri dari ekstrakurikuler ini.');
      } else {
        throw Exception('Anda sudah pernah mendaftar pada ekstrakurikuler ini.');
      }
    }

    try {
      await _db.from('memberships').insert({
        'extracurricular_id': extracurricularId,
        'student_id': _uid,
        'motivation': motivation,
        'status': 'pending',
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505' ||
          e.message.contains('memberships_extracurricular_id_student_id_key') ||
          e.message.contains('duplicate key')) {
        throw Exception('Anda sudah pernah mendaftar pada ekstrakurikuler ini. Silakan periksa status pendaftaran Anda.');
      }
      throw Exception('Pendaftaran gagal: ${e.message}');
    } catch (e) {
      if (e.toString().contains('23505') ||
          e.toString().contains('memberships_extracurricular_id_student_id_key') ||
          e.toString().contains('duplicate key')) {
        throw Exception('Anda sudah pernah mendaftar pada ekstrakurikuler ini. Silakan periksa status pendaftaran Anda.');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSchedules({
    String? extracurricularId,
    DateTime? from,
  }) async {
    var query = _db.from('schedules').select('*, extracurriculars(name)');
    if (extracurricularId != null) {
      query = query.eq('extracurricular_id', extracurricularId);
    }
    if (from != null) query = query.gte('activity_date', from.toIso8601String().substring(0, 10));
    return await query.order('activity_date');
  }

  Future<List<Map<String, dynamic>>> getMySchedules({DateTime? from}) async {
    final memberships = await _db.from('memberships')
        .select('extracurricular_id')
        .eq('student_id', _uid)
        .eq('status', 'approved');
    final ids = memberships.map((e) => e['extracurricular_id'] as String).toList();
    if (ids.isEmpty) return [];
    var query = _db.from('schedules').select('*, extracurriculars(name)').inFilter('extracurricular_id', ids);
    if (from != null) query = query.gte('activity_date', from.toIso8601String().substring(0, 10));
    return await query.order('activity_date');
  }

  Future<List<Map<String, dynamic>>> getAttendanceSessions({String? extracurricularId}) async {
    var query = _db.from('attendance_sessions').select('*, extracurriculars(name)');
    if (extracurricularId != null) query = query.eq('extracurricular_id', extracurricularId);
    return await query.order('session_date', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getCoachSchedules() async =>
      await _db.from('schedules').select('*, extracurriculars!inner(name,coach_id)')
          .eq('extracurriculars.coach_id', _uid).order('activity_date');

  Future<List<Map<String, dynamic>>> getCoachAttendanceSessions() async =>
      await _db.from('attendance_sessions').select('*, extracurriculars!inner(name,coach_id)')
          .eq('extracurriculars.coach_id', _uid).order('session_date', ascending: false);

  Future<List<Map<String, dynamic>>> getSessionAttendance(String sessionId) async =>
      await _db.from('attendance_records')
          .select('*, profiles!attendance_records_student_id_fkey(full_name,identifier,class_name)')
          .eq('session_id', sessionId).order('marked_at');

  Future<void> updateSchedule(String id, {
    required String title, required DateTime date, String? startTime,
    String? endTime, String? location, String? notes,
  }) async {
    await _db.from('schedules').update({
      'title': title.trim(),
      'activity_date': date.toIso8601String().substring(0, 10),
      'start_time': startTime, 'end_time': endTime,
      'location': location, 'notes': notes,
    }).eq('id', id);
  }

  Future<void> deleteSchedule(String id) async {
    await _db.from('schedules').delete().eq('id', id);
  }

  Future<void> submitPermission({
    String? extracurricularId,
    String? scheduleId,
    required String type,
    required DateTime startDate,
    DateTime? endDate,
    required String reason,
    String? attachmentUrl,
  }) async {
    await _db.from('permission_requests').insert({
      'student_id': _uid,
      'extracurricular_id': extracurricularId,
      'schedule_id': scheduleId,
      'permission_type': type,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate?.toIso8601String().substring(0, 10),
      'reason': reason,
      'attachment_url': attachmentUrl,
      'status': 'pending',
    });
  }

  Future<void> submitResignation({
    required String extracurricularId,
    required String reason,
    String? reasonCategory,
    String? attachmentUrl,
  }) async {
    await _db.from('resignation_requests').insert({
      'student_id': _uid,
      'extracurricular_id': extracurricularId,
      'reason': reason,
      'reason_category': reasonCategory,
      'attachment_url': attachmentUrl,
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getMyAttendance() async {
    await Backend.ensureInitialized();
    try {
      final results = await Future.wait([
        _db.from('attendance_records')
            .select('*, attendance_sessions(title, session_date, extracurriculars(name))')
            .eq('student_id', _uid)
            .order('marked_at', ascending: false),
        _db.from('permission_requests')
            .select('*, extracurriculars(name)')
            .eq('student_id', _uid)
            .eq('status', 'approved')
            .order('start_date', ascending: false),
      ]);

      final records = (results[0] as List).cast<Map<String, dynamic>>();
      final permissions = (results[1] as List).cast<Map<String, dynamic>>();

      final existingSessionDates = <String>{};
      for (final r in records) {
        final sess = r['attendance_sessions'];
        if (sess is Map && sess['session_date'] != null) {
          existingSessionDates.add(sess['session_date'].toString().substring(0, 10));
        }
      }

      final merged = List<Map<String, dynamic>>.from(records);

      for (final p in permissions) {
        final startDate = p['start_date']?.toString();
        final dateKey = startDate != null && startDate.length >= 10 ? startDate.substring(0, 10) : '';

        if (dateKey.isEmpty || !existingSessionDates.contains(dateKey)) {
          final permType = p['permission_type']?.toString().toLowerCase() ?? 'izin';
          final status = permType.contains('sakit') ? 'Sakit' : 'Izin';
          final extra = p['extracurriculars'] is Map
              ? p['extracurriculars'] as Map<String, dynamic>
              : <String, dynamic>{'name': 'Ekstrakurikuler'};

          merged.add({
            'id': p['id'],
            'student_id': _uid,
            'status': status,
            'note': p['reason'] ?? 'Izin resmi telah disetujui oleh Pembina.',
            'marked_at': p['reviewed_at'] ?? p['created_at'],
            'is_approved_permission': true,
            'permission_type': p['permission_type'],
            'attendance_sessions': {
              'title': 'Izin Resmi: ${p['permission_type'] ?? 'Dispensasi'}',
              'session_date': startDate ?? p['created_at'],
              'extracurriculars': extra,
            },
          });
        }
      }

      merged.sort((a, b) {
        final dateA = (a['attendance_sessions'] is Map ? a['attendance_sessions']['session_date'] : null) ?? a['marked_at'] ?? '';
        final dateB = (b['attendance_sessions'] is Map ? b['attendance_sessions']['session_date'] : null) ?? b['marked_at'] ?? '';
        return dateB.toString().compareTo(dateA.toString());
      });

      return merged;
    } catch (_) {
      return await _db.from('attendance_records')
          .select('*, attendance_sessions(title, session_date, extracurriculars(name))')
          .eq('student_id', _uid)
          .order('marked_at', ascending: false);
    }
  }

  Future<List<Map<String, dynamic>>> getMyNotifications() async =>
      await _db.from('notifications').select().eq('user_id', _uid)
          .order('created_at', ascending: false);

  Future<List<Map<String, dynamic>>> getAdminNotifications() async {
    await Backend.ensureInitialized();
    try {
      return await _db.from('notifications').select().order('created_at', ascending: false);
    } catch (_) {
      return await getMyNotifications();
    }
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _db.from('notifications').update({'is_read': true})
        .eq('id', notificationId).eq('user_id', _uid);
  }

  Future<void> markAllNotificationsRead() async {
    await _db.from('notifications').update({'is_read': true})
        .eq('user_id', _uid).eq('is_read', false);
  }

  Future<String> createAttendanceSession({
    required String extracurricularId,
    required String title,
    required DateTime date,
    String? notes,
  }) async {
    final row = await _db.from('attendance_sessions').insert({
      'extracurricular_id': extracurricularId,
      'title': title,
      'session_date': date.toIso8601String().substring(0, 10),
      'notes': notes,
      'created_by': _uid,
    }).select('id').single();
    return row['id'] as String;
  }

  Future<void> saveAttendance(String sessionId, List<Map<String, String>> records) async {
    await _db.from('attendance_records').upsert(
      records.map((record) => {
        'session_id': sessionId,
        'student_id': record['student_id'],
        'status': record['status'],
        'note': record['note'],
        'marked_by': _uid,
      }).toList(),
      onConflict: 'session_id,student_id',
    );
  }

  Future<List<Map<String, dynamic>>> getPendingMemberships() async =>
      await _db.from('memberships').select('*, profiles!memberships_student_id_fkey(full_name,identifier), extracurriculars(name)')
          .eq('status', 'pending').order('created_at');

  Future<List<Map<String, dynamic>>> getMembershipsForAdmin({String? status}) async {
    var query = _db.from('memberships').select(
      '*, profiles!memberships_student_id_fkey(full_name,identifier,class_name,major), extracurriculars(name)',
    );
    if (status != null) query = query.eq('status', status);
    return await query.order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getPendingMembershipsForCoach() async =>
      await _db.from('memberships')
          .select('*, profiles!memberships_student_id_fkey(full_name,identifier), extracurriculars!inner(name,coach_id)')
          .eq('status', 'pending')
          .eq('extracurriculars.coach_id', _uid)
          .order('created_at');

  Future<List<Map<String, dynamic>>> getMembershipsForCoach({String? status}) async {
    var query = _db.from('memberships')
        .select('*, profiles!memberships_student_id_fkey(full_name,identifier,class_name), extracurriculars!inner(name,coach_id)')
        .eq('extracurriculars.coach_id', _uid);
    if (status != null) query = query.eq('status', status);
    return await query.order('created_at', ascending: false);
  }

  Future<void> reviewMembership(String id, {required bool approve}) async {
    await _db.from('memberships').update({
      'status': approve ? 'approved' : 'rejected',
      'reviewed_by': _uid,
      'reviewed_at': DateTime.now().toIso8601String(),
      'joined_at': approve ? DateTime.now().toIso8601String() : null,
    }).eq('id', id);
  }



  /// Statistik dashboard dihitung dari baris database, bukan angka contoh.
  Future<Map<String, int>> getAdminDashboardStats() async {
    await Backend.ensureInitialized();
    final students = await _db.from('profiles').select('id').eq('role', 'siswa').eq('is_active', true);
    final coaches = await _db.from('profiles').select('id').eq('role', 'pembina').eq('is_active', true);
    final extras = await _db.from('extracurriculars').select('id');
    final memberships = await _db.from('memberships').select('id').eq('status', 'approved');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final sessions = await _db.from('attendance_sessions').select('id').eq('session_date', today);
    final sessionIds = sessions.map((e) => e['id'].toString()).toList();
    var attendance = <Map<String, dynamic>>[];
    if (sessionIds.isNotEmpty) {
      attendance = await _db.from('attendance_records').select('status').inFilter('session_id', sessionIds);
    }
    final present = attendance.where((r) => r['status'] == 'Hadir').length;
    final percent = attendance.isEmpty ? 0 : ((present / attendance.length) * 100).round();
    return {
      'students': students.length,
      'coaches': coaches.length,
      'extracurriculars': extras.length,
      'memberships': memberships.length,
      'sessions': sessions.length,
      'attendance_percent': percent,
      'attendance_records': attendance.length,
    };
  }

  /// Daftar siswa untuk panel Admin beserta keanggotaan ekstrakurikulernya.
  Future<List<Map<String, dynamic>>> getAdminStudents() async {
    await Backend.ensureInitialized();
    final profiles = await _db.from('profiles').select(
      'id, full_name, identifier, email, class_name, major, is_active, created_at',
    ).eq('role', 'siswa').order('full_name');
    final memberships = await _db.from('memberships').select(
      'student_id, status, extracurriculars(name)',
    );
    final byStudent = <String, List<Map<String, dynamic>>>{};
    for (final item in memberships) {
      final key = item['student_id']?.toString() ?? '';
      if (key.isEmpty) continue;
      byStudent.putIfAbsent(key, () => []).add(Map<String, dynamic>.from(item));
    }
    return profiles.map((raw) {
      final profile = Map<String, dynamic>.from(raw);
      final rows = byStudent[profile['id']?.toString()] ?? [];
      final active = rows.where((m) => m['status'] == 'approved').toList();
      final names = active.map((m) => (m['extracurriculars'] as Map?)?['name']?.toString())
          .whereType<String>().where((n) => n.isNotEmpty).toList();
      final className = profile['class_name']?.toString() ?? '';
      final major = profile['major']?.toString() ?? '';
      final gradeMatch = RegExp(r'^(XII|XI|X)\b', caseSensitive: false).firstMatch(className);
      return {
        ...profile,
        'name': profile['full_name'] ?? 'Tanpa Nama',
        'nisn': profile['identifier'] ?? '-',
        'class': className,
        'tingkat': gradeMatch == null ? 'Tidak diketahui' : 'Kelas ${gradeMatch.group(1)}',
        'jurusan': major.isEmpty ? 'Belum diisi' : major,
        'ekskul': names.isEmpty ? 'Belum Memilih Ekskul' : names.join(', '),
        'kehadiran': '-',
        'status': names.isEmpty ? 'Belum' : 'Aktif',
        'icon': 0,
      };
    }).toList();
  }

  Future<Map<String, int>> getCoachDashboardStats() async {
    await Backend.ensureInitialized();
    final extras = await _db.from('extracurriculars').select('id').eq('coach_id', _uid).eq('is_open', true);
    final ids = extras.map((e) => e['id'].toString()).toList();
    if (ids.isEmpty) return {'extracurriculars': 0, 'members': 0, 'pending': 0, 'sessions': 0};
    final members = await _db.from('memberships').select('id').inFilter('extracurricular_id', ids).eq('status', 'approved');
    final pending = await _db.from('memberships').select('id').inFilter('extracurricular_id', ids).eq('status', 'pending');
    final sessions = await _db.from('attendance_sessions').select('id').inFilter('extracurricular_id', ids);
    return {'extracurriculars': extras.length, 'members': members.length, 'pending': pending.length, 'sessions': sessions.length};
  }

  // ===== PROFIL & DATA MASTER =====
  Future<Map<String, dynamic>> getMyProfile() async =>
      await _db.from('profiles').select().eq('id', _uid).single();

  Future<List<Map<String, dynamic>>> getProfiles({String? role}) async {
    var query = _db.from('profiles').select();
    if (role != null) query = query.eq('role', role);
    return await query.order('full_name');
  }

  Future<void> updateMyProfile({
    required String fullName,
    String? className,
    String? major,
    String? phone,
  }) async {
    await _db.from('profiles').update({
      'full_name': fullName.trim(),
      'class_name': className,
      'major': major,
      'phone': phone,
    }).eq('id', _uid);
  }

  Future<void> updateStudentProfile({
    required String studentId,
    required String fullName,
    String? identifier,
    String? className,
    String? major,
  }) async {
    await _db.from('profiles').update({
      'full_name': fullName.trim(),
      'identifier': identifier?.trim(),
      'class_name': className?.trim(),
      'major': major?.trim(),
    }).eq('id', studentId).eq('role', 'siswa');
  }

  Future<void> assignStudentToExtracurricular({
    required String studentId,
    required String extracurricularId,
  }) async {
    await _db.from('memberships').insert({
      'student_id': studentId,
      'extracurricular_id': extracurricularId,
      'status': 'approved',
      'reviewed_by': _uid,
      'reviewed_at': DateTime.now().toIso8601String(),
      'joined_at': DateTime.now().toIso8601String(),
    });
  }

  Future<String> createExtracurricular({
    required String name,
    required String category,
    String? description,
    String? location,
    int quota = 0,
    String? coachId,
    String? coachName,
    String? scheduleSummary,
    bool isOpen = true,
  }) async {
    if (coachId != null && coachId.isNotEmpty) {
      final existing = await _db.from('extracurriculars')
          .select('id, name')
          .eq('coach_id', coachId)
          .maybeSingle();
      if (existing != null) {
        throw Exception('Pembina sudah ditugaskan pada ekstrakurikuler "${existing['name']}". 1 akun pembina hanya boleh mengurus 1 ekstrakurikuler.');
      }
    }
    final row = await _db.from('extracurriculars').insert({
      'name': name.trim(),
      'category': category,
      'description': description ?? '',
      'location': (location != null && location.isNotEmpty) ? location : 'SMKN 8 Malang',
      'quota': quota,
      'coach_id': (coachId != null && coachId.isNotEmpty) ? coachId : null,
      'coach_name': coachName,
      'schedule_summary': (scheduleSummary != null && scheduleSummary.isNotEmpty) ? scheduleSummary : 'Jadwal belum ditentukan',
      'created_by': _uid,
      'is_open': isOpen,
    }).select('id').single();
    return row['id'] as String;
  }

  Future<void> updateExtracurricular(
    String id, {
    required String name,
    required String category,
    String? description,
    String? location,
    int quota = 0,
    String? coachId,
    String? coachName,
    String? scheduleSummary,
    required bool isOpen,
  }) async {
    if (coachId != null && coachId.isNotEmpty) {
      final existing = await _db.from('extracurriculars')
          .select('id, name')
          .eq('coach_id', coachId)
          .neq('id', id)
          .maybeSingle();
      if (existing != null) {
        throw Exception('Pembina sudah ditugaskan pada ekstrakurikuler "${existing['name']}". 1 akun pembina hanya boleh mengurus 1 ekstrakurikuler.');
      }
    }
    final Map<String, dynamic> updateData = {
      'name': name.trim(),
      'category': category,
      'quota': quota,
      'coach_id': (coachId != null && coachId.isNotEmpty) ? coachId : null,
      'is_open': isOpen,
    };
    if (coachName != null) updateData['coach_name'] = coachName;
    if (description != null) updateData['description'] = description;
    if (location != null) updateData['location'] = location;
    if (scheduleSummary != null) updateData['schedule_summary'] = scheduleSummary;

    await _db.from('extracurriculars').update(updateData).eq('id', id);
  }

  Future<void> toggleExtracurricularStatus(String id, bool isOpen) async {
    await Backend.ensureInitialized();
    await _db.from('extracurriculars').update({'is_open': isOpen}).eq('id', id);
  }

  Future<void> deleteExtracurricular(String id) async {
    await _db.from('extracurriculars').delete().eq('id', id);
  }

  // ===== PERIZINAN & PENGUNDURAN DIRI =====
  Future<List<Map<String, dynamic>>> getMyPermissionRequests() async =>
      await _db.from('permission_requests')
          .select('*, extracurriculars(name)')
          .eq('student_id', _uid)
          .order('created_at', ascending: false);

  Future<List<Map<String, dynamic>>> getPendingPermissionRequests() async =>
      await _db.from('permission_requests')
          .select('*, profiles!permission_requests_student_id_fkey(full_name,identifier), extracurriculars(name)')
          .eq('status', 'pending')
          .order('created_at');

  Future<List<Map<String, dynamic>>> getPermissionRequestsForCoach({String? status}) async {
    try {
      var query = _db.from('permission_requests')
          .select('*, profiles!permission_requests_student_id_fkey(full_name,identifier,class_name), extracurriculars!inner(name,coach_id)')
          .eq('extracurriculars.coach_id', _uid);
      if (status != null) query = query.eq('status', status);
      final res = await query.order('created_at', ascending: false);
      if (res.isNotEmpty) return res;
    } catch (_) {}
    var fallbackQuery = _db.from('permission_requests')
        .select('*, profiles!permission_requests_student_id_fkey(full_name,identifier,class_name), extracurriculars(name,coach_id)');
    if (status != null) fallbackQuery = fallbackQuery.eq('status', status);
    return await fallbackQuery.order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getPendingPermissionRequestsForCoach() async =>
      await getPermissionRequestsForCoach(status: 'pending');

  Future<void> reviewPermission(String id, {required bool approve}) async {
    await _db.from('permission_requests').update({
      'status': approve ? 'approved' : 'rejected',
      'reviewed_by': _uid,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getPendingResignations() async =>
      await _db.from('resignation_requests')
          .select('*, profiles!resignation_requests_student_id_fkey(full_name,identifier), extracurriculars(name)')
          .eq('status', 'pending')
          .order('created_at');

  Future<List<Map<String, dynamic>>> getPendingResignationsForCoach() async =>
      await _db.from('resignation_requests')
          .select('*, profiles!resignation_requests_student_id_fkey(full_name,identifier), extracurriculars!inner(name,coach_id)')
          .eq('status', 'pending')
          .eq('extracurriculars.coach_id', _uid)
          .order('created_at');

  Future<List<Map<String, dynamic>>> getMyResignations() async =>
      await _db.from('resignation_requests')
          .select('*, extracurriculars(name)')
          .eq('student_id', _uid)
          .order('created_at', ascending: false);

  Future<void> reviewResignation(String id, {required bool approve}) async {
    await _db.from('resignation_requests').update({
      'status': approve ? 'approved' : 'rejected',
      'reviewed_by': _uid,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ===== JADWAL & PRESENSI PEMBINA =====
  Future<List<Map<String, dynamic>>> getCoachExtracurriculars() async {
    final rows = await _db.from('extracurriculars')
        .select()
        .eq('coach_id', _uid)
        .order('name');
    if (rows.isNotEmpty) return rows;

    // Fallback cerdas: jika coach_id belum tersambung langsung di DB,
    // periksa class_name atau email profile untuk auto-linking
    try {
      final myProfile = await getMyProfile();
      final className = myProfile['class_name']?.toString() ?? '';
      final email = myProfile['email']?.toString() ?? '';

      String keyword = '';
      if (className.isNotEmpty && className != 'SMKN 8 Malang') {
        keyword = className.split('(').first.trim();
      } else if (email.contains('.')) {
        final part = email.split('@').first.split('.').last;
        if (part != 'pembina') keyword = part;
      }

      if (keyword.isNotEmpty) {
        final matches = await _db.from('extracurriculars')
            .select()
            .ilike('name', '%$keyword%')
            .order('name');
        if (matches.isNotEmpty) {
          final target = matches.first;
          if (target['coach_id'] == null || target['coach_id'] == _uid) {
            await _db.from('extracurriculars').update({
              'coach_id': _uid,
              'coach_name': myProfile['full_name'] ?? 'Pembina',
            }).eq('id', target['id']);
            return [{
              ...target,
              'coach_id': _uid,
              'coach_name': myProfile['full_name'] ?? 'Pembina',
            }];
          }
        }
      }
    } catch (_) {}

    return [];
  }

  Future<void> claimExtracurricularAsCoach(String extracurricularId) async {
    final myProfile = await getMyProfile();
    final existing = await _db.from('extracurriculars')
        .select('id, name, coach_id')
        .eq('id', extracurricularId)
        .single();
    if (existing['coach_id'] != null && existing['coach_id'] != _uid) {
      throw Exception('Ekstrakurikuler "${existing['name']}" sudah memiliki pembina.');
    }
    final currentCoachExtras = await _db.from('extracurriculars')
        .select('id, name')
        .eq('coach_id', _uid);
    if (currentCoachExtras.isNotEmpty && currentCoachExtras.first['id'] != extracurricularId) {
      throw Exception('Anda sudah membina ekstrakurikuler "${currentCoachExtras.first['name']}". 1 akun pembina hanya boleh mengurus 1 ekstrakurikuler.');
    }

    await _db.from('extracurriculars').update({
      'coach_id': _uid,
      'coach_name': myProfile['full_name'] ?? 'Pembina',
    }).eq('id', extracurricularId);
  }

  Future<List<Map<String, dynamic>>> getMembers(String extracurricularId) async =>
      await _db.from('memberships')
          .select('*, profiles!memberships_student_id_fkey(id,full_name,identifier,class_name,major)')
          .eq('extracurricular_id', extracurricularId)
          .eq('status', 'approved')
          .order('created_at');

  Future<String> createSchedule({
    required String extracurricularId,
    required String title,
    required DateTime date,
    String? startTime,
    String? endTime,
    String? location,
    String? notes,
  }) async {
    final row = await _db.from('schedules').insert({
      'extracurricular_id': extracurricularId,
      'title': title.trim(),
      'activity_date': date.toIso8601String().substring(0, 10),
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'notes': notes,
      'created_by': _uid,
    }).select('id').single();
    return row['id'] as String;
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
  }) async {
    await _db.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
    });
  }


  // ===== MODUL ADMIN: KATEGORI, AKTIVITAS, PRESTASI, DIKLAT, PROPOSAL =====
  Future<List<Map<String, dynamic>>> getCategories({bool activeOnly = false}) async {
    var query = _db.from('extracurricular_categories').select();
    if (activeOnly) query = query.eq('is_active', true);
    return await query.order('name');
  }

  Future<String> createCategory({required String name, String? icon, String? description}) async {
    final row = await _db.from('extracurricular_categories').insert({
      'name': name.trim(), 'icon': icon ?? '📌', 'description': description,
      'is_active': true, 'created_by': _uid,
    }).select('id').single();
    return row['id'].toString();
  }

  Future<void> updateCategory(String id, {required String name, String? icon, String? description, required bool isActive}) async {
    await _db.from('extracurricular_categories').update({
      'name': name.trim(), 'icon': icon ?? '📌', 'description': description, 'is_active': isActive,
    }).eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await _db.from('extracurricular_categories').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getActivityLogs({int limit = 100}) async =>
      await _db.from('activity_logs').select('*, profiles!activity_logs_actor_id_fkey(full_name)')
          .order('created_at', ascending: false).limit(limit);

  Future<void> logActivity({required String action, required String description, String? entityType, String? entityId}) async {
    await _db.from('activity_logs').insert({
      'actor_id': _uid, 'action': action, 'description': description,
      'entity_type': entityType, 'entity_id': entityId,
    });
  }

  Future<List<Map<String, dynamic>>> getAchievements({String? extracurricularId}) async {
    var query = _db.from('achievements').select('*, extracurriculars(name)');
    if (extracurricularId != null) query = query.eq('extracurricular_id', extracurricularId);
    return await query.order('achievement_date', ascending: false);
  }

  Future<String> createAchievement({String? extracurricularId, required String title, String? competitionName, String? award, DateTime? date, String? description, String? imageUrl}) async {
    final row = await _db.from('achievements').insert({
      'extracurricular_id': extracurricularId, 'title': title.trim(),
      'competition_name': competitionName, 'award': award,
      'achievement_date': date?.toIso8601String().substring(0, 10),
      'description': description, 'image_url': imageUrl, 'created_by': _uid,
    }).select('id').single();
    return row['id'].toString();
  }

  Future<void> updateAchievement(String id, Map<String, dynamic> values) async =>
      await _db.from('achievements').update(values).eq('id', id);
  Future<void> deleteAchievement(String id) async => await _db.from('achievements').delete().eq('id', id);

  Future<List<Map<String, dynamic>>> getTrainings({String? extracurricularId}) async {
    var query = _db.from('trainings').select('*, extracurriculars(name)');
    if (extracurricularId != null) query = query.eq('extracurricular_id', extracurricularId);
    return await query.order('start_date', ascending: false);
  }

  Future<String> createTraining({String? extracurricularId, required String title, String? description, DateTime? startDate, DateTime? endDate, String? location, int? quota}) async {
    final row = await _db.from('trainings').insert({
      'extracurricular_id': extracurricularId, 'title': title.trim(), 'description': description,
      'start_date': startDate?.toIso8601String().substring(0, 10),
      'end_date': endDate?.toIso8601String().substring(0, 10), 'location': location,
      'quota': quota, 'created_by': _uid,
    }).select('id').single();
    return row['id'].toString();
  }

  Future<void> updateTraining(String id, Map<String, dynamic> values) async =>
      await _db.from('trainings').update(values).eq('id', id);
  Future<void> deleteTraining(String id) async => await _db.from('trainings').delete().eq('id', id);

  Future<List<Map<String, dynamic>>> getProposals({String? status}) async {
    var query = _db.from('proposals').select('*, extracurriculars(name), profiles!proposals_submitted_by_fkey(full_name)');
    if (status != null) query = query.eq('status', status);
    return await query.order('created_at', ascending: false);
  }

  Future<String> createProposal({String? extracurricularId, required String title, String? description, num budget = 0, DateTime? eventDate}) async {
    final row = await _db.from('proposals').insert({
      'extracurricular_id': extracurricularId, 'submitted_by': _uid,
      'title': title.trim(), 'description': description, 'budget': budget,
      'event_date': eventDate?.toIso8601String().substring(0, 10),
    }).select('id').single();
    return row['id'].toString();
  }

  Future<void> reviewProposal(String id, {required String status}) async {
    if (!{'approved', 'rejected', 'forwarded'}.contains(status)) throw ArgumentError('Status proposal tidak valid.');
    await _db.from('proposals').update({
      'status': status, 'reviewed_by': _uid, 'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> deleteProposal(String id) async => await _db.from('proposals').delete().eq('id', id);

  // ===== MODUL DISPENSASI =====
  Future<List<Map<String, dynamic>>> getMyDispensations() async =>
      await _db.from('dispensation_requests').select('*, extracurriculars(name)')
          .eq('student_id', _uid).order('created_at', ascending: false);

  Future<List<Map<String, dynamic>>> getDispensations({String? status}) async {
    var query = _db.from('dispensation_requests')
        .select('*, profiles!dispensation_requests_student_id_fkey(full_name,identifier), extracurriculars(name)');
    if (status != null) query = query.eq('status', status);
    return await query.order('created_at', ascending: false);
  }

  Future<String> submitDispensation({String? extracurricularId, required String reason, required DateTime startDate, DateTime? endDate, String? attachmentUrl}) async {
    final row = await _db.from('dispensation_requests').insert({
      'student_id': _uid, 'extracurricular_id': extracurricularId, 'reason': reason.trim(),
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate?.toIso8601String().substring(0, 10), 'attachment_url': attachmentUrl,
    }).select('id').single();
    return row['id'].toString();
  }

  Future<void> reviewDispensation(String id, {required bool approve}) async {
    await _db.from('dispensation_requests').update({
      'status': approve ? 'approved' : 'rejected', 'reviewed_by': _uid,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

}
  