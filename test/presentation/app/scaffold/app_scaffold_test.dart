// test/presentation/app/scaffold/app_scaffold_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/locale/locale_provider.dart';
import 'package:sport_tech_app/config/theme/theme_provider.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/domain/auth/entities/auth_user.dart';
import 'package:sport_tech_app/domain/profiles/entities/user_profile.dart';
import 'package:sport_tech_app/presentation/app/scaffold/app_scaffold.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

// Mock classes
class MockAuthNotifier extends Mock implements AuthNotifier {}

class MockLocaleNotifier extends Mock implements LocaleNotifier {}

class MockThemeModeNotifier extends StateNotifier<ThemeMode>
    with Mock
    implements ThemeModeNotifier {
  MockThemeModeNotifier() : super(ThemeMode.light);
}

void main() {
  late MockAuthNotifier mockAuthNotifier;
  late MockLocaleNotifier mockLocaleNotifier;
  late MockThemeModeNotifier mockThemeModeNotifier;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    mockLocaleNotifier = MockLocaleNotifier();
    mockThemeModeNotifier = MockThemeModeNotifier();
  });

  Widget createTestWidget({
    required AuthState authState,
    Size? size,
  }) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
        localeProvider.overrideWith((ref) => mockLocaleNotifier),
        themeModeProvider.overrideWith((ref) => mockThemeModeNotifier),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('es', ''),
        ],
        home: MediaQuery(
          data: MediaQueryData(size: size ?? const Size(400, 800)),
          child: const AppScaffold(
            child: Center(child: Text('Test Content')),
          ),
        ),
      ),
    );
  }

  UserProfile createTestProfile(UserRole role) {
    return UserProfile(
      id: 'user-123',
      displayName: 'Test User',
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('AppScaffold Widget Tests -', () {
    group('Navigation by role -', () {
      testWidgets('should show only player navigation for player role',
          (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'player@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act
        await tester.pumpWidget(createTestWidget(authState: authState));

        // Assert - Should have Dashboard, Evaluaciones, Notes, Profile
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('My Evaluations'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
        // Should NOT have Coach or Super Admin
        expect(find.text('Coach'), findsNothing);
        expect(find.text('Super Admin'), findsNothing);
      });

      testWidgets('should show coach panel for coach role', (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-456',
            email: 'coach@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.coach),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act
        await tester.pumpWidget(createTestWidget(authState: authState));

        // Assert - Should have Dashboard, Coach, Evaluaciones, Notes, Profile
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Coach'), findsOneWidget);
        expect(find.text('My Evaluations'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
        // Should NOT have Super Admin
        expect(find.text('Super Admin'), findsNothing);
      });

      testWidgets('should show all panels for super admin role', (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-789',
            email: 'admin@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.superAdmin),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act
        await tester.pumpWidget(createTestWidget(authState: authState));

        // Assert - Should have all navigation items
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Coach'), findsOneWidget);
        expect(find.text('Super Admin'), findsOneWidget);
        expect(find.text('My Evaluations'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
      });

      testWidgets('should show admin panel for admin role', (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-999',
            email: 'clubadmin@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.admin),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act
        await tester.pumpWidget(createTestWidget(authState: authState));

        // Assert - Should have Dashboard, Coach, Evaluaciones, Notes, Profile
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Coach'), findsOneWidget);
        expect(find.text('My Evaluations'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
        // Should have Super Admin (since admin.isSuperAdmin is true)
        expect(find.text('Super Admin'), findsOneWidget);
      });
    });

    group('Layout variations -', () {
      testWidgets('should show NavigationRail on wide screens', (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act - Wide screen (>= 640px)
        await tester.pumpWidget(
          createTestWidget(
            authState: authState,
            size: const Size(800, 600),
          ),
        );

        // Assert
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(AppBar), findsNothing);
      });

      testWidgets('should show NavigationBar and AppBar on mobile',
          (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act - Mobile screen (< 640px)
        await tester.pumpWidget(
          createTestWidget(
            authState: authState,
            size: const Size(375, 667),
          ),
        );

        // Assert
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      });
    });

    group('Action buttons -', () {
      testWidgets('should have language toggle button', (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act
        await tester.pumpWidget(createTestWidget(authState: authState));

        // Assert
        expect(find.byIcon(Icons.language_outlined), findsOneWidget);
      });

      testWidgets('should have theme toggle button', (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act
        await tester.pumpWidget(createTestWidget(authState: authState));

        // Assert
        expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
      });

      testWidgets('should have logout button', (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act
        await tester.pumpWidget(createTestWidget(authState: authState));

        // Assert
        expect(find.byIcon(Icons.logout_outlined), findsOneWidget);
      });

      testWidgets('should call toggleLocale when language button tapped',
          (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);
        when(() => mockLocaleNotifier.toggleLocale())
            .thenAnswer((_) async => {});

        await tester.pumpWidget(createTestWidget(authState: authState));

        // Act
        final languageButton = find.byIcon(Icons.language_outlined);
        await tester.tap(languageButton);
        await tester.pump();

        // Assert
        verify(() => mockLocaleNotifier.toggleLocale()).called(1);
      });

      testWidgets('should call toggle when theme button tapped', (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);
        when(() => mockThemeModeNotifier.toggle()).thenReturn(null);

        await tester.pumpWidget(createTestWidget(authState: authState));

        // Act
        final themeButton = find.byIcon(Icons.dark_mode_outlined);
        await tester.tap(themeButton);
        await tester.pump();

        // Assert
        verify(() => mockThemeModeNotifier.toggle()).called(1);
      });

      testWidgets('should call signOut when logout button tapped',
          (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);
        when(() => mockAuthNotifier.signOut()).thenAnswer((_) async => {});

        await tester.pumpWidget(createTestWidget(authState: authState));

        // Act
        final logoutButton = find.byIcon(Icons.logout_outlined);
        await tester.tap(logoutButton);
        await tester.pump();

        // Assert
        verify(() => mockAuthNotifier.signOut()).called(1);
      });
    });

    group('Content rendering -', () {
      testWidgets('should render child content', (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act
        await tester.pumpWidget(createTestWidget(authState: authState));

        // Assert
        expect(find.text('Test Content'), findsOneWidget);
      });

      testWidgets('should show app icon in navigation rail', (tester) async {
        // Arrange
        final authState = AuthStateAuthenticated(
          user: AuthUser(
            id: 'user-123',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          ),
          profile: createTestProfile(UserRole.player),
        );

        when(() => mockAuthNotifier.build()).thenReturn(authState);
        when(() => mockLocaleNotifier.build()).thenReturn(null);
        when(() => mockThemeModeNotifier.build()).thenReturn(ThemeMode.light);

        // Act - Wide screen
        await tester.pumpWidget(
          createTestWidget(
            authState: authState,
            size: const Size(800, 600),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
      });
    });
  });
}
