// lib/domain/profiles/repositories/profiles_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/profiles/entities/user_profile.dart';

/// Repository interface for user profile operations
/// This is the contract that infrastructure layer must implement
abstract class ProfilesRepository {
  /// Get the profile for the current authenticated user
  /// Returns [UserProfile] on success, [Failure] on error
  Future<Result<UserProfile>> getCurrentUserProfile();

  /// Get a profile by user ID
  /// Returns [UserProfile] on success, [Failure] on error
  Future<Result<UserProfile>> getProfileById(String userId);

  /// Update the current user's profile
  /// Returns updated [UserProfile] on success, [Failure] on error
  Future<Result<UserProfile>> updateProfile({
    String? displayName,
  });

  /// Create a new profile for a user
  /// This is typically called after sign up
  /// Returns created [UserProfile] on success, [Failure] on error
  Future<Result<UserProfile>> createProfile({
    required String userId,
    required String displayName,
    required String role,
  });

  /// Get all user profiles (admin only)
  /// Returns list of [UserProfile] on success, [Failure] on error
  Future<Result<List<UserProfile>>> getAllProfiles();

  /// Update a user's role (super admin only)
  /// Returns updated [UserProfile] on success, [Failure] on error
  Future<Result<UserProfile>> updateUserRole({
    required String userId,
    required String role,
  });

  /// Reset a user's password (admin only)
  /// Returns void on success, [Failure] on error
  Future<Result<void>> resetUserPassword({
    required String userId,
  });
}
