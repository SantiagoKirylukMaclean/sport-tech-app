-- 20251208000001_staff_members_and_attendance.sql
-- Staff members (coaches, coordinators, etc.) and their attendance tracking
-- Requires: public.is_superadmin(), public.is_coach_of_team(bigint)

-- ========== Enum Type for Staff Position ==========
do $$
begin
  if not exists (select 1 from pg_type where typname = 'staff_position') then
    create type staff_position as enum (
      'head_coach',
      'assistant_coach',
      'coordinator',
      'physical_trainer',
      'medic'
    );
  end if;
end $$;

-- ========== Staff Members Table ==========
create table if not exists public.staff_members (
  id bigserial primary key,
  team_id bigint references public.teams(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text not null,
  position staff_position not null,
  email text,
  created_at timestamptz not null default now(),

  -- A staff member can only be associated with one team once
  unique(team_id, user_id)
);

create index if not exists idx_staff_members_team on public.staff_members(team_id);
create index if not exists idx_staff_members_user on public.staff_members(user_id);

alter table public.staff_members enable row level security;

-- ========== Staff Attendance Table ==========
create table if not exists public.staff_attendance (
  training_id bigint not null references public.training_sessions(id) on delete cascade,
  staff_id bigint not null references public.staff_members(id) on delete cascade,
  status attendance_status not null,
  primary key (training_id, staff_id)
);

create index if not exists idx_staff_attendance_training on public.staff_attendance(training_id);
create index if not exists idx_staff_attendance_staff on public.staff_attendance(staff_id);

alter table public.staff_attendance enable row level security;

-- ========== RLS Policies for staff_members ==========

-- super_admin: all
drop policy if exists "staff_members superadmin all" on public.staff_members;
create policy "staff_members superadmin all"
on public.staff_members
for all
using (public.is_superadmin())
with check (public.is_superadmin());

-- coach/admin of the team: CRUD on staff members of their team
drop policy if exists "staff_members coach crud" on public.staff_members;
create policy "staff_members coach crud"
on public.staff_members
for all
using ( public.is_coach_of_team(team_id) )
with check ( public.is_coach_of_team(team_id) );

-- staff members can read their own record
drop policy if exists "staff_members read own" on public.staff_members;
create policy "staff_members read own"
on public.staff_members
for select
using ( auth.uid() = user_id );

-- ========== RLS Policies for staff_attendance ==========

-- super_admin: all
drop policy if exists "staff_attendance superadmin all" on public.staff_attendance;
create policy "staff_attendance superadmin all"
on public.staff_attendance
for all
using (public.is_superadmin())
with check (public.is_superadmin());

-- coach/admin: CRUD only for training sessions of their teams
-- AND staff members that belong to their teams
drop policy if exists "staff_attendance coach crud" on public.staff_attendance;
create policy "staff_attendance coach crud"
on public.staff_attendance
for all
using (
  exists (
    select 1
    from public.training_sessions ts
    where ts.id = staff_attendance.training_id
      and public.is_coach_of_team(ts.team_id)
  )
  and exists (
    select 1
    from public.staff_members sm
    where sm.id = staff_attendance.staff_id
      and public.is_coach_of_team(sm.team_id)
  )
)
with check (
  exists (
    select 1
    from public.training_sessions ts
    where ts.id = staff_attendance.training_id
      and public.is_coach_of_team(ts.team_id)
  )
  and exists (
    select 1
    from public.staff_members sm
    where sm.id = staff_attendance.staff_id
      and public.is_coach_of_team(sm.team_id)
  )
);

-- staff members can read their own attendance
drop policy if exists "staff_attendance read own" on public.staff_attendance;
create policy "staff_attendance read own"
on public.staff_attendance
for select
using (
  exists (
    select 1
    from public.staff_members sm
    where sm.id = staff_attendance.staff_id
      and sm.user_id = auth.uid()
  )
);
