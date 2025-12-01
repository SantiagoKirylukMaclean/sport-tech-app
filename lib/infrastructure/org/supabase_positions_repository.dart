// lib/infrastructure/org/supabase_positions_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/position.dart';
import 'package:sport_tech_app/domain/org/repositories/positions_repository.dart';
import 'package:sport_tech_app/infrastructure/org/mappers/position_mapper.dart';

/// Supabase implementation of [PositionsRepository]
class SupabasePositionsRepository implements PositionsRepository {
  final SupabaseClient _client;

  SupabasePositionsRepository(this._client);

  @override
  Future<Result<List<Position>>> getPositionsBySport(String sportId) async {
    try {
      final response = await _client
          .from('positions')
          .select()
          .eq('sport_id', sportId)
          .order('name', ascending: true);

      final positions = (response as List)
          .map((json) => PositionMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(positions);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting positions: $e'));
    }
  }

  @override
  Future<Result<Position>> getPositionById(String id) async {
    try {
      final response = await _client
          .from('positions')
          .select()
          .eq('id', id)
          .single();

      return Success(PositionMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Position not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting position: $e'));
    }
  }
}
