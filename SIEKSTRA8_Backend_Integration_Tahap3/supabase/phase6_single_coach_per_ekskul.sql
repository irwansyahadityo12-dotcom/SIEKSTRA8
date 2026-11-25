-- SIEKSTRA-8 Phase 6: 1 Akun Pembina Hanya Mengurus 1 Ekstrakulikuler
-- Jalankan di SQL Editor Supabase

-- 1. Perbarui role akun pembina PMR yang telah dibuat
update public.profiles
set role = 'pembina',
    class_name = 'PMR Wira SMKN 8',
    major = 'ASN Guru',
    is_active = true
where email = 'pembina.pmr@smkn8malang.sch.id';

-- 2. Hubungkan ekstrakurikuler "PMR Wira SMKN 8" ke akun pembina ini
-- (Ini menghubungkan akun pembina ke ekskul agar bisa mengelola jadwal & presensi)
update public.extracurriculars
set coach_id = (select id from public.profiles where email = 'pembina.pmr@smkn8malang.sch.id'),
    coach_name = 'Budi Santoso, S.Pd'
where name ilike '%PMR%';

-- 3. Lepaskan duplikasi pembina (khresnas.r sebelumnya membina Robotik dan Volly Ball sekaligus)
-- agar Volly Ball dapat ditugaskan ke pembina yang lain:
update public.extracurriculars
set coach_id = null,
    coach_name = 'Belum ditugaskan'
where name = 'Volly Ball SMKN 8 Malang'
  and coach_id = '4011b445-61cf-4057-a451-1b2f11335b8f';

-- 4. Terapkan unique constraint / index di tabel extracurriculars
-- Menjamin secara mutlak di level database bahwa 1 coach_id hanya bisa membina 1 ekstrakurikuler:
create unique index if not exists idx_extracurriculars_single_coach
on public.extracurriculars(coach_id)
where coach_id is not null;
