# SIEKSTRA-8 — Frontend Pembina Tahap 1

## Perubahan

1. Menambahkan `record_detail_screen.dart` sebagai halaman detail reusable untuk anggota, prestasi, agenda diklat, peserta, dan informasi akun.
2. Menambahkan `record_form_screen.dart` untuk form tambah/edit data Pembina dengan validasi dan dukungan nilai awal.
3. Menambahkan `help_screen.dart` dan menghubungkannya dari menu Bantuan pada Profil Pembina.
4. Kartu pada Manajemen Anggota sekarang dapat dibuka ke detail anggota.
5. Menu Edit Profil membuka formulir yang telah diisi data contoh; menu Data Akun membuka detail informasi akun.
6. Menu Tambah Prestasi, Detail & Arsip, Sertifikat, Detail Tim Peserta, dan Edit Jadwal pada halaman Prestasi kini memiliki tujuan navigasi.
7. Menu Buat Diklat, Kelola Peserta, Edit, Detail, Buka Daftar, Nilai & Sertifikat, dan Arsip Dokumentasi pada halaman Diklat kini memiliki aksi atau umpan balik.
8. Tombol persetujuan/penolakan izin dan pengunduran diri diberi umpan balik/konfirmasi lokal.
9. Tombol ekspor daftar anggota dan rekap presensi diberi informasi bahwa ekspor belum diimplementasikan.

## Batasan

- Data tetap contoh lokal dan tidak disimpan ke Supabase.
- Tombol ekspor PDF/Excel, unggah/lihat lampiran, WhatsApp, dan pengiriman notifikasi belum diimplementasikan.
- Form mengembalikan nilai saat ditutup, tetapi belum memperbarui data sumber secara persisten.
- Perlu menjalankan `flutter pub get`, `flutter analyze`, dan `flutter run` pada komputer pengguna. Flutter SDK tidak tersedia pada lingkungan pembuatan paket.

## Saran pengujian

- Pembina → Anggota → buka salah satu kartu untuk melihat Detail Anggota.
- Pembina → Profil → Bantuan.
- Pembina → Profil → Edit Profil dan Data Akun.
- Pembina → Profil → Lomba & Prestasi → coba Tambah, Detail & Arsip, Sertifikat, Edit, dan Detail Tim Peserta.
- Pembina → Profil → Kelola Diklat → coba Buat Diklat, Kelola Peserta, Edit, Detail, dan Nilai & Sertifikat.
- Pembina → Pengunduran Diri / Persetujuan Izin → uji konfirmasi dan umpan balik.
