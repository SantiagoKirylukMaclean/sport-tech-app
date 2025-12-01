// lib/infrastructure/org/supabase_sports_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/domain/org/repositories/sports_repository.dart';
import 'package:sport_tech_app/infrastructure/org/mappers/sport_mapper.dart';
import 'package:uuid/uuid.dart';

/// Supabase implementation of [SportsRepository]
class SupabaseSportsRepository implements SportsRepository {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  SupabaseSportsRepository(this._client);

  @override
  Future<Result<List<Sport>>> getAllSports() async {
    try {
      final response = await _client
          .from('sports')
          .select()
          .order('name', ascending: true);

      final sports = (response as List)
          .map((json) => SportMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(sports);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting sports: $e'));
    }
  }

  @override
  Future<Result<Sport>> getSportById(String id) async {
    try {
      final response = await _client
          .from('sports')
          .select()
          .eq('id', id)
          .single();

      return Success(SportMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Sport not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting sport: $e'));
    }
  }

  @override
  Future<Result<Sport>> createSport({required String name}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client.from('sports').insert({
        'id': _uuid.v4(),
        'name': name.trim(),
        'created_at': now,
      }).select().single();

      return Success(SportMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating sport: $e'));
    }
  }

  @override
  Future<Result<Sport>> updateSport({
    required String id,
    required String name,
  }) async {
    try {
      final response = await _client
          .from('sports')
          .update({'name': name.trim()})
          .eq('id', id)
          .select()
          .single();

      return Success(SportMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Sport not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating sport: $e'));
    }
  }

  @override
  Future<Result<void>> deleteSport(String id) async {
    try {
      await _client.from('sports').delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting sport: $e'));
    }
  }
}
