-- 20260126153000_fix_player_team_read_policy_multiteam.sql
-- Fix player RLS to support multi-team users by checking all teams

-- 1. Create new helper function that returns all team IDs for the user
create or replace function public.get_user_team_ids()
returns setof bigint
language sql
stable
security definer
as $$
  select team_id 
  from public.players 
  where user_id = auth.uid();
$$;

-- 2. Drop the restrictive/buggy policy
drop policy if exists "players read team members" on public.players;

-- 3. Create new policy using the new function
create policy "players read team members" on public.players
  for select using (
    team_id in (select public.get_user_team_ids())
  );

-- 4. Comment
comment on policy "players read team members" on public.players is 
'Allows players to read information about other players in ANY of their teams';
