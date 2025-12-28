// test/infrastructure/profiles/supabase_profiles_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/infrastructure/profiles/supabase_profiles_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fake_postgrest_builder.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late SupabaseProfilesRepository repository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockSupabaseQueryBuilder mockQueryBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    repository = SupabaseProfilesRepository(mockClient);

    // Register fallbacks
    registerFallbackValue({});
  });

  void setUpMocks() {
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
    when(() => mockQueryBuilder.insert(any())).thenAnswer((_) => mockFilterBuilder);
    when(() => mockQueryBuilder.update(any())).thenAnswer((_) => mockFilterBuilder);
    when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) => mockFilterBuilder);
    when(() => mockFilterBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
  }

  group('SupabaseProfilesRepository -', () {
    test('smoke test', () {
      expect(true, isTrue);
    });

    group('getCurrentUserProfile', () {
      test('should return Success with UserProfile when user is authenticated',
          () async {
        // Arrange
        setUpMocks();
        const userId = 'user-123';
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn(userId);
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final profileData = {
          'id': userId,
          'display_name': 'Test User',
          'role': 'player',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        when(() => mockFilterBuilder.eq('id', userId))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.single()).thenAnswer((_) => FakePostgrestTransformBuilder(profileData));

        // Act
        final result = await repository.getCurrentUserProfile();

        // Assert
        expect(result, isA<Success>());
        expect(result.isSuccess, isTrue);
        final profile = (result as Success).data;
        expect(profile.userId, userId);
        expect(profile.displayName, 'Test User');
      });

      test('should return Failed with AuthFailure when no user authenticated',
          () async {
        // Arrange
        setUpMocks();
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await repository.getCurrentUserProfile();

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, contains('No authenticated user'));
      });
    });

    group('getProfileById', () {
      const userId = 'user-456';

      test('should return Success with UserProfile when profile exists',
          () async {
        // Arrange
        setUpMocks();
        final profileData = {
          'id': userId,
          'display_name': 'Another User',
          'role': 'coach',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        when(() => mockClient.from('profiles')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockFilterBuilder.eq('id', userId))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.single()).thenAnswer((_) => FakePostgrestTransformBuilder(profileData));

        // Act
        final result = await repository.getProfileById(userId);

        // Assert
        expect(result, isA<Success>());
        final profile = (result as Success).data;
        expect(profile.userId, userId);
        expect(profile.displayName, 'Another User');
        expect(profile.role.value, 'coach');
      });

      test('should return Failed with NotFoundFailure when profile not found',
          () async {
        // Arrange
        setUpMocks();
        final exception = PostgrestException(
          message: 'Profile not found',
          code: 'PGRST116',
        );

        when(() => mockFilterBuilder.eq('id', userId))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.single()).thenThrow(exception);

        // Act
        final result = await repository.getProfileById(userId);

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<NotFoundFailure>());
        expect(failure.message, contains('Profile not found'));
      });

      test('should return Failed with ServerFailure on PostgrestException',
          () async {
        // Arrange
        setUpMocks();
        final exception = PostgrestException(
          message: 'Database error',
          code: '500',
        );

        when(() => mockClient.from('profiles')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockFilterBuilder.eq('id', userId))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.single()).thenThrow(exception);

        // Act
        final result = await repository.getProfileById(userId);

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<ServerFailure>());
      });
    });

    group('updateProfile', () {
      const userId = 'user-789';
      const newDisplayName = 'Updated Name';

      test('should return Success with updated UserProfile', () async {
        // Arrange
        setUpMocks();
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn(userId);
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final updatedData = {
          'id': userId,
          'display_name': newDisplayName,
          'role': 'player',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        when(() => mockFilterBuilder.eq('id', userId))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.single()).thenAnswer((_) => FakePostgrestTransformBuilder(updatedData));

        // Act
        final result = await repository.updateProfile(displayName: newDisplayName);

        // Assert
        expect(result, isA<Success>());
        final profile = (result as Success).data;
        expect(profile.displayName, newDisplayName);
        verify(() => mockQueryBuilder.update(any(
              that: predicate<Map<String, dynamic>>((map) {
                return map['display_name'] == newDisplayName &&
                    map.containsKey('updated_at');
              }),
            ))).called(1);
      });

      test('should return Failed when no user authenticated', () async {
        // Arrange
        setUpMocks();
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await repository.updateProfile(displayName: newDisplayName);

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<AuthFailure>());
      });

      test('should trim display name before update', () async {
        // Arrange
        setUpMocks();
        const nameWithSpaces = '  Updated Name  ';
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn(userId);
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final updatedData = {
          'id': userId,
          'display_name': newDisplayName,
          'role': 'player',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        when(() => mockFilterBuilder.eq('id', userId))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.single()).thenAnswer((_) => FakePostgrestTransformBuilder(updatedData));

        // Act
        await repository.updateProfile(displayName: nameWithSpaces);

        // Assert
        verify(() => mockQueryBuilder.update(any(
              that: predicate<Map<String, dynamic>>((map) {
                return map['display_name'] == newDisplayName;
              }),
            ))).called(1);
      });
    });

    group('createProfile', () {
      const userId = 'new-user-123';
      const displayName = 'New User';
      const role = 'player';

      test('should return Success with created UserProfile', () async {
        // Arrange
        setUpMocks();
        final createdData = {
          'id': userId,
          'display_name': displayName,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        when(() => mockFilterBuilder.single()).thenAnswer((_) => FakePostgrestTransformBuilder(createdData));

        // Act
        final result = await repository.createProfile(
          userId: userId,
          displayName: displayName,
          role: role,
        );

        // Assert
        expect(result, isA<Success>());
        final profile = (result as Success).data;
        expect(profile.userId, userId);
        expect(profile.displayName, displayName);
        verify(() => mockQueryBuilder.insert(any(
              that: predicate<Map<String, dynamic>>((map) {
                return map['id'] == userId &&
                    map['display_name'] == displayName &&
                    map['role'] == role &&
                    map.containsKey('created_at') &&
                    map.containsKey('updated_at');
              }),
            ))).called(1);
      });

      test('should return Failed on PostgrestException', () async {
        // Arrange
        setUpMocks();
        final exception = PostgrestException(
          message: 'Duplicate key violation',
          code: '23505',
        );

        when(() => mockFilterBuilder.single()).thenThrow(exception);

        // Act
        final result = await repository.createProfile(
          userId: userId,
          displayName: displayName,
          role: role,
        );

        // Assert
        expect(result, isA<Failed>());
        final failure = (result as Failed).failure;
        expect(failure, isA<ServerFailure>());
      });

      test('should trim display name before create', () async {
        // Arrange
        setUpMocks();
        const nameWithSpaces = '  New User  ';
        final createdData = {
          'id': userId,
          'display_name': displayName,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        when(() => mockFilterBuilder.single()).thenAnswer((_) => FakePostgrestTransformBuilder(createdData));

        // Act
        await repository.createProfile(
          userId: userId,
          displayName: nameWithSpaces,
          role: role,
        );

        // Assert
        verify(() => mockQueryBuilder.insert(any(
              that: predicate<Map<String, dynamic>>((map) {
                return map['display_name'] == displayName;
              }),
            ))).called(1);
      });
    });
  });
}
