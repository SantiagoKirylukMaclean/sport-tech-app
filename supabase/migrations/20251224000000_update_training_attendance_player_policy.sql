-- Update RLS policy for training_attendance to allow players to read all attendance records from their team
-- This enables players to see how many teammates attended each training session (e.g., "8/10 attended")
-- Previous policy only allowed players to read their own attendance records

DROP POLICY IF EXISTS "training_attendance_player_read_own" ON public.training_attendance;

CREATE POLICY "training_attendance_player_read_own"
ON public.training_attendance
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.training_sessions ts
    JOIN public.players p ON p.team_id = ts.team_id
    WHERE ts.id = training_attendance.training_id
    AND p.user_id = auth.uid()
  )
);

COMMENT ON POLICY "training_attendance_player_read_own" ON public.training_attendance IS
'Allows players to read training attendance records for all sessions of their team';
