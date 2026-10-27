import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/category.dart';
import '../../models/favorite.dart';
import '../../models/meditation_session.dart';
import '../../models/session_history.dart';
import '../../models/user_settings.dart';
import '../seed/seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('find_your_calm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const categoryTable = '''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        sortOrder INTEGER NOT NULL
      )
    ''';

    const sessionTable = '''
      CREATE TABLE meditation_sessions (
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL,
        audioSource TEXT NOT NULL,
        artworkPath TEXT NOT NULL,
        transcript TEXT NOT NULL,
        isDownloadable INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''';

    const favoriteTable = '''
      CREATE TABLE favorites (
        sessionId TEXT PRIMARY KEY,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES meditation_sessions (id) ON DELETE CASCADE
      )
    ''';

    const historyTable = '''
      CREATE TABLE session_history (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        startedAt TEXT NOT NULL,
        completedAt TEXT NOT NULL,
        actualDurationSeconds INTEGER NOT NULL,
        status TEXT NOT NULL,
        sessionType TEXT NOT NULL
      )
    ''';

    const settingsTable = '''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        themeMode TEXT NOT NULL DEFAULT 'system',
        defaultDurationMinutes INTEGER NOT NULL DEFAULT 5,
        reminderEnabled INTEGER NOT NULL DEFAULT 0,
        reminderTime TEXT NOT NULL DEFAULT '20:00',
        preferredCategoryId TEXT,
        breathingSoundEnabled INTEGER NOT NULL DEFAULT 1,
        onboardingCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''';

    await db.execute(categoryTable);
    await db.execute(sessionTable);
    await db.execute(favoriteTable);
    await db.execute(historyTable);
    await db.execute(settingsTable);

    // Create indexes
    await db.execute('CREATE INDEX idx_sessions_category ON meditation_sessions(categoryId)');
    await db.execute('CREATE INDEX idx_history_completed ON session_history(completedAt)');

    // Seed initial categories
    for (final category in SeedData.categories) {
      await db.insert('categories', category.toMap());
    }

    // Seed initial sessions
    for (final session in SeedData.sessions) {
      await db.insert('meditation_sessions', session.toMap());
    }

    // Seed default user settings
    await db.insert('user_settings', const UserSettings().toMap()..['id'] = 1);
  }

  // --- Category Methods ---
  Future<List<Category>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', orderBy: 'sortOrder ASC');
    return result.map((json) => Category.fromMap(json)).toList();
  }

  // --- Meditation Session Methods ---
  Future<List<MeditationSession>> getSessions() async {
    final db = await instance.database;
    final result = await db.query('meditation_sessions');
    return result.map((json) => MeditationSession.fromMap(json)).toList();
  }

  Future<MeditationSession?> getSessionById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'meditation_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return MeditationSession.fromMap(result.first);
    }
    return null;
  }

  Future<List<MeditationSession>> getSessionsByCategory(String categoryId) async {
    final db = await instance.database;
    final result = await db.query(
      'meditation_sessions',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return result.map((json) => MeditationSession.fromMap(json)).toList();
  }

  // --- Favorite Methods ---
  Future<List<String>> getFavoriteSessionIds() async {
    final db = await instance.database;
    final result = await db.query('favorites', orderBy: 'createdAt DESC');
    return result.map((json) => json['sessionId'] as String).toList();
  }

  Future<bool> isFavorite(String sessionId) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
    return result.isNotEmpty;
  }

  Future<void> addFavorite(String sessionId) async {
    final db = await instance.database;
    final favorite = Favorite(
      sessionId: sessionId,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    await db.insert(
      'favorites',
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(String sessionId) async {
    final db = await instance.database;
    await db.delete(
      'favorites',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
  }

  // --- Session History Methods ---
  Future<void> addHistory(SessionHistory history) async {
    final db = await instance.database;
    await db.insert(
      'session_history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SessionHistory>> getHistory() async {
    final db = await instance.database;
    final result = await db.query('session_history', orderBy: 'completedAt DESC');
    return result.map((json) => SessionHistory.fromMap(json)).toList();
  }

  // --- User Settings Methods ---
  Future<UserSettings> getUserSettings() async {
    final db = await instance.database;
    final result = await db.query('user_settings', where: 'id = 1');
    if (result.isNotEmpty) {
      return UserSettings.fromMap(result.first);
    }
    return const UserSettings();
  }

  Future<void> updateUserSettings(UserSettings settings) async {
    final db = await instance.database;
    final map = settings.toMap()..['id'] = 1;
    await db.update(
      'user_settings',
      map,
      where: 'id = 1',
    );
  }

  Future<void> clearHistory() async {
    final db = await instance.database;
    await db.delete('session_history');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
