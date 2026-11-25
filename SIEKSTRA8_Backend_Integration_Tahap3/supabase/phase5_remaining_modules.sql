-- SIEKSTRA-8 Phase 5: tabel tambahan untuk modul yang belum ditampung schema awal.
-- Aman dijalankan setelah schema.sql, phase3, dan phase4.
-- Tidak menghapus tabel atau data yang sudah ada.

create table if not exists public.extracurricular_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  icon text not null default '📌',
  description text,
  is_active boolean not null default true,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  description text not null,
  entity_type text,
  entity_id uuid,
  created_at timestamptz not null default now()
);

create table if not exists public.dispensation_requests (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  extracurricular_id uuid references public.extracurriculars(id) on delete set null,
  reason text not null,
  start_date date not null,
  end_date date,
  attachment_url text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  reviewed_by uuid references public.profiles(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  constraint dispensation_dates_valid check (end_date is null or end_date >= start_date)
);

create index if not exists idx_activity_logs_created on public.activity_logs(created_at desc);
create index if not exists idx_dispensation_student on public.dispensation_requests(student_id, created_at desc);
create index if not exists idx_dispensation_extra on public.dispensation_requests(extracurricular_id, status);

alter table public.extracurricular_categories enable row level security;
alter table public.activity_logs enable row level security;
alter table public.dispensation_requests enable row level security;

grant select, insert, update, delete on public.extracurricular_categories to authenticated;
grant select, insert on public.activity_logs to authenticated;
grant select, insert, update on public.dispensation_requests to authenticated;

-- Kategori dapat dibaca semua pengguna login; hanya Admin mengelola.
drop policy if exists "category read authenticated" on public.extracurricular_categories;
create policy "category read authenticated" on public.extracurricular_categories
for select to authenticated using (true);
drop policy if exists "category admin insert" on public.extracurricular_categories;
create policy "category admin insert" on public.extracurricular_categories
for insert to authenticated with check (public.is_admin());
drop policy if exists "category admin update" on public.extracurricular_categories;
create policy "category admin update" on public.extracurricular_categories
for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "category admin delete" on public.extracurricular_categories;
create policy "category admin delete" on public.extracurricular_categories
for delete to authenticated using (public.is_admin());

-- Aktivitas hanya dapat dibaca Admin dan Pembina; aktor mencatat aktivitasnya sendiri.
drop policy if exists "activity log staff read" on public.activity_logs;
create policy "activity log staff read" on public.activity_logs
for select to authenticated using (public.is_staff());
drop policy if exists "activity log self insert" on public.activity_logs;
create policy "activity log self insert" on public.activity_logs
for insert to authenticated with check (actor_id = auth.uid() and public.is_staff());

-- Siswa mengajukan dispensasi sendiri. Admin dapat melihat semua; Pembina hanya yang ekskulnya dibina.
drop policy if exists "dispensation read own or assigned staff" on public.dispensation_requests;
create policy "dispensation read own or assigned staff" on public.dispensation_requests
for select to authenticated using (
  student_id = auth.uid()
  or public.is_admin()
  or exists (
    select 1 from public.extracurriculars e
    where e.id = extracurricular_id and e.coach_id = auth.uid()
  )
);
drop policy if exists "dispensation student insert own" on public.dispensation_requests;
create policy "dispensation student insert own" on public.dispensation_requests
for insert to authenticated with check (
  student_id = auth.uid() and public.current_app_role() = 'siswa' and status = 'pending'
);
drop policy if exists "dispensation assigned staff review" on public.dispensation_requests;
create policy "dispensation assigned staff review" on public.dispensation_requests
for update to authenticated using (
  public.is_admin() or exists (
    select 1 from public.extracurriculars e
    where e.id = extracurricular_id and e.coach_id = auth.uid()
  )
) with check (
  public.is_admin() or exists (
    select 1 from public.extracurriculars e
    where e.id = extracurricular_id and e.coach_id = auth.uid()
  )
);

-- Seed kategori hanya jika belum ada. Ini data master kategori, bukan data anggota/siswa.
insert into public.extracurricular_categories(name, icon, description)
values
 ('Olahraga','⚽','Cabang olahraga dan aktivitas kebugaran.'),
 ('Teknologi & IT','💻','Pemrograman, robotika, jaringan, dan teknologi.'),
 ('Kemanusiaan / PMR','🩺','Kesehatan, pertolongan pertama, dan relawan.'),
 ('Bela Negara','🇮🇩','Paskibra, Pramuka, dan kedisiplinan.'),
 ('Seni & Budaya','🎭','Musik, tari, teater, dan seni rupa.'),
 ('Keagamaan','🕌','Kegiatan pembinaan kerohanian.'),
 ('Bahasa & Komunikasi','🗣️','Bahasa, debat, jurnalistik, dan public speaking.')
on conflict (name) do nothing;
