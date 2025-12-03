// lib/infrastructure/org/mappers/position_mapper.dart

import 'package:sport_tech_app/domain/org/entities/position.dart';

/// Mapper for converting between Supabase JSON and Position entity
class PositionMapper {
  /// Convert from Supabase JSON to Position entity
  static Position fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'].toString(),
      name: json['name'] as String,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from Position entity to Supabase JSON
  static Map<String, dynamic> toJson(Position position) {
    return {
      'id': position.id,
      'name': position.name,
      'display_order': position.displayOrder,
      'created_at': position.createdAt.toIso8601String(),
    };
  }
}
