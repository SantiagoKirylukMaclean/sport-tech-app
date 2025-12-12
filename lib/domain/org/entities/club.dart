// lib/domain/org/entities/club.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a club in the domain
/// Maps to the public.clubs table in Supabase
class Club extends Equatable {
  final String id;
  final String sportId;
  final String name;
  final DateTime createdAt;

  /// Primary brand color for Material Design 3 theming
  final Color? primaryColor;

  /// Secondary brand color for Material Design 3 theming
  final Color? secondaryColor;

  /// Tertiary brand color for Material Design 3 theming
  final Color? tertiaryColor;

  const Club({
    required this.id,
    required this.sportId,
    required this.name,
    required this.createdAt,
    this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
  });

  @override
  List<Object?> get props => [
        id,
        sportId,
        name,
        createdAt,
        primaryColor,
        secondaryColor,
        tertiaryColor,
      ];

  @override
  String toString() => 'Club(id: $id, name: $name, sportId: $sportId)';

  /// Create a copy with updated fields
  Club copyWith({
    String? id,
    String? sportId,
    String? name,
    DateTime? createdAt,
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
  }) {
    return Club(
      id: id ?? this.id,
      sportId: sportId ?? this.sportId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      tertiaryColor: tertiaryColor ?? this.tertiaryColor,
    );
  }
}
