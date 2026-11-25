-- SIEKSTRA-8 Tahap 4: cegah role Admin/Pembina ditentukan oleh metadata registrasi publik.
-- Jalankan setelah schema.sql. Registrasi aplikasi publik selalu membuat role siswa.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles(id, full_name, email, identifier, role, class_name, major)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    new.email,
    nullif(new.raw_user_meta_data->>'identifier', ''),
    'siswa',
    nullif(new.raw_user_meta_data->>'class_name', ''),
    nullif(new.raw_user_meta_data->>'major', '')
  )
  on conflict (id) do update set
    full_name = excluded.full_name,
    identifier = coalesce(excluded.identifier, profiles.identifier),
    class_name = coalesce(excluded.class_name, profiles.class_name),
    major = coalesce(excluded.major, profiles.major);
  return new;
end;
$$;

-- Tidak ada perubahan pada key service-role di aplikasi Flutter.
-- Pembuatan akun staf dilakukan oleh Edge Function admin-create-user.

-- Admin dapat menetapkan siswa ke ekstrakurikuler melalui dashboard.
drop policy if exists "membership admin assign" on public.memberships;
create policy "membership admin assign" on public.memberships
for insert to authenticated
with check (public.is_admin() and status = 'approved' and reviewed_by = auth.uid());

-- Perubahan NIS/NISN hanya lolos trigger prevent_self_role_escalation untuk Admin.
grant update (identifier) on public.profiles to authenticated;
