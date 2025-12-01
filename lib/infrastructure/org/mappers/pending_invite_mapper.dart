// lib/infrastructure/org/mappers/pending_invite_mapper.dart

import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';

/// Mapper for converting between Supabase JSON and PendingInvite entity
class PendingInviteMapper {
  /// Convert from Supabase JSON to PendingInvite entity
  static PendingInvite fromJson(Map<String, dynamic> json) {
    return PendingInvite(
      id: json['id'] as String,
      email: json['email'] as String,
      teamId: json['team_id'] as String,
      role: json['role'] as String,
      playerName: json['player_name'] as String?,
      jerseyNumber: json['jersey_number'] as int?,
      invitedBy: json['invited_by'] as String,
      inviteToken: json['invite_token'] as String,
      accepted: json['accepted'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  /// Convert from PendingInvite entity to Supabase JSON
  static Map<String, dynamic> toJson(PendingInvite invite) {
    return {
      'id': invite.id,
      'email': invite.email,
      'team_id': invite.teamId,
      'role': invite.role,
      'player_name': invite.playerName,
      'jersey_number': invite.jerseyNumber,
      'invited_by': invite.invitedBy,
      'invite_token': invite.inviteToken,
      'accepted': invite.accepted,
      'created_at': invite.createdAt.toIso8601String(),
      'expires_at': invite.expiresAt.toIso8601String(),
    };
  }
}
