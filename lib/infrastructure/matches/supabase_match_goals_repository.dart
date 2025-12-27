// lib/infrastructure/matches/supabase_match_goals_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match_goal.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_goals_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/mappers/match_goal_mapper.dart';

/// Supabase implementation of [MatchGoalsRepository]
class SupabaseMatchGoalsRepository implements MatchGoalsRepository {
  final SupabaseClient _client;

  SupabaseMatchGoalsRepository(this._client);

  @override
  Future<Result<List<MatchGoal>>> getGoalsByMatch(String matchId) async {
    try {
      final response = await _client
          .from('match_goals')
          .select('''
            *,
            scorer:scorer_id(full_name),
            assister:assister_id(full_name)
          ''')
          .eq('match_id', matchId)
          .order('quarter', ascending: true)
          .order('created_at', ascending: true);

      final goals = (response as List).map((json) {
        // Flatten the nested structure for the mapper
        final flatJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
        if (json['scorer'] != null) {
          flatJson['scorer_name'] = json['scorer']['full_name'];
        }
        if (json['assister'] != null) {
          flatJson['assister_name'] = json['assister']['full_name'];
        }
        return MatchGoalMapper.fromJson(flatJson);
      }).toList();

      return Success(goals);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting goals: $e'));
    }
  }

  @override
  Future<Result<List<MatchGoal>>> getGoalsByMatchAndQuarter({
    required String matchId,
    required int quarter,
  }) async {
    try {
      final response = await _client
          .from('match_goals')
          .select('''
            *,
            scorer:scorer_id(full_name),
            assister:assister_id(full_name)
          ''')
          .eq('match_id', matchId)
          .eq('quarter', quarter)
          .order('created_at', ascending: true);

      final goals = (response as List).map((json) {
        // Flatten the nested structure for the mapper
        final flatJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
        if (json['scorer'] != null) {
          flatJson['scorer_name'] = json['scorer']['full_name'];
        }
        if (json['assister'] != null) {
          flatJson['assister_name'] = json['assister']['full_name'];
        }
        return MatchGoalMapper.fromJson(flatJson);
      }).toList();

      return Success(goals);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting quarter goals: $e'));
    }
  }

  @override
  Future<Result<MatchGoal>> createGoal({
    required String matchId,
    required int quarter,
    required String scorerId,
    String? assisterId,
    bool isOwnGoal = false,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client.from('match_goals').insert({
        'match_id': int.parse(matchId),
        'quarter': quarter,
        'scorer_id': int.parse(scorerId),
        'assister_id': assisterId != null ? int.parse(assisterId) : null,
        'is_own_goal': isOwnGoal,
        'created_at': now,
      }).select('''
        *,
        scorer:scorer_id(full_name),
        assister:assister_id(full_name)
      ''').single();

      // Flatten the nested structure for the mapper
      final flatJson = Map<String, dynamic>.from(response);
      if (response['scorer'] != null) {
        flatJson['scorer_name'] = response['scorer']['full_name'];
      }
      if (response['assister'] != null) {
        flatJson['assister_name'] = response['assister']['full_name'];
      }

      return Success(MatchGoalMapper.fromJson(flatJson));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating goal: $e'));
    }
  }

  @override
  Future<Result<MatchGoal>> updateGoal({
    required String id,
    String? scorerId,
    String? assisterId,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (scorerId != null) {
        updates['scorer_id'] = int.parse(scorerId);
      }
      if (assisterId != null) {
        updates['assister_id'] = int.parse(assisterId);
      }

      final response = await _client
          .from('match_goals')
          .update(updates)
          .eq('id', id)
          .select('''
            *,
            scorer:scorer_id(full_name),
            assister:assister_id(full_name)
          ''')
          .single();

      // Flatten the nested structure for the mapper
      final flatJson = Map<String, dynamic>.from(response);
      if (response['scorer'] != null) {
        flatJson['scorer_name'] = response['scorer']['full_name'];
      }
      if (response['assister'] != null) {
        flatJson['assister_name'] = response['assister']['full_name'];
      }

      return Success(MatchGoalMapper.fromJson(flatJson));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Goal not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating goal: $e'));
    }
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    try {
      await _client.from('match_goals').delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting goal: $e'));
    }
  }
}
