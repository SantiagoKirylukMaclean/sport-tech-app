// lib/infrastructure/matches/supabase_match_player_periods_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match_player_period.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_player_periods_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/mappers/match_player_period_mapper.dart';

/// Supabase implementation of [MatchPlayerPeriodsRepository]
class SupabaseMatchPlayerPeriodsRepository
    implements MatchPlayerPeriodsRepository {
  final SupabaseClient _client;

  SupabaseMatchPlayerPeriodsRepository(this._client);

  @override
  Future<Result<List<MatchPlayerPeriod>>> getPeriodsByMatch(
    String matchId,
  ) async {
    try {
      final response = await _client
          .from('match_player_periods')
          .select()
          .eq('match_id', matchId)
          .order('period', ascending: true);

      final periods = (response as List)
          .map(
            (json) => MatchPlayerPeriodMapper.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();

      return Success(periods);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting periods: $e'));
    }
  }

  @override
  Future<Result<List<MatchPlayerPeriod>>> getPeriodsByMatchAndPlayer({
    required String matchId,
    required String playerId,
  }) async {
    try {
      final response = await _client
          .from('match_player_periods')
          .select()
          .eq('match_id', matchId)
          .eq('player_id', playerId)
          .order('period', ascending: true);

      final periods = (response as List)
          .map(
            (json) => MatchPlayerPeriodMapper.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();

      return Success(periods);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting player periods: $e'));
    }
  }

  @override
  Future<Result<List<MatchPlayerPeriod>>> getPeriodsByMatchAndQuarter({
    required String matchId,
    required int quarter,
  }) async {
    try {
      final response = await _client
          .from('match_player_periods')
          .select()
          .eq('match_id', matchId)
          .eq('period', quarter)
          .order('player_id', ascending: true);

      final periods = (response as List)
          .map(
            (json) => MatchPlayerPeriodMapper.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();

      return Success(periods);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting quarter periods: $e'));
    }
  }

  @override
  Future<Result<MatchPlayerPeriod>> setPlayerPeriod({
    required String matchId,
    required String playerId,
    required int period,
    required Fraction fraction,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Upsert: delete existing + insert new
      await _client
          .from('match_player_periods')
          .delete()
          .eq('match_id', matchId)
          .eq('player_id', playerId)
          .eq('period', period);

      final response = await _client.from('match_player_periods').insert({
        'match_id': int.parse(matchId),
        'player_id': int.parse(playerId),
        'period': period,
        'fraction': fraction.value,
        'created_at': now,
      }).select().single();

      return Success(MatchPlayerPeriodMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error setting player period: $e'));
    }
  }

  @override
  Future<Result<void>> removePlayerPeriod({
    required String matchId,
    required String playerId,
    required int period,
  }) async {
    try {
      await _client
          .from('match_player_periods')
          .delete()
          .eq('match_id', matchId)
          .eq('player_id', playerId)
          .eq('period', period);

      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error removing player period: $e'));
    }
  }

  @override
  Future<Result<void>> removeAllPlayerPeriods({
    required String matchId,
    required String playerId,
  }) async {
    try {
      await _client
          .from('match_player_periods')
          .delete()
          .eq('match_id', matchId)
          .eq('player_id', playerId);

      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error removing all player periods: $e'));
    }
  }
}
