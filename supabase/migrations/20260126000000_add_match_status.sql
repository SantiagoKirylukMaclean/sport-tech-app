-- 20260126000000_add_match_status.sql
-- Add status column to matches table for live updates

-- 1) Create match_status enum
do $$ begin
  if not exists (select 1 from pg_type where typname = 'match_status') then
    create type match_status as enum ('scheduled', 'live', 'finished');
  end if;
end $$;

-- 2) Add status column to matches
alter table public.matches
  add column if not exists status match_status not null default 'scheduled';

-- 3) Create index for faster filtering of live matches
create index if not exists idx_matches_status on public.matches(status);

-- 4) Enable Realtime for matches (if not already enabled)
-- This is usually done via publication, but we can ensure replica identity is full just in case
alter table public.matches replica identity full;

-- 5) Enable Realtime for basketball_match_stats to allow live score updates
alter table public.basketball_match_stats replica identity full;

-- Ensure both tables are in the supabase_realtime publication
-- Note: In Supabase managed service this is often done via UI or specific API, 
-- but we can try to add it to the publication if the user has permissions. 
-- If 'supabase_realtime' publication exists, add tables to it.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.matches;
    alter publication supabase_realtime add table public.basketball_match_stats;
  end if;
exception when others then
  -- Ignore errors if we don't have permission to alter publication or if tables are already there
  null;
end $$;
