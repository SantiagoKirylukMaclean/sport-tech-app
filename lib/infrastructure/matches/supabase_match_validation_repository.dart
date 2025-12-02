// lib/infrastructure/matches/supabase_match_validation_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_validation_repository.dart';

/// Supabase implementation of [MatchValidationRepository]
class SupabaseMatchValidationRepository implements MatchValidationRepository {
  final SupabaseClient _client;

  SupabaseMatchValidationRepository(this._client);

  @override
  Future<Result<List<PlayerMinimumPeriodsViolation>>> validateMinimumPeriods(
    String matchId,
  ) async {
    try {
      final response = await _client.rpc(
        'validate_match_minimum_periods',
        params: {'p_match_id': int.parse(matchId)},
      ) as List;

      final violations = response
          .map(
            (json) => PlayerMinimumPeriodsViolation(
              playerId: json['player_id'].toString(),
              playerName: json['full_name'] as String,
              periodsPlayed: json['periods_played'] as int,
            ),
          )
          .toList();

      return Success(violations);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error validating minimum periods: $e'));
    }
  }
}
