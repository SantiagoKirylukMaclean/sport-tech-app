import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/domain/stats/entities/scorer_stats.dart';
import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';
import 'package:sport_tech_app/domain/stats/entities/quarter_performance.dart';
import 'package:sport_tech_app/domain/stats/repositories/stats_repository.dart';
import 'package:sport_tech_app/infrastructure/stats/mappers/player_statistics_mapper.dart';
import 'package:sport_tech_app/infrastructure/stats/mappers/scorer_stats_mapper.dart';
import 'package:sport_tech_app/infrastructure/stats/mappers/match_summary_mapper.dart';
import 'package:sport_tech_app/infrastructure/stats/mappers/quarter_performance_mapper.dart';

import 'package:sport_tech_app/domain/stats/entities/player_quarter_stats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStatsRepository implements StatsRepository {
  final SupabaseClient _client;

  SupabaseStatsRepository(this._client);

  @override
  Future<List<PlayerStatistics>> getTeamPlayerStatistics(String teamId) async {
    try {
      // Call the RPC function to get player statistics
      final response = await _client.rpc(
        'get_team_player_statistics',
        params: {'p_team_id': int.parse(teamId)},
      );

      // Now we need to enrich with goals and assists
      final teamIdInt = int.parse(teamId);

      // Count goals and assists per player
      final goalsMap = <String, int>{};
      final assistsMap = <String, int>{};

      // First get all matches for the team
      final matchesResponse =
          await _client.from('matches').select('id').eq('team_id', teamIdInt);

      final matchIds =
          (matchesResponse as List).map((m) => m['id'] as int).toList();

      if (matchIds.isNotEmpty) {
        // Get all goals for these matches (excluding own goals)
        final allGoals = await _client
            .from('match_goals')
            .select('scorer_id, assister_id')
            .inFilter('match_id', matchIds)
            .eq('is_own_goal', false);

        for (final goal in allGoals as List) {
          final scorerId = goal['scorer_id'].toString();
          goalsMap[scorerId] = (goalsMap[scorerId] ?? 0) + 1;

          if (goal['assister_id'] != null) {
            final assisterId = goal['assister_id'].toString();
            assistsMap[assisterId] = (assistsMap[assisterId] ?? 0) + 1;
          }
        }
      }

      final stats = (response as List).map((json) {
        final playerId = json['player_id'].toString();
        final enrichedJson = Map<String, dynamic>.from(json);
        enrichedJson['total_goals'] = goalsMap[playerId] ?? 0;
        enrichedJson['total_assists'] = assistsMap[playerId] ?? 0;
        return PlayerStatisticsMapper.fromJson(enrichedJson);
      }).toList();

      return stats;
    } catch (e) {
      throw Exception('Failed to get team player statistics: $e');
    }
  }

  @override
  Future<PlayerStatistics?> getPlayerStatistics(
      String playerId, String teamId) async {
    try {
      // Get all player statistics for the team
      final allStats = await getTeamPlayerStatistics(teamId);

      // Find the specific player's stats
      try {
        return allStats.firstWhere(
          (stat) => stat.playerId == playerId,
        );
      } catch (e) {
        // Player not found in statistics
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get player statistics: $e');
    }
  }

  @override
  Future<List<ScorerStats>> getScorersRanking(String teamId,
      {int limit = 10}) async {
    try {
      final teamIdInt = int.parse(teamId);

      // Get all matches for the team
      final matchesResponse =
          await _client.from('matches').select('id').eq('team_id', teamIdInt);

      final matchIds =
          (matchesResponse as List).map((m) => m['id'] as int).toList();

      if (matchIds.isEmpty) {
        return [];
      }

      // Get goals grouped by scorer (excluding own goals)
      final goalsResponse = await _client
          .from('match_goals')
          .select(
              'scorer_id, players!match_goals_scorer_id_fkey(id, full_name, jersey_number)')
          .inFilter('match_id', matchIds)
          .eq('is_own_goal', false);

      // Group and count
      final scorersMap = <String, Map<String, dynamic>>{};

      for (final goal in goalsResponse as List) {
        final player = goal['players'];
        if (player != null) {
          final playerId = player['id'].toString();
          if (scorersMap.containsKey(playerId)) {
            scorersMap[playerId]!['count'] =
                (scorersMap[playerId]!['count'] as int) + 1;
          } else {
            scorersMap[playerId] = {
              'player_id': player['id'],
              'full_name': player['full_name'],
              'jersey_number': player['jersey_number'],
              'count': 1,
            };
          }
        }
      }

      final scorers = scorersMap.values
          .map((json) => ScorerStatsMapper.fromJson(json))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));

      return scorers.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get scorers ranking: $e');
    }
  }

  @override
  Future<List<ScorerStats>> getAssistersRanking(String teamId,
      {int limit = 10}) async {
    try {
      final teamIdInt = int.parse(teamId);

      // Get all matches for the team
      final matchesResponse =
          await _client.from('matches').select('id').eq('team_id', teamIdInt);

      final matchIds =
          (matchesResponse as List).map((m) => m['id'] as int).toList();

      if (matchIds.isEmpty) {
        return [];
      }

      // Get goals with assisters grouped by assister (excluding own goals)
      final assistsResponse = await _client
          .from('match_goals')
          .select(
              'assister_id, players!match_goals_assister_id_fkey(id, full_name, jersey_number)')
          .not('assister_id', 'is', null)
          .inFilter('match_id', matchIds)
          .eq('is_own_goal', false);

      // Group and count
      final assistersMap = <String, Map<String, dynamic>>{};

      for (final assist in assistsResponse as List) {
        final player = assist['players'];
        if (player != null) {
          final playerId = player['id'].toString();
          if (assistersMap.containsKey(playerId)) {
            assistersMap[playerId]!['count'] =
                (assistersMap[playerId]!['count'] as int) + 1;
          } else {
            assistersMap[playerId] = {
              'player_id': player['id'],
              'full_name': player['full_name'],
              'jersey_number': player['jersey_number'],
              'count': 1,
            };
          }
        }
      }

      final assisters = assistersMap.values
          .map((json) => ScorerStatsMapper.fromJson(json))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));

      return assisters.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get assisters ranking: $e');
    }
  }

  @override
  Future<List<MatchSummary>> getMatchesSummary(String teamId) async {
    try {
      final teamIdInt = int.parse(teamId);

      // Get all matches with their quarter results
      final matchesResponse = await _client.from('matches').select('''
            id,
            opponent,
            match_date,
            match_quarter_results(team_goals, opponent_goals)
          ''').eq('team_id', teamIdInt).order('match_date', ascending: false);

      final summaries = (matchesResponse as List).map((json) {
        // Calculate total goals from quarters
        int teamGoals = 0;
        int opponentGoals = 0;

        final quarters = json['match_quarter_results'] as List?;
        if (quarters != null) {
          for (final quarter in quarters) {
            teamGoals += (quarter['team_goals'] as num?)?.toInt() ?? 0;
            opponentGoals += (quarter['opponent_goals'] as num?)?.toInt() ?? 0;
          }
        }

        return MatchSummaryMapper.fromJson({
          'match_id': json['id'],
          'opponent': json['opponent'],
          'match_date': json['match_date'],
          'team_goals': teamGoals,
          'opponent_goals': opponentGoals,
        });
      }).toList();

      return summaries;
    } catch (e) {
      throw Exception('Failed to get matches summary: $e');
    }
  }

  @override
  Future<List<QuarterPerformance>> getQuarterPerformance(String teamId) async {
    try {
      final teamIdInt = int.parse(teamId);

      // Get all quarter results for the team
      final quartersResponse = await _client
          .from('match_quarter_results')
          .select('quarter, team_goals, opponent_goals, matches!inner(team_id)')
          .eq('matches.team_id', teamIdInt);

      // Group by quarter number
      final quarterStats = <int, Map<String, dynamic>>{
        1: {
          'quarter_number': 1,
          'goals_for': 0,
          'goals_against': 0,
          'wins': 0,
          'draws': 0,
          'losses': 0
        },
        2: {
          'quarter_number': 2,
          'goals_for': 0,
          'goals_against': 0,
          'wins': 0,
          'draws': 0,
          'losses': 0
        },
        3: {
          'quarter_number': 3,
          'goals_for': 0,
          'goals_against': 0,
          'wins': 0,
          'draws': 0,
          'losses': 0
        },
        4: {
          'quarter_number': 4,
          'goals_for': 0,
          'goals_against': 0,
          'wins': 0,
          'draws': 0,
          'losses': 0
        },
      };

      for (final qr in quartersResponse as List) {
        final quarterNum = (qr['quarter'] as num).toInt();
        final teamGoals = (qr['team_goals'] as num?)?.toInt() ?? 0;
        final oppGoals = (qr['opponent_goals'] as num?)?.toInt() ?? 0;

        if (quarterStats.containsKey(quarterNum)) {
          quarterStats[quarterNum]!['goals_for'] =
              (quarterStats[quarterNum]!['goals_for'] as int) + teamGoals;
          quarterStats[quarterNum]!['goals_against'] =
              (quarterStats[quarterNum]!['goals_against'] as int) + oppGoals;

          if (teamGoals > oppGoals) {
            quarterStats[quarterNum]!['wins'] =
                (quarterStats[quarterNum]!['wins'] as int) + 1;
          } else if (teamGoals < oppGoals) {
            quarterStats[quarterNum]!['losses'] =
                (quarterStats[quarterNum]!['losses'] as int) + 1;
          } else {
            quarterStats[quarterNum]!['draws'] =
                (quarterStats[quarterNum]!['draws'] as int) + 1;
          }
        }
      }

      return quarterStats.values
          .map((json) => QuarterPerformanceMapper.fromJson(json))
          .toList()
        ..sort((a, b) => a.quarterNumber.compareTo(b.quarterNumber));
    } catch (e) {
      throw Exception('Failed to get quarter performance: $e');
    }
  }

  @override
  Future<List<PlayerQuarterStats>> getPlayerQuarterStats(String teamId) async {
    try {
      final teamIdInt = int.parse(teamId);

      // 1. Get all matches for the team
      final matchesResponse = await _client
          .from('matches')
          .select(
              'id, match_quarter_results(quarter, team_goals, opponent_goals)')
          .eq('team_id', teamIdInt);

      final matchIds =
          (matchesResponse as List).map((m) => m['id'] as int).toList();

      if (matchIds.isEmpty) {
        return [];
      }

      // 2. Identify Result for each Quarter
      // Map<MatchId, Map<QuarterNumber, Result>>
      // Result: 1 (Win), -1 (Loss), 0 (Draw)
      final matchQuarterResults = <int, Map<int, int>>{};

      for (final match in matchesResponse) {
        final matchId = match['id'] as int;
        final quarters = match['match_quarter_results'] as List?;
        final quarterMap = <int, int>{};

        if (quarters != null) {
          for (final q in quarters) {
            final qNum = (q['quarter'] as num).toInt();
            final tGoals = (q['team_goals'] as num?)?.toInt() ?? 0;
            final oGoals = (q['opponent_goals'] as num?)?.toInt() ?? 0;

            if (tGoals > oGoals) {
              quarterMap[qNum] = 1; // Win
            } else if (tGoals < oGoals) {
              quarterMap[qNum] = -1; // Loss
            } else {
              quarterMap[qNum] = 0; // Draw
            }
          }
        }
        matchQuarterResults[matchId] = quarterMap;
      }

      // 3. Get Player Participation (Periods)
      final periodsResponse = await _client
          .from('match_player_periods')
          .select(
              'player_id, match_id, period, players!inner(id, full_name, jersey_number)')
          .inFilter('match_id', matchIds);

      // 4. Aggregate Stats per Player
      final playerStatsMap = <String, Map<String, dynamic>>{};

      for (final period in periodsResponse as List) {
        final playerId = period['player_id'].toString();
        final matchId = period['match_id'] as int;
        final periodNum = (period['period'] as num).toInt();
        final player = period['players'];

        // Get result for this specific quarter
        final quarterResult = matchQuarterResults[matchId]?[periodNum];

        // If we don't have a result for this quarter (e.g. data missing in match_quarter_results), skip or treat as draw?
        // Let's assume valid data exists. If null, we might count as played but unknown result, or ignore.
        // For now, let's treat null as 0 (Draw/Unknown) to avoid crashes, but strictly we need result.
        // Actually, if result is missing, it means the quarter wasn't recorded in match_quarter_results.
        // We should validly count it as "Played", but won/loss will depend on data availability.

        final resultStub = quarterResult ?? 0; // Default to draw if unknown

        if (!playerStatsMap.containsKey(playerId)) {
          playerStatsMap[playerId] = {
            'player': player, // Store player info to create entity later
            'played': 0,
            'won': 0,
            'lost': 0,
            'drawn': 0,
          };
        }

        final stats = playerStatsMap[playerId]!;
        stats['played'] = (stats['played'] as int) + 1;

        if (resultStub == 1) {
          stats['won'] = (stats['won'] as int) + 1;
        } else if (resultStub == -1) {
          stats['lost'] = (stats['lost'] as int) + 1;
        } else {
          stats['drawn'] = (stats['drawn'] as int) + 1;
        }
      }

      // 5. Convert to List<PlayerQuarterStats>
      final statsList = playerStatsMap.entries.map((entry) {
        final data = entry.value;
        final player = data['player'];
        return PlayerQuarterStats(
          playerId: entry.key,
          playerName: player['full_name'] ?? 'Unknown',
          jerseyNumber: player['jersey_number']?.toString() ?? '-',
          quartersPlayed: data['played'],
          quartersWon: data['won'],
          quartersLost: data['lost'],
          quartersDrawn: data['drawn'],
        );
      }).toList();

      // Sort by Quarters Played (descending) as default
      statsList.sort((a, b) => b.quartersPlayed.compareTo(a.quartersPlayed));

      return statsList;
    } catch (e) {
      throw Exception('Failed to get player quarter statistics: $e');
    }
  }

  @override
  Future<double> getTeamTrainingAttendance(String teamId) async {
    try {
      final teamIdInt = int.parse(teamId);

      // Get all training sessions for the team
      final trainingsResponse = await _client
          .from('training_sessions')
          .select('id')
          .eq('team_id', teamIdInt);

      final trainingIds =
          (trainingsResponse as List).map((t) => t['id'] as int).toList();

      if (trainingIds.isEmpty) {
        return 0.0;
      }

      // Get all training attendance records for these sessions
      final attendanceResponse = await _client
          .from('training_attendance')
          .select('status')
          .inFilter('training_id', trainingIds);

      final totalRecords = (attendanceResponse as List).length;

      if (totalRecords == 0) {
        return 0.0;
      }

      final attendedCount = attendanceResponse
          .where((a) => a['status'] == 'on_time' || a['status'] == 'late')
          .length;

      return (attendedCount / totalRecords) * 100;
    } catch (e) {
      throw Exception('Failed to get team training attendance: $e');
    }
  }
}
