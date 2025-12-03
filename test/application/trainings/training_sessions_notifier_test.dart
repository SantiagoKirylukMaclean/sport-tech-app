import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport_tech_app/application/trainings/training_sessions_notifier.dart';
import 'package:sport_tech_app/domain/trainings/entities/training_session.dart';
import 'package:sport_tech_app/domain/trainings/repositories/training_sessions_repository.dart';

class MockTrainingSessionsRepository extends Mock
    implements TrainingSessionsRepository {}

void main() {
  late MockTrainingSessionsRepository mockRepository;
  late TrainingSessionsNotifier notifier;

  setUp(() {
    mockRepository = MockTrainingSessionsRepository();
    notifier = TrainingSessionsNotifier(mockRepository);
  });

  group('TrainingSessionsNotifier', () {
    test('initial state is empty and not loading', () {
      expect(notifier.state.sessions, isEmpty);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, null);
    });

    test('loadSessions updates state with sessions', () async {
      // Arrange
      final sessions = [
        TrainingSession(
          id: 'session-1',
          teamId: 'team-1',
          sessionDate: DateTime(2024, 1, 15, 18, 0),
          notes: 'Test session',
          createdAt: DateTime(2024, 1, 10),
        ),
      ];

      when(() => mockRepository.getByTeamId('team-1'))
          .thenAnswer((_) async => sessions);

      // Act
      await notifier.loadSessions('team-1');

      // Assert
      expect(notifier.state.sessions, sessions);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, null);
    });

    test('loadSessions sets error on failure', () async {
      // Arrange
      when(() => mockRepository.getByTeamId('team-1'))
          .thenThrow(Exception('Failed to load'));

      // Act
      await notifier.loadSessions('team-1');

      // Assert
      expect(notifier.state.sessions, isEmpty);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNotNull);
    });

    test('createSession adds new session to state', () async {
      // Arrange
      final newSession = TrainingSession(
        id: 'session-new',
        teamId: 'team-1',
        sessionDate: DateTime(2024, 1, 20, 18, 0),
        notes: 'New session',
        createdAt: DateTime(2024, 1, 20),
      );

      when(() => mockRepository.create(
            teamId: 'team-1',
            sessionDate: any(named: 'sessionDate'),
            notes: 'New session',
          )).thenAnswer((_) async => newSession);

      // Act
      await notifier.createSession(
        teamId: 'team-1',
        sessionDate: DateTime(2024, 1, 20, 18, 0),
        notes: 'New session',
      );

      // Assert
      expect(notifier.state.sessions, contains(newSession));
    });

    test('deleteSession removes session from state', () async {
      // Arrange
      final session = TrainingSession(
        id: 'session-1',
        teamId: 'team-1',
        sessionDate: DateTime(2024, 1, 15, 18, 0),
        createdAt: DateTime(2024, 1, 10),
      );

      notifier.state = notifier.state.copyWith(sessions: [session]);

      when(() => mockRepository.delete('session-1'))
          .thenAnswer((_) async => {});

      // Act
      await notifier.deleteSession('session-1');

      // Assert
      expect(notifier.state.sessions, isEmpty);
    });
  });
}
