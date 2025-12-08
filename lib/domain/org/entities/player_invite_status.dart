// lib/domain/org/entities/player_invite_status.dart

/// Represents the invite status of a player
enum PlayerInviteStatus {
  /// Player has no associated user and no pending invite
  noInvite,

  /// Player has a pending invite
  invited,

  /// Player has accepted the invite (has userId or invite is accepted)
  accepted,
}

extension PlayerInviteStatusExtension on PlayerInviteStatus {
  /// Get display label for the status
  String get label {
    switch (this) {
      case PlayerInviteStatus.noInvite:
        return 'Sin invitación';
      case PlayerInviteStatus.invited:
        return 'Invitado';
      case PlayerInviteStatus.accepted:
        return 'Aceptado';
    }
  }

  /// Get short label for compact display
  String get shortLabel {
    switch (this) {
      case PlayerInviteStatus.noInvite:
        return 'Sin inv.';
      case PlayerInviteStatus.invited:
        return 'Invitado';
      case PlayerInviteStatus.accepted:
        return 'Activo';
    }
  }
}
