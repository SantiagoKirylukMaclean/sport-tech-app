// lib/domain/org/repositories/players_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';

/// Repository interface for players operations
/// This is the contract that infrastructure layer must implement
abstract class PlayersRepository {
  /// Get players by team
  /// Returns list of [Player] on success, [Failure] on error
  Future<Result<List<Player>>> getPlayersByTeam(String teamId);

  /// Get a player by ID
  /// Returns [Player] on success, [Failure] on error
  Future<Result<Player>> getPlayerById(String id);

  /// Create a new player
  /// Returns created [Player] on success, [Failure] on error
  Future<Result<Player>> createPlayer({
    required String teamId,
    required String fullName,
    String? userId,
    int? jerseyNumber,
  });

  /// Update an existing player
  /// Returns updated [Player] on success, [Failure] on error
  Future<Result<Player>> updatePlayer({
    required String id,
    String? fullName,
    int? jerseyNumber,
  });

  /// Delete a player
  /// Returns void on success, [Failure] on error
  Future<Result<void>> deletePlayer(String id);

  /// Assign credentials (email and password) to a player
  /// Creates a Supabase auth user and links it to the player
  /// Returns updated [Player] on success, [Failure] on error
  Future<Result<Player>> assignCredentials({
    required String playerId,
    required String email,
    required String password,
  });
}
