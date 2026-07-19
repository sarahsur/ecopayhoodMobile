-- Fix error:
-- PostgrestException(message: column reference "status" is ambiguous)
--
-- Penyebab:
-- Function ini punya output column bernama "status", sementara tabel
-- pickup_requests juga punya column "status". Di PL/pgSQL, nama output
-- tersebut dianggap variable, jadi Postgres bingung saat membaca
-- `where status = 'scheduled'`.
--
-- Cara pakai:
-- 1. Buka Supabase Dashboard -> SQL Editor.
-- 2. Paste seluruh isi file ini.
-- 3. Klik Run.

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
    from public.profiles as profile
    where profile.id = v_collector_id and profile.role = 'penjemput'
  ) then
    raise exception 'Hanya role penjemput yang bisa scan QR warga';
  end if;

  select pickup.id
  into v_request_id
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

  return query
  select
    v_request_id as request_id,
    p_warga_id as warga_id,
    v_collector_id as collector_id,
    v_points as points_awarded,
    'picked_up'::text as status;
end;
$$;
