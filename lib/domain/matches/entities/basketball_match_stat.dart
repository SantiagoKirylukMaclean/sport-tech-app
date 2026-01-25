import 'package:equatable/equatable.dart';

enum BasketballStatType {
  point1('POINT_1', '1 Point', 1),
  point2('POINT_2', '2 Points', 2),
  point3('POINT_3', '3 Points', 3),
  reboundOff('REBOUND_OFF', 'Offensive Rebound', 0),
  reboundDef('REBOUND_DEF', 'Defensive Rebound', 0),
  assist('ASSIST', 'Assist', 0),
  block('BLOCK', 'Block', 0),
  steal('STEAL', 'Steal', 0),
  turnover('TURNOVER', 'Turnover', 0),
  foul('FOUL', 'Foul', 0);

  final String value;
  final String displayName;
  final int pointsValue;

  const BasketballStatType(this.value, this.displayName, this.pointsValue);

  static BasketballStatType fromString(String value) {
    return BasketballStatType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => BasketballStatType.point2,
    );
  }
}

class BasketballMatchStat extends Equatable {
  final String id;
  final String matchId;
  final String playerId;
  final String? playerName;
  final int? playerJerseyNumber;
  final int quarter;
  final BasketballStatType statType;
  final DateTime createdAt;

  const BasketballMatchStat({
    required this.id,
    required this.matchId,
    required this.playerId,
    this.playerName,
    this.playerJerseyNumber,
    required this.quarter,
    required this.statType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        playerId,
        playerName,
        playerJerseyNumber,
        quarter,
        statType,
        createdAt
      ];

  BasketballMatchStat copyWith({
    String? id,
    String? matchId,
    String? playerId,
    String? playerName,
    int? playerJerseyNumber,
    int? quarter,
    BasketballStatType? statType,
    DateTime? createdAt,
  }) {
    return BasketballMatchStat(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      playerJerseyNumber: playerJerseyNumber ?? this.playerJerseyNumber,
      quarter: quarter ?? this.quarter,
      statType: statType ?? this.statType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
