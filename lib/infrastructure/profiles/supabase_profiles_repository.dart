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
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

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

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

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
      final response = await _client.from('profiles').insert({
        'id': userId,
        'display_name': displayName.trim(),
        'role': role,
        'created_at': now,
        'updated_at': now,
      }).select().single();

      return Success(UserProfileMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating profile: $e'));
    }
  }
}
