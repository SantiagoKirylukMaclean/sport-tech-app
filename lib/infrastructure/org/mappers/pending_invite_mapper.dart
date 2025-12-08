// lib/infrastructure/org/mappers/pending_invite_mapper.dart

import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';

/// Mapper for converting between Supabase JSON and PendingInvite entity
class PendingInviteMapper {
  /// Convert from Supabase JSON to PendingInvite entity
  static PendingInvite fromJson(Map<String, dynamic> json) {
    // Parse team_ids array from PostgreSQL array format
    final teamIds = (json['team_ids'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];

    return PendingInvite(
      id: json['id'] as int,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      role: json['role'] as String,
      teamIds: teamIds,
      playerId: json['player_id'] as int?,
      status: json['status'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
    );
  }

  /// Convert from PendingInvite entity to Supabase JSON
  static Map<String, dynamic> toJson(PendingInvite invite) {
    return {
      'id': invite.id,
      'email': invite.email,
      'display_name': invite.displayName,
      'role': invite.role,
      'team_ids': invite.teamIds,
      'player_id': invite.playerId,
      'status': invite.status,
      'created_by': invite.createdBy,
      'created_at': invite.createdAt.toIso8601String(),
      'accepted_at': invite.acceptedAt?.toIso8601String(),
    };
  }
}
