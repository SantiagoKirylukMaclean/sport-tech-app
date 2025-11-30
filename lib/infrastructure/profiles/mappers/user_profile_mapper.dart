// lib/infrastructure/profiles/mappers/user_profile_mapper.dart

import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/domain/profiles/entities/user_profile.dart';

/// Maps between JSON and domain UserProfile
class UserProfileMapper {
  /// Convert JSON from Supabase to domain UserProfile
  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['id'] as String,
      role: UserRole.fromString(json['role'] as String),
      displayName: (json['display_name'] as String?) ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert domain UserProfile to JSON for Supabase
  static Map<String, dynamic> toJson(UserProfile profile) {
    return {
      'id': profile.userId,
      'role': profile.role.value,
      'display_name': profile.displayName,
      'created_at': profile.createdAt.toIso8601String(),
      'updated_at': profile.updatedAt.toIso8601String(),
    };
  }
}
