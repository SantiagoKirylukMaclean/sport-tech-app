// lib/infrastructure/matches/supabase_match_call_ups_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match_call_up.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_call_ups_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/mappers/match_call_up_mapper.dart';

/// Supabase implementation of [MatchCallUpsRepository]
class SupabaseMatchCallUpsRepository implements MatchCallUpsRepository {
  final SupabaseClient _client;

  SupabaseMatchCallUpsRepository(this._client);

  @override
  Future<Result<List<MatchCallUp>>> getCallUpsByMatch(String matchId) async {
    try {
      final response = await _client
          .from('match_call_ups')
          .select('*, players(full_name, jersey_number)')
          .eq('match_id', matchId)
          .order('created_at', ascending: true);

      final callUps = (response as List)
          .map((json) =>
              MatchCallUpMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(callUps);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting call-ups: $e'));
    }
  }

  @override
  Future<Result<MatchCallUp>> addPlayerToCallUp({
    required String matchId,
    required String playerId,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('match_call_ups')
          .insert({
            'match_id': int.parse(matchId),
            'player_id': int.parse(playerId),
            'created_at': now,
          })
          .select()
          .single();

      return Success(MatchCallUpMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error adding player to call-up: $e'));
    }
  }

  @override
  Future<Result<void>> removePlayerFromCallUp({
    required String matchId,
    required String playerId,
  }) async {
    try {
      await _client
          .from('match_call_ups')
          .delete()
          .eq('match_id', matchId)
          .eq('player_id', playerId);

      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error removing player from call-up: $e'));
    }
  }

  @override
  Future<Result<bool>> isPlayerCalledUp({
    required String matchId,
    required String playerId,
  }) async {
    try {
      final response = await _client
          .from('match_call_ups')
          .select('player_id')
          .eq('match_id', matchId)
          .eq('player_id', playerId)
          .maybeSingle();

      return Success(response != null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error checking if player is called up: $e'));
    }
  }
}
