// lib/infrastructure/org/mappers/team_mapper.dart

import 'package:sport_tech_app/domain/org/entities/team.dart';

/// Mapper for converting between Supabase JSON and Team entity
class TeamMapper {
  /// Convert from Supabase JSON to Team entity
  static Team fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'].toString(),
      clubId: json['club_id'].toString(),
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from Team entity to Supabase JSON
  static Map<String, dynamic> toJson(Team team) {
    return {
      'id': team.id,
      'club_id': team.clubId,
      'name': team.name,
      'created_at': team.createdAt.toIso8601String(),
    };
  }
}
