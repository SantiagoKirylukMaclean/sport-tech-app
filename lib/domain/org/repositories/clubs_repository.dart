// lib/domain/org/repositories/clubs_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';

/// Repository interface for clubs operations
/// This is the contract that infrastructure layer must implement
abstract class ClubsRepository {
  /// Get all clubs
  /// Returns list of [Club] on success, [Failure] on error
  Future<Result<List<Club>>> getAllClubs();

  /// Get clubs by sport
  /// Returns list of [Club] on success, [Failure] on error
  Future<Result<List<Club>>> getClubsBySport(String sportId);

  /// Get a club by ID
  /// Returns [Club] on success, [Failure] on error
  Future<Result<Club>> getClubById(String id);

  /// Create a new club
  /// Returns created [Club] on success, [Failure] on error
  Future<Result<Club>> createClub({
    required String sportId,
    required String name,
  });

  /// Update an existing club
  /// Returns updated [Club] on success, [Failure] on error
  Future<Result<Club>> updateClub({
    required String id,
    required String name,
  });

  /// Delete a club
  /// Returns void on success, [Failure] on error
  Future<Result<void>> deleteClub(String id);
}
