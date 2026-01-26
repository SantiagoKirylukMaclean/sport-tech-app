-- 20260126150000_player_read_call_ups.sql
-- Allow players to read call-ups for matches of their team

drop policy if exists "mcu read own team" on public.match_call_ups;
create policy "mcu read own team" on public.match_call_ups
  for select using (
    exists (
      select 1 
      from public.matches m
      join public.players p on p.team_id = m.team_id
      where m.id = match_call_ups.match_id
        and p.user_id = auth.uid()
    )
  );
