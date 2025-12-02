// test/infrastructure/auth/supabase_auth_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/infrastructure/auth/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

class MockAuthException extends Mock implements AuthException {}

void main() {
  late SupabaseAuthRepository repository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    repository = SupabaseAuthRepository(mockClient);

    // Setup default mock behavior
    when(() => mockClient.auth).thenReturn(mockAuth);
  });

  group('SupabaseAuthRepository -', () {
    group('signIn', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      test('should return Success with AuthUser on successful sign in', () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('user-123');
        when(() => mockUser.email).thenReturn(testEmail);
        when(() => mockUser.createdAt).thenReturn(DateTime.now().toIso8601String());
        when(() => mockResponse.user).thenReturn(mockUser);
        when(() => mockAuth.signInWithPassword(
              email: testEmail.trim(),
              password: testPassword,
            )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.signIn(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, isA<Success>());
        expect(result.isSuccess, isTrue);
        verify(() => mockAuth.signInWithPassword(
              email: testEmail.trim(),
              password: testPassword,
            )).called(1);
      });

      test('should return Failed with AuthFailure when user is null', () async {
        // Arrange
        final mockResponse = MockAuthResponse();
        when(() => mockResponse.user).thenReturn(null);
        when(() => mockAuth.signInWithPassword(
              email: testEmail.trim(),
              password: testPassword,
            )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.signIn(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, isA<Failed>());
        expect(result.isFailure, isTrue);
        final failure = (result as Failed).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, contains('Sign in failed'));
      });

      test('should return Failed with AuthFailure on AuthException', () async {
        // Arrange
        final exception = AuthException('Invalid credentials', statusCode: '401');
        when(() => mockAuth.signInWithPassword(
              email: testEmail.trim(),
              password: testPassword,
            )).thenThrow(exception);

        // Act
        final result = await repository.signIn(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Invalid credentials');
        expect(failure.code, '401');
      });

      test('should trim email before sign in', () async {
        // Arrange
        const emailWithSpaces = '  test@example.com  ';
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('user-123');
        when(() => mockUser.email).thenReturn(testEmail);
        when(() => mockUser.createdAt).thenReturn(DateTime.now().toIso8601String());
        when(() => mockResponse.user).thenReturn(mockUser);
        when(() => mockAuth.signInWithPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => mockResponse);

        // Act
        await repository.signIn(
          email: emailWithSpaces,
          password: testPassword,
        );

        // Assert
        verify(() => mockAuth.signInWithPassword(
              email: testEmail,
              password: testPassword,
            )).called(1);
      });
    });

    group('signOut', () {
      test('should return Success on successful sign out', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Success>());
        expect(result.isSuccess, isTrue);
        verify(() => mockAuth.signOut()).called(1);
      });

      test('should return Failed with AuthFailure on AuthException', () async {
        // Arrange
        final exception = AuthException('Sign out failed', statusCode: '500');
        when(() => mockAuth.signOut()).thenThrow(exception);

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Sign out failed');
      });

      test('should return Failed on unexpected error', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenThrow(Exception('Network error'));

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, contains('Unexpected error'));
      });
    });

    group('getCurrentUser', () {
      test('should return Success with AuthUser when user exists', () async {
        // Arrange
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('user-123');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.createdAt).thenReturn(DateTime.now().toIso8601String());
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Success>());
        expect(result.isSuccess, isTrue);
        final user = (result as Success).value;
        expect(user, isNotNull);
      });

      test('should return Success with null when no user', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Success>());
        final user = (result as Success).value;
        expect(user, isNull);
      });

      test('should return Failed on error', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenThrow(Exception('Error'));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<AuthFailure>());
      });
    });

    group('signUp', () {
      const testEmail = 'newuser@example.com';
      const testPassword = 'password123';

      test('should return Success with AuthUser on successful sign up', () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('user-456');
        when(() => mockUser.email).thenReturn(testEmail);
        when(() => mockUser.createdAt).thenReturn(DateTime.now().toIso8601String());
        when(() => mockResponse.user).thenReturn(mockUser);
        when(() => mockAuth.signUp(
              email: testEmail.trim(),
              password: testPassword,
            )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.signUp(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, isA<Success>());
        expect(result.isSuccess, isTrue);
        verify(() => mockAuth.signUp(
              email: testEmail.trim(),
              password: testPassword,
            )).called(1);
      });

      test('should return Failed when user is null', () async {
        // Arrange
        final mockResponse = MockAuthResponse();
        when(() => mockResponse.user).thenReturn(null);
        when(() => mockAuth.signUp(
              email: testEmail.trim(),
              password: testPassword,
            )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.signUp(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, contains('Sign up failed'));
      });
    });

    group('resetPassword', () {
      const testEmail = 'test@example.com';

      test('should return Success on successful password reset', () async {
        // Arrange
        when(() => mockAuth.resetPasswordForEmail(testEmail.trim()))
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.resetPassword(email: testEmail);

        // Assert
        expect(result, isA<Success>());
        verify(() => mockAuth.resetPasswordForEmail(testEmail.trim())).called(1);
      });

      test('should return Failed on AuthException', () async {
        // Arrange
        final exception = AuthException('Email not found', statusCode: '404');
        when(() => mockAuth.resetPasswordForEmail(testEmail.trim()))
            .thenThrow(exception);

        // Act
        final result = await repository.resetPassword(email: testEmail);

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<AuthFailure>());
      });

      test('should trim email before reset', () async {
        // Arrange
        const emailWithSpaces = '  test@example.com  ';
        when(() => mockAuth.resetPasswordForEmail(testEmail))
            .thenAnswer((_) async => Future.value());

        // Act
        await repository.resetPassword(email: emailWithSpaces);

        // Assert
        verify(() => mockAuth.resetPasswordForEmail(testEmail)).called(1);
      });
    });
  });
}
