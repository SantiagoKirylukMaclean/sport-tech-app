// lib/domain/org/repositories/staff_members_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/staff_member.dart';

/// Repository interface for staff members operations
/// This is the contract that infrastructure layer must implement
abstract class StaffMembersRepository {
  /// Get staff members by team
  /// Returns list of [StaffMember] on success, [Failure] on error
  Future<Result<List<StaffMember>>> getStaffMembersByTeam(String teamId);

  /// Get a staff member by ID
  /// Returns [StaffMember] on success, [Failure] on error
  Future<Result<StaffMember>> getStaffMemberById(String id);

  /// Get staff members by user ID
  /// Returns list of [StaffMember] on success, [Failure] on error
  Future<Result<List<StaffMember>>> getStaffMembersByUser(String userId);

  /// Create a new staff member
  /// Returns created [StaffMember] on success, [Failure] on error
  Future<Result<StaffMember>> createStaffMember({
    required String teamId,
    required String userId,
    required String fullName,
    required StaffPosition position,
    String? email,
  });

  /// Update an existing staff member
  /// Returns updated [StaffMember] on success, [Failure] on error
  Future<Result<StaffMember>> updateStaffMember({
    required String id,
    String? fullName,
    StaffPosition? position,
    String? email,
  });

  /// Delete a staff member
  /// Returns void on success, [Failure] on error
  Future<Result<void>> deleteStaffMember(String id);
}
