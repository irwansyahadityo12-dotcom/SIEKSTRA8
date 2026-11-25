 -- SIEKSTRA-8 Tahap 3: batasi pengelolaan jadwal dan presensi per ekstrakurikuler.
-- Jalankan melalui Supabase SQL Editor setelah schema.sql.

-- Jadwal: Admin boleh mengelola semua; Pembina hanya ekskul yang dibinanya.
drop policy if exists "schedule staff manage" on public.schedules;
create policy "schedule staff manage own extracurricular" on public.schedules
for all to authenticated
using (
  public.current_app_role() = 'admin'
  or exists (
    select 1 from public.extracurriculars e
    where e.id = extracurricular_id and e.coach_id = auth.uid()
  )
)
with check (
  public.current_app_role() = 'admin'
  or exists (
    select 1 from public.extracurriculars e
    where e.id = extracurricular_id and e.coach_id = auth.uid()
  )
);

-- Sesi presensi: Admin semua; Pembina hanya sesi ekskul binaannya.
drop policy if exists "session read staff" on public.attendance_sessions;
create policy "session read admin or own coach" on public.attendance_sessions
for select to authenticated
using (
  public.current_app_role() = 'admin'
  or exists (
    select 1 from public.extracurriculars e
    where e.id = extracurricular_id and e.coach_id = auth.uid()
  )
);
drop policy if exists "session staff manage" on public.attendance_sessions;
create policy "session manage admin or own coach" on public.attendance_sessions
for all to authenticated
using (
  public.current_app_role() = 'admin'
  or exists (
    select 1 from public.extracurriculars e
    where e.id = extracurricular_id and e.coach_id = auth.uid()
  )
)
with check (
  public.current_app_role() = 'admin'
  or exists (
    select 1 from public.extracurriculars e
    where e.id = extracurricular_id and e.coach_id = auth.uid()
  )
);

-- Catatan presensi: Admin semua; Pembina hanya catatan sesi dari ekskulnya.
drop policy if exists "attendance staff manage" on public.attendance_records;
create policy "attendance manage admin or own coach" on public.attendance_records
for all to authenticated
using (
  public.current_app_role() = 'admin'
  or exists (
    select 1 from public.attendance_sessions s
    join public.extracurriculars e on e.id = s.extracurricular_id
    where s.id = session_id and e.coach_id = auth.uid()
  )
)
with check (
  public.current_app_role() = 'admin'
  or exists (
    select 1 from public.attendance_sessions s
    join public.extracurriculars e on e.id = s.extracurricular_id
    where s.id = session_id and e.coach_id = auth.uid()
  )
);

-- Pembina hanya dapat membaca presensi dari ekskul binaannya; siswa tetap dapat membaca miliknya.
drop policy if exists "attendance read own or staff" on public.attendance_records;
create policy "attendance read own or authorized staff" on public.attendance_records
for select to authenticated
using (
  student_id = auth.uid()
  or public.current_app_role() = 'admin'
  or exists (
    select 1 from public.attendance_sessions s
    join public.extracurriculars e on e.id = s.extracurricular_id
    where s.id = session_id and e.coach_id = auth.uid()
  )
);
