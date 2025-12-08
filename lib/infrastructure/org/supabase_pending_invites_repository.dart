// lib/infrastructure/org/supabase_pending_invites_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';
import 'package:sport_tech_app/domain/org/repositories/pending_invites_repository.dart';
import 'package:sport_tech_app/infrastructure/org/mappers/pending_invite_mapper.dart';

/// Supabase implementation of [PendingInvitesRepository]
class SupabasePendingInvitesRepository implements PendingInvitesRepository {
  final SupabaseClient _client;

  SupabasePendingInvitesRepository(this._client);

  @override
  Future<Result<List<PendingInvite>>> getAllInvites() async {
    try {
      final response = await _client
          .from('pending_invites')
          .select()
          .order('created_at', ascending: false);

      final invites = (response as List)
          .map((json) => PendingInviteMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(invites);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting all invites: $e'));
    }
  }

  @override
  Future<Result<List<PendingInvite>>> getInvitesByTeam(int teamId) async {
    try {
      // Query using array contains operator
      final response = await _client
          .from('pending_invites')
          .select()
          .contains('team_ids', [teamId])
          .order('created_at', ascending: false);

      final invites = (response as List)
          .map((json) => PendingInviteMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(invites);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting invites: $e'));
    }
  }

  @override
  Future<Result<PendingInvite>> getInviteByEmail(String email) async {
    try {
      final response = await _client
          .from('pending_invites')
          .select()
          .eq('email', email.trim().toLowerCase())
          .eq('status', 'pending')
          .maybeSingle();

      if (response == null) {
        return const Failed(NotFoundFailure('Invite not found'));
      }

      return Success(PendingInviteMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Invite not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting invite: $e'));
    }
  }

  @override
  Future<Result<PendingInvite>> createPlayerInvite({
    required String email,
    required int playerId,
    required String createdBy,
    String? displayName,
    bool sendEmail = true,
  }) async {
    try {
      // Get the team_id from the player record
      final playerResponse = await _client
          .from('players')
          .select('team_id')
          .eq('id', playerId)
          .single();

      final teamId = playerResponse['team_id'] as int;

      // Call the Edge Function 'invite-user' which handles user creation and email sending
      // Note: The function expects camelCase field names
      final response = await _client.functions.invoke(
        'invite-user',
        body: {
          'email': email.trim().toLowerCase(),
          'role': 'player',
          'displayName': displayName,
          'teamIds': [teamId],
          'playerId': playerId,
          'sendEmail': sendEmail,
          'redirectTo': 'sporttech://login-callback', // Deep link for mobile app
        },
      );

      if (response.status != 200) {
        return Failed(
          ServerFailure(
            'Error al enviar invitación: ${response.data}',
          ),
        );
      }

      // After successful Edge Function call, fetch the created invite from the database
      final inviteResponse = await _client
          .from('pending_invites')
          .select()
          .eq('email', email.trim().toLowerCase())
          .eq('player_id', playerId)
          .single();

      return Success(PendingInviteMapper.fromJson(inviteResponse));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } on FunctionException catch (e) {
      return Failed(
        ServerFailure('Error llamando a la función invite-user: ${e.details}'),
      );
    } catch (e) {
      return Failed(ServerFailure('Error creating player invite: $e'));
    }
  }

  @override
  Future<Result<PendingInvite>> createStaffInvite({
    required String email,
    required List<int> teamIds,
    required String role,
    required String createdBy,
    String? displayName,
  }) async {
    try {
      if (role != 'coach' && role != 'admin') {
        return const Failed(
          ValidationFailure('Invalid role. Must be "coach" or "admin"'),
        );
      }

      if (teamIds.isEmpty) {
        return const Failed(
          ValidationFailure('At least one team is required'),
        );
      }

      final response = await _client.from('pending_invites').insert({
        'email': email.trim().toLowerCase(),
        'display_name': displayName,
        'role': role,
        'team_ids': teamIds,
        'status': 'pending',
        'created_by': createdBy,
      }).select().single();

      return Success(PendingInviteMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating staff invite: $e'));
    }
  }

  @override
  Future<Result<PendingInvite>> markInviteAccepted(String email) async {
    try {
      final response = await _client
          .from('pending_invites')
          .update({
            'status': 'accepted',
            'accepted_at': DateTime.now().toIso8601String(),
          })
          .eq('email', email.trim().toLowerCase())
          .eq('status', 'pending')
          .select()
          .single();

      return Success(PendingInviteMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Invite not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error accepting invite: $e'));
    }
  }

  @override
  Future<Result<void>> deleteInvite(int id) async {
    try {
      await _client.from('pending_invites').delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting invite: $e'));
    }
  }

  @override
  Future<Result<PendingInvite>> cancelInvite(int id) async {
    try {
      final response = await _client
          .from('pending_invites')
          .update({'status': 'canceled'})
          .eq('id', id)
          .select()
          .single();

      return Success(PendingInviteMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Invite not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error canceling invite: $e'));
    }
  }

  @override
  Future<Result<String>> resendInvite(int id, {bool sendEmail = true}) async {
    try {
      // First, verify the invite exists and is pending
      final inviteResponse = await _client
          .from('pending_invites')
          .select()
          .eq('id', id)
          .single();

      if (inviteResponse['status'] != 'pending') {
        return const Failed(
          ValidationFailure('Cannot resend an invite that is not pending'),
        );
      }

      final email = inviteResponse['email'] as String;
      final role = inviteResponse['role'] as String;
      final displayName = inviteResponse['display_name'] as String?;
      final teamIds = inviteResponse['team_ids'] as List?;
      final playerId = inviteResponse['player_id'] as int?;

      // Call the existing Edge Function 'invite-user'
      // Note: The function expects camelCase field names
      final response = await _client.functions.invoke(
        'invite-user',
        body: {
          'email': email,
          'role': role,
          'displayName': displayName,
          'teamIds': teamIds?.cast<int>() ?? [],
          'playerId': playerId,
          'inviteId': id,
          'sendEmail': sendEmail,
          'redirectTo': 'sporttech://login-callback', // Deep link for mobile app
        },
      );

      if (response.status != 200) {
        return Failed(
          ServerFailure(
            'Error al enviar invitación: ${response.data}',
          ),
        );
      }

      // Extract action_link from response (the magic link to share)
      final responseData = response.data as Map<String, dynamic>?;
      final actionLink = responseData?['action_link'] as String?;

      if (actionLink == null) {
        return const Failed(
          ServerFailure('No se pudo generar el enlace de invitación'),
        );
      }

      return Success(actionLink);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Invite not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } on FunctionException catch (e) {
      return Failed(
        ServerFailure('Error llamando a la función invite-user: ${e.details}'),
      );
    } catch (e) {
      return Failed(ServerFailure('Error resending invite: $e'));
    }
  }
}
