# SIEKSTRA-8 — Frontend Siswa (Tahap 1)

## Dasar pengerjaan
- Melanjutkan project dari `SIEKSTRA8_Frontend_Admin_Pembina_Tahap3.zip`.
- Mempertahankan tema Siswa yang sudah ada: biru `#1D4ED8`, latar `#F5F7FD`, kartu putih, Plus Jakarta Sans, dan widget pada `lib/siswa/core/widgets.dart`.
- Tidak mengubah Supabase schema, autentikasi, atau repository.
- Halaman baru menggunakan data contoh lokal dan menampilkan penjelasan bahwa sinkronisasi backend belum dilakukan.

## Halaman baru
- `lib/siswa/screens/registration_status_screen.dart` — status dan tahapan verifikasi pendaftaran.
- `lib/siswa/screens/registration_history_screen.dart` — daftar riwayat pengajuan ekstrakurikuler.
- `lib/siswa/screens/membership_detail_screen.dart` — detail keanggotaan ekstrakurikuler.
- `lib/siswa/screens/permission_history_screen.dart` — riwayat permohonan izin.
- `lib/siswa/screens/achievement_detail_screen.dart` — rincian prestasi.
- `lib/siswa/screens/account_settings_screen.dart` — informasi akun dan preferensi notifikasi.
- `lib/siswa/screens/help_screen.dart` — FAQ dan informasi bantuan.

## Perubahan navigasi dan aksi
- Menu Profil diarahkan ke halaman Data Diri/Pengaturan, Detail Keanggotaan, Status Pendaftaran, Riwayat Pendaftaran, Riwayat Izin, Detail Prestasi, dan Pusat Bantuan.
- Submit formulir pendaftaran mengarahkan siswa ke Status Pendaftaran.
- Submit formulir izin mengarahkan siswa ke Riwayat Pengajuan Izin.
- `PrimaryButton` dan `SoftButton` sekarang menghormati callback `null`, sehingga tombol tanpa aksi menjadi nonaktif dan tombol dengan syarat yang belum terpenuhi benar-benar tidak bisa ditekan.

## Batasan
- Data halaman baru masih contoh lokal; belum tersambung ke Supabase.
- Penyimpanan perubahan pengaturan akun hanya menampilkan konfirmasi lokal.
- Belum dilakukan `flutter analyze` atau build runtime karena Flutter/Dart SDK tidak tersedia di lingkungan pengerjaan ini. Perlu diuji pada komputer pengguna.
