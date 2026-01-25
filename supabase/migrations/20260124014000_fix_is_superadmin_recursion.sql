-- 20260124014000_fix_is_superadmin_recursion.sql
-- Fix infinite recursion in RLS policies by making role check functions SECURITY DEFINER
-- This bypasses RLS when checking for roles, preventing the loop:
-- Policy -> checks role -> reads profile -> triggers Policy -> ...

-- Recreate is_superadmin as SECURITY DEFINER

CREATE OR REPLACE FUNCTION public.is_superadmin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid() AND p.role = 'super_admin'
  );
$$;

-- Recreate is_coach_of_team as SECURITY DEFINER (good practice, though not strictly causing the recursion here)
CREATE OR REPLACE FUNCTION public.is_coach_of_team(p_team_id bigint)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_team_roles utr
    WHERE utr.user_id = auth.uid()
      AND utr.team_id = p_team_id
      AND utr.role IN ('coach','admin')
  );
$$;

-- Also allow 'super_admin' to see everything (redundant but safe) in user_team_roles if not already covered
-- The previous migration `20250923010400...` covered this but we ensure the function is robust.
