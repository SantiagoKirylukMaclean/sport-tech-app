// lib/domain/org/entities/staff_member.dart

import 'package:equatable/equatable.dart';

/// Position/role of a staff member
enum StaffPosition {
  headCoach('head_coach'),
  assistantCoach('assistant_coach'),
  coordinator('coordinator'),
  physicalTrainer('physical_trainer'),
  medic('medic');

  final String value;
  const StaffPosition(this.value);

  static StaffPosition fromString(String value) {
    return StaffPosition.values.firstWhere(
      (position) => position.value == value,
      orElse: () => StaffPosition.assistantCoach,
    );
  }

  String get displayName {
    switch (this) {
      case StaffPosition.headCoach:
        return 'Head Coach';
      case StaffPosition.assistantCoach:
        return 'Assistant Coach';
      case StaffPosition.coordinator:
        return 'Coordinator';
      case StaffPosition.physicalTrainer:
        return 'Physical Trainer';
      case StaffPosition.medic:
        return 'Medic';
    }
  }
}

/// Represents a staff member (coach, coordinator, etc.) in the domain
/// Maps to the public.staff_members table in Supabase
class StaffMember extends Equatable {
  final String id;
  final String teamId;
  final String userId; // Always linked to auth user
  final String fullName;
  final StaffPosition position;
  final String? email;
  final DateTime createdAt;

  const StaffMember({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.fullName,
    required this.position,
    required this.createdAt,
    this.email,
  });

  @override
  List<Object?> get props => [
        id,
        teamId,
        userId,
        fullName,
        position,
        email,
        createdAt,
      ];

  @override
  String toString() => 'StaffMember(id: $id, name: $fullName, position: ${position.displayName})';

  /// Create a copy with updated fields
  StaffMember copyWith({
    String? id,
    String? teamId,
    String? userId,
    String? fullName,
    StaffPosition? position,
    String? email,
    DateTime? createdAt,
  }) {
    return StaffMember(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      position: position ?? this.position,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
