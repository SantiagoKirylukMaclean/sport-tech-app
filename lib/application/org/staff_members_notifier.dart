// lib/application/org/staff_members_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/org/entities/staff_member.dart';
import 'package:sport_tech_app/domain/org/repositories/staff_members_repository.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// State for staff members management
class StaffMembersState {
  final List<StaffMember> staffMembers;
  final bool isLoading;
  final String? error;

  const StaffMembersState({
    this.staffMembers = const [],
    this.isLoading = false,
    this.error,
  });

  StaffMembersState copyWith({
    List<StaffMember>? staffMembers,
    bool? isLoading,
    String? error,
  }) {
    return StaffMembersState(
      staffMembers: staffMembers ?? this.staffMembers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing staff members state
class StaffMembersNotifier extends StateNotifier<StaffMembersState> {
  final StaffMembersRepository _repository;

  StaffMembersNotifier(this._repository) : super(const StaffMembersState());

  /// Load staff members by team
  Future<void> loadStaffMembersByTeam(String teamId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getStaffMembersByTeam(teamId);

    result.when(
      success: (staffMembers) {
        state = state.copyWith(
          staffMembers: staffMembers,
          isLoading: false,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
    );
  }

  /// Create a new staff member
  Future<bool> createStaffMember({
    required String teamId,
    required String userId,
    required String fullName,
    required StaffPosition position,
    String? email,
  }) async {
    final result = await _repository.createStaffMember(
      teamId: teamId,
      userId: userId,
      fullName: fullName,
      position: position,
      email: email,
    );

    return result.when(
      success: (staffMember) {
        state = state.copyWith(
          staffMembers: [...state.staffMembers, staffMember],
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Update a staff member
  Future<bool> updateStaffMember({
    required String id,
    String? fullName,
    StaffPosition? position,
    String? email,
  }) async {
    final result = await _repository.updateStaffMember(
      id: id,
      fullName: fullName,
      position: position,
      email: email,
    );

    return result.when(
      success: (updatedStaffMember) {
        state = state.copyWith(
          staffMembers: state.staffMembers
              .map((s) => s.id == id ? updatedStaffMember : s)
              .toList(),
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Delete a staff member
  Future<bool> deleteStaffMember(String id) async {
    final result = await _repository.deleteStaffMember(id);

    return result.when(
      success: (_) {
        state = state.copyWith(
          staffMembers: state.staffMembers.where((s) => s.id != id).toList(),
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }
}

/// Provider for staff members notifier
final staffMembersNotifierProvider =
    StateNotifierProvider<StaffMembersNotifier, StaffMembersState>((ref) {
  final repository = ref.watch(staffMembersRepositoryProvider);
  return StaffMembersNotifier(repository);
});
