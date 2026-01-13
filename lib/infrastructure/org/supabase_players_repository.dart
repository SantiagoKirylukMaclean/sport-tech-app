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
      final parsedTeamId = int.tryParse(teamId) ?? teamId;

      final response = await _client
          .from('players')
          .select()
          .eq('team_id', parsedTeamId)
          .order('full_name', ascending: true);

      final players = (response as List)
          .map((json) => PlayerMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(players);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting players: $e'));
    }
  }

  @override
  Future<Result<Player>> getPlayerById(String id) async {
    try {
      final response =
          await _client.from('players').select().eq('id', id).single();

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
  Future<Result<List<Player>>> getPlayersByUserId(String userId) async {
    try {
      final response =
          await _client.from('players').select().eq('user_id', userId);

      final players = (response as List)
          .map((json) => PlayerMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(players);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting players by user ID: $e'));
    }
  }

  @override
  Future<Result<Player?>> getPlayerByUserIdAndTeamId(
      String userId, String teamId) async {
    try {
      final parsedTeamId = int.tryParse(teamId) ?? teamId;

      final response = await _client
          .from('players')
          .select()
          .eq('user_id', userId)
          .eq('team_id', parsedTeamId)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      return Success(PlayerMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(
          ServerFailure('Error getting player by user ID and team ID: $e'));
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
      final response = await _client
          .from('players')
          .insert({
            'team_id': int.tryParse(teamId) ?? teamId,
            'user_id': userId,
            'full_name': fullName.trim(),
            'jersey_number': jerseyNumber,
          })
          .select()
          .single();

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
      // Call edge function to delete player and associated auth user
      final response = await _client.functions.invoke(
        'delete-player',
        body: {
          'playerId': int.tryParse(id) ?? id,
        },
      );

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] ?? 'Error desconocido';
        return Failed(ServerFailure('Error eliminando jugador: $errorMessage'));
      }

      return const Success(null);
    } on FunctionException catch (e) {
      return Failed(
        ServerFailure('Error llamando a la función: ${e.details}'),
      );
    } catch (e) {
      return Failed(ServerFailure('Error deleting player: $e'));
    }
  }

  @override
  Future<Result<Player>> assignCredentials({
    required String playerId,
    required String email,
    required String password,
  }) async {
    try {
      // Call edge function to create auth user and link to player
      final response = await _client.functions.invoke(
        'assign-player-credentials',
        body: {
          'playerId': int.tryParse(playerId) ?? playerId,
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] ?? 'Error desconocido';
        return Failed(ServerFailure('Error al crear cuenta: $errorMessage'));
      }

      // Fetch the updated player
      final playerResult = await getPlayerById(playerId);
      return playerResult;
    } on FunctionException catch (e) {
      return Failed(
        ServerFailure('Error llamando a la función: ${e.details}'),
      );
    } catch (e) {
      return Failed(ServerFailure('Error asignando credenciales: $e'));
    }
  }

  @override
  Future<Result<Player>> importPlayer({
    required String teamId,
    required String fullName,
    int? jerseyNumber,
    String? userId,
    String? email,
  }) async {
    try {
      // Call edge function to import player securely
      final response = await _client.functions.invoke(
        'import-player',
        body: {
          'teamId': int.tryParse(teamId) ?? teamId,
          'fullName': fullName.trim(),
          'jerseyNumber': jerseyNumber,
          'userId': userId,
          'email': email,
        },
      );

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] ?? 'Error desconocido';
        return Failed(ServerFailure('Error importando jugador: $errorMessage'));
      }

      final data = response.data as Map<String, dynamic>;
      final playerData = data['player'] as Map<String, dynamic>;

      return Success(PlayerMapper.fromJson(playerData));
    } on FunctionException catch (e) {
      return Failed(
        ServerFailure(
            'Error llamando a la función de importación: ${e.details}'),
      );
    } catch (e) {
      return Failed(ServerFailure('Error inesperado al importar: $e'));
    }
  }
}
