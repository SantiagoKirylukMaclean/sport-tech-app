import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/auth/entities/auth_user.dart';
import 'package:sport_tech_app/domain/profiles/entities/user_profile.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

/// Provider to get the current authenticated user
final currentUserProvider = Provider<AuthUser?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState is AuthStateAuthenticated) {
    return authState.user;
  }
  return null;
});

/// Provider to get the current user profile
final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState is AuthStateAuthenticated) {
    return authState.profile;
  }
  return null;
});
