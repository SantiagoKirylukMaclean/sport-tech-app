// lib/infrastructure/matches/supabase_match_quarter_results_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match_quarter_result.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_quarter_results_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/mappers/match_quarter_result_mapper.dart';

/// Supabase implementation of [MatchQuarterResultsRepository]
class SupabaseMatchQuarterResultsRepository
    implements MatchQuarterResultsRepository {
  final SupabaseClient _client;

  SupabaseMatchQuarterResultsRepository(this._client);

  @override
  Future<Result<List<MatchQuarterResult>>> getResultsByMatch(
    String matchId,
  ) async {
    try {
      final response = await _client
          .from('match_quarter_results')
          .select()
          .eq('match_id', matchId)
          .order('quarter', ascending: true);

      final results = (response as List)
          .map(
            (json) => MatchQuarterResultMapper.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();

      return Success(results);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting quarter results: $e'));
    }
  }

  @override
  Future<Result<MatchQuarterResult?>> getResultByMatchAndQuarter({
    required String matchId,
    required int quarter,
  }) async {
    try {
      final response = await _client
          .from('match_quarter_results')
          .select()
          .eq('match_id', matchId)
          .eq('quarter', quarter)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      return Success(MatchQuarterResultMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting quarter result: $e'));
    }
  }

  @override
  Future<Result<MatchQuarterResult>> upsertQuarterResult({
    required String matchId,
    required int quarter,
    required int teamGoals,
    required int opponentGoals,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Check if result exists
      final existing = await _client
          .from('match_quarter_results')
          .select('id, created_at')
          .eq('match_id', matchId)
          .eq('quarter', quarter)
          .maybeSingle();

      final response = await _client.from('match_quarter_results').upsert({
        if (existing != null) 'id': existing['id'],
        'match_id': int.parse(matchId),
        'quarter': quarter,
        'team_goals': teamGoals,
        'opponent_goals': opponentGoals,
        'created_at': existing != null
            ? existing['created_at']
            : now, // Keep original created_at
        'updated_at': now,
      }).select().single();

      return Success(MatchQuarterResultMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error upserting quarter result: $e'));
    }
  }

  @override
  Future<Result<void>> deleteQuarterResult({
    required String matchId,
    required int quarter,
  }) async {
    try {
      await _client
          .from('match_quarter_results')
          .delete()
          .eq('match_id', matchId)
          .eq('quarter', quarter);

      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting quarter result: $e'));
    }
  }
}
