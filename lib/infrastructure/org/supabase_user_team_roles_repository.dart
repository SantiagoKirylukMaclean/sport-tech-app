// lib/infrastructure/org/supabase_user_team_roles_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/user_team_role.dart';
import 'package:sport_tech_app/domain/org/repositories/user_team_roles_repository.dart';
import 'package:sport_tech_app/infrastructure/org/mappers/user_team_role_mapper.dart';

/// Supabase implementation of [UserTeamRolesRepository]
class SupabaseUserTeamRolesRepository implements UserTeamRolesRepository {
  final SupabaseClient _client;

  SupabaseUserTeamRolesRepository(this._client);

  @override
  Future<Result<List<UserTeamRole>>> getRolesByUser(String userId) async {
    try {
      final response =
          await _client.from('user_team_roles').select().eq('user_id', userId);

      final roles = (response as List)
          .map((json) =>
              UserTeamRoleMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(roles);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting user roles: $e'));
    }
  }

  @override
  Future<Result<List<UserTeamRole>>> getRolesByTeam(String teamId) async {
    try {
      final response =
          await _client.from('user_team_roles').select().eq('team_id', teamId);

      final roles = (response as List)
          .map((json) =>
              UserTeamRoleMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(roles);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting team roles: $e'));
    }
  }

  @override
  Future<Result<UserTeamRole>> assignRole({
    required String userId,
    required String teamId,
    required TeamRole role,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('user_team_roles')
          .upsert({
            'user_id': userId,
            'team_id': teamId,
            'role': role.value,
            'created_at': now,
          }, onConflict: 'user_id, team_id, role', ignoreDuplicates: true)
          .select()
          .single();

      return Success(UserTeamRoleMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error assigning role: $e'));
    }
  }

  @override
  Future<Result<void>> removeRole({
    required String userId,
    required String teamId,
    required TeamRole role,
  }) async {
    try {
      await _client.from('user_team_roles').delete().match({
        'user_id': userId,
        'team_id': teamId,
        'role': role.value,
      });
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error removing role: $e'));
    }
  }
}
