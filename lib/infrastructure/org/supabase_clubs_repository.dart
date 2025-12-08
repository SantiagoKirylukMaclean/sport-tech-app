// lib/infrastructure/org/supabase_clubs_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';
import 'package:sport_tech_app/domain/org/repositories/clubs_repository.dart';
import 'package:sport_tech_app/infrastructure/org/mappers/club_mapper.dart';

/// Supabase implementation of [ClubsRepository]
class SupabaseClubsRepository implements ClubsRepository {
  final SupabaseClient _client;

  SupabaseClubsRepository(this._client);

  @override
  Future<Result<List<Club>>> getAllClubs() async {
    try {
      final response = await _client
          .from('clubs')
          .select()
          .order('name', ascending: true);

      final clubs = (response as List)
          .map((json) => ClubMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(clubs);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting clubs: $e'));
    }
  }

  @override
  Future<Result<List<Club>>> getClubsBySport(String sportId) async {
    try {
      final response = await _client
          .from('clubs')
          .select()
          .eq('sport_id', sportId)
          .order('name', ascending: true);

      final clubs = (response as List)
          .map((json) => ClubMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(clubs);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting clubs by sport: $e'));
    }
  }

  @override
  Future<Result<Club>> getClubById(String id) async {
    try {
      final response = await _client
          .from('clubs')
          .select()
          .eq('id', id)
          .single();

      return Success(ClubMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Club not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting club: $e'));
    }
  }

  @override
  Future<Result<Club>> createClub({
    required String sportId,
    required String name,
  }) async {
    try {
      final response = await _client.from('clubs').insert({
        'sport_id': sportId,
        'name': name.trim(),
      }).select().single();

      return Success(ClubMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating club: $e'));
    }
  }

  @override
  Future<Result<Club>> updateClub({
    required String id,
    required String name,
  }) async {
    try {
      final response = await _client
          .from('clubs')
          .update({'name': name.trim()})
          .eq('id', id)
          .select()
          .single();

      return Success(ClubMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Club not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating club: $e'));
    }
  }

  @override
  Future<Result<void>> deleteClub(String id) async {
    try {
      await _client.from('clubs').delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting club: $e'));
    }
  }
}
