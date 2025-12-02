// lib/application/matches/match_lineup_state.dart

import 'package:sport_tech_app/domain/matches/entities/match_call_up.dart';
import 'package:sport_tech_app/domain/matches/entities/match_goal.dart';
import 'package:sport_tech_app/domain/matches/entities/match_player_period.dart';
import 'package:sport_tech_app/domain/matches/entities/match_quarter_result.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';

/// State for match lineup management
class MatchLineupState {
  final bool isLoading;
  final String? error;
  final int currentQuarter; // 1-4
  final bool substitutionMode;

  // Call-ups (convocatoria)
  final List<MatchCallUp> callUps;
  final List<Player> calledUpPlayers; // Full player objects

  // Periods (players in field per quarter)
  final List<MatchPlayerPeriod> allPeriods; // All periods for the match
  final List<MatchPlayerPeriod> currentQuarterPeriods; // Periods for current quarter

  // Quarter results
  final List<MatchQuarterResult> quarterResults;
  final MatchQuarterResult? currentQuarterResult;

  // Goals
  final List<MatchGoal> allGoals;
  final List<MatchGoal> currentQuarterGoals;

  // Substitution selection
  final String? selectedPlayerOut;
  final String? selectedPlayerIn;

  const MatchLineupState({
    this.isLoading = false,
    this.error,
    this.currentQuarter = 1,
    this.substitutionMode = false,
    this.callUps = const [],
    this.calledUpPlayers = const [],
    this.allPeriods = const [],
    this.currentQuarterPeriods = const [],
    this.quarterResults = const [],
    this.currentQuarterResult,
    this.allGoals = const [],
    this.currentQuarterGoals = const [],
    this.selectedPlayerOut,
    this.selectedPlayerIn,
  });

  /// Check if minimum call-ups requirement is met (7 players)
  bool get hasMinimumCallUps => callUps.length >= 7;

  /// Get players currently on field for current quarter
  List<Player> get fieldPlayers {
    final fieldPlayerIds = currentQuarterPeriods.map((p) => p.playerId).toSet();
    return calledUpPlayers
        .where((p) => fieldPlayerIds.contains(p.id))
        .toList();
  }

  /// Get players on bench (called up but not in current quarter)
  List<Player> get benchPlayers {
    final fieldPlayerIds = currentQuarterPeriods.map((p) => p.playerId).toSet();
    return calledUpPlayers
        .where((p) => !fieldPlayerIds.contains(p.id))
        .toList();
  }

  /// Check if field is full (7 players max)
  bool get isFieldFull => fieldPlayers.length >= 7;

  MatchLineupState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? currentQuarter,
    bool? substitutionMode,
    List<MatchCallUp>? callUps,
    List<Player>? calledUpPlayers,
    List<MatchPlayerPeriod>? allPeriods,
    List<MatchPlayerPeriod>? currentQuarterPeriods,
    List<MatchQuarterResult>? quarterResults,
    MatchQuarterResult? currentQuarterResult,
    bool clearCurrentQuarterResult = false,
    List<MatchGoal>? allGoals,
    List<MatchGoal>? currentQuarterGoals,
    String? selectedPlayerOut,
    bool clearSelectedPlayerOut = false,
    String? selectedPlayerIn,
    bool clearSelectedPlayerIn = false,
  }) {
    return MatchLineupState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentQuarter: currentQuarter ?? this.currentQuarter,
      substitutionMode: substitutionMode ?? this.substitutionMode,
      callUps: callUps ?? this.callUps,
      calledUpPlayers: calledUpPlayers ?? this.calledUpPlayers,
      allPeriods: allPeriods ?? this.allPeriods,
      currentQuarterPeriods: currentQuarterPeriods ?? this.currentQuarterPeriods,
      quarterResults: quarterResults ?? this.quarterResults,
      currentQuarterResult: clearCurrentQuarterResult
          ? null
          : (currentQuarterResult ?? this.currentQuarterResult),
      allGoals: allGoals ?? this.allGoals,
      currentQuarterGoals: currentQuarterGoals ?? this.currentQuarterGoals,
      selectedPlayerOut: clearSelectedPlayerOut
          ? null
          : (selectedPlayerOut ?? this.selectedPlayerOut),
      selectedPlayerIn: clearSelectedPlayerIn
          ? null
          : (selectedPlayerIn ?? this.selectedPlayerIn),
    );
  }
}
