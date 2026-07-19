-- Jalankan file ini kalau seed penjemput error:
-- column "role" of relation "profiles" does not exist
--
-- File ini fokus menambahkan kolom dan function role/point yang dibutuhkan
-- tanpa mengulang seluruh setup awal.

alter table public.profiles
  add column if not exists role text not null default 'warga';

alter table public.profiles
  add column if not exists points integer not null default 0;

alter table public.profiles
  drop constraint if exists profiles_role_check;

alter table public.profiles
  add constraint profiles_role_check check (role in ('warga', 'penjemput'));

alter table public.pickup_requests
  add column if not exists collector_id uuid references auth.users(id) on delete set null;

alter table public.pickup_requests
  add column if not exists picked_up_at timestamptz;

create table if not exists public.point_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  collector_id uuid references auth.users(id) on delete set null,
  pickup_request_id uuid references public.pickup_requests(id) on delete set null,
  points integer not null,
  type text not null default 'pickup_reward',
  description text not null default '',
  created_at timestamptz not null default now()
);

alter table public.point_transactions enable row level security;

create or replace function public.current_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid()
$$;

drop policy if exists "Users can read own point transactions" on public.point_transactions;
create policy "Users can read own point transactions"
on public.point_transactions
for select
to authenticated
using (auth.uid() = user_id or auth.uid() = collector_id);

drop policy if exists "Collectors can update pickup requests" on public.pickup_requests;
create policy "Collectors can update pickup requests"
on public.pickup_requests
for update
to authenticated
using (public.current_user_role() = 'penjemput')
with check (public.current_user_role() = 'penjemput');

create or replace function public.complete_pickup_by_qr(p_warga_id uuid)
returns table (
  request_id uuid,
  warga_id uuid,
  collector_id uuid,
  points_awarded integer,
  status text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_collector_id uuid := auth.uid();
  v_request_id uuid;
  v_points integer := 25;
begin
  if v_collector_id is null then
    raise exception 'User belum login';
  end if;

  if not exists (
    select 1
    from public.profiles
    where id = v_collector_id and role = 'penjemput'
  ) then
    raise exception 'Hanya role penjemput yang bisa scan QR warga';
  end if;

  select id
  into v_request_id
  from public.pickup_requests
  where user_id = p_warga_id and status = 'scheduled'
  order by created_at asc
  limit 1
  for update;

  if v_request_id is null then
    raise exception 'Tidak ada request penjemputan aktif untuk warga ini';
  end if;

  update public.pickup_requests
  set
    status = 'picked_up',
    collector_id = v_collector_id,
    picked_up_at = now()
  where id = v_request_id;

  update public.profiles
  set
    points = points + v_points,
    updated_at = now()
  where id = p_warga_id;

  insert into public.point_transactions (
    user_id,
    collector_id,
    pickup_request_id,
    points,
    type,
    description
  )
  values (
    p_warga_id,
    v_collector_id,
    v_request_id,
    v_points,
    'pickup_reward',
    'Poin dari penjemputan sampah'
  );

  return query
  select
    v_request_id,
    p_warga_id,
    v_collector_id,
    v_points,
    'picked_up'::text;
end;
$$;

select column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and table_name = 'profiles'
  and column_name in ('role', 'points')
order by column_name;
