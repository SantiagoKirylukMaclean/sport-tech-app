// lib/domain/org/repositories/positions_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/position.dart';

/// Repository interface for positions operations
/// This is the contract that infrastructure layer must implement
abstract class PositionsRepository {
  /// Get positions by sport
  /// Returns list of [Position] on success, [Failure] on error
  Future<Result<List<Position>>> getPositionsBySport(String sportId);

  /// Get a position by ID
  /// Returns [Position] on success, [Failure] on error
  Future<Result<Position>> getPositionById(String id);
}
