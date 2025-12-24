-- 20251218000001_get_player_id_from_user.sql
-- Helper function to get player.id from auth.uid()
-- Returns the player ID (bigint) for the currently authenticated user in a specific team

create or replace function public.get_player_id_for_user(team_id_param bigint)
returns bigint
language plpgsql
security definer
stable
as $$
declare
  player_id_result bigint;
begin
  select id into player_id_result
  from public.players
  where user_id = auth.uid()
    and team_id = team_id_param
  limit 1;

  return player_id_result;
end;
$$;

-- Grant execute permission
grant execute on function public.get_player_id_for_user(bigint) to authenticated;

comment on function public.get_player_id_for_user(bigint) is
  'Returns the player.id (bigint) for the authenticated user in the specified team';
