-- 20260124013500_fix_teams_rls_for_admins.sql
-- Allow authenticated staff (admin/coach) to view all teams to facilitate invitations and management.

-- Drop the restrictive policy
drop policy if exists "teams coach read own" on public.teams;

-- Create a more permissive policy for reading teams
-- Authenticated users with a profile role of 'admin' or 'coach' can read all teams
-- This is acceptable as teams are generally public within the org context for staff
create policy "teams staff read all" on public.teams
  for select using (
    exists (
      select 1 from public.profiles
      where id = auth.uid()
        and role in ('admin', 'coach', 'super_admin')
    )
  );
