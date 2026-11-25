# SIEKSTRA-8 — Backend Integration Tahap 2

Project ini merupakan kelanjutan dari `SIEKSTRA8_Backend_Integration_Tahap1.zip`.

Perubahan tahap 2:
- Integrasi submit izin dan riwayat izin siswa.
- Integrasi submit pengunduran diri siswa.
- Integrasi daftar notifikasi siswa dan penandaan sudah dibaca.
- Integrasi antrian persetujuan izin dan pengunduran diri Pembina.
- Penambahan query repository yang membatasi hasil Pembina berdasarkan `coach_id`.

Sebelum menjalankan, gunakan konfigurasi Supabase milik project. Jalankan `flutter pub get`, `flutter analyze`, lalu `flutter run --dart-define-from-file=supabase_config.json`.

Status: file sudah diperbarui dan dikemas; belum dikompilasi di lingkungan ini karena Flutter SDK tidak tersedia.
