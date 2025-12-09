-- 20251208000002_allow_player_in_user_team_roles.sql
-- Allow 'player' role in user_team_roles table
-- This is needed for players to see their assigned teams

-- Drop the old constraint that only allowed 'admin' and 'coach'
alter table public.user_team_roles
drop constraint if exists user_team_roles_role_check;

-- Add new constraint that includes 'player'
alter table public.user_team_roles
add constraint user_team_roles_role_check
check (role in ('admin', 'coach', 'player'));
