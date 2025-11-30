// lib/infrastructure/auth/mappers/auth_user_mapper.dart

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:sport_tech_app/domain/auth/entities/auth_user.dart';

/// Maps between Supabase User and domain AuthUser
class AuthUserMapper {
  /// Convert Supabase User to domain AuthUser
  static AuthUser fromSupabase(supabase.User user) {
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      emailConfirmedAt: user.emailConfirmedAt != null
          ? DateTime.tryParse(user.emailConfirmedAt!)
          : null,
    );
  }
}
