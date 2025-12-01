// lib/domain/org/entities/pending_invite.dart

import 'package:equatable/equatable.dart';

/// Represents a pending invitation
/// Maps to the public.pending_invites table in Supabase
class PendingInvite extends Equatable {
  final String id;
  final String email;
  final String teamId;
  final String role; // 'player', 'coach', or 'admin'
  final String? playerName; // Only for player invites
  final int? jerseyNumber; // Only for player invites
  final String invitedBy; // User ID who sent the invite
  final String inviteToken;
  final bool accepted;
  final DateTime createdAt;
  final DateTime expiresAt;

  const PendingInvite({
    required this.id,
    required this.email,
    required this.teamId,
    required this.role,
    this.playerName,
    this.jerseyNumber,
    required this.invitedBy,
    required this.inviteToken,
    required this.accepted,
    required this.createdAt,
    required this.expiresAt,
  });

  /// Check if the invite has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if the invite is still valid (not accepted and not expired)
  bool get isValid => !accepted && !isExpired;

  @override
  List<Object?> get props => [
        id,
        email,
        teamId,
        role,
        playerName,
        jerseyNumber,
        invitedBy,
        inviteToken,
        accepted,
        createdAt,
        expiresAt,
      ];

  @override
  String toString() =>
      'PendingInvite(email: $email, role: $role, teamId: $teamId)';

  /// Create a copy with updated fields
  PendingInvite copyWith({
    String? id,
    String? email,
    String? teamId,
    String? role,
    String? playerName,
    int? jerseyNumber,
    String? invitedBy,
    String? inviteToken,
    bool? accepted,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return PendingInvite(
      id: id ?? this.id,
      email: email ?? this.email,
      teamId: teamId ?? this.teamId,
      role: role ?? this.role,
      playerName: playerName ?? this.playerName,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      invitedBy: invitedBy ?? this.invitedBy,
      inviteToken: inviteToken ?? this.inviteToken,
      accepted: accepted ?? this.accepted,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
