-- Fix tambahan:
-- 1. Scan QR tidak langsung mengambil request pertama.
--    Flutter bisa mengirim beberapa pickup_request id yang dicentang.
-- 2. Warga bisa menukar poin dari katalog reward statis di Flutter.
--    Catalog tidak disimpan ke database, tetapi saldo points tetap dikurangi
--    dari public.profiles agar tidak balik saat aplikasi dibuka ulang.
--
-- Cara pakai:
-- Supabase Dashboard -> SQL Editor -> paste semua isi file ini -> Run.

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
