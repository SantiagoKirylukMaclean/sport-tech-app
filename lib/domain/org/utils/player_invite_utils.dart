// lib/domain/org/utils/player_invite_utils.dart

import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';
import 'package:sport_tech_app/domain/org/entities/player_invite_status.dart';

/// Utility functions for determining player invite status
class PlayerInviteUtils {
  /// Determine the invite status for a player
  ///
  /// Returns [PlayerInviteStatus.accepted] if the player has a userId
  /// Returns [PlayerInviteStatus.invited] if there's a pending invite for the player
  /// Returns [PlayerInviteStatus.noInvite] if the player has no userId and no pending invite
  static PlayerInviteStatus getPlayerStatus(
    Player player,
    List<PendingInvite> pendingInvites,
  ) {
    // If player has a userId, they've accepted and are active
    if (player.userId != null) {
      return PlayerInviteStatus.accepted;
    }

    // Check if there's a pending invite for this player
    final playerIdInt = int.tryParse(player.id);
    if (playerIdInt != null) {
      final hasInvite = pendingInvites.any(
        (invite) =>
            invite.playerId == playerIdInt && invite.status == 'pending',
      );

      if (hasInvite) {
        return PlayerInviteStatus.invited;
      }
    }

    // No userId and no pending invite
    return PlayerInviteStatus.noInvite;
  }

  /// Get the pending invite for a player, if one exists
  static PendingInvite? getPlayerInvite(
    Player player,
    List<PendingInvite> pendingInvites,
  ) {
    final playerIdInt = int.tryParse(player.id);
    if (playerIdInt == null) return null;

    try {
      return pendingInvites.firstWhere(
        (invite) => invite.playerId == playerIdInt && invite.status == 'pending',
      );
    } catch (_) {
      return null;
    }
  }
}
