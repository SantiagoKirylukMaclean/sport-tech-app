-- 20260124015500_fix_sports_clubs_rls.sql
-- Apply the secure get_my_role() helper to Sports and Clubs policies
-- to ensure Super Admins and Staff can view them without recursion or restriction.

-- SPORTS
-- Allow any staff to read sports (needed for dropdowns)
DROP POLICY IF EXISTS "sports coach read by team" ON public.sports;
CREATE POLICY "sports staff read all" ON public.sports
  FOR SELECT
  USING (
    public.get_my_role() IN ('admin', 'coach', 'super_admin')
  );

-- Also ensure the superadmin policy uses the safe check (or just rely on the above if super_admin is included)
-- But we can keep specific superadmin full access policy if we want, just ensuring it doesn't loop.
-- The "sports superadmin all" uses is_superadmin() which we fixed to be SECURITY DEFINER, so it should be fine.
-- However, "sports staff read all" is broader and covers it for SELECT.

-- CLUBS
-- Allow any staff to read clubs (needed for dropdowns)
DROP POLICY IF EXISTS "clubs coach read by team" ON public.clubs;
CREATE POLICY "clubs staff read all" ON public.clubs
  FOR SELECT
  USING (
    public.get_my_role() IN ('admin', 'coach', 'super_admin')
  );
