// lib/domain/matches/entities/match.dart

import 'package:equatable/equatable.dart';

/// Status of a match
enum MatchStatus {
  scheduled,
  live,
  finished,
}

/// Represents a match in the domain
/// Maps to the public.matches table in Supabase
class Match extends Equatable {
  final String id;
  final String teamId;
  final String opponent;
  final DateTime matchDate;
  final String? location;
  final String? notes;
  final int? numberOfPeriods;
  final int? periodDuration;
  final MatchStatus status;
  final DateTime createdAt;

  const Match({
    required this.id,
    required this.teamId,
    required this.opponent,
    required this.matchDate,
    required this.createdAt,
    this.location,
    this.notes,
    this.numberOfPeriods,
    this.periodDuration,
    this.status = MatchStatus.scheduled,
  });

  @override
  List<Object?> get props => [
        id,
        teamId,
        opponent,
        matchDate,
        location,
        notes,
        numberOfPeriods,
        periodDuration,
        status,
        createdAt,
      ];

  @override
  String toString() =>
      'Match(id: $id, opponent: $opponent, date: $matchDate, status: $status)';

  /// Create a copy with updated fields
  Match copyWith({
    String? id,
    String? teamId,
    String? opponent,
    DateTime? matchDate,
    String? location,
    String? notes,
    int? numberOfPeriods,
    int? periodDuration,
    MatchStatus? status,
    DateTime? createdAt,
  }) {
    return Match(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      opponent: opponent ?? this.opponent,
      matchDate: matchDate ?? this.matchDate,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      numberOfPeriods: numberOfPeriods ?? this.numberOfPeriods,
      periodDuration: periodDuration ?? this.periodDuration,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
