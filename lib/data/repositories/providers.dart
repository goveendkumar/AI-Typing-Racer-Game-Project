import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../models/meditation_session.dart';
import '../../models/session_history.dart';
import '../../models/user_settings.dart';
import '../database/database_helper.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final dbHelper = ref.watch(databaseHelperProvider);
  return await dbHelper.getCategories();
});

final sessionsProvider = FutureProvider<List<MeditationSession>>((ref) async {
  final dbHelper = ref.watch(databaseHelperProvider);
  return await dbHelper.getSessions();
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  final DatabaseHelper _dbHelper;

  FavoritesNotifier(this._dbHelper) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favorites = await _dbHelper.getFavoriteSessionIds();
    state = favorites;
  }

  Future<void> toggleFavorite(String sessionId) async {
    if (state.contains(sessionId)) {
      await _dbHelper.removeFavorite(sessionId);
      state = state.where((id) => id != sessionId).toList();
    } else {
      await _dbHelper.addFavorite(sessionId);
      state = [...state, sessionId];
    }
  }

  bool isFavorite(String sessionId) {
    return state.contains(sessionId);
  }
}

final favoritesNotifierProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return FavoritesNotifier(dbHelper);
});

class HistoryNotifier extends StateNotifier<List<SessionHistory>> {
  final DatabaseHelper _dbHelper;

  HistoryNotifier(this._dbHelper) : super([]) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final history = await _dbHelper.getHistory();
    state = history;
  }

  Future<void> addHistoryRecord(SessionHistory historyRecord) async {
    await _dbHelper.addHistory(historyRecord);
    await loadHistory();
  }

  Future<void> clearHistoryRecords() async {
    await _dbHelper.clearHistory();
    state = [];
  }
}

final historyNotifierProvider = StateNotifierProvider<HistoryNotifier, List<SessionHistory>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return HistoryNotifier(dbHelper);
});

class SettingsNotifier extends StateNotifier<UserSettings> {
  final DatabaseHelper _dbHelper;

  SettingsNotifier(this._dbHelper) : super(const UserSettings()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final settings = await _dbHelper.getUserSettings();
    state = settings;
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    await _dbHelper.updateUserSettings(newSettings);
    state = newSettings;
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SettingsNotifier(dbHelper);
});
