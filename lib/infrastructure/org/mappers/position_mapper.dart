// lib/infrastructure/org/mappers/position_mapper.dart

import 'package:sport_tech_app/domain/org/entities/position.dart';

/// Mapper for converting between Supabase JSON and Position entity
class PositionMapper {
  /// Convert from Supabase JSON to Position entity
  static Position fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] as String,
      sportId: json['sport_id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      fieldZone: json['field_zone'] as String?,
    );
  }

  /// Convert from Position entity to Supabase JSON
  static Map<String, dynamic> toJson(Position position) {
    return {
      'id': position.id,
      'sport_id': position.sportId,
      'name': position.name,
      'abbreviation': position.abbreviation,
      'field_zone': position.fieldZone,
    };
  }
}
