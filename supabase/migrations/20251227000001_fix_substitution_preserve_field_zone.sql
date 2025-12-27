-- 20251227000001_fix_substitution_preserve_field_zone.sql
-- Fix: Preservar field_zone al hacer sustituciones

-- Eliminar función existente
drop function if exists public.apply_match_substitution(bigint, smallint, bigint, bigint);

-- Recrear función para aplicar un cambio preservando field_zone
create or replace function public.apply_match_substitution(
  p_match_id bigint,
  p_period smallint,
  p_player_out bigint,
  p_player_in bigint
)
returns void
language plpgsql
security definer
as $$
declare
  v_field_zone text;
begin
  -- Validar que el período sea válido
  if p_period not between 1 and 4 then
    raise exception 'Período inválido: debe estar entre 1 y 4';
  end if;

  -- Validar que ambos jugadores estén convocados
  if not exists (
    select 1 from public.match_call_ups
    where match_id = p_match_id and player_id = p_player_out
  ) then
    raise exception 'El jugador que sale no está convocado';
  end if;

  if not exists (
    select 1 from public.match_call_ups
    where match_id = p_match_id and player_id = p_player_in
  ) then
    raise exception 'El jugador que entra no está convocado';
  end if;

  -- Obtener la zona del campo del jugador que sale
  select field_zone into v_field_zone
  from public.match_player_periods
  where match_id = p_match_id
    and period = p_period
    and player_id = p_player_out;

  -- Registrar el cambio
  insert into public.match_substitutions (match_id, period, player_out, player_in)
  values (p_match_id, p_period, p_player_out, p_player_in)
  on conflict (match_id, period, player_out, player_in) do nothing;

  -- Eliminar registros existentes
  delete from public.match_player_periods
  where match_id = p_match_id
    and period = p_period
    and player_id in (p_player_out, p_player_in);

  -- Insertar HALF para ambos jugadores, preservando la zona del campo
  insert into public.match_player_periods (match_id, player_id, period, fraction, field_zone)
  values
    (p_match_id, p_player_out, p_period, 'HALF', v_field_zone),
    (p_match_id, p_player_in, p_period, 'HALF', v_field_zone);
end;
$$;
