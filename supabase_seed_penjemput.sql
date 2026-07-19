-- Seeder akun penjemput sampah Ecopayhood.
--
-- Langkah aman untuk kelas:
-- 1. Buka Supabase Dashboard -> Authentication -> Users.
-- 2. Klik Add user, aktifkan Auto Confirm User.
-- 3. Buat akun berikut:
--
--    greenie1@ecopayhood.test / Greenie123!
--    greenie2@ecopayhood.test / Greenie123!
--    greenie3@ecopayhood.test / Greenie123!
--
-- 4. Setelah user Auth dibuat, jalankan SQL ini di SQL Editor.

insert into public.profiles (id, name, email, phone, role, points)
select
  id,
  case email
    when 'greenie1@ecopayhood.test' then 'Greenie Penjemput 1'
    when 'greenie2@ecopayhood.test' then 'Greenie Penjemput 2'
    when 'greenie3@ecopayhood.test' then 'Greenie Penjemput 3'
    else 'Greenie Penjemput'
  end as name,
  email,
  case email
    when 'greenie1@ecopayhood.test' then '081200000001'
    when 'greenie2@ecopayhood.test' then '081200000002'
    when 'greenie3@ecopayhood.test' then '081200000003'
    else ''
  end as phone,
  'penjemput' as role,
  0 as points
from auth.users
where email in (
  'greenie1@ecopayhood.test',
  'greenie2@ecopayhood.test',
  'greenie3@ecopayhood.test'
)
on conflict (id) do update
set
  name = excluded.name,
  email = excluded.email,
  phone = excluded.phone,
  role = 'penjemput',
  updated_at = now();

select id, name, email, role
from public.profiles
where role = 'penjemput'
order by email;
