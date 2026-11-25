# SIEKSTRA-8 — Patch Backend Tahap 5

## Status
Patch ini menambahkan lapisan repository Supabase untuk modul yang sebelumnya belum mempunyai operasi backend lengkap, serta SQL tambahan untuk kategori, log aktivitas, dan dispensasi.

## File berubah
- `lib/data/siekstra_repository.dart`: operasi CRUD kategori, aktivitas, prestasi, diklat, proposal, dan dispensasi.
- `supabase/phase5_remaining_modules.sql`: tabel tambahan dan RLS.

## Urutan penerapan
1. Backup database terlebih dahulu.
2. Jalankan `supabase/phase5_remaining_modules.sql` di Supabase SQL Editor.
3. Jalankan `flutter pub get`.
4. Jalankan `flutter analyze`.
5. Uji login masing-masing role dan uji query repository.

Jangan menghapus atau mengganti tiga file SQL tahap sebelumnya.

## Pemetaan modul ke tabel
| Modul | Tabel |
|---|---|
| Katalog/kelola ekstrakurikuler | `extracurriculars` |
| Kategori filter | `extracurricular_categories` (baru) |
| Pendaftaran/anggota | `memberships` |
| Jadwal | `schedules` |
| Presensi | `attendance_sessions`, `attendance_records` |
| Prestasi | `achievements` |
| Diklat | `trainings` |
| Proposal | `proposals` |
| Notifikasi | `notifications` |
| Dispensasi | `dispensation_requests` (baru) |
| Izin | `permission_requests` |
| Pengunduran diri | `resignation_requests` |
| Aktivitas admin | `activity_logs` (baru) |

## Batasan patch
Patch ini menyediakan tabel dan operasi repository; tidak otomatis mengubah seluruh widget/halaman yang masih membaca state lokal. Halaman UI yang masih memakai `EkstraStore`, daftar literal, atau tombol dengan toast mode contoh masih perlu dihubungkan ke method repository. `flutter`/`dart` tidak tersedia di lingkungan pembuatan patch, dan tidak ada kredensial Supabase untuk menjalankan pengujian integrasi, sehingga patch belum boleh dianggap lulus build atau lulus runtime.
