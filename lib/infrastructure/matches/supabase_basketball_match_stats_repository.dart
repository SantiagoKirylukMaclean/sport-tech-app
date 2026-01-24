import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';
import 'package:sport_tech_app/domain/matches/repositories/basketball_match_stats_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/mappers/basketball_match_stat_mapper.dart';

class SupabaseBasketballMatchStatsRepository
    implements BasketballMatchStatsRepository {
  final SupabaseClient _client;

  SupabaseBasketballMatchStatsRepository(this._client);

  @override
  Future<Result<List<BasketballMatchStat>>> getStatsByMatch(
      String matchId) async {
    try {
      final response = await _client
          .from('basketball_match_stats')
          .select()
          .eq('match_id', int.parse(matchId))
          .order('created_at', ascending: false);

      final stats = (response as List)
          .map((json) =>
              BasketballMatchStatMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(stats);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting stats: $e'));
    }
  }

  @override
  Future<Result<BasketballMatchStat>> createStat({
    required String matchId,
    required String playerId,
    required int quarter,
    required BasketballStatType statType,
  }) async {
    try {
      final response = await _client
          .from('basketball_match_stats')
          .insert({
            'match_id': int.parse(matchId),
            'player_id': int.parse(playerId),
            'quarter': quarter,
            'stat_type': statType.value,
          })
          .select()
          .single();

      return Success(BasketballMatchStatMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating stat: $e'));
    }
  }

  @override
  Future<Result<void>> deleteStat(String statId) async {
    try {
      await _client
          .from('basketball_match_stats')
          .delete()
          .eq('id', int.parse(statId));
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting stat: $e'));
    }
  }
}
