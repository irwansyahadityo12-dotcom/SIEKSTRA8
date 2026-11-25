-- ==============================================================================
-- Fix RLS Policy untuk Tabel notifications
-- Mengizinkan siswa/user terautentikasi mengirim notifikasi & permohonan konsultasi
-- ==============================================================================

-- 1. Pastikan RLS aktif pada tabel notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 2. Hapus policy lama yang membatasi hanya staff (admin/pembina)
DROP POLICY IF EXISTS "notifications staff insert" ON public.notifications;
DROP POLICY IF EXISTS "notifications insert authenticated" ON public.notifications;

-- 3. Buat policy baru: Semua user terautentikasi dapat membuat (INSERT) notifikasi
--    (Contoh: siswa mengirim permohonan konsultasi ke pembina, atau membuat pengingat untuk diri sendiri)
CREATE POLICY "notifications insert authenticated" ON public.notifications
  FOR INSERT TO authenticated
  WITH CHECK (true);

-- 4. Pastikan policy SELECT tetap mengizinkan user membaca notifikasinya sendiri
DROP POLICY IF EXISTS "notifications own read" ON public.notifications;
CREATE POLICY "notifications own read" ON public.notifications
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

-- 5. Pastikan policy UPDATE tetap mengizinkan user memperbarui notifikasinya sendiri (misal: tandai sudah dibaca)
DROP POLICY IF EXISTS "notifications own update" ON public.notifications;
CREATE POLICY "notifications own update" ON public.notifications
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- 6. Opsional: Tambahkan policy DELETE jika user ingin menghapus notifikasinya sendiri
DROP POLICY IF EXISTS "notifications own delete" ON public.notifications;
CREATE POLICY "notifications own delete" ON public.notifications
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

