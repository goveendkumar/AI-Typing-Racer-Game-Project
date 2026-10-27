import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:find_your_calm/data/database/database_helper.dart';
import 'package:find_your_calm/models/session_history.dart';
import 'package:find_your_calm/models/user_settings.dart';

void main() {
  sqfliteFfiInit();

  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  group('DatabaseHelper Tests', () {
    test('Initial database seeding creates categories and sessions', () async {
      final dbHelper = DatabaseHelper.instance;
      final categories = await dbHelper.getCategories();
      final sessions = await dbHelper.getSessions();

      expect(categories.length, equals(6));
      expect(sessions.length, equals(6));

      expect(categories.first.name, equals('Beginner Meditation'));
      expect(sessions.first.title, equals('Morning Clarity'));
    });

    test('Favorite add and remove works correctly', () async {
      final dbHelper = DatabaseHelper.instance;
      const sessionId = 'session_morning_clarity';

      expect(await dbHelper.isFavorite(sessionId), isFalse);

      await dbHelper.addFavorite(sessionId);
      expect(await dbHelper.isFavorite(sessionId), isTrue);

      final favorites = await dbHelper.getFavoriteSessionIds();
      expect(favorites.contains(sessionId), isTrue);

      await dbHelper.removeFavorite(sessionId);
      expect(await dbHelper.isFavorite(sessionId), isFalse);
    });

    test('Session history operations work correctly', () async {
      final dbHelper = DatabaseHelper.instance;

      final history = SessionHistory(
        id: 'hist_1',
        sessionId: 'session_morning_clarity',
        startedAt: DateTime.now().toUtc().toIso8601String(),
        completedAt: DateTime.now().toUtc().toIso8601String(),
        actualDurationSeconds: 180,
        status: SessionStatus.completed,
        sessionType: SessionType.guidedMeditation,
      );

      await dbHelper.addHistory(history);

      final historyList = await dbHelper.getHistory();
      expect(historyList.length, equals(1));
      expect(historyList.first.sessionId, equals('session_morning_clarity'));
      expect(historyList.first.actualDurationSeconds, equals(180));
    });

    test('User settings update and persistence works', () async {
      final dbHelper = DatabaseHelper.instance;
      final initialSettings = await dbHelper.getUserSettings();

      final updatedSettings = initialSettings.copyWith(
        themeMode: 'dark',
        defaultDurationMinutes: 10,
        onboardingCompleted: true,
      );

      await dbHelper.updateUserSettings(updatedSettings);

      final retrievedSettings = await dbHelper.getUserSettings();
      expect(retrievedSettings.themeMode, equals('dark'));
      expect(retrievedSettings.defaultDurationMinutes, equals(10));
      expect(retrievedSettings.onboardingCompleted, isTrue);
    });
  });
}
