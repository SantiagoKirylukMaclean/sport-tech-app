// lib/infrastructure/org/mappers/staff_member_mapper.dart

import 'package:sport_tech_app/domain/org/entities/staff_member.dart';

/// Mapper for converting between Supabase JSON and StaffMember entity
class StaffMemberMapper {
  /// Convert from Supabase JSON to StaffMember entity
  static StaffMember fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'].toString(),
      teamId: json['team_id'].toString(),
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      position: StaffPosition.fromString(json['position'] as String),
      email: json['email'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from StaffMember entity to Supabase JSON
  static Map<String, dynamic> toJson(StaffMember staffMember) {
    return {
      'id': staffMember.id,
      'team_id': staffMember.teamId,
      'user_id': staffMember.userId,
      'full_name': staffMember.fullName,
      'position': staffMember.position.value,
      'email': staffMember.email,
      'created_at': staffMember.createdAt.toIso8601String(),
    };
  }

  /// Convert to JSON for insert/update operations (without id and created_at)
  static Map<String, dynamic> toInsertJson({
    required String teamId,
    required String userId,
    required String fullName,
    required StaffPosition position,
    String? email,
  }) {
    return {
      'team_id': int.tryParse(teamId) ?? teamId,
      'user_id': userId,
      'full_name': fullName.trim(),
      'position': position.value,
      'email': email?.trim(),
    };
  }
}
