// lib/infrastructure/org/supabase_pending_invites_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';
import 'package:sport_tech_app/domain/org/repositories/pending_invites_repository.dart';
import 'package:sport_tech_app/infrastructure/org/mappers/pending_invite_mapper.dart';
import 'package:uuid/uuid.dart';

/// Supabase implementation of [PendingInvitesRepository]
class SupabasePendingInvitesRepository implements PendingInvitesRepository {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  SupabasePendingInvitesRepository(this._client);

  @override
  Future<Result<List<PendingInvite>>> getInvitesByTeam(String teamId) async {
    try {
      final response = await _client
          .from('pending_invites')
          .select()
          .eq('team_id', teamId)
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
  Future<Result<PendingInvite>> getInviteByToken(String token) async {
    try {
      final response = await _client
          .from('pending_invites')
          .select()
          .eq('invite_token', token)
          .single();

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
    required String teamId,
    required String playerName,
    required String invitedBy,
    int? jerseyNumber,
    int expiryDays = 7,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(Duration(days: expiryDays));
      final token = _uuid.v4();

      final response = await _client.from('pending_invites').insert({
        'id': _uuid.v4(),
        'email': email.trim().toLowerCase(),
        'team_id': teamId,
        'role': 'player',
        'player_name': playerName.trim(),
        'jersey_number': jerseyNumber,
        'invited_by': invitedBy,
        'invite_token': token,
        'accepted': false,
        'created_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      }).select().single();

      return Success(PendingInviteMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating player invite: $e'));
    }
  }

  @override
  Future<Result<PendingInvite>> createStaffInvite({
    required String email,
    required String teamId,
    required String role,
    required String invitedBy,
    int expiryDays = 7,
  }) async {
    try {
      if (role != 'coach' && role != 'admin') {
        return const Failed(
          ValidationFailure('Invalid role. Must be "coach" or "admin"'),
        );
      }

      final now = DateTime.now();
      final expiresAt = now.add(Duration(days: expiryDays));
      final token = _uuid.v4();

      final response = await _client.from('pending_invites').insert({
        'id': _uuid.v4(),
        'email': email.trim().toLowerCase(),
        'team_id': teamId,
        'role': role,
        'invited_by': invitedBy,
        'invite_token': token,
        'accepted': false,
        'created_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      }).select().single();

      return Success(PendingInviteMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating staff invite: $e'));
    }
  }

  @override
  Future<Result<PendingInvite>> markInviteAccepted(String token) async {
    try {
      final response = await _client
          .from('pending_invites')
          .update({'accepted': true})
          .eq('invite_token', token)
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
  Future<Result<void>> deleteInvite(String id) async {
    try {
      await _client.from('pending_invites').delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting invite: $e'));
    }
  }
}
