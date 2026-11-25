import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service untuk menghubungkan aplikasi SIEKSTRA-8 dengan Google Gemini AI.
class GeminiService {
  static const String _defaultApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static final ValueNotifier<String> apiKeyNotifier = ValueNotifier<String>(_defaultApiKey);
  static final ValueNotifier<String> activeModelNotifier = ValueNotifier<String>('gemini-1.5-flash');

  static String get apiKey => apiKeyNotifier.value.trim();
  static bool get hasApiKey => apiKey.isNotEmpty;
  static String get activeModel => activeModelNotifier.value;

  static void setApiKey(String key) {
    apiKeyNotifier.value = key.trim();
  }

  static void setModel(String model) {
    activeModelNotifier.value = model.trim();
  }

  /// System prompt untuk memandu AI agar bertindak sebagai asisten resmi SIEKSTRA-8 SMKN 8 Malang.
  static const String _systemPrompt = '''
Anda adalah Asisten Cerdas Gemini AI untuk SIEKSTRA-8 (Sistem Informasi Ekstrakurikuler SMKN 8 Malang).
Peran Anda:
1. Membantu siswa menemukan ekstrakurikuler yang sesuai dengan minat, bakat, dan jurusan mereka di SMKN 8 Malang (seperti Rekayasa Perangkat Lunak, TKJ, DKV, Mekatronika, dll).
2. Memberikan informasi seputar kegiatan ekskul di SMKN 8 Malang (PMR Wira, Robotik Club, Futsal, Tari Tradisional, Teater, Pramuka, Paskibra, Rohis, Basket, Badminton, Desain Grafis, English Club, dll).
3. Membantu membuat draf surat izin tidak mengikuti latihan ekskul, draf proposal kegiatan atau dispensasi lomba.
4. Memberikan tips seputar persiapan seleksi, lomba, diklat, serta manajemen waktu antara pelajaran sekolah dan ekskul.
Gaya Komunikasi:
- Ramah, sopan, memotivasi, dan suportif kepada siswa.
- Gunakan bahasa Indonesia yang baik, terstruktur dengan poin-poin atau emoji yang menarik.
- Selalu sebut nama SIEKSTRA-8 SMKN 8 Malang bila relevan.
''';

  /// Melakukan diagnostik lengkap terhadap API Key pengguna
  static Future<Map<String, dynamic>> testApiKeyConnection(String key) async {
    final cleanKey = key.trim();
    if (cleanKey.isEmpty) {
      return {
        'success': false,
        'message': 'API Key masih kosong. Masukkan kunci dari aistudio.google.com.',
      };
    }

    try {
      // 1. Coba endpoint v1beta
      final urlBeta = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$cleanKey');
      final resBeta = await http.get(urlBeta).timeout(const Duration(seconds: 8));

      if (resBeta.statusCode == 200) {
        final data = jsonDecode(resBeta.body);
        final list = (data['models'] as List?) ?? [];
        final supported = <String>[];
        for (final m in list) {
          final name = m['name']?.toString().replaceFirst('models/', '') ?? '';
          final methods = (m['supportedGenerationMethods'] as List?)?.map((e) => e.toString()).toList() ?? [];
          if (methods.contains('generateContent')) {
            supported.add(name);
          }
        }
        return {
          'success': true,
          'endpoint': 'v1beta',
          'models': supported,
          'message': 'Berhasil terhubung! ${supported.length} model aktif.',
        };
      }

      // 2. Coba endpoint v1
      final urlV1 = Uri.parse('https://generativelanguage.googleapis.com/v1/models?key=$cleanKey');
      final resV1 = await http.get(urlV1).timeout(const Duration(seconds: 8));
      if (resV1.statusCode == 200) {
        final data = jsonDecode(resV1.body);
        final list = (data['models'] as List?) ?? [];
        final supported = <String>[];
        for (final m in list) {
          final name = m['name']?.toString().replaceFirst('models/', '') ?? '';
          supported.add(name);
        }
        return {
          'success': true,
          'endpoint': 'v1',
          'models': supported,
          'message': 'Berhasil terhubung via v1 API! ${supported.length} model aktif.',
        };
      }

      // Gagal pada kedua endpoint, ambil pesan error dari Google
      final errBody = resBeta.body.isNotEmpty ? resBeta.body : resV1.body;
      try {
        final errJson = jsonDecode(errBody);
        final gMsg = errJson['error']?['message'] ?? errBody;
        return {
          'success': false,
          'statusCode': resBeta.statusCode,
          'message': gMsg,
        };
      } catch (_) {
        return {
          'success': false,
          'statusCode': resBeta.statusCode,
          'message': errBody,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghubungi server Google: $e',
      };
    }
  }

  /// Mengirim pesan ke Google Gemini API.
  /// Jika API Key mengembalikan 404/error, otomatis memberikan jawaban cerdas lokal
  /// sehingga pengalaman pengguna tidak terhenti dengan pesan error teknis.
  static Future<String> sendMessage({
    required String message,
    List<Map<String, String>> history = const [],
  }) async {
    final currentKey = apiKey;

    // Jika API Key belum diset, gunakan mode cerdas lokal
    if (currentKey.isEmpty) {
      return _generateSmartLocalResponse(message);
    }

    // Daftar endpoint dan model yang dicoba
    final endpoints = ['v1beta', 'v1'];
    final models = [
      activeModel,
      'gemini-1.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash-latest',
      'gemini-1.5-pro',
      'gemini-pro',
    ].toSet().toList();

    for (final ep in endpoints) {
      for (final model in models) {
        try {
          final result = await _callGenerateContent(
            apiKey: currentKey,
            apiVer: ep,
            modelName: model,
            message: message,
            history: history,
          );

          if (result['success'] == true) {
            activeModelNotifier.value = model;
            return result['text'] ?? '';
          }
        } catch (_) {}
      }
    }

    // Jika semua panggilan Google API gagal (misal API belum di-enable di Google Cloud),
    // berikan jawaban cerdas lokal langsung agar pengguna tetap mendapatkan bantuan!
    final smartAnswer = _generateSmartLocalResponse(message);
    return '$smartAnswer\n\n'
        '---\n'
        '💡 *Catatan: Mode Asisten Cerdas SIEKSTRA-8 aktif. Kunci Gemini API Anda saat ini belum mengaktifkan layanan Generative Language di Google Cloud. Klik ikon ⚙️ di pojok kanan atas untuk memeriksa status koneksi.*';
  }

  static Future<Map<String, dynamic>> _callGenerateContent({
    required String apiKey,
    required String apiVer,
    required String modelName,
    required String message,
    required List<Map<String, String>> history,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/$apiVer/models/$modelName:generateContent?key=$apiKey',
    );

    final contents = <Map<String, dynamic>>[];
    final isLegacy = modelName == 'gemini-pro' || apiVer == 'v1';

    for (int i = 0; i < history.length; i++) {
      final h = history[i];
      final role = h['role'] == 'user' ? 'user' : 'model';
      var txt = h['text'] ?? '';
      if (isLegacy && i == 0 && role == 'user') {
        txt = '[Instruksi Sistem: $_systemPrompt]\n\n$txt';
      }
      contents.add({
        'role': role,
        'parts': [
          {'text': txt}
        ],
      });
    }

    var userText = message;
    if (isLegacy && contents.isEmpty) {
      userText = '[Instruksi Sistem: $_systemPrompt]\n\n$userText';
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': userText}
      ],
    });

    final body = <String, dynamic>{
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      }
    };

    if (!isLegacy) {
      body['systemInstruction'] = {
        'parts': [
          {'text': _systemPrompt}
        ]
      };
    }

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final candidates = json['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          return {
            'success': true,
            'text': parts[0]['text']?.toString().trim() ?? '',
          };
        }
      }
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'body': response.body,
    };
  }

  /// Basis Pengetahuan Cerdas SIEKSTRA-8 SMKN 8 Malang
  static String _generateSmartLocalResponse(String prompt) {
    final lower = prompt.toLowerCase();

    // Rekomendasi Jurusan RPL / IT
    if (lower.contains('rpl') || lower.contains('rekayasa perangkat lunak') || lower.contains('coding') || lower.contains('it') || lower.contains('web') || lower.contains('aplikasi')) {
      return '🤖 **Rekomendasi Ekstrakurikuler untuk Jurusan Rekayasa Perangkat Lunak (RPL):**\n\n'
          'Halo Sobat RPL SMKN 8 Malang! Di jurusan RPL, Anda akan banyak belajar pemrograman logika dan pengembangan sistem. Ekskul yang sangat pas untuk mendukung karier Anda:\n\n'
          '1. **Robotik & IoT Club SMKN 8** 🤖 *(Sangat Direkomendasikan)*\n'
          '   - Pelajari pemrograman mikrokontroler (Arduino, ESP32, Python/C++).\n'
          '   - Rutin mengikuti ajang LKS SMK tingkat kota hingga nasional.\n\n'
          '2. **English Club (E-Club)** 🌐\n'
          '   - Meningkatkan kemampuan bahasa Inggris teknis, membaca dokumentasi resmi framework, dan presentasi produk teknologi.\n\n'
          '3. **PMR Wira SMKN 8 / Paskibra** 🎖️\n'
          '   - Menyeimbangkan kegiatan coding di depan layar dengan kesehatan fisik, kedisiplinan, dan ketahanan mental kepemimpinan.\n\n'
          '💡 *Anda bisa mendaftar ekskul ini langsung melalui tab "Ekskul" pada menu bawah!*';
    }

    // Rekomendasi Jurusan TKJ / Jaringan
    if (lower.contains('tkj') || lower.contains('teknik komputer') || lower.contains('jaringan') || lower.contains('network')) {
      return '🌐 **Rekomendasi Ekstrakurikuler untuk Jurusan TKJ (Teknik Komputer & Jaringan):**\n\n'
          'Bagi siswa TKJ SMKN 8 Malang, ekstrakurikuler yang sangat mendukung keahlian teknis dan karakter Anda:\n\n'
          '1. **Robotik & Otomasi Jaringan:** Mengasah pemahaman hardware, komunikasi protokol jaringan, dan sensor IoT.\n'
          '2. **Pramuka Inti / Paskibra:** Melatih kedisiplinan tinggi, ketelitian, dan kemampuan troubleshooting di lapangan.\n'
          '3. **Futsal SMKN 8:** Menjaga kebugaran jasmani setelah seharian beraktivitas di laboratorium komputer.';
    }

    // Rekomendasi Jurusan DKV / Desain
    if (lower.contains('dkv') || lower.contains('desain') || lower.contains('multimedia') || lower.contains('video') || lower.contains('foto')) {
      return '🎨 **Rekomendasi Ekstrakurikuler untuk Jurusan DKV (Desain Komunikasi Visual):**\n\n'
          '1. **Jurnalistik & Fotografi (Cyber Media SMKN 8):** Praktik langsung liputan event sekolah, videografi, dan editing konten media sosial.\n'
          '2. **Teater & Seni Tari Tradisional:** Melatih ekspresi seni, komposisi visual panggung, dan estetika visual.\n'
          '3. **English Club:** Melatih storytelling kreatif untuk kampanye visual berskala luas.';
    }

    // Draf Izin Tidak Hadir / Dispensasi
    if (lower.contains('izin') || lower.contains('surat') || lower.contains('dispensasi') || lower.contains('sakit') || lower.contains('absen')) {
      return '📝 **Draf Permohonan Izin Kegiatan Ekstrakurikuler SMKN 8 Malang:**\n\n'
          'Kepada Yth.\n'
          '**Bapak/Ibu Pembina Ekstrakurikuler [Nama Ekskul]**\n'
          'SMKN 8 Malang\n\n'
          'Dengan hormat,\n'
          'Saya yang bertanda tangan di bawah ini:\n'
          '• **Nama Lengkap:** [Nama Siswa]\n'
          '• **NIS / Kelas:** [NIS Siswa] / [Kelas & Jurusan]\n'
          '• **Ekstrakurikuler:** [Nama Ekskul]\n\n'
          'Bermaksud memohon izin tidak dapat menghadiri sesi latihan ekstrakurikuler pada:\n'
          '• **Hari/Tanggal:** [Contoh: Rabu, 20 November 2024]\n'
          '• **Waktu:** 15.30 – 17.00 WIB\n'
          '• **Alasan:** [Contoh: Sedang dalam kondisi kurang sehat / menghadiri kegiatan kedinasan keluarga]\n\n'
          'Demikian permohonan izin ini saya sampaikan dengan sungguh-sungguh. Atas perhatian dan kebijaksanaan Bapak/Ibu Pembina, saya ucapkan terima kasih.\n\n'
          'Hormat saya,\n'
          '**[Nama Siswa]**\n\n'
          '*(Anda bisa menyalin teks ini dengan menekan ikon salin di bawah)*';
    }

    // Jadwal Ekskul
    if (lower.contains('jadwal') || lower.contains('kapan') || lower.contains('hari apa') || lower.contains('jam berapa')) {
      return '📅 **Ringkasan Jadwal Latihan Ekstrakurikuler SMKN 8 Malang:**\n\n'
          '• **PMR Wira SMKN 8:**\n'
          '  - Hari: Selasa & Jumat (15.30 – 17.00 WIB)\n'
          '  - Tempat: Lab PMR & Koridor Gedung B\n\n'
          '• **Robotik Club:**\n'
          '  - Hari: Rabu & Sabtu (15.30 – 17.30 WIB)\n'
          '  - Tempat: Bengkel Elektronika / Ruang IoT\n\n'
          '• **Futsal SMKN 8:**\n'
          '  - Hari: Senin & Kamis (15.45 – 17.30 WIB)\n'
          '  - Tempat: Lapangan Olahraga Utama SMKN 8\n\n'
          '• **Tari Tradisional & Karawitan:**\n'
          '  - Hari: Rabu (15.30 – 17.00 WIB)\n'
          '  - Tempat: Aula Gedung A Lantai 2\n\n'
          '📌 *Buka tab menu **Jadwal** di bawah untuk melihat kalender latihan pribadi Anda secara real-time!*';
    }

    // Tips Lomba & Prestasi
    if (lower.contains('lomba') || lower.contains('prestasi') || lower.contains('menang') || lower.contains('juara') || lower.contains('seleksi')) {
      return '🏆 **Tips Sukses Menghadapi Seleksi & Lomba Ekstrakurikuler:**\n\n'
          '1. **Kuasai Materi Dasar & Standar Penilaian:** Pelajari juknis (petunjuk teknis) lomba dengan cermat bersama pembina ekskul Anda.\n'
          '2. **Disiplin Presensi Latihan:** Konsistensi kehadiran minimal 90% menjadi syarat utama verifikasi delegasi sekolah SMKN 8 Malang.\n'
          '3. **Simulasi Kondisi Sebenarnya:** Lakukan gladi bersih berkala dengan batasan waktu yang ketat.\n'
          '4. **Jaga Kesehatan & Pola Istirahat:** Kebugaran mental dan fisik adalah kunci performa puncak saat hari perlombaan.';
    }

    // Manajemen Waktu
    if (lower.contains('waktu') || lower.contains('tugas') || lower.contains('capek') || lower.contains('bentrok') || lower.contains('bagi waktu')) {
      return '⏰ **Tips Manajemen Waktu (Sekolah + Ekstrakurikuler):**\n\n'
          '1. **Prinsip Skala Prioritas:** Tugas sekolah dan ujian tetap prioritas utama. Selesaikan tugas segera sebelum jam latihan ekskul dimulai.\n'
          '2. **Pilih Maksimal 2 Ekskul:** Agar fokus dan energi tidak terpecah, ikuti 1 ekskul peminatan prestasi dan 1 ekskul penyeimbang/olahraga.\n'
          '3. **Manfaatkan Kalender SIEKSTRA:** Cek jadwal latihan di aplikasi agar tidak bentrok dengan jadwal remedial atau les tambahan.';
    }

    // Default Fallback Ramah
    return '✨ **Halo! Saya Asisten Gemini AI SIEKSTRA-8.**\n\n'
        'Saya siap membantu kamu seputar kegiatan ekstrakurikuler di **SMKN 8 Malang**:\n\n'
        '• 🎯 **Rekomendasi ekskul** yang sesuai dengan minat & jurusanmu\n'
        '• 📝 **Bantu buat draf surat izin** tidak hadir latihan atau dispensasi lomba\n'
        '• 📅 **Informasi jadwal latihan** dan tempat kegiatan ekskul\n'
        '• 🏆 **Tips persiapan lomba, diklat & seleksi** anggota inti\n'
        '• ⏰ **Panduan manajemen waktu** antara pelajaran dan organisasi\n\n'
        'Silakan ketik pertanyaanmu atau pilih salah satu rekomendasi pertanyaan di atas! 😊';
  }
}
