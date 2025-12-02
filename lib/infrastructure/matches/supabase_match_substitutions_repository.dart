// lib/infrastructure/matches/supabase_match_substitutions_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match_substitution.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_substitutions_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/mappers/match_substitution_mapper.dart';

/// Supabase implementation of [MatchSubstitutionsRepository]
class SupabaseMatchSubstitutionsRepository
    implements MatchSubstitutionsRepository {
  final SupabaseClient _client;

  SupabaseMatchSubstitutionsRepository(this._client);

  @override
  Future<Result<List<MatchSubstitution>>> getSubstitutionsByMatch(
    String matchId,
  ) async {
    try {
      final response = await _client
          .from('match_substitutions')
          .select()
          .eq('match_id', matchId)
          .order('period', ascending: true)
          .order('created_at', ascending: true);

      final substitutions = (response as List)
          .map(
            (json) => MatchSubstitutionMapper.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();

      return Success(substitutions);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting substitutions: $e'));
    }
  }

  @override
  Future<Result<List<MatchSubstitution>>> getSubstitutionsByMatchAndQuarter({
    required String matchId,
    required int quarter,
  }) async {
    try {
      final response = await _client
          .from('match_substitutions')
          .select()
          .eq('match_id', matchId)
          .eq('period', quarter)
          .order('created_at', ascending: true);

      final substitutions = (response as List)
          .map(
            (json) => MatchSubstitutionMapper.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();

      return Success(substitutions);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting quarter substitutions: $e'));
    }
  }

  @override
  Future<Result<void>> applySubstitution({
    required String matchId,
    required int period,
    required String playerOut,
    required String playerIn,
  }) async {
    try {
      // Call RPC function that handles the logic
      await _client.rpc(
        'apply_match_substitution',
        params: {
          'p_match_id': int.parse(matchId),
          'p_period': period,
          'p_player_out': int.parse(playerOut),
          'p_player_in': int.parse(playerIn),
        },
      );

      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error applying substitution: $e'));
    }
  }

  @override
  Future<Result<void>> removeSubstitution({
    required String matchId,
    required int period,
    required String playerOut,
    required String playerIn,
  }) async {
    try {
      // Call RPC function that handles the logic
      await _client.rpc(
        'remove_match_substitution',
        params: {
          'p_match_id': int.parse(matchId),
          'p_period': period,
          'p_player_out': int.parse(playerOut),
          'p_player_in': int.parse(playerIn),
        },
      );

      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error removing substitution: $e'));
    }
  }
}
