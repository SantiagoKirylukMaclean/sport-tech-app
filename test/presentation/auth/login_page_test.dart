// test/presentation/auth/login_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/presentation/auth/pages/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Mock classes
class MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  late MockAuthNotifier mockAuthNotifier;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
  });

  Widget createTestWidget(AuthState authState) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
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
        home: const LoginPage(),
      ),
    );
  }

  group('LoginPage Widget Tests -', () {
    testWidgets('should render all form fields and buttons', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());

      // Act
      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Assert
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
      expect(find.text('Sport Tech'), findsOneWidget);
      expect(find.text('Team Sport Management'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('should show email validation error when email is empty',
        (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());

      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Act
      // Find and tap login button without entering email
      final loginButton = find.widgetWithText(FilledButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should show email validation error when email is invalid',
        (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());

      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Act
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');

      final loginButton = find.widgetWithText(FilledButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show password validation error when password is empty',
        (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());

      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Act
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final loginButton = find.widgetWithText(FilledButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should show password validation error when password is too short',
        (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());

      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Act
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, '12345');

      final loginButton = find.widgetWithText(FilledButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should call signIn when form is valid and login button tapped',
        (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());
      when(() => mockAuthNotifier.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Act
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      final loginButton = find.widgetWithText(FilledButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      verify(() => mockAuthNotifier.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('should show loading indicator when state is loading',
        (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthStateLoading());

      // Act
      await tester.pumpWidget(createTestWidget(const AuthStateLoading()));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });

    testWidgets('should disable form fields when state is loading',
        (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthStateLoading());

      await tester.pumpWidget(createTestWidget(const AuthStateLoading()));

      // Act
      final emailField =
          tester.widget<TextFormField>(find.byType(TextFormField).first);
      final passwordField =
          tester.widget<TextFormField>(find.byType(TextFormField).last);

      // Assert
      expect(emailField.enabled, isFalse);
      expect(passwordField.enabled, isFalse);
    });

    testWidgets('should toggle password visibility when icon tapped',
        (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());

      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Act - Initial state should be obscured
      TextFormField passwordField =
          tester.widget<TextFormField>(find.byType(TextFormField).last);
      expect(passwordField.obscureText, isTrue);

      // Tap visibility toggle
      final visibilityIcon = find.byIcon(Icons.visibility_outlined);
      await tester.tap(visibilityIcon);
      await tester.pump();

      // Assert - Should now be visible
      passwordField =
          tester.widget<TextFormField>(find.byType(TextFormField).last);
      expect(passwordField.obscureText, isFalse);

      // Tap again to hide
      final visibilityOffIcon = find.byIcon(Icons.visibility_off_outlined);
      await tester.tap(visibilityOffIcon);
      await tester.pump();

      // Assert - Should be obscured again
      passwordField =
          tester.widget<TextFormField>(find.byType(TextFormField).last);
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('should show snackbar message for forgot password',
        (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());

      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Act
      final forgotPasswordButton =
          find.widgetWithText(TextButton, 'Forgot password?');
      await tester.tap(forgotPasswordButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('Forgot password feature coming soon'), findsOneWidget);
    });

    testWidgets('should trim email before validation and submission',
        (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());
      when(() => mockAuthNotifier.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Act
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, '  test@example.com  ');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      final loginButton = find.widgetWithText(FilledButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert - email should be trimmed
      verify(() => mockAuthNotifier.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('should have correct accessibility labels', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());

      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Assert
      final emailField =
          tester.widget<TextFormField>(find.byType(TextFormField).first);
      expect(emailField.decoration?.labelText, equals('Email'));
      expect(emailField.decoration?.hintText, equals('Enter your email'));

      final passwordField =
          tester.widget<TextFormField>(find.byType(TextFormField).last);
      expect(passwordField.decoration?.labelText, equals('Password'));
      expect(passwordField.decoration?.hintText, equals('Enter your password'));
    });

    testWidgets('should have appropriate keyboard types', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.build()).thenReturn(const AuthStateInitial());

      await tester.pumpWidget(createTestWidget(const AuthStateInitial()));

      // Assert
      final emailField =
          tester.widget<TextFormField>(find.byType(TextFormField).first);
      expect(emailField.keyboardType, equals(TextInputType.emailAddress));

      final passwordField =
          tester.widget<TextFormField>(find.byType(TextFormField).last);
      expect(passwordField.obscureText, isTrue);
    });
  });
}
