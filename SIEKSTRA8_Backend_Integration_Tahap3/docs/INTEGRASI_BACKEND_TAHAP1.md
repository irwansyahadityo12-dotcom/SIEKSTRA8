# Integrasi Backend Supabase — Tahap 1

Tahap ini menghubungkan alur inti pendaftaran ekstrakurikuler:

1. Siswa mengambil katalog ekstrakurikuler dari `public.extracurriculars`.
2. Siswa mengirim pendaftaran ke `public.memberships`.
3. Siswa melihat status pendaftaran dari `public.memberships`.
4. Pembina melihat pendaftaran pending untuk ekstrakurikuler yang `coach_id`-nya sama dengan akun Pembina.
5. Admin melihat seluruh pendaftaran pending dan dapat menyetujui/menolak.

## Yang belum terintegrasi pada tahap ini

- CRUD seluruh halaman Admin (data siswa, pembina, ekstrakurikuler, proposal, dispensasi, diklat, prestasi).
- Pengajuan izin dan pengunduran diri dari layar Siswa.
- Persetujuan izin/pengunduran diri dari layar Pembina.
- Input dan rekap presensi langsung ke database.
- Pengelolaan jadwal, notifikasi, dan unggah lampiran.
- Pembuatan akun Admin/Pembina dari dalam aplikasi.

## Persiapan Supabase

1. Buka Supabase Dashboard untuk project yang URL-nya sudah tersimpan di `supabase_config.json`.
2. Masuk ke SQL Editor.
3. Jika schema belum pernah dijalankan, jalankan isi `supabase/schema.sql`.
4. Pastikan tabel `profiles`, `extracurriculars`, dan `memberships` muncul di Table Editor.
5. Pastikan katalog ekstrakurikuler tersedia di `public.extracurriculars`.

Jangan menaruh `service_role` atau secret key di aplikasi Flutter. File konfigurasi saat ini memakai publishable key.

## Menjalankan Flutter

Dari folder project:

```bash
flutter pub get
flutter run --dart-define-from-file=supabase_config.json
```

Untuk pemeriksaan:

```bash
flutter analyze
```

## Membuat akun Admin dan Pembina

Registrasi dari aplikasi hanya membuat akun Siswa.

1. Buat akun Admin/Pembina melalui Supabase Authentication > Users.
2. Trigger `on_auth_user_created` akan membuat baris `profiles` dengan role awal `siswa`.
3. Ubah role melalui SQL Editor:

```sql
update public.profiles
set role = 'admin'
where email = 'admin@contoh.sch.id';

update public.profiles
set role = 'pembina'
where email = 'pembina@contoh.sch.id';
```

4. Untuk menugaskan Pembina ke ekstrakurikuler, gunakan UUID profile Pembina:

```sql
update public.extracurriculars
set coach_id = 'UUID_PROFILE_PEMBINA'
where name = 'Nama Ekstrakurikuler';
```

Ganti email, UUID, dan nama ekstrakurikuler dengan data sebenarnya.

## Catatan keamanan

Schema saat ini memakai `is_staff()` untuk beberapa policy yang memberi Admin dan Pembina akses bersama ke banyak data. Query layar Pembina pada tahap ini difilter ke ekstrakurikuler yang ditugaskan kepadanya, tetapi policy RLS database masih perlu diperketat agar Pembina tidak dapat membaca/mengubah data ekskul Pembina lain melalui request langsung. Jangan gunakan konfigurasi policy saat ini sebagai pengaturan produksi sebelum audit RLS selesai.

## Status validasi

Perubahan kode sudah ditulis ke project dan dimasukkan ke ZIP. Lingkungan pembuatan ini tidak memiliki Flutter/Dart SDK, sehingga `flutter analyze` dan kompilasi Android belum dapat dijalankan di sini. Jalankan perintah tersebut di komputer pengembang dan kirimkan output jika ada error.
