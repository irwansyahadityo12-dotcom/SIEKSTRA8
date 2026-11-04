# SIEKSTRA-8

Sistem Informasi Ekstrakurikuler SMKN 8 Malang. **Satu aplikasi Flutter** untuk tiga peran: Siswa, Pembina, dan Admin Kesiswaan (frontend UI dari desain Figma).

## Menjalankan
```bash
flutter create . --org id.sch.smkn8malang   # sekali saja: generate android/ios/web
flutter pub get
flutter run            # atau: flutter run -d chrome
```
`flutter create .` aman: hanya menambah folder platform, tidak menimpa `lib/` maupun `pubspec.yaml`.

## Alur
Welcome → Login. Di layar Login pilih peran lalu tekan "Masuk ke SIEKSTRA":

| Peran | Tujuan |
|---|---|
| Siswa | Beranda siswa (5 tab: Beranda, Ekskul, Jadwal, Notifikasi, Profil) |
| Pembina | Beranda pembimbing (5 tab: Beranda, Ekskul, Anggota, Daftar, Jadwal) |
| Admin | Beranda admin (6 tab: Beranda, Ekstra, Pendaftaran, Proposal, Presensi, Sistem) |

"Daftar" selalu membuat akun siswa. Tombol "Keluar dari Akun" di tiap peran kembali ke Login.

## Struktur `lib/`
```
lib/
  main.dart          entry point (MaterialApp, tema ikut peran aktif)
  app/session.dart   pilih peran saat login (enterRole) dan keluar akun (logout)
  siswa/             core/ (theme, data, widgets) + screens/ (15 layar)
  pembina/           theme/ + widgets/ + screens/ (15 layar)
  admin/             theme.dart, shell.dart, widgets/ + screens/ (14 layar)
```
Tiap folder peran berdiri sendiri (punya tema dan widget sendiri) dan tidak saling impor.
Hanya `app/session.dart` yang mengimpor ketiganya, memakai prefix karena nama class-nya mirip.
