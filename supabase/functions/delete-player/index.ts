import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'npm:@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        {
          status: 405,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Authorization header required' }),
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
        JSON.stringify({ error: 'Invalid or expired token' }),
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

    if (profileError || !profile || (profile.role !== 'super_admin' && profile.role !== 'admin' && profile.role !== 'coach')) {
      return new Response(
        JSON.stringify({ error: 'Insufficient permissions. Admin, Super Admin, or Coach role required.' }),
        {
          status: 403,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const { playerId } = await req.json()

    if (!playerId) {
      return new Response(
        JSON.stringify({ error: 'playerId is required' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Get player to check if it has a user_id
    const { data: player, error: playerError } = await supabaseAdmin
      .from('players')
      .select('id, user_id, full_name')
      .eq('id', playerId)
      .single()

    if (playerError || !player) {
      return new Response(
        JSON.stringify({ error: 'Player not found' }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // If player has a user_id, remove their role for this team ONLY
    if (player.user_id) {
      // Get the team_id from the player record first
      const { data: playerWithTeam, error: teamError } = await supabaseAdmin
        .from('players')
        .select('team_id')
        .eq('id', playerId)
        .single()

      if (playerWithTeam && playerWithTeam.team_id) {
        const { error: deleteRoleError } = await supabaseAdmin
          .from('user_team_roles')
          .delete()
          .eq('user_id', player.user_id)
          .eq('team_id', playerWithTeam.team_id)
          .eq('role', 'player') // Only delete player role

        if (deleteRoleError) {
          console.error('Failed to delete user_team_role:', deleteRoleError)
          // Continue anyway to delete the player record
        }
      }
    }

    // Delete the player
    const { error: deletePlayerError } = await supabaseAdmin
      .from('players')
      .delete()
      .eq('id', playerId)

    if (deletePlayerError) {
      return new Response(
        JSON.stringify({ error: `Failed to delete player: ${deletePlayerError.message}` }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Player and associated account deleted successfully'
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Error deleting player:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
