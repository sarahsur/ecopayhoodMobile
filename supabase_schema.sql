-- Supabase schema for Ecopayhood Mobile Day 2.
-- Run this in Supabase Dashboard -> SQL Editor.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  email text not null default '',
  phone text not null default '',
  address text not null default '',
  address_detail text not null default '',
  role text not null default 'warga' check (role in ('warga', 'penjemput')),
  points integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pickup_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null,
  amount text not null default '2',
  unit text not null default 'kg',
  status text not null default 'scheduled',
  collector_id uuid references auth.users(id) on delete set null,
  picked_up_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null,
  time_label text not null default 'Baru',
  icon_type text not null default 'notification',
  is_read boolean not null default false,
  category text,
  group_label text,
  created_at timestamptz not null default now()
);

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

alter table public.profiles
  add column if not exists role text not null default 'warga',
  add column if not exists points integer not null default 0;

alter table public.pickup_requests
  add column if not exists collector_id uuid references auth.users(id) on delete set null,
  add column if not exists picked_up_at timestamptz;

alter table public.profiles
  drop constraint if exists profiles_role_check;

alter table public.profiles
  add constraint profiles_role_check check (role in ('warga', 'penjemput'));

alter table public.profiles enable row level security;
alter table public.pickup_requests enable row level security;
alter table public.notifications enable row level security;
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

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', ''),
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'role', 'warga')
  )
  on conflict (id) do update
  set
    name = excluded.name,
    email = excluded.email,
    updated_at = now();

  return new;
end;
$$;

create or replace function public.complete_selected_pickups_by_qr(
  p_warga_id uuid,
  p_request_ids uuid[]
)
returns table (
  request_id uuid,
  warga_id uuid,
  collector_id uuid,
  points_awarded integer,
  completed_count integer,
  status text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_collector_id uuid := auth.uid();
  v_first_request_id uuid;
  v_completed_count integer;
  v_points_per_request integer := 25;
  v_total_points integer;
  v_categories text;
begin
  if v_collector_id is null then
    raise exception 'User belum login';
  end if;

  if p_request_ids is null or array_length(p_request_ids, 1) is null then
    raise exception 'Pilih minimal satu pengajuan yang dijemput';
  end if;

  if not exists (
    select 1
    from public.profiles as profile
    where profile.id = v_collector_id and profile.role = 'penjemput'
  ) then
    raise exception 'Hanya role penjemput yang bisa scan QR warga';
  end if;

  with selected_pickups as (
    select pickup.id, pickup.category
    from public.pickup_requests as pickup
    where pickup.user_id = p_warga_id
      and pickup.status = 'scheduled'
      and pickup.id = any(p_request_ids)
    for update
  )
  select
    count(*),
    min(selected_pickups.id),
    string_agg(selected_pickups.category, ', ' order by selected_pickups.category)
  into v_completed_count, v_first_request_id, v_categories
  from selected_pickups;

  if v_completed_count <> array_length(p_request_ids, 1) then
    raise exception 'Sebagian pengajuan tidak valid atau sudah dijemput';
  end if;

  v_total_points := v_completed_count * v_points_per_request;

  update public.pickup_requests as pickup
  set
    status = 'picked_up',
    collector_id = v_collector_id,
    picked_up_at = now()
  where pickup.user_id = p_warga_id
    and pickup.status = 'scheduled'
    and pickup.id = any(p_request_ids);

  update public.profiles as profile
  set
    points = profile.points + v_total_points,
    updated_at = now()
  where profile.id = p_warga_id;

  insert into public.point_transactions (
    user_id,
    collector_id,
    pickup_request_id,
    points,
    type,
    description
  )
  select
    p_warga_id,
    v_collector_id,
    pickup.id,
    v_points_per_request,
    'pickup_reward',
    'Poin dari penjemputan sampah'
  from public.pickup_requests as pickup
  where pickup.id = any(p_request_ids);

  insert into public.notifications (
    user_id,
    title,
    description,
    time_label,
    icon_type,
    is_read,
    category
  )
  values (
    p_warga_id,
    'Sampah berhasil dijemput',
    v_completed_count || ' pengajuan (' || coalesce(v_categories, 'sampah') ||
      ') sudah ditandai selesai oleh Greenie.' || chr(10) || chr(10) ||
      'Poin kamu bertambah ' || v_total_points || ' poin.',
    'Baru',
    'point',
    false,
    v_categories
  );

  return query
  select
    v_first_request_id as request_id,
    p_warga_id as warga_id,
    v_collector_id as collector_id,
    v_total_points as points_awarded,
    v_completed_count as completed_count,
    'picked_up'::text as status;
end;
$$;

create or replace function public.redeem_user_points(
  p_points integer,
  p_reward_name text
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_profile public.profiles;
begin
  if v_user_id is null then
    raise exception 'User belum login';
  end if;

  if p_points <= 0 then
    raise exception 'Jumlah poin tidak valid';
  end if;

  select *
  into v_profile
  from public.profiles as profile
  where profile.id = v_user_id
  for update;

  if v_profile.id is null then
    raise exception 'Profile user belum tersedia';
  end if;

  if v_profile.role <> 'warga' then
    raise exception 'Hanya warga yang bisa menukar poin';
  end if;

  if v_profile.points < p_points then
    raise exception 'Poin belum cukup';
  end if;

  update public.profiles as profile
  set
    points = profile.points - p_points,
    updated_at = now()
  where profile.id = v_user_id
  returning * into v_profile;

  insert into public.point_transactions (
    user_id,
    points,
    type,
    description
  )
  values (
    v_user_id,
    -p_points,
    'reward_redemption',
    'Tukar poin: ' || coalesce(p_reward_name, 'Reward Ecopayhood')
  );

  insert into public.notifications (
    user_id,
    title,
    description,
    time_label,
    icon_type,
    is_read
  )
  values (
    v_user_id,
    'Poin berhasil ditukar',
    p_points || ' poin berhasil ditukar dengan ' ||
      coalesce(p_reward_name, 'Reward Ecopayhood') || '.',
    'Baru',
    'reward',
    false
  );

  return v_profile;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile"
on public.profiles
for select
to authenticated
using (auth.uid() = id);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
on public.profiles
for insert
to authenticated
with check (auth.uid() = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "Users can read own pickup requests" on public.pickup_requests;
create policy "Users can read own pickup requests"
on public.pickup_requests
for select
to authenticated
using (auth.uid() = user_id or public.current_user_role() = 'penjemput');

drop policy if exists "Users can insert own pickup requests" on public.pickup_requests;
create policy "Users can insert own pickup requests"
on public.pickup_requests
for insert
to authenticated
with check (auth.uid() = user_id and public.current_user_role() = 'warga');

drop policy if exists "Collectors can update pickup requests" on public.pickup_requests;
create policy "Collectors can update pickup requests"
on public.pickup_requests
for update
to authenticated
using (public.current_user_role() = 'penjemput')
with check (public.current_user_role() = 'penjemput');

drop policy if exists "Users can read own notifications" on public.notifications;
create policy "Users can read own notifications"
on public.notifications
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert own notifications" on public.notifications;
create policy "Users can insert own notifications"
on public.notifications
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update own notifications" on public.notifications;
create policy "Users can update own notifications"
on public.notifications
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can read own point transactions" on public.point_transactions;
create policy "Users can read own point transactions"
on public.point_transactions
for select
to authenticated
using (auth.uid() = user_id or auth.uid() = collector_id);

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
  v_category text;
  v_points integer := 25;
begin
  if v_collector_id is null then
    raise exception 'User belum login';
  end if;

  if not exists (
    select 1
    from public.profiles as profile
    where profile.id = v_collector_id and profile.role = 'penjemput'
  ) then
    raise exception 'Hanya role penjemput yang bisa scan QR warga';
  end if;

  select pickup.id, pickup.category
  into v_request_id, v_category
  from public.pickup_requests as pickup
  where pickup.user_id = p_warga_id and pickup.status = 'scheduled'
  order by pickup.created_at asc
  limit 1
  for update;

  if v_request_id is null then
    raise exception 'Tidak ada request penjemputan aktif untuk warga ini';
  end if;

  update public.pickup_requests as pickup
  set
    status = 'picked_up',
    collector_id = v_collector_id,
    picked_up_at = now()
  where pickup.id = v_request_id;

  update public.profiles as profile
  set
    points = profile.points + v_points,
    updated_at = now()
  where profile.id = p_warga_id;

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

  insert into public.notifications (
    user_id,
    title,
    description,
    time_label,
    icon_type,
    is_read,
    category
  )
  values (
    p_warga_id,
    'Sampah berhasil dijemput',
    'Pengajuan ' || coalesce(v_category, 'sampah') ||
      ' sudah ditandai selesai oleh Greenie.' || chr(10) || chr(10) ||
      'Poin kamu bertambah ' || v_points || ' poin.',
    'Baru',
    'point',
    false,
    v_category
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
