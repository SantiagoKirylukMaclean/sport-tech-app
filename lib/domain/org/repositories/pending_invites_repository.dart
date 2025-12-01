// lib/domain/org/repositories/pending_invites_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';

/// Repository interface for pending invites operations
/// This is the contract that infrastructure layer must implement
abstract class PendingInvitesRepository {
  /// Get pending invites by team
  /// Returns list of [PendingInvite] on success, [Failure] on error
  Future<Result<List<PendingInvite>>> getInvitesByTeam(String teamId);

  /// Get an invite by token
  /// Returns [PendingInvite] on success, [Failure] on error
  Future<Result<PendingInvite>> getInviteByToken(String token);

  /// Create a new player invite
  /// Returns created [PendingInvite] on success, [Failure] on error
  Future<Result<PendingInvite>> createPlayerInvite({
    required String email,
    required String teamId,
    required String playerName,
    required String invitedBy,
    int? jerseyNumber,
    int expiryDays = 7,
  });

  /// Create a new staff invite (coach or admin)
  /// Returns created [PendingInvite] on success, [Failure] on error
  Future<Result<PendingInvite>> createStaffInvite({
    required String email,
    required String teamId,
    required String role, // 'coach' or 'admin'
    required String invitedBy,
    int expiryDays = 7,
  });

  /// Mark an invite as accepted
  /// Returns updated [PendingInvite] on success, [Failure] on error
  Future<Result<PendingInvite>> markInviteAccepted(String token);

  /// Delete an invite
  /// Returns void on success, [Failure] on error
  Future<Result<void>> deleteInvite(String id);
}
