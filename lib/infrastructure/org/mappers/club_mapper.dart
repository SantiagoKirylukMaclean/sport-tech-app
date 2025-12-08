// lib/infrastructure/org/mappers/club_mapper.dart

import 'package:sport_tech_app/domain/org/entities/club.dart';

/// Mapper for converting between Supabase JSON and Club entity
class ClubMapper {
  /// Convert from Supabase JSON to Club entity
  static Club fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'].toString(),
      sportId: json['sport_id'].toString(),
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from Club entity to Supabase JSON
  static Map<String, dynamic> toJson(Club club) {
    return {
      'id': club.id,
      'sport_id': club.sportId,
      'name': club.name,
      'created_at': club.createdAt.toIso8601String(),
    };
  }
}
