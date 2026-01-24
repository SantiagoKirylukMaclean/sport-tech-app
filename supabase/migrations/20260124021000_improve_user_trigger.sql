-- 20260124021000_improve_user_trigger.sql
-- Update handle_new_user trigger to use role from user_metadata if available.
-- This ensures that users created via Admin API with a specific role are initialized correctly,
-- avoiding race conditions or overwrites where they default to 'player'.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  extracted_role public.app_role;
  meta_role text;
BEGIN
  -- Try to get role from metadata
  meta_role := NEW.raw_user_meta_data->>'role';
  
  -- Validate and cast to enum, default to 'player' if invalid or missing
  IF meta_role IS NOT NULL AND meta_role IN ('super_admin', 'admin', 'coach', 'player') THEN
    extracted_role := meta_role::public.app_role;
  ELSE
    extracted_role := 'player';
  END IF;

  INSERT INTO public.profiles (id, email, display_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    NEW.raw_user_meta_data->>'display_name', -- Also extract display name if possible
    extracted_role
  )
  ON CONFLICT (id) DO UPDATE SET
    role = EXCLUDED.role,
    display_name = COALESCE(EXCLUDED.display_name, public.profiles.display_name);
    
  RETURN NEW;
END;
$$;
