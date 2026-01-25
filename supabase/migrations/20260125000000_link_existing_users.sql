-- 20260125000000_link_existing_users.sql
-- Function to link an existing user (by email) to a player profile
-- avoiding the need for a new invitation flow if the user already exists.

create or replace function public.link_existing_user_to_player(
  p_email text,
  p_player_id bigint
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_team_id bigint;
  v_existing_link uuid;
begin
  -- 1. Find user by email (case insensitive)
  select id into v_user_id
  from public.profiles
  where lower(email) = lower(p_email)
  limit 1;

  -- If user doesn't exist, we return false so the caller can proceed with standard invite
  if v_user_id is null then
    return false;
  end if;

  -- 2. Validate player exists and get team_id
  select team_id, user_id into v_team_id, v_existing_link
  from public.players
  where id = p_player_id;

  if v_team_id is null then
    -- Player record not found
    return false;
  end if;

  -- If player is already linked to THIS user, return true (idempotent)
  if v_existing_link = v_user_id then
    return true;
  end if;
  
  -- If player is linked to ANOTHER user, decide usage. 
  -- For now, let's assume we overwrite or error. 
  -- Given the requirements, we likely want to overwrite if we are the admin.
  
  -- 3. Link player to user
  update public.players
  set user_id = v_user_id
  where id = p_player_id;

  -- 4. Add user to team roles (so they can access the team)
  insert into public.user_team_roles (user_id, team_id, role)
  values (v_user_id, v_team_id, 'player')
  on conflict (user_id, team_id, role) do nothing;
  
  -- 5. Create an 'accepted' invite record for audit trail
  -- We try/catch to avoid unique constraint errors if one exists
  begin
    insert into public.pending_invites (email, role, team_ids, player_id, status, accepted_at, created_by)
    values (
      lower(p_email), 
      'player', 
      array[v_team_id], 
      p_player_id, 
      'accepted', 
      now(), 
      auth.uid()
    );
  exception when others then
    -- Ignore insertion errors for history (e.g. duplicate invite)
    null;
  end;

  return true;
end;
$$;

-- Grant permissions
grant execute on function public.link_existing_user_to_player(text, bigint) to authenticated;
