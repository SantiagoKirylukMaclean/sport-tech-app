// lib/domain/matches/entities/match_player_period.dart

import 'package:equatable/equatable.dart';
import 'package:sport_tech_app/domain/matches/entities/field_zone.dart';

/// Fraction of a period played by a player
enum Fraction {
  full('FULL'),
  half('HALF');

  const Fraction(this.value);
  final String value;

  static Fraction fromString(String value) {
    return Fraction.values.firstWhere(
      (f) => f.value == value.toUpperCase(),
      orElse: () => Fraction.full,
    );
  }
}

/// Represents a player's participation in a specific period of a match
/// Maps to the public.match_player_periods table in Supabase
class MatchPlayerPeriod extends Equatable {
  final String matchId;
  final String playerId;
  final int period; // 1-4 (quarters)
  final Fraction fraction;
  final FieldZone? fieldZone; // Position on the field
  final DateTime createdAt;

  const MatchPlayerPeriod({
    required this.matchId,
    required this.playerId,
    required this.period,
    required this.fraction,
    required this.createdAt,
    this.fieldZone,
  });

  @override
  List<Object?> get props => [
        matchId,
        playerId,
        period,
        fraction,
        fieldZone,
        createdAt,
      ];

  @override
  String toString() =>
      'MatchPlayerPeriod(matchId: $matchId, playerId: $playerId, period: $period, fraction: ${fraction.value}, fieldZone: ${fieldZone?.value})';

  /// Create a copy with updated fields
  MatchPlayerPeriod copyWith({
    String? matchId,
    String? playerId,
    int? period,
    Fraction? fraction,
    FieldZone? fieldZone,
    bool clearFieldZone = false,
    DateTime? createdAt,
  }) {
    return MatchPlayerPeriod(
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      period: period ?? this.period,
      fraction: fraction ?? this.fraction,
      fieldZone: clearFieldZone ? null : (fieldZone ?? this.fieldZone),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
