// lib/infrastructure/org/supabase_staff_attendance_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/staff_attendance.dart';
import 'package:sport_tech_app/domain/org/repositories/staff_attendance_repository.dart';
import 'package:sport_tech_app/domain/trainings/entities/training_attendance.dart';
import 'package:sport_tech_app/infrastructure/org/mappers/staff_attendance_mapper.dart';

/// Supabase implementation of [StaffAttendanceRepository]
class SupabaseStaffAttendanceRepository implements StaffAttendanceRepository {
  final SupabaseClient _client;

  SupabaseStaffAttendanceRepository(this._client);

  @override
  Future<Result<List<StaffAttendance>>> getBySessionId(String sessionId) async {
    try {
      final response = await _client
          .from('staff_attendance')
          .select()
          .eq('training_id', int.tryParse(sessionId) ?? sessionId);

      final attendances = (response as List)
          .map((json) => StaffAttendanceMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(attendances);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting staff attendance: $e'));
    }
  }

  @override
  Future<Result<StaffAttendance?>> getBySessionAndStaff({
    required String sessionId,
    required String staffId,
  }) async {
    try {
      final response = await _client
          .from('staff_attendance')
          .select()
          .eq('training_id', int.tryParse(sessionId) ?? sessionId)
          .eq('staff_id', int.tryParse(staffId) ?? staffId)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      return Success(StaffAttendanceMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting staff attendance: $e'));
    }
  }

  @override
  Future<Result<StaffAttendance>> upsert({
    required String sessionId,
    required String staffId,
    required AttendanceStatus status,
  }) async {
    try {
      final json = StaffAttendanceMapper.toUpsertJson(
        trainingId: sessionId,
        staffId: staffId,
        status: status,
      );

      final response = await _client
          .from('staff_attendance')
          .upsert(
            json,
            onConflict: 'training_id,staff_id',
          )
          .select()
          .single();

      return Success(StaffAttendanceMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error upserting staff attendance: $e'));
    }
  }

  @override
  Future<Result<List<StaffAttendance>>> getByStaffId(String staffId) async {
    try {
      final response = await _client
          .from('staff_attendance')
          .select()
          .eq('staff_id', int.tryParse(staffId) ?? staffId);

      final attendances = (response as List)
          .map((json) => StaffAttendanceMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(attendances);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting staff attendance: $e'));
    }
  }
}
