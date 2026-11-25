/// Konfigurasi Supabase dibaca dari --dart-define-from-file=supabase_config.json
/// atau menggunakan nilai default terbaru di bawah jika dijalankan langsung.
/// Hanya gunakan publishable / anon key di aplikasi Flutter. Jangan pernah gunakan secret/service_role.
class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ndzddmrumlmlszbcgbwy.supabase.co',
  );
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kemRkbXJ1bWxtbHN6YmNnYnd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQyNzQzMjcsImV4cCI6MjEwOTg1MDMyN30.Nfi0XwK_ARrWgL8c4zEF6CSjxEJH89zx7gEVm_4df10',
  );
  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
