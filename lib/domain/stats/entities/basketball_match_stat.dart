import 'package:equatable/equatable.dart';

enum BasketballStatType {
  points,
  fieldGoal,
  freeThrow,
  assist,
  turnover,
  rebound,
  steal,
  block,
  foul,
  hustle,
}

enum BasketballStatSubType {
  // Points
  twoPoints,
  threePoints,

  // Field Goals / Free Throws
  attempted,
  made,

  // Rebounds
  offensive,
  defensive,

  // Hustle
  looseBallRecovered,
  jumpBallWon,
}

class BasketballMatchStat extends Equatable {
  final String id;
  final String matchId;
  final String playerId;
  final int period;
  final BasketballStatType type;
  final BasketballStatSubType? subType;
  final int
      value; // Generic value, usually 1 for counts, or 2/3 for points if aggregated
  final DateTime timestamp;

  const BasketballMatchStat({
    required this.id,
    required this.matchId,
    required this.playerId,
    required this.period,
    required this.type,
    this.subType,
    required this.value,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        playerId,
        period,
        type,
        subType,
        value,
        timestamp,
      ];

  BasketballMatchStat copyWith({
    String? id,
    String? matchId,
    String? playerId,
    int? period,
    BasketballStatType? type,
    BasketballStatSubType? subType,
    int? value,
    DateTime? timestamp,
  }) {
    return BasketballMatchStat(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      period: period ?? this.period,
      type: type ?? this.type,
      subType: subType ?? this.subType,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
