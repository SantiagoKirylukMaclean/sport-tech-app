-- 20251202000000_notes.sql
-- Tabla de notas personales por usuario + RLS

create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_notes_user on public.notes(user_id);
create index if not exists idx_notes_created on public.notes(created_at desc);

alter table public.notes enable row level security;

-- Policies
-- IMPORTANTE: Postgres no tiene CREATE POLICY IF NOT EXISTS -> usar DROP/CREATE

-- super_admin: all
drop policy if exists "notes superadmin all" on public.notes;
create policy "notes superadmin all"
on public.notes
for all
using (public.is_superadmin())
with check (public.is_superadmin());

-- usuario: acceso completo a sus propias notas
drop policy if exists "notes user own" on public.notes;
create policy "notes user own"
on public.notes
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
