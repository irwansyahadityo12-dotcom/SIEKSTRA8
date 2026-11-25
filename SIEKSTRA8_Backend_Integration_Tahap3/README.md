# SIEKSTRA-8 — Flutter + Supabase

Paket ini berisi aplikasi Flutter SIEKSTRA-8, fondasi backend Supabase, SQL schema/RLS, dan konfigurasi untuk project Supabase yang diberikan.

## A. Konfigurasi project

File `supabase_config.json` sudah diisi dengan Project URL dan **publishable key** yang Anda berikan. Publishable key memang ditujukan untuk aplikasi client; keamanan data tetap wajib dijaga dengan RLS. File ini di-ignore oleh Git.

Jangan pernah memasukkan `sb_secret_...` atau `service_role` ke aplikasi Flutter.

## B. Buat database

1. Buka https://supabase.com/dashboard dan pilih project `ndzddmrumlmlszbcgbwy`.
2. Buka **SQL Editor → New query**.
3. Buka `supabase/schema.sql` dari paket ini, salin seluruh isinya, lalu tempel ke SQL Editor.
4. Klik **Run** dan pastikan tidak ada error.

SQL membuat tabel profil, ekstrakurikuler, pendaftaran/keanggotaan, jadwal, presensi, izin, pengunduran diri, prestasi, diklat, proposal, dan notifikasi. RLS diaktifkan dan akses role dibatasi. Jalankan hanya satu kali pada project database baru ini; jika mengulang karena error, periksa pesan error terlebih dahulu.

## C. Jalankan aplikasi

Pastikan Flutter SDK sudah terpasang. Dari folder project:

```bash
flutter pub get
flutter run --dart-define-from-file=supabase_config.json
```

Build APK:

```bash
flutter build apk --release --dart-define-from-file=supabase_config.json
```

Jika Flutter versi lama belum mendukung `--dart-define-from-file`, jalankan dengan dua argumen:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://ndzddmrumlmlszbcgbwy.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=ISI_PUBLISHABLE_KEY_ANDA
```

## D. Akun dan role

- Registrasi di aplikasi hanya membuat akun **siswa**.
- Login memakai email dan password, kemudian role akun dicocokkan dengan pilihan role di layar login.
- Admin/Pembina harus dibuat oleh pengelola project melalui Supabase Auth terlebih dahulu, lalu role profilnya diubah melalui SQL Editor. Contoh:

```sql
update public.profiles set role = 'admin'
where email = 'admin@sekolah.sch.id';

update public.profiles set role = 'pembina'
where email = 'pembina@sekolah.sch.id';
```

Ganti alamat email contoh dengan email akun yang benar. Jangan membuat mekanisme agar pengguna bisa memilih sendiri role admin/pembina.

Jika email confirmation diaktifkan pada Supabase Auth, siswa perlu verifikasi email sebelum login.

## E. Integrasi Tahap 4

Tahap 4 memperbarui dashboard Admin, Data Siswa, Pendaftaran, Presensi, dashboard Pembina, persetujuan anggota Pembina, dashboard Siswa, katalog ekstrakurikuler Siswa, dan riwayat pendaftaran Siswa agar membaca data Supabase. Login tidak lagi menerima akun fallback/demo. Registrasi publik selalu membuat role siswa.

Langkah tambahan yang wajib dilakukan:

1. Jalankan `supabase/phase4_auth_roles_and_edge_function.sql` di SQL Editor.
2. Deploy function `supabase/functions/admin-create-user/index.ts` dengan `supabase functions deploy admin-create-user`.
3. Function menggunakan secret bawaan server Supabase; jangan menambahkan service-role key ke Flutter.
4. Buat akun Admin awal melalui Supabase Dashboard, lalu set role pada `profiles` melalui SQL tepercaya.

**Catatan cakupan:** masih ada beberapa modul sekunder yang perlu dimigrasikan dari data contoh/local store ke Supabase, termasuk beberapa halaman jadwal, prestasi, proposal, diklat, aktivitas, notifikasi Pembina, dan beberapa rekap. Periksa `BACKEND_INTEGRATION_STATUS.md`. Jangan menganggap seluruh halaman sudah 100% terintegrasi.

## F. Keamanan dan pemeriksaan

- Jangan commit `supabase_config.json` ke repository publik (sudah ditambahkan ke `.gitignore`).
- Publishable key bukan pengganti RLS. Jangan nonaktifkan RLS.
- Buat dan uji satu akun per role.
- Jangan masukkan data pribadi siswa asli sebelum aturan akses dan persetujuan sekolah diverifikasi.
- Storage bucket/lampiran belum dikonfigurasi; tambahkan bucket private dan Storage Policies sebelum unggah berkas.


## Integrasi Backend Supabase

Lihat [`docs/INTEGRASI_BACKEND_TAHAP1.md`](docs/INTEGRASI_BACKEND_TAHAP1.md) untuk setup database, pembuatan akun Admin/Pembina, dan cakupan integrasi tahap pertama.
