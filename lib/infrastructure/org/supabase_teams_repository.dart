// lib/infrastructure/org/supabase_teams_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';
import 'package:sport_tech_app/domain/org/repositories/teams_repository.dart';
import 'package:sport_tech_app/infrastructure/org/mappers/team_mapper.dart';

/// Supabase implementation of [TeamsRepository]
class SupabaseTeamsRepository implements TeamsRepository {
  final SupabaseClient _client;

  SupabaseTeamsRepository(this._client);

  @override
  Future<Result<List<Team>>> getAllTeams() async {
    try {
      final response = await _client
          .from('teams')
          .select()
          .order('name', ascending: true);

      final teams = (response as List)
          .map((json) => TeamMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(teams);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting teams: $e'));
    }
  }

  @override
  Future<Result<List<Team>>> getTeamsByClub(String clubId) async {
    try {
      final response = await _client
          .from('teams')
          .select()
          .eq('club_id', int.tryParse(clubId) ?? clubId)
          .order('name', ascending: true);

      final teams = (response as List)
          .map((json) => TeamMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(teams);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting teams by club: $e'));
    }
  }

  @override
  Future<Result<List<Team>>> getTeamsByUser(String userId) async {
    try {
      // Join with user_team_roles to get teams for a specific user
      final response = await _client
          .from('user_team_roles')
          .select('team_id, teams(*)')
          .eq('user_id', userId);

      final teams = (response as List)
          .map((json) {
            final teamData = json['teams'] as Map<String, dynamic>;
            return TeamMapper.fromJson(teamData);
          })
          .toList();

      return Success(teams);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting teams by user: $e'));
    }
  }

  @override
  Future<Result<Team>> getTeamById(String id) async {
    try {
      final response = await _client
          .from('teams')
          .select()
          .eq('id', int.tryParse(id) ?? id)
          .single();

      return Success(TeamMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Team not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting team: $e'));
    }
  }

  @override
  Future<Result<Team>> createTeam({
    required String clubId,
    required String name,
    String? standingsUrl,
    String? resultsUrl,
    String? calendarUrl,
  }) async {
    try {
      final response = await _client.from('teams').insert({
        'club_id': clubId,
        'name': name.trim(),
        if (standingsUrl != null) 'standings_url': standingsUrl,
        if (resultsUrl != null) 'results_url': resultsUrl,
        if (calendarUrl != null) 'calendar_url': calendarUrl,
      }).select().single();

      return Success(TeamMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating team: $e'));
    }
  }

  @override
  Future<Result<Team>> updateTeam({
    required String id,
    required String name,
    String? standingsUrl,
    String? resultsUrl,
    String? calendarUrl,
  }) async {
    try {
      final response = await _client
          .from('teams')
          .update({
            'name': name.trim(),
            'standings_url': standingsUrl,
            'results_url': resultsUrl,
            'calendar_url': calendarUrl,
          })
          .eq('id', int.tryParse(id) ?? id)
          .select()
          .single();

      return Success(TeamMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Team not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating team: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTeam(String id) async {
    try {
      await _client.from('teams').delete().eq('id', int.tryParse(id) ?? id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting team: $e'));
    }
  }
}
