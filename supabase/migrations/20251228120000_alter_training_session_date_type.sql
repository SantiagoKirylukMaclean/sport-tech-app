-- 20251228120000_alter_training_session_date_type.sql
-- Change session_date from DATE to TIMESTAMPTZ to preserve time information

ALTER TABLE public.training_sessions
ALTER COLUMN session_date TYPE timestamptz USING session_date::timestamptz;
