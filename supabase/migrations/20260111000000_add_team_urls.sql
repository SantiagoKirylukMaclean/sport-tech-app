-- Add missing URL columns to teams table
alter table "public"."teams"
  add column if not exists "calendar_url" text,
  add column if not exists "standings_url" text,
  add column if not exists "results_url" text;
