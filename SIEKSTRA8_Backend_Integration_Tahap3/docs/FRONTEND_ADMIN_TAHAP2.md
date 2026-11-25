# SIEKSTRA-8 — Frontend Admin Tahap 2

## Perubahan tahap ini

1. Form tambah/edit generik mendukung `initialValues` sehingga halaman edit dapat menampilkan data contoh yang dipilih.
2. Form mengembalikan map nilai yang diisi ketika disimpan. Saat ini nilai tersebut belum disimpan permanen atau dipersistensikan ke repository; penyimpanan masih menunggu integrasi state/data dan Supabase.
3. Halaman Edit Data Siswa kini terisi dengan nama, NISN, kelas, jurusan, dan ekstrakurikuler dari kartu siswa yang dipilih.
4. Halaman Edit Akun Pembina kini terisi dengan nama, ID/NIP, username, ekstrakurikuler, dan jenis pembina dari kartu yang dipilih.
5. Halaman Edit Ekstrakurikuler kini terisi dengan informasi cabang yang dipilih.
6. Tombol Rincian pada rekap presensi membuka halaman detail rekap siswa.
7. Tombol Detail pada dua agenda diklat membuka halaman detail agenda, bukan hanya menampilkan toast.
8. Tombol aksi tertentu yang sebelumnya tidak memiliki callback diberi umpan balik yang menjelaskan bahwa tindakan masih simulasi atau menunggu modul terkait.

## Batasan

- Seluruh data tetap data contoh lokal.
- Menekan Simpan pada form memvalidasi dan mengembalikan nilai ke halaman sebelumnya, tetapi belum memperbarui daftar sumber karena belum ada state/repository yang mengelola data tersebut.
- Ekspor PDF/XLS, pengiriman WhatsApp, reset password, sinkronisasi, dan penerbitan dokumen resmi belum diimplementasikan.
- Flutter SDK tidak tersedia di lingkungan pembuatan paket ini, sehingga `flutter analyze` dan uji runtime perlu dijalankan pada komputer pengembang.

## Langkah uji

Dari folder project:

```bash
flutter pub get
flutter analyze
flutter run --dart-define-from-file=supabase_config.json
```

Uji khusus:
- Admin → Sistem → Data Siswa → Edit Data; pastikan field terisi dari kartu siswa.
- Admin → Sistem → Akun Pembina → Edit; pastikan field terisi dari kartu pembina.
- Admin → Ekstra → Edit; pastikan field terisi dari kartu ekskul.
- Admin → Presensi → Rincian pada siswa dengan kehadiran baik.
- Admin → Diklat → Detail pada dua agenda pertama.
