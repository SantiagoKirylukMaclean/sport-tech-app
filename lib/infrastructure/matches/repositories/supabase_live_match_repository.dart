import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/domain/matches/entities/match.dart';
import 'package:sport_tech_app/domain/matches/repositories/live_match_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/mappers/match_mapper.dart';

class SupabaseLiveMatchRepository implements LiveMatchRepository {
  final SupabaseClient _client;

  SupabaseLiveMatchRepository(this._client);

  @override
  Future<Match?> getLiveMatch(String teamId) async {
    try {
      final response = await _client
          .from('matches')
          .select()
          .eq('team_id', teamId)
          .eq('status',
              'live') // Assuming 'live' is the status for active matches
          .maybeSingle();

      if (response == null) {
        // Also check for 'in_progress' if that's a used status
        final responseInProgress = await _client
            .from('matches')
            .select()
            .eq('team_id', teamId)
            .eq('status', 'in_progress')
            .maybeSingle();

        if (responseInProgress == null) return null;
        return MatchMapper.fromJson(responseInProgress);
      }

      return MatchMapper.fromJson(response);
    } catch (e) {
      // Return null on error or rethrow depending on needs.
      // For now, if we can't fetch, we assume no live match.
      return null;
    }
  }
}
