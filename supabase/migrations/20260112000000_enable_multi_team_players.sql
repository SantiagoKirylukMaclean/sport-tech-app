-- 20260112000000_enable_multi_team_players.sql
-- Enable multi-team players by changing uniqueness constraint on players table

-- 1. Drop the constraint that limits a user to only one player record
alter table public.players
drop constraint if exists uniq_players_user_id;

-- 2. Add a new constraint that ensures a user can only have ONE player record PER TEAM
-- This allows the same user_id to appear in multiple rows, as long as team_id is different
alter table public.players
add constraint uniq_players_team_user unique (team_id, user_id);

-- 3. Verify user_team_roles supports multi-team
-- The PK of user_team_roles is (user_id, team_id, role), which naturally supports
-- the same user in different teams with the same or different roles.
-- No changes needed there.

-- 4. Helper function to get ALL player IDs for a user (if needed)
-- But typically we query by team_id anyway.
