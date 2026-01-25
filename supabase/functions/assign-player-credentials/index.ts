import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'npm:@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

interface AssignCredentialsRequest {
  playerId: number;
  email: string;
  password: string;
}

serve(async (req) => {
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

    // Check if user has admin permissions
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

    const body: AssignCredentialsRequest = await req.json()

    if (!body.playerId || !body.email || !body.password) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: 'Missing required fields: playerId, email, and password are required'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(body.email)) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Invalid email format' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Validate password length
    if (body.password.length < 6) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Password must be at least 6 characters long' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Verify player exists and doesn't already have a user_id
    const { data: player, error: playerError } = await supabaseAdmin
      .from('players')
      .select('id, user_id, full_name, team_id')
      .eq('id', body.playerId)
      .single()

    if (playerError || !player) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Player not found' }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    if (player.user_id) {
      return new Response(
        JSON.stringify({ ok: false, error: 'This player already has an associated account' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Check if email is already in use
    const { data: existingUsers } = await supabaseAdmin.auth.admin.listUsers()
    const existingUser = existingUsers.users.find(u => u.email?.toLowerCase() === body.email.toLowerCase())

    if (existingUser) {
      // LINK TO EXISTING USER INSTEAD OF ERRORING

      // 1. Link the player to the existing user
      const { error: updateError } = await supabaseAdmin
        .from('players')
        .update({
          user_id: existingUser.id,
          email: body.email.toLowerCase().trim()
        })
        .eq('id', body.playerId)

      if (updateError) {
        return new Response(
          JSON.stringify({
            ok: false,
            error: `Failed to link player to existing user: ${updateError.message}`
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        )
      }

      // 2. Create user_team_role entry for the existin user and new team
      const { error: teamRoleError } = await supabaseAdmin
        .from('user_team_roles')
        .insert({
          user_id: existingUser.id,
          team_id: player.team_id,
          role: 'player'
        })

      if (teamRoleError) {
        // Try to rollback player link if role creation fails
        await supabaseAdmin
          .from('players')
          .update({ user_id: null, email: null })
          .eq('id', body.playerId)

        return new Response(
          JSON.stringify({
            ok: false,
            error: `Failed to assign team role for existing user: ${teamRoleError.message}`
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        )
      }

      // Success for existing user
      return new Response(
        JSON.stringify({
          ok: true,
          message: 'Existing user linked successfully',
          userId: existingUser.id
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Create the auth user
    const { data: newUser, error: createUserError } = await supabaseAdmin.auth.admin.createUser({
      email: body.email,
      password: body.password,
      email_confirm: true, // Auto-confirm the email
      user_metadata: {
        display_name: player.full_name,
        role: 'player'
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

    // Link the player to the user and store email
    const { error: updateError } = await supabaseAdmin
      .from('players')
      .update({
        user_id: newUser.user.id,
        email: body.email.toLowerCase().trim()
      })
      .eq('id', body.playerId)

    if (updateError) {
      // Rollback: delete the created user
      await supabaseAdmin.auth.admin.deleteUser(newUser.user.id)

      return new Response(
        JSON.stringify({
          ok: false,
          error: `Failed to link player to user: ${updateError.message}`
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Create profile for the user (if your schema requires it)
    const { error: profileCreateError } = await supabaseAdmin
      .from('profiles')
      .insert({
        id: newUser.user.id,
        display_name: player.full_name,
        role: 'player'
      })

    if (profileCreateError) {
      console.error('Failed to create profile (may be auto-created by trigger):', profileCreateError)
      // Don't fail the request, as the trigger might handle this
    }

    // Create user_team_role entry so the player can see their team
    const { error: teamRoleError } = await supabaseAdmin
      .from('user_team_roles')
      .insert({
        user_id: newUser.user.id,
        team_id: player.team_id,
        role: 'player'
      })

    if (teamRoleError) {
      console.error('Failed to create user_team_role:', teamRoleError)
      // Rollback: delete the created user and player link
      await supabaseAdmin.auth.admin.deleteUser(newUser.user.id)
      await supabaseAdmin
        .from('players')
        .update({ user_id: null, email: null })
        .eq('id', body.playerId)

      return new Response(
        JSON.stringify({
          ok: false,
          error: `Failed to assign team role: ${teamRoleError.message}`
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
        message: 'Credentials assigned successfully',
        userId: newUser.user.id
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Unexpected error in assign-player-credentials function:', error)
    return new Response(
      JSON.stringify({
        ok: false,
        error: 'Internal server error'
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
