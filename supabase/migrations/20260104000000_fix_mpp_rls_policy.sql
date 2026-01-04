-- 20260104000000_fix_mpp_rls_policy.sql
-- Fix the RLS policy for match_player_periods to allow coaches to view/edit all periods for their matches
-- Previous policy "mpp coach crud" was too restrictive, requiring a join with players table 
-- that could fail if player-team relationship was inconsistent.

-- Drop the restrictive policy
drop policy if exists "mpp coach crud" on public.match_player_periods;

-- Re-create with simpler logic (same as match_quarter_results)
-- Coaches can CRUD periods if they are the coach of the match's team
create policy "mpp coach crud" on public.match_player_periods
  for all using (
    exists (
      select 1
      from public.matches m
      where m.id = match_id
        and public.is_coach_of_team(m.team_id)
    )
  )
  with check (
    exists (
      select 1
      from public.matches m
      where m.id = match_id
        and public.is_coach_of_team(m.team_id)
    )
  );
