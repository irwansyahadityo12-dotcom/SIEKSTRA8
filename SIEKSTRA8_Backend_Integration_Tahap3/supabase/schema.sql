
-- SIEKSTRA-8 | Supabase schema v1
-- Jalankan seluruh file ini di Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null unique,
  identifier text unique,
  role text not null default 'siswa' check (role in ('admin','pembina','siswa')),
  class_name text,
  major text,
  phone text,
  avatar_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles(id, full_name, email, identifier, role, class_name, major)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email,'@',1)),
    new.email,
    nullif(new.raw_user_meta_data->>'identifier',''),
    'siswa', -- Role publik tidak boleh ditentukan oleh metadata dari client.
    nullif(new.raw_user_meta_data->>'class_name',''),
    nullif(new.raw_user_meta_data->>'major','')
  )
  on conflict (id) do update set
    full_name = excluded.full_name,
    identifier = coalesce(excluded.identifier, profiles.identifier),
    role = excluded.role,
    class_name = coalesce(excluded.class_name, profiles.class_name),
    major = coalesce(excluded.major, profiles.major);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

create table if not exists public.extracurriculars (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null,
  description text,
  location text,
  quota integer not null default 0 check (quota >= 0),
  coach_id uuid references public.profiles(id) on delete set null,
  coach_name text,
  schedule_summary text,
  image_url text,
  is_open boolean not null default true,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists idx_extracurriculars_name_unique on public.extracurriculars(name);

create table if not exists public.memberships (
  id uuid primary key default gen_random_uuid(),
  extracurricular_id uuid not null references public.extracurriculars(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  motivation text,
  status text not null default 'pending' check (status in ('pending','approved','rejected','resigned')),
  reviewed_by uuid references public.profiles(id) on delete set null,
  reviewed_at timestamptz,
  joined_at timestamptz,
  created_at timestamptz not null default now(),
  unique(extracurricular_id, student_id)
);

create table if not exists public.schedules (
  id uuid primary key default gen_random_uuid(),
  extracurricular_id uuid not null references public.extracurriculars(id) on delete cascade,
  title text not null,
  activity_date date not null,
  start_time time,
  end_time time,
  location text,
  notes text,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.attendance_sessions (
  id uuid primary key default gen_random_uuid(),
  extracurricular_id uuid not null references public.extracurriculars(id) on delete cascade,
  schedule_id uuid references public.schedules(id) on delete set null,
  title text not null,
  session_date date not null default current_date,
  notes text,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.attendance_records (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.attendance_sessions(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  status text not null check (status in ('Hadir','Izin','Sakit','Alfa')),
  note text,
  marked_by uuid references public.profiles(id) on delete set null,
  marked_at timestamptz not null default now(),
  unique(session_id, student_id)
);

create table if not exists public.permission_requests (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  extracurricular_id uuid references public.extracurriculars(id) on delete set null,
  schedule_id uuid references public.schedules(id) on delete set null,
  permission_type text not null check (permission_type in ('Akademik','Sakit','Personal','Lainnya')),
  start_date date not null,
  end_date date,
  reason text not null,
  attachment_url text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  reviewed_by uuid references public.profiles(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.resignation_requests (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  extracurricular_id uuid not null references public.extracurriculars(id) on delete cascade,
  reason_category text,
  reason text not null,
  attachment_url text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  reviewed_by uuid references public.profiles(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  extracurricular_id uuid references public.extracurriculars(id) on delete set null,
  title text not null,
  competition_name text,
  award text,
  achievement_date date,
  description text,
  image_url text,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.trainings (
  id uuid primary key default gen_random_uuid(),
  extracurricular_id uuid references public.extracurriculars(id) on delete cascade,
  title text not null,
  description text,
  start_date date,
  end_date date,
  location text,
  quota integer,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.proposals (
  id uuid primary key default gen_random_uuid(),
  extracurricular_id uuid references public.extracurriculars(id) on delete set null,
  submitted_by uuid references public.profiles(id) on delete set null,
  title text not null,
  description text,
  budget numeric(14,2) not null default 0,
  event_date date,
  status text not null default 'pending' check (status in ('pending','approved','rejected','forwarded')),
  reviewed_by uuid references public.profiles(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  type text default 'general',
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_memberships_student on public.memberships(student_id);
create index if not exists idx_memberships_ekskul on public.memberships(extracurricular_id);
create index if not exists idx_schedules_date on public.schedules(activity_date);
create index if not exists idx_attendance_student on public.attendance_records(student_id);
create index if not exists idx_notifications_user on public.notifications(user_id, created_at desc);

create or replace function public.current_app_role()
returns text language sql stable security definer set search_path = public
as $$ select role from public.profiles where id = auth.uid() and is_active = true limit 1 $$;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce(public.current_app_role() = 'admin', false) $$;

create or replace function public.is_staff()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce(public.current_app_role() in ('admin','pembina'), false) $$;



-- Data API permissions: RLS remains the row-level security boundary.
grant usage on schema public to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage, select on all sequences in schema public to authenticated;
revoke insert, update, delete on public.profiles from authenticated;
grant update (full_name, class_name, major, phone, avatar_url) on public.profiles to authenticated;

create or replace function public.prevent_self_role_escalation()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  if auth.uid() is not null and not public.is_admin() then
    if new.role is distinct from old.role
      or new.is_active is distinct from old.is_active
      or new.identifier is distinct from old.identifier
      or new.email is distinct from old.email then
      raise exception 'Perubahan role, status, identitas, dan email harus dilakukan administrator.';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_profile_privileged_fields on public.profiles;
create trigger protect_profile_privileged_fields
before update on public.profiles
for each row execute function public.prevent_self_role_escalation();

-- RLS wajib aktif pada semua tabel aplikasi.
do $$
declare t text;
begin
  foreach t in array array['profiles','extracurriculars','memberships','schedules',
    'attendance_sessions','attendance_records','permission_requests','resignation_requests',
    'achievements','trainings','proposals','notifications']
  loop execute format('alter table public.%I enable row level security', t); end loop;
end $$;

-- Profiles
drop policy if exists "profile read self or admin" on public.profiles;
drop policy if exists "profile read self or staff" on public.profiles;
create policy "profile read self or staff" on public.profiles for select to authenticated
using (id = auth.uid() or public.is_staff());
drop policy if exists "profile update self limited" on public.profiles;
create policy "profile update self limited" on public.profiles for update to authenticated
using (id = auth.uid() or public.is_admin())
with check (id = auth.uid() or public.is_admin());

-- Catalog can be read by signed-in users; only staff manages it.
drop policy if exists "catalog read" on public.extracurriculars;
create policy "catalog read" on public.extracurriculars for select to authenticated using (true);
drop policy if exists "catalog staff insert" on public.extracurriculars;
create policy "catalog staff insert" on public.extracurriculars for insert to authenticated with check (public.is_staff());
drop policy if exists "catalog staff update" on public.extracurriculars;
create policy "catalog staff update" on public.extracurriculars for update to authenticated using (public.is_staff()) with check (public.is_staff());
drop policy if exists "catalog admin delete" on public.extracurriculars;
create policy "catalog admin delete" on public.extracurriculars for delete to authenticated using (public.is_admin());

-- Memberships: student creates/views own; staff manages all.
drop policy if exists "membership read own or staff" on public.memberships;
create policy "membership read own or staff" on public.memberships for select to authenticated
using (student_id = auth.uid() or public.is_staff());
drop policy if exists "membership student apply" on public.memberships;
create policy "membership student apply" on public.memberships for insert to authenticated
with check (student_id = auth.uid() and public.current_app_role() = 'siswa' and status = 'pending');
drop policy if exists "membership staff update" on public.memberships;
create policy "membership staff update" on public.memberships for update to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Staff owns schedules/sessions; students can read schedules.
drop policy if exists "schedule read" on public.schedules;
create policy "schedule read" on public.schedules for select to authenticated using (true);
drop policy if exists "schedule staff manage" on public.schedules;
create policy "schedule staff manage" on public.schedules for all to authenticated
using (public.is_staff()) with check (public.is_staff());

drop policy if exists "session read staff" on public.attendance_sessions;
create policy "session read staff" on public.attendance_sessions for select to authenticated using (public.is_staff());
drop policy if exists "session staff manage" on public.attendance_sessions;
create policy "session staff manage" on public.attendance_sessions for all to authenticated using (public.is_staff()) with check (public.is_staff());

drop policy if exists "attendance read own or staff" on public.attendance_records;
create policy "attendance read own or staff" on public.attendance_records for select to authenticated
using (student_id = auth.uid() or public.is_staff());
drop policy if exists "attendance staff manage" on public.attendance_records;
create policy "attendance staff manage" on public.attendance_records for all to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Students submit requests; only staff reviews.
drop policy if exists "permission read own or staff" on public.permission_requests;
create policy "permission read own or staff" on public.permission_requests for select to authenticated
using (student_id = auth.uid() or public.is_staff());
drop policy if exists "permission student insert" on public.permission_requests;
create policy "permission student insert" on public.permission_requests for insert to authenticated
with check (student_id = auth.uid() and public.current_app_role() = 'siswa' and status = 'pending');
drop policy if exists "permission staff update" on public.permission_requests;
create policy "permission staff update" on public.permission_requests for update to authenticated
using (public.is_staff()) with check (public.is_staff());

drop policy if exists "resignation read own or staff" on public.resignation_requests;
create policy "resignation read own or staff" on public.resignation_requests for select to authenticated
using (student_id = auth.uid() or public.is_staff());
drop policy if exists "resignation student insert" on public.resignation_requests;
create policy "resignation student insert" on public.resignation_requests for insert to authenticated
with check (student_id = auth.uid() and public.current_app_role() = 'siswa' and status = 'pending');
drop policy if exists "resignation staff update" on public.resignation_requests;
create policy "resignation staff update" on public.resignation_requests for update to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Staff manages information resources.
do $$
declare t text;
begin
  foreach t in array array['achievements','trainings','proposals']
  loop
    execute format('drop policy if exists %I on public.%I', t||' read', t);
    execute format('create policy %I on public.%I for select to authenticated using (true)', t||' read', t);
    execute format('drop policy if exists %I on public.%I', t||' staff insert', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (public.is_staff())', t||' staff insert', t);
    execute format('drop policy if exists %I on public.%I', t||' staff update', t);
    execute format('create policy %I on public.%I for update to authenticated using (public.is_staff()) with check (public.is_staff())', t||' staff update', t);
    execute format('drop policy if exists %I on public.%I', t||' staff delete', t);
    execute format('create policy %I on public.%I for delete to authenticated using (public.is_admin())', t||' staff delete', t);
  end loop;
end $$;

drop policy if exists "notifications own read" on public.notifications;
create policy "notifications own read" on public.notifications for select to authenticated using (user_id = auth.uid());
drop policy if exists "notifications own update" on public.notifications;
create policy "notifications own update" on public.notifications for update to authenticated
using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "notifications staff insert" on public.notifications;
drop policy if exists "notifications insert authenticated" on public.notifications;
create policy "notifications insert authenticated" on public.notifications for insert to authenticated with check (true);

-- Sample catalog from the current Flutter prototype; safe to edit in Supabase.
insert into public.extracurriculars(name,category,description,location,quota,coach_name,schedule_summary)
values
('Robotik SMKN 8 Malang','Vokasi & Keahlian','Mengembangkan keterampilan teknologi, rekayasa, dan pemrograman.','Robotik',100,'M Rafi Haryo Putra','Rabu & Sabtu'),
('Volly Ball SMKN 8 Malang','Olahraga','Melatih teknik dasar dan solidaritas dalam olahraga.','Volly',50,'Soni Subakti, S.Pd','Selasa & Jumat'),
('Badan Dakwah Islam SMKN 8 Malang','Keagamaan','Wadah pembinaan kerohanian dan karakter.','Masjid Ulil Albab',40,'Muzakki, S.Pd','Kamis & Sabtu'),
('Pramuka Gugus Depan 08','Kepemimpinan','Membentuk karakter, disiplin, dan keterampilan.','Lapangan Utama',0,'Dra. Roem Anjarwati','Jumat Sore'),
('PMR Wira SMKN 8','Kepemimpinan & Sosial','Kesiapsiagaan medis, P3K, tanggap bencana, dan donor darah.','UKS Terpadu',60,'Rezaldi Hafidz Fadilla','Senin & Kamis'),
('Futsal SMKN 8 Malang','Olahraga','Pembinaan atlet dan strategi pertandingan.','Lapangan Futsal Semi Indoor',40,'Coach Jurgen Ibra','Selasa & Sabtu')
on conflict (name) do nothing;
