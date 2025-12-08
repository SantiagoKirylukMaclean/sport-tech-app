// lib/domain/org/entities/pending_invite.dart

import 'package:equatable/equatable.dart';

/// Represents a pending invitation
/// Maps to the public.pending_invites table in Supabase
class PendingInvite extends Equatable {
  final int id;
  final String email;
  final String? displayName;
  final String role; // 'player', 'coach', or 'admin'
  final List<int> teamIds; // Array of team IDs (for coach/admin)
  final int? playerId; // Reference to player record (for player invites)
  final String status; // 'pending', 'accepted', 'canceled'
  final String createdBy; // User ID who sent the invite
  final DateTime createdAt;
  final DateTime? acceptedAt;

  const PendingInvite({
    required this.id,
    required this.email,
    required this.role,
    required this.teamIds,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.displayName,
    this.playerId,
    this.acceptedAt,
  });

  /// Check if the invite is pending
  bool get isPending => status == 'pending';

  /// Check if the invite has been accepted
  bool get isAccepted => status == 'accepted';

  /// Check if the invite has been canceled
  bool get isCanceled => status == 'canceled';

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        role,
        teamIds,
        playerId,
        status,
        createdBy,
        createdAt,
        acceptedAt,
      ];

  @override
  String toString() =>
      'PendingInvite(email: $email, role: $role, status: $status)';

  /// Create a copy with updated fields
  PendingInvite copyWith({
    int? id,
    String? email,
    String? displayName,
    String? role,
    List<int>? teamIds,
    int? playerId,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return PendingInvite(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      teamIds: teamIds ?? this.teamIds,
      playerId: playerId ?? this.playerId,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}
