-- 20260124004442_basketball_match_stats.sql
-- Support for basketball stats and configurable match periods

-- 1) Add configurable periods to matches
alter table public.matches 
  add column if not exists number_of_periods smallint default 4,
  add column if not exists period_duration smallint default 10; -- minutes

-- 2) Create basketball match stats table
create table if not exists public.basketball_match_stats (
  id bigserial primary key,
  match_id bigint not null references public.matches(id) on delete cascade,
  player_id bigint not null references public.players(id) on delete cascade,
  quarter smallint not null,
  stat_type text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_basketball_match_stats_match on public.basketball_match_stats(match_id);
create index if not exists idx_basketball_match_stats_player on public.basketball_match_stats(player_id);

-- 3) RLS for basketball_match_stats
alter table public.basketball_match_stats enable row level security;

-- Policies

-- super_admin all
drop policy if exists "bms superadmin all" on public.basketball_match_stats;
create policy "bms superadmin all" on public.basketball_match_stats
  for all using ( public.is_superadmin() ) with check ( public.is_superadmin() );

-- coach CRUD if is coach of the team of the match
drop policy if exists "bms coach crud" on public.basketball_match_stats;
create policy "bms coach crud" on public.basketball_match_stats
  for all using (
    exists (
      select 1 from public.matches m
      where m.id = match_id
        and public.is_coach_of_team(m.team_id)
    )
  )
  with check (
    exists (
      select 1 from public.matches m
      where m.id = match_id
        and public.is_coach_of_team(m.team_id)
    )
  );
