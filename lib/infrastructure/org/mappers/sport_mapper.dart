// lib/infrastructure/org/mappers/sport_mapper.dart

import 'package:sport_tech_app/domain/org/entities/sport.dart';

/// Mapper for converting between Supabase JSON and Sport entity
class SportMapper {
  /// Convert from Supabase JSON to Sport entity
  static Sport fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from Sport entity to Supabase JSON
  static Map<String, dynamic> toJson(Sport sport) {
    return {
      'id': sport.id,
      'name': sport.name,
      'created_at': sport.createdAt.toIso8601String(),
    };
  }
}
