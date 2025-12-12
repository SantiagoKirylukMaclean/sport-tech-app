// lib/infrastructure/org/mappers/club_mapper.dart

import 'package:flutter/material.dart';
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
      primaryColor: _colorFromInt(json['primary_color']),
      secondaryColor: _colorFromInt(json['secondary_color']),
      tertiaryColor: _colorFromInt(json['tertiary_color']),
    );
  }

  /// Convert from Club entity to Supabase JSON
  static Map<String, dynamic> toJson(Club club) {
    return {
      'id': club.id,
      'sport_id': club.sportId,
      'name': club.name,
      'created_at': club.createdAt.toIso8601String(),
      'primary_color': club.primaryColor?.toARGB32(),
      'secondary_color': club.secondaryColor?.toARGB32(),
      'tertiary_color': club.tertiaryColor?.toARGB32(),
    };
  }

  /// Convert integer ARGB value to Flutter Color
  /// Returns null if value is null or invalid
  static Color? _colorFromInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return Color(value);
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed != null ? Color(parsed) : null;
    }
    return null;
  }
}
