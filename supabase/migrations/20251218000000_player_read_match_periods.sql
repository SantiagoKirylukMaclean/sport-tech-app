-- 20251218000000_player_read_match_periods.sql
-- Allow players to read their own match_player_periods data
-- Players should be able to see which quarters they played in their team's matches

-- Helper function: Check if user is a player in a specific team
create or replace function public.is_player_of_team(team_id_param bigint)
returns boolean
language plpgsql
security definer
stable
as $$
begin
  return exists (
    select 1
    from public.user_team_roles utr
    where utr.user_id = auth.uid()
      and utr.team_id = team_id_param
      and utr.role = 'player'
  );
end;
$$;

-- Policy: Players can read match_player_periods for matches of their team
-- This allows players to see which quarters they and their teammates played
drop policy if exists "mpp player read" on public.match_player_periods;
create policy "mpp player read" on public.match_player_periods
  for select using (
    exists (
      select 1
      from public.matches m
      where m.id = match_player_periods.match_id
        and public.is_player_of_team(m.team_id)
    )
  );

-- Grant execute permission on the helper function
grant execute on function public.is_player_of_team(bigint) to authenticated;
