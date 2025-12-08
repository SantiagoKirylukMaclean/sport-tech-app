-- Add email column to players table
-- This allows us to store the user's email directly in the players table
-- instead of requiring edge functions to fetch it from auth.users

ALTER TABLE public.players
ADD COLUMN IF NOT EXISTS email TEXT;

-- Add comment
COMMENT ON COLUMN public.players.email IS 'User email address (stored here for easy access)';
