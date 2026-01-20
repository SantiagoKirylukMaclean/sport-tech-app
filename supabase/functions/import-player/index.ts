import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

interface ImportPlayerRequest {
    teamId: string;
    fullName: string;
    jerseyNumber?: number;
    userId?: string; // Optional: ID of the existing user if they have one
    email?: string;  // Optional: Email of the existing user
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

        // Verify the caller is an authenticated user (coach/admin)
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

        // Check permissions (Coach, Admin, Super Admin)
        const { data: profile, error: profileError } = await supabaseAdmin
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single()

        if (profileError || !profile || (profile.role !== 'super_admin' && profile.role !== 'admin' && profile.role !== 'coach')) {
            return new Response(
                JSON.stringify({ ok: false, error: 'Insufficient permissions.' }),
                {
                    status: 403,
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                }
            )
        }

        const body: ImportPlayerRequest = await req.json()

        if (!body.teamId || !body.fullName) {
            return new Response(
                JSON.stringify({
                    ok: false,
                    error: 'Missing required fields: teamId and fullName are required'
                }),
                {
                    status: 400,
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                }
            )
        }

        // 1. Create the Player record
        // We use .select() to get the created player back
        const { data: newPlayer, error: createPlayerError } = await supabaseAdmin
            .from('players')
            .insert({
                team_id: body.teamId,
                full_name: body.fullName,
                jersey_number: body.jerseyNumber,
                user_id: body.userId || null,
                email: body.email || null, // If we have the email, stick it in (though triggers might sync it)
            })
            .select()
            .single()

        if (createPlayerError) {
            return new Response(
                JSON.stringify({
                    ok: false,
                    error: `Failed to create player: ${createPlayerError.message}`
                }),
                {
                    status: 500,
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                }
            )
        }

        // 2. If the imported player involves a User ID, create the user_team_role link
        if (body.userId) {
            const { error: teamRoleError } = await supabaseAdmin
                .from('user_team_roles')
                .insert({
                    user_id: body.userId,
                    team_id: body.teamId,
                    role: 'player'
                })

            // If this fails, we should probably warn but keeping the player is fine? 
            // Or rollback? Ideally rollback to keep state consistent.
            if (teamRoleError) {
                console.error('Failed to create user_team_role:', teamRoleError)

                // Rollback: delete the player we just created to avoid half-state
                await supabaseAdmin.from('players').delete().eq('id', newPlayer.id)

                return new Response(
                    JSON.stringify({
                        ok: false,
                        error: `Failed to assign permissions (rolled back): ${teamRoleError.message}`
                    }),
                    {
                        status: 500,
                        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                    }
                )
            }
        }

        // Success
        return new Response(
            JSON.stringify({
                ok: true,
                message: 'Player imported successfully',
                player: newPlayer
            }),
            {
                status: 200,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
        )

    } catch (error) {
        console.error('Unexpected error in import-player function:', error)
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
