// lib/domain/matches/repositories/matches_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match.dart';

/// Repository interface for matches operations
/// This is the contract that infrastructure layer must implement
abstract class MatchesRepository {
  /// Get matches by team
  /// Returns list of [Match] on success, [Failure] on error
  Future<Result<List<Match>>> getMatchesByTeam(String teamId);

  /// Get a match by ID
  /// Returns [Match] on success, [Failure] on error
  Future<Result<Match>> getMatchById(String id);

  /// Create a new match
  /// Returns created [Match] on success, [Failure] on error
  Future<Result<Match>> createMatch({
    required String teamId,
    required String opponent,
    required DateTime matchDate,
    String? location,
    String? notes,
  });

  /// Update an existing match
  /// Returns updated [Match] on success, [Failure] on error
  Future<Result<Match>> updateMatch({
    required String id,
    String? opponent,
    DateTime? matchDate,
    String? location,
    String? notes,
  });

  /// Delete a match
  /// Returns void on success, [Failure] on error
  Future<Result<void>> deleteMatch(String id);
}
