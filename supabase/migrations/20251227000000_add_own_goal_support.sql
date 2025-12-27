-- Add support for own goals in match_goals table

-- Add is_own_goal column to match_goals table
alter table public.match_goals
add column if not exists is_own_goal boolean not null default false;

-- Add comment to explain the column
comment on column public.match_goals.is_own_goal is 'Indicates if this goal was an own goal (autogol)';
