// lib/infrastructure/org/supabase_staff_members_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/staff_member.dart';
import 'package:sport_tech_app/domain/org/repositories/staff_members_repository.dart';
import 'package:sport_tech_app/infrastructure/org/mappers/staff_member_mapper.dart';

/// Supabase implementation of [StaffMembersRepository]
class SupabaseStaffMembersRepository implements StaffMembersRepository {
  final SupabaseClient _client;

  SupabaseStaffMembersRepository(this._client);

  @override
  Future<Result<List<StaffMember>>> getStaffMembersByTeam(String teamId) async {
    try {
      final parsedTeamId = int.tryParse(teamId) ?? teamId;

      final response = await _client
          .from('staff_members')
          .select()
          .eq('team_id', parsedTeamId)
          .order('full_name', ascending: true);

      final staffMembers = (response as List)
          .map((json) => StaffMemberMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(staffMembers);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting staff members: $e'));
    }
  }

  @override
  Future<Result<StaffMember>> getStaffMemberById(String id) async {
    try {
      final response = await _client
          .from('staff_members')
          .select()
          .eq('id', int.tryParse(id) ?? id)
          .single();

      return Success(StaffMemberMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Staff member not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting staff member: $e'));
    }
  }

  @override
  Future<Result<List<StaffMember>>> getStaffMembersByUser(String userId) async {
    try {
      final response = await _client
          .from('staff_members')
          .select()
          .eq('user_id', userId)
          .order('full_name', ascending: true);

      final staffMembers = (response as List)
          .map((json) => StaffMemberMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(staffMembers);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting staff members by user: $e'));
    }
  }

  @override
  Future<Result<StaffMember>> createStaffMember({
    required String teamId,
    required String userId,
    required String fullName,
    required StaffPosition position,
    String? email,
  }) async {
    try {
      final json = StaffMemberMapper.toInsertJson(
        teamId: teamId,
        userId: userId,
        fullName: fullName,
        position: position,
        email: email,
      );

      final response = await _client
          .from('staff_members')
          .insert(json)
          .select()
          .single();

      return Success(StaffMemberMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating staff member: $e'));
    }
  }

  @override
  Future<Result<StaffMember>> updateStaffMember({
    required String id,
    String? fullName,
    StaffPosition? position,
    String? email,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null) {
        updates['full_name'] = fullName.trim();
      }
      if (position != null) {
        updates['position'] = position.value;
      }
      if (email != null) {
        updates['email'] = email.trim();
      }

      final response = await _client
          .from('staff_members')
          .update(updates)
          .eq('id', int.tryParse(id) ?? id)
          .select()
          .single();

      return Success(StaffMemberMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Staff member not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating staff member: $e'));
    }
  }

  @override
  Future<Result<void>> deleteStaffMember(String id) async {
    try {
      await _client
          .from('staff_members')
          .delete()
          .eq('id', int.tryParse(id) ?? id);

      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting staff member: $e'));
    }
  }
}
