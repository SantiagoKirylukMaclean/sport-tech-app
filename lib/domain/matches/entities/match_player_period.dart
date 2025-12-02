// lib/domain/matches/entities/match_player_period.dart

import 'package:equatable/equatable.dart';

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
  final DateTime createdAt;

  const MatchPlayerPeriod({
    required this.matchId,
    required this.playerId,
    required this.period,
    required this.fraction,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        matchId,
        playerId,
        period,
        fraction,
        createdAt,
      ];

  @override
  String toString() =>
      'MatchPlayerPeriod(matchId: $matchId, playerId: $playerId, period: $period, fraction: ${fraction.value})';

  /// Create a copy with updated fields
  MatchPlayerPeriod copyWith({
    String? matchId,
    String? playerId,
    int? period,
    Fraction? fraction,
    DateTime? createdAt,
  }) {
    return MatchPlayerPeriod(
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      period: period ?? this.period,
      fraction: fraction ?? this.fraction,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
