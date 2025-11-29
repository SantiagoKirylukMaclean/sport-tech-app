// lib/application/auth/auth_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/domain/auth/repositories/auth_repository.dart';
import 'package:sport_tech_app/domain/profiles/repositories/profiles_repository.dart';
import 'package:sport_tech_app/infrastructure/auth/providers/auth_repository_provider.dart';
import 'package:sport_tech_app/infrastructure/profiles/providers/profiles_repository_provider.dart';

/// Notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final ProfilesRepository _profilesRepository;
  StreamSubscription? _authStateSubscription;

  AuthNotifier({
    required AuthRepository authRepository,
    required ProfilesRepository profilesRepository,
  })  : _authRepository = authRepository,
        _profilesRepository = profilesRepository,
        super(const AuthStateInitial()) {
    // Initialize by checking current session
    _initializeAuth();
  }

  /// Initialize authentication by checking current session and listening to auth changes
  Future<void> _initializeAuth() async {
    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges().listen(
      (authUser) {
        if (authUser == null) {
          state = const AuthStateUnauthenticated();
        } else {
          _loadUserProfile(authUser);
        }
      },
      onError: (error) {
        state = AuthStateError('Auth state error: $error');
      },
    );

    // Check current session
    final result = await _authRepository.getCurrentUser();
    result.when(
      success: (authUser) {
        if (authUser == null) {
          state = const AuthStateUnauthenticated();
        } else {
          _loadUserProfile(authUser);
        }
      },
      failure: (failure) {
        state = AuthStateError(failure.message);
      },
    );
  }

  /// Load user profile after authentication
  Future<void> _loadUserProfile(dynamic authUser) async {
    final profileResult = await _profilesRepository.getCurrentUserProfile();
    profileResult.when(
      success: (profile) {
        state = AuthStateAuthenticated(
          user: authUser,
          profile: profile,
        );
      },
      failure: (failure) {
        state = AuthStateError('Failed to load profile: ${failure.message}');
      },
    );
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthStateLoading();

    final result = await _authRepository.signIn(
      email: email,
      password: password,
    );

    result.when(
      success: (authUser) async {
        // Profile will be loaded automatically by auth state listener
        await _loadUserProfile(authUser);
      },
      failure: (failure) {
        state = AuthStateError(failure.message);
      },
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = const AuthStateLoading();

    final result = await _authRepository.signOut();

    result.when(
      success: (_) {
        state = const AuthStateUnauthenticated();
      },
      failure: (failure) {
        state = AuthStateError(failure.message);
      },
    );
  }

  /// Sign up a new user
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthStateLoading();

    final result = await _authRepository.signUp(
      email: email,
      password: password,
    );

    result.when(
      success: (authUser) async {
        // Create profile for the new user
        final profileResult = await _profilesRepository.createProfile(
          userId: authUser.id,
          displayName: displayName,
          role: 'player', // Default role
        );

        profileResult.when(
          success: (profile) {
            state = AuthStateAuthenticated(
              user: authUser,
              profile: profile,
            );
          },
          failure: (failure) {
            state = AuthStateError('Failed to create profile: ${failure.message}');
          },
        );
      },
      failure: (failure) {
        state = AuthStateError(failure.message);
      },
    );
  }

  /// Reset password for the given email
  Future<void> resetPassword({required String email}) async {
    final result = await _authRepository.resetPassword(email: email);
    // Don't change state for password reset, just return the result
    result.when(
      success: (_) {
        // Success - could show a snackbar or dialog
      },
      failure: (failure) {
        state = AuthStateError(failure.message);
      },
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for the AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profilesRepository = ref.watch(profilesRepositoryProvider);

  return AuthNotifier(
    authRepository: authRepository,
    profilesRepository: profilesRepository,
  );
});
