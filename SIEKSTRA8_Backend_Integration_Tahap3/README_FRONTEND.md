# SIEKSTRA-8 — Frontend Admin, Pembina, dan Siswa

Paket ini melanjutkan project Flutter dari tahap sebelumnya. Desain utama ketiga role dipertahankan.

## Menjalankan

```bash
flutter pub get
flutter analyze
flutter run --dart-define-from-file=supabase_config.json
```

## Catatan

- Halaman tambahan Siswa pada tahap ini memakai data contoh lokal.
- Backend Supabase dan skema database tidak diubah.
- Jalankan `flutter analyze` dan uji navigasi pada komputer yang memiliki Flutter SDK sebelum menganggap build siap produksi.
- File konfigurasi Supabase berisi publishable key; jangan menggantinya dengan secret/service-role key dan jangan menonaktifkan RLS.
