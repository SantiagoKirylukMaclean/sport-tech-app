// lib/domain/org/repositories/pending_invites_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';

/// Repository interface for pending invites operations
/// This is the contract that infrastructure layer must implement
abstract class PendingInvitesRepository {
  /// Get all pending invites (admin only)
  /// Returns list of [PendingInvite] on success, [Failure] on error
  Future<Result<List<PendingInvite>>> getAllInvites();

  /// Get pending invites by team
  /// Returns list of [PendingInvite] on success, [Failure] on error
  Future<Result<List<PendingInvite>>> getInvitesByTeam(int teamId);

  /// Get an invite by email
  /// Returns [PendingInvite] on success, [Failure] on error
  Future<Result<PendingInvite>> getInviteByEmail(String email);

  /// Create a new player invite (links to existing player record)
  /// [sendEmail] if true, sends email automatically. If false, returns magic link for manual sharing
  /// Returns created [PendingInvite] on success, [Failure] on error
  Future<Result<PendingInvite>> createPlayerInvite({
    required String email,
    required int playerId,
    required String createdBy,
    String? displayName,
    bool sendEmail = true,
  });

  /// Create a new staff invite (coach or admin)
  /// Returns created [PendingInvite] on success, [Failure] on error
  Future<Result<PendingInvite>> createStaffInvite({
    required String email,
    required List<int> teamIds,
    required String role, // 'coach' or 'admin'
    required String createdBy,
    String? displayName,
  });

  /// Mark an invite as accepted by email
  /// Returns updated [PendingInvite] on success, [Failure] on error
  Future<Result<PendingInvite>> markInviteAccepted(String email);

  /// Delete an invite
  /// Returns void on success, [Failure] on error
  Future<Result<void>> deleteInvite(int id);

  /// Cancel an invite (sets status to 'canceled')
  /// Returns updated [PendingInvite] on success, [Failure] on error
  Future<Result<PendingInvite>> cancelInvite(int id);

  /// Resend an invitation email to the user
  /// [sendEmail] if true, sends email automatically. If false, returns magic link for manual sharing
  /// Returns signup URL string or confirmation message on success, [Failure] on error
  Future<Result<String>> resendInvite(int id, {bool sendEmail = true});
}
