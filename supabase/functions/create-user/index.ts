import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

interface CreateUserRequest {
  email: string;
  password?: string;
  displayName?: string;
  role: 'coach' | 'admin';
  teamIds: number[];
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ ok: false, error: 'Method not allowed' }),
        {
          status: 405,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Authorization header required' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(token)

    if (authError || !user) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Invalid or expired token' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Initialize Supabase Admin client for profile check
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileError || !profile || (profile.role !== 'super_admin' && profile.role !== 'admin')) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Insufficient permissions. Admin or Super Admin role required.' }),
        {
          status: 403,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const body: CreateUserRequest = await req.json()

    if (!body.email || !body.role || !body.teamIds || body.teamIds.length === 0) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: 'Missing required fields: email, role, and teamIds are required'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    if (!['coach', 'admin'].includes(body.role)) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Invalid role. Must be "coach" or "admin"' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Validate teams exist
    const { data: teams, error: teamsError } = await supabaseAdmin
      .from('teams')
      .select('id')
      .in('id', body.teamIds)

    if (teamsError) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Failed to validate team IDs' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    if (teams.length !== body.teamIds.length) {
      return new Response(
        JSON.stringify({ ok: false, error: 'One or more team IDs are invalid' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Check if user already exists
    const { data: existingUsers } = await supabaseAdmin.auth.admin.listUsers()
    const existingUser = existingUsers.users.find(u => u.email?.toLowerCase() === body.email.toLowerCase())

    if (existingUser) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: 'User already exists with this email'
        }),
        {
          status: 409,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Create the user
    // Generate random password if not provided (though for this feature it should be provided)
    const password = body.password || crypto.randomUUID()

    const { data: newUser, error: createUserError } = await supabaseAdmin.auth.admin.createUser({
      email: body.email,
      password: password,
      email_confirm: true,
      user_metadata: {
        display_name: body.displayName || body.email.split('@')[0],
        role: body.role
      }
    })

    if (createUserError || !newUser.user) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: `Failed to create user: ${createUserError?.message || 'Unknown error'}`
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const userId = newUser.user.id

    // Check if profile exists (update it)
    const { error: profileUpdateError } = await supabaseAdmin
      .from('profiles')
      .upsert({
        id: userId,
        role: body.role,
        display_name: body.displayName || body.email.split('@')[0],
        updated_at: new Date().toISOString()
      })

    if (profileUpdateError) {
      console.error('Error updating profile:', profileUpdateError)
    }

    // Assign to teams
    const userTeamRoles = body.teamIds.map(teamId => ({
      user_id: userId,
      team_id: teamId,
      role: body.role
    }))

    const { error: rolesError } = await supabaseAdmin
      .from('user_team_roles')
      .insert(userTeamRoles)

    if (rolesError) {
      console.error('Error assigning roles:', rolesError)
      // Note: User is created but teams failed. 
      // In a real prod env, we might want to delete user or handle transaction differently.
      return new Response(
        JSON.stringify({
          ok: false,
          error: `User created but failed to assign teams: ${rolesError.message}`
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    return new Response(
      JSON.stringify({
        ok: true,
        userId: userId
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Unexpected error in create-user function:', error)
    return new Response(
      JSON.stringify({
        ok: false,
        error: error instanceof Error ? error.message : 'Internal server error'
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
