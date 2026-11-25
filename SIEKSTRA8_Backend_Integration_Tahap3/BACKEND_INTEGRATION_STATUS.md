# SIEKSTRA-8 — Integrasi Backend Tahap 4

## Perubahan pada tahap ini

- Login hanya menerima autentikasi Supabase yang valid dan profil dengan role yang sesuai; fallback akun contoh dihapus.
- Registrasi publik mengirim metadata role siswa. Trigger database juga menetapkan role siswa secara paksa.
- Dashboard Admin menghitung total ekstrakurikuler, siswa aktif, pembina aktif, anggota disetujui, sesi presensi, dan persentase kehadiran dari Supabase.
- Halaman Data Siswa Admin mengambil profil siswa dan keanggotaan dari Supabase; tidak lagi menampilkan master siswa buatan.
- Dashboard Pembina mengambil jumlah ekstrakurikuler binaan, anggota, pendaftar, dan sesi dari Supabase.
- Dashboard Siswa mengambil keanggotaan, jadwal, profil, dan katalog ekstrakurikuler dari Supabase.
- Riwayat pendaftaran Siswa dan persetujuan anggota Pembina mulai menggunakan data database, bukan daftar contoh.
- Pembuatan akun Pembina dipindahkan ke Edge Function yang memverifikasi sesi Admin dan menggunakan service-role key hanya di server.

## Yang wajib dilakukan di Supabase

1. Jalankan `supabase/phase4_auth_roles_and_edge_function.sql` di SQL Editor.
2. Deploy Edge Function: `supabase functions deploy admin-create-user`.
3. Pastikan secret bawaan Supabase tersedia untuk function: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, dan `SUPABASE_SERVICE_ROLE_KEY`. Jangan pernah menaruh service-role key di Flutter atau file konfigurasi client.
4. Pastikan akun Admin awal dibuat melalui Supabase Dashboard/SQL tepercaya, lalu set `profiles.role = 'admin'` untuk UUID akun tersebut.
5. Jalankan `flutter pub get` lalu `flutter analyze` pada komputer yang memiliki Flutter SDK.
6. Jalankan aplikasi dengan konfigurasi project: `flutter run --dart-define-from-file=supabase_config.json`.

## Catatan penting

- ZIP sumber belum menyertakan akses ke project Supabase untuk menguji query/RLS secara langsung.
- Lingkungan pengerjaan ini tidak memiliki Flutter/Dart SDK, sehingga `flutter analyze`, build Android, dan pengujian runtime belum dapat dijalankan di sini.
- Modul admin/pembina/siswa yang masih memiliki daftar contoh di halaman selain yang disebut di atas harus dimigrasikan berikutnya sebelum aplikasi dinyatakan 100% terintegrasi. Jangan menganggap seluruh halaman sudah selesai hanya karena dashboard telah terhubung.


## Patch Tahap 5 (17 November 2026)

- Menambahkan `supabase/phase5_remaining_modules.sql` untuk tabel `extracurricular_categories`, `activity_logs`, dan `dispensation_requests` beserta RLS.
- Menambahkan method repository untuk kategori, log aktivitas, prestasi, diklat, proposal, dan dispensasi.
- Patch ini belum menghubungkan semua widget/halaman yang masih memakai state lokal; lihat `PHASE5_MIGRATION_NOTES.md`.
- SQL tahap 5 belum dijalankan oleh pengembang karena tidak memiliki akses ke project Supabase pengguna. Pengguna perlu menjalankannya setelah backup.
