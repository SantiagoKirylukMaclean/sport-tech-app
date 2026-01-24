// lib/infrastructure/profiles/supabase_profiles_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/profiles/entities/user_profile.dart';
import 'package:sport_tech_app/domain/profiles/repositories/profiles_repository.dart';
import 'package:sport_tech_app/infrastructure/profiles/mappers/user_profile_mapper.dart';

/// Supabase implementation of [ProfilesRepository]
class SupabaseProfilesRepository implements ProfilesRepository {
  final SupabaseClient _client;

  SupabaseProfilesRepository(this._client);

  @override
  Future<Result<UserProfile>> getCurrentUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failed(
          AuthFailure('No authenticated user'),
        );
      }

      return getProfileById(userId);
    } catch (e) {
      return Failed(
        ServerFailure('Error getting current user profile: $e'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> getProfileById(String userId) async {
    try {
      final response =
          await _client.from('profiles').select().eq('id', userId).single();

      return Success(UserProfileMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Not found
        return Failed(
          NotFoundFailure('Profile not found for user $userId', code: e.code),
        );
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting profile: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile({String? displayName}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failed(AuthFailure('No authenticated user'));
      }

      final updates = <String, dynamic>{};

      if (displayName != null) {
        updates['display_name'] = displayName.trim();
      }

      final response = await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return Success(UserProfileMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating profile: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> createProfile({
    required String userId,
    required String displayName,
    required String role,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('profiles')
          .insert({
            'id': userId,
            'display_name': displayName.trim(),
            'role': role,
            'created_at': now,
          })
          .select()
          .single();

      return Success(UserProfileMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating profile: $e'));
    }
  }

  @override
  Future<Result<List<UserProfile>>> getAllProfiles() async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      final profiles = (response as List)
          .map((json) =>
              UserProfileMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(profiles);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting all profiles: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      final response = await _client
          .from('profiles')
          .update({
            'role': role,
          })
          .eq('id', userId)
          .select()
          .single();

      return Success(UserProfileMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Profile not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating user role: $e'));
    }
  }

  @override
  Future<Result<void>> resetUserPassword({
    required String userId,
  }) async {
    try {
      // Get the user's email from their profile
      final profileResult = await getProfileById(userId);

      // In a real implementation, we'd need to get the email from auth.users
      // For now, we'll use Supabase Admin API to reset password
      // This requires admin privileges

      // Note: This is a placeholder - actual implementation depends on your backend setup
      // You might need to call a Supabase Edge Function or use the Admin API

      return const Success(null);
    } catch (e) {
      return Failed(ServerFailure('Error resetting password: $e'));
    }
  }
}
