// lib/infrastructure/matches/supabase_match_player_periods_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/field_zone.dart';
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
      final matchIdInt = int.tryParse(matchId);
      if (matchIdInt == null) {
        return Failed(ServerFailure('Invalid matchId format: $matchId'));
      }

      final response = await _client
          .from('match_player_periods')
          .select()
          .eq('match_id', matchIdInt)
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
      // Parse matchId as int since it's stored as integer in the database
      // playerId remains as string (UUID)
      final matchIdInt = int.tryParse(matchId);
      if (matchIdInt == null) {
        return Failed(ServerFailure('Invalid matchId format: $matchId'));
      }

      final response = await _client
          .from('match_player_periods')
          .select()
          .eq('match_id', matchIdInt)
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
      final matchIdInt = int.tryParse(matchId);
      if (matchIdInt == null) {
        return Failed(ServerFailure('Invalid matchId format: $matchId'));
      }

      final response = await _client
          .from('match_player_periods')
          .select()
          .eq('match_id', matchIdInt)
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
    FieldZone? fieldZone,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final matchIdInt = int.parse(matchId);

      // Upsert: delete existing + insert new
      await _client
          .from('match_player_periods')
          .delete()
          .eq('match_id', matchIdInt)
          .eq('player_id', playerId)
          .eq('period', period);

      final insertData = {
        'match_id': matchIdInt,
        'player_id': playerId, // Keep as string (UUID)
        'period': period,
        'fraction': fraction.value,
        'created_at': now,
      };

      if (fieldZone != null) {
        insertData['field_zone'] = fieldZone.value;
      }

      final response = await _client
          .from('match_player_periods')
          .insert(insertData)
          .select()
          .single();

      return Success(MatchPlayerPeriodMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error setting player period: $e'));
    }
  }

  @override
  Future<Result<MatchPlayerPeriod>> updatePlayerFieldZone({
    required String matchId,
    required String playerId,
    required int period,
    required FieldZone fieldZone,
  }) async {
    try {
      final matchIdInt = int.parse(matchId);
      final response = await _client
          .from('match_player_periods')
          .update({'field_zone': fieldZone.value})
          .eq('match_id', matchIdInt)
          .eq('player_id', playerId)
          .eq('period', period)
          .select()
          .maybeSingle();

      if (response == null) {
        return Failed(
          ServerFailure('Player period not found. Player must be on field first.'),
        );
      }

      return Success(MatchPlayerPeriodMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating player field zone: $e'));
    }
  }

  @override
  Future<Result<void>> removePlayerPeriod({
    required String matchId,
    required String playerId,
    required int period,
  }) async {
    try {
      final matchIdInt = int.parse(matchId);
      await _client
          .from('match_player_periods')
          .delete()
          .eq('match_id', matchIdInt)
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
      final matchIdInt = int.parse(matchId);
      await _client
          .from('match_player_periods')
          .delete()
          .eq('match_id', matchIdInt)
          .eq('player_id', playerId);

      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error removing all player periods: $e'));
    }
  }
}
