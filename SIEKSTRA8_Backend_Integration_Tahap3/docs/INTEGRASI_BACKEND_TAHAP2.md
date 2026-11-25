# Integrasi Backend SIEKSTRA-8 — Tahap 2

Tahap 2 menghubungkan alur perizinan, pengunduran diri, riwayat izin, dan notifikasi siswa dengan Supabase, serta menampilkan antrian persetujuan pada role Pembina.

## Fitur yang dihubungkan

- Siswa mengirim permohonan izin ke `permission_requests`.
- Siswa melihat riwayat permohonan izin dari `permission_requests`.
- Siswa mengirim permohonan pengunduran diri ke `resignation_requests`.
- Siswa melihat notifikasi dari `notifications` dan dapat menandai satu/semua notifikasi sebagai dibaca.
- Pembina melihat permohonan izin yang terkait dengan ekstrakurikuler yang ditugaskan kepadanya.
- Pembina menyetujui/menolak permohonan izin.
- Pembina melihat permohonan pengunduran diri untuk ekstrakurikuler yang ditugaskan kepadanya.
- Pembina menyetujui/menolak permohonan pengunduran diri.

## Ketentuan data

- Pengajuan izin dan pengunduran diri mengambil ekstrakurikuler pertama yang berstatus `approved` dari keanggotaan siswa.
- Jika siswa belum memiliki keanggotaan aktif, aplikasi menolak pengiriman dan menampilkan pesan yang sesuai.
- Jenis izin dipetakan ke nilai schema: `Akademik`, `Sakit`, atau `Personal`.
- Tanggal awal izin menggunakan tanggal saat pengajuan. Form belum menyediakan pemilihan rentang tanggal pada tahap ini.
- Lampiran dokumen belum diunggah ke Supabase Storage.

## Belum termasuk

- Integrasi jadwal siswa/Pembina ke tabel `schedules`.
- Input presensi Pembina ke `attendance_sessions` dan `attendance_records`.
- CRUD Admin untuk seluruh data master.
- Integrasi prestasi, diklat, proposal, dan dispensasi.
- Notifikasi otomatis yang dibuat ketika status pengajuan berubah.
- Audit dan pengetatan seluruh RLS untuk produksi.

## Menjalankan dan memeriksa

```bash
flutter pub get
flutter analyze
flutter run --dart-define-from-file=supabase_config.json
```

Lingkungan penyusunan ZIP ini tidak memiliki Flutter/Dart SDK. Karena itu kompilasi dan `flutter analyze` harus dijalankan di komputer pengembang. Jangan menjalankan ulang `schema.sql` tanpa memastikan apakah tabel/policy sudah ada.
