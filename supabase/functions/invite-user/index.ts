import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'npm:@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

interface InviteUserRequest {
  email: string;
  displayName?: string;
  role: 'coach' | 'admin' | 'player';
  teamIds: number[];
  playerId?: number;
  redirectTo?: string;
  sendEmail?: boolean; // If true, send email automatically. If false, return magic link
}

interface InviteUserResponse {
  ok: boolean;
  action_link?: string;
  error?: string;
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

    const body: InviteUserRequest = await req.json()

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

    if (!['coach', 'admin', 'player'].includes(body.role)) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Invalid role. Must be "coach", "admin", or "player"' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    if (body.role === 'player') {
      if (!body.playerId) {
        return new Response(
          JSON.stringify({ ok: false, error: 'playerId is required for player invitations' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        )
      }

      const { data: player, error: playerError } = await supabaseAdmin
        .from('players')
        .select('id, user_id, team_id')
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
          JSON.stringify({ ok: false, error: 'This player already has a linked account' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        )
      }

      if (body.teamIds.length !== 1 || body.teamIds[0] !== player.team_id) {
        return new Response(
          JSON.stringify({ ok: false, error: 'Player must be assigned to their team only' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        )
      }
    }

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

    // Check if user already exists in auth.users
    const { data: existingUsers } = await supabaseAdmin.auth.admin.listUsers()
    const existingUser = existingUsers.users.find(u => u.email?.toLowerCase() === body.email.toLowerCase())

    let userId: string
    let userAlreadyExists = false

    if (existingUser) {
      userId = existingUser.id
      userAlreadyExists = true
    } else {
      const { data: newUser, error: createUserError } = await supabaseAdmin.auth.admin.createUser({
        email: body.email,
        email_confirm: false, // Don't auto-confirm, let them set password via invite link
        user_metadata: {
          display_name: body.displayName || body.email.split('@')[0]
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

      userId = newUser.user.id
    }

    // Check if we should send email or just generate the link
    const sendEmail = body.sendEmail !== false; // Default to true if not specified
    let actionLink: string

    // For existing users, use 'recovery' type instead of 'invite'
    // For new users, use 'invite'
    const linkType = userAlreadyExists ? 'recovery' : 'invite'

    if (sendEmail) {
      // Option 1: Send email automatically
      if (userAlreadyExists) {
        // For existing users, send a recovery/password reset email
        const { data: recoveryData, error: recoveryError } = await supabaseAdmin.auth.admin.generateLink({
          type: 'recovery',
          email: body.email,
        })

        if (recoveryError) {
          return new Response(
            JSON.stringify({
              ok: false,
              error: `Failed to send invitation: ${recoveryError.message}`
            }),
            {
              status: 500,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
          )
        }

        // Send the recovery email manually or use Supabase's built-in method
        // For now, we'll use the admin API to trigger the email
        const { error: resetError } = await supabaseAdmin.auth.resetPasswordForEmail(body.email)

        if (resetError) {
          return new Response(
            JSON.stringify({
              ok: false,
              error: `Failed to send password reset: ${resetError.message}`
            }),
            {
              status: 500,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
          )
        }

        actionLink = 'Password reset email sent successfully to ' + body.email
      } else {
        // For new users, send invitation email
        const { data: inviteData, error: inviteError } = await supabaseAdmin.auth.admin.inviteUserByEmail(
          body.email,
          {
            data: {
              display_name: body.displayName || body.email.split('@')[0],
              role: body.role,
              team_ids: body.teamIds,
              player_id: body.playerId
            }
          }
        )

        if (inviteError) {
          return new Response(
            JSON.stringify({
              ok: false,
              error: `Failed to send invitation: ${inviteError.message}`
            }),
            {
              status: 500,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
          )
        }

        actionLink = 'Email sent successfully to ' + body.email
      }
    } else {
      // Option 2: Generate link without sending email
      // For manual sharing, use a simple success page
      // The user will set their password and then see a confirmation message
      const defaultRedirect = 'https://supabase.com'

      const linkOptions: any = {
        // Use a neutral redirect that won't fail
        // After password is set, user will be redirected to this page
        redirectTo: body.redirectTo || defaultRedirect
      }

      const { data: magicLinkData, error: magicLinkError } = await supabaseAdmin.auth.admin.generateLink({
        type: linkType,
        email: body.email,
        options: linkOptions
      })

      if (magicLinkError || !magicLinkData.properties?.action_link) {
        return new Response(
          JSON.stringify({
            ok: false,
            error: `Failed to generate invitation link: ${magicLinkError?.message || 'Unknown error'}`
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        )
      }

      // Clean up the link - replace localhost redirect with supabase.com
      let cleanLink = magicLinkData.properties.action_link
      try {
        const linkUrl = new URL(cleanLink)
        const redirect = linkUrl.searchParams.get('redirect_to')

        // If redirect contains localhost, replace it with supabase.com
        if (redirect && (redirect.includes('localhost') || redirect.includes('127.0.0.1'))) {
          linkUrl.searchParams.set('redirect_to', defaultRedirect)
          cleanLink = linkUrl.toString()
        }
      } catch (e) {
        console.error('Failed to clean link:', e)
        // If parsing fails, use original link
      }

      actionLink = cleanLink
    }

    // Crear/actualizar pending invitation
    const pendingInviteData: any = {
      email: body.email.toLowerCase(),
      display_name: body.displayName,
      role: body.role,
      team_ids: body.teamIds,
      status: 'pending',
      created_by: user.id
    }

    if (body.role === 'player' && body.playerId) {
      pendingInviteData.player_id = body.playerId
    }

    const { error: dbError } = await supabaseAdmin
      .from('pending_invites')
      .upsert(pendingInviteData, {
        onConflict: 'email'
      })

    if (dbError) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: `Failed to create invitation record: ${dbError.message}`
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const response: InviteUserResponse = {
      ok: true,
      action_link: actionLink
    }

    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Unexpected error in invite-user function:', error)
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
