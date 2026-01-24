// lib/infrastructure/matches/supabase_matches_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match.dart';
import 'package:sport_tech_app/domain/matches/repositories/matches_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/mappers/match_mapper.dart';

/// Supabase implementation of [MatchesRepository]
class SupabaseMatchesRepository implements MatchesRepository {
  final SupabaseClient _client;

  SupabaseMatchesRepository(this._client);

  @override
  Future<Result<List<Match>>> getMatchesByTeam(String teamId) async {
    try {
      final response = await _client
          .from('matches')
          .select()
          .eq('team_id', teamId)
          .order('match_date', ascending: false);

      final matches = (response as List)
          .map((json) => MatchMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(matches);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting matches: $e'));
    }
  }

  @override
  Future<Result<Match>> getMatchById(String id) async {
    try {
      final response =
          await _client.from('matches').select().eq('id', id).single();

      return Success(MatchMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Match not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting match: $e'));
    }
  }

  @override
  Future<Result<Match>> createMatch({
    required String teamId,
    required String opponent,
    required DateTime matchDate,
    String? location,
    String? notes,
    int? numberOfPeriods,
    int? periodDuration,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('matches')
          .insert({
            'team_id': int.parse(teamId),
            'opponent': opponent.trim(),
            'match_date': matchDate.toIso8601String().split('T')[0],
            'location': location?.trim(),
            'notes': notes?.trim(),
            'number_of_periods': numberOfPeriods,
            'period_duration': periodDuration,
            'created_at': now,
          })
          .select()
          .single();

      return Success(MatchMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating match: $e'));
    }
  }

  @override
  Future<Result<Match>> updateMatch({
    required String id,
    String? opponent,
    DateTime? matchDate,
    String? location,
    String? notes,
    int? numberOfPeriods,
    int? periodDuration,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (opponent != null) {
        updates['opponent'] = opponent.trim();
      }
      if (matchDate != null) {
        updates['match_date'] = matchDate.toIso8601String().split('T')[0];
      }
      if (location != null) {
        updates['location'] = location.trim();
      }
      if (notes != null) {
        updates['notes'] = notes.trim();
      }
      if (numberOfPeriods != null) {
        updates['number_of_periods'] = numberOfPeriods;
      }
      if (periodDuration != null) {
        updates['period_duration'] = periodDuration;
      }

      final response = await _client
          .from('matches')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Success(MatchMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Match not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating match: $e'));
    }
  }

  @override
  Future<Result<void>> deleteMatch(String id) async {
    try {
      await _client.from('matches').delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting match: $e'));
    }
  }
}
