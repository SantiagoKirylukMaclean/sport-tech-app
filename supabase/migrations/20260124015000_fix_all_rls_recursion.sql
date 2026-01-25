-- 20260124015000_fix_all_rls_recursion.sql
-- Fix remaining RLS recursion issues by introducing a secure helper for role retrieval.
-- This replaces direct table queries in policies with SECURITY DEFINER function calls.

-- 1. Create a secure helper to get the current user's role
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS public.app_role
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

-- 2. Fix 'profiles' policies to avoid recursion
-- Previous policy queried 'public.profiles' inside the policy for 'public.profiles', causing a loop.
DROP POLICY IF EXISTS profiles_admin_can_select_all ON public.profiles;
CREATE POLICY profiles_admin_can_select_all ON public.profiles
  FOR SELECT
  USING (
    public.get_my_role() IN ('admin', 'super_admin')
  );

-- 3. Update 'teams' policy to use the safe helper
DROP POLICY IF EXISTS "teams staff read all" ON public.teams;
CREATE POLICY "teams staff read all" ON public.teams
  FOR SELECT
  USING (
    public.get_my_role() IN ('admin', 'coach', 'super_admin')
  );
