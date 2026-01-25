// lib/domain/org/entities/team.dart

import 'package:equatable/equatable.dart';

/// Represents a team in the domain
/// Maps to the public.teams table in Supabase
class Team extends Equatable {
  final String id;
  final String clubId;
  final String name;
  final String? sportId; // Fetched from Club
  final String? sportName; // Fetched from Club -> Sport
  final DateTime createdAt;
  final String? standingsUrl;
  final String? resultsUrl;
  final String? calendarUrl;

  const Team({
    required this.id,
    required this.clubId,
    required this.name,
    this.sportId,
    this.sportName,
    required this.createdAt,
    this.standingsUrl,
    this.resultsUrl,
    this.calendarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        clubId,
        name,
        sportId,
        sportName,
        createdAt,
        standingsUrl,
        resultsUrl,
        calendarUrl
      ];

  @override
  String toString() => 'Team(id: $id, name: $name, clubId: $clubId)';

  /// Create a copy with updated fields
  Team copyWith({
    String? id,
    String? clubId,
    String? name,
    String? sportId,
    String? sportName,
    DateTime? createdAt,
    String? standingsUrl,
    String? resultsUrl,
    String? calendarUrl,
  }) {
    return Team(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      name: name ?? this.name,
      sportId: sportId ?? this.sportId,
      sportName: sportName ?? this.sportName,
      createdAt: createdAt ?? this.createdAt,
      standingsUrl: standingsUrl ?? this.standingsUrl,
      resultsUrl: resultsUrl ?? this.resultsUrl,
      calendarUrl: calendarUrl ?? this.calendarUrl,
    );
  }
}
