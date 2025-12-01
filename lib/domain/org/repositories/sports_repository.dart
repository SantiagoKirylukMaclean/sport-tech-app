// lib/domain/org/repositories/sports_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';

/// Repository interface for sports operations
/// This is the contract that infrastructure layer must implement
abstract class SportsRepository {
  /// Get all sports
  /// Returns list of [Sport] on success, [Failure] on error
  Future<Result<List<Sport>>> getAllSports();

  /// Get a sport by ID
  /// Returns [Sport] on success, [Failure] on error
  Future<Result<Sport>> getSportById(String id);

  /// Create a new sport
  /// Returns created [Sport] on success, [Failure] on error
  Future<Result<Sport>> createSport({
    required String name,
  });

  /// Update an existing sport
  /// Returns updated [Sport] on success, [Failure] on error
  Future<Result<Sport>> updateSport({
    required String id,
    required String name,
  });

  /// Delete a sport
  /// Returns void on success, [Failure] on error
  Future<Result<void>> deleteSport(String id);
}
