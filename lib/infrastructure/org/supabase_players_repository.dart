// lib/infrastructure/org/supabase_players_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/domain/org/repositories/players_repository.dart';
import 'package:sport_tech_app/infrastructure/org/mappers/player_mapper.dart';

/// Supabase implementation of [PlayersRepository]
class SupabasePlayersRepository implements PlayersRepository {
  final SupabaseClient _client;

  SupabasePlayersRepository(this._client);

  @override
  Future<Result<List<Player>>> getPlayersByTeam(String teamId) async {
    try {
      print('DEBUG SupabasePlayersRepository: getPlayersByTeam called with teamId: $teamId (type: ${teamId.runtimeType})');
      final parsedTeamId = int.tryParse(teamId) ?? teamId;
      print('DEBUG SupabasePlayersRepository: parsedTeamId: $parsedTeamId (type: ${parsedTeamId.runtimeType})');
      
      final response = await _client
          .from('players')
          .select()
          .eq('team_id', parsedTeamId)
          .order('full_name', ascending: true);

      print('DEBUG SupabasePlayersRepository: response type: ${response.runtimeType}');
      print('DEBUG SupabasePlayersRepository: response: $response');

      final players = (response as List)
          .map((json) => PlayerMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(players);
    } on PostgrestException catch (e) {
      print('DEBUG SupabasePlayersRepository: PostgrestException: ${e.message}');
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      print('DEBUG SupabasePlayersRepository: Exception: $e');
      return Failed(ServerFailure('Error getting players: $e'));
    }
  }

  @override
  Future<Result<Player>> getPlayerById(String id) async {
    try {
      final response = await _client
          .from('players')
          .select()
          .eq('id', id)
          .single();

      return Success(PlayerMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Player not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting player: $e'));
    }
  }

  @override
  Future<Result<Player>> createPlayer({
    required String teamId,
    required String fullName,
    String? userId,
    int? jerseyNumber,
  }) async {
    try {
      // Don't specify 'id' - let PostgreSQL's bigserial auto-generate it
      // Don't specify 'created_at' - let PostgreSQL default handle it
      final response = await _client.from('players').insert({
        'team_id': int.tryParse(teamId) ?? teamId,
        'user_id': userId,
        'full_name': fullName.trim(),
        'jersey_number': jerseyNumber,
      }).select().single();

      return Success(PlayerMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating player: $e'));
    }
  }

  @override
  Future<Result<Player>> updatePlayer({
    required String id,
    String? fullName,
    int? jerseyNumber,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null) {
        updates['full_name'] = fullName.trim();
      }
      if (jerseyNumber != null) {
        updates['jersey_number'] = jerseyNumber;
      }

      final response = await _client
          .from('players')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Success(PlayerMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Player not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating player: $e'));
    }
  }

  @override
  Future<Result<void>> deletePlayer(String id) async {
    try {
      await _client.from('players').delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting player: $e'));
    }
  }
}
