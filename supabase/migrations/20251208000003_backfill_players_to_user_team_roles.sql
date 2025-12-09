-- 20251208000003_backfill_players_to_user_team_roles.sql
-- Backfill existing players with user_id to user_team_roles table

-- Insert all existing players that have user_id but are not in user_team_roles
insert into public.user_team_roles (user_id, team_id, role)
select
  p.user_id,
  p.team_id,
  'player'::app_role
from public.players p
where p.user_id is not null
  and not exists (
    select 1
    from public.user_team_roles utr
    where utr.user_id = p.user_id
      and utr.team_id = p.team_id
      and utr.role = 'player'
  )
on conflict (user_id, team_id, role) do nothing;
