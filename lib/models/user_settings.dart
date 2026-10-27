class UserSettings {
  final String themeMode; // 'light', 'dark', 'system'
  final int defaultDurationMinutes; // 3, 5, 10
  final bool reminderEnabled;
  final String reminderTime; // 'HH:mm' format
  final String? preferredCategoryId;
  final bool breathingSoundEnabled;
  final bool onboardingCompleted;

  const UserSettings({
    this.themeMode = 'system',
    this.defaultDurationMinutes = 5,
    this.reminderEnabled = false,
    this.reminderTime = '20:00',
    this.preferredCategoryId,
    this.breathingSoundEnabled = true,
    this.onboardingCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode,
      'defaultDurationMinutes': defaultDurationMinutes,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderTime': reminderTime,
      'preferredCategoryId': preferredCategoryId,
      'breathingSoundEnabled': breathingSoundEnabled ? 1 : 0,
      'onboardingCompleted': onboardingCompleted ? 1 : 0,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      themeMode: (map['themeMode'] as String?) ?? 'system',
      defaultDurationMinutes: (map['defaultDurationMinutes'] as num?)?.toInt() ?? 5,
      reminderEnabled: (map['reminderEnabled'] as num?) == 1,
      reminderTime: (map['reminderTime'] as String?) ?? '20:00',
      preferredCategoryId: map['preferredCategoryId'] as String?,
      breathingSoundEnabled: (map['breathingSoundEnabled'] as num?) == 1,
      onboardingCompleted: (map['onboardingCompleted'] as num?) == 1,
    );
  }

  UserSettings copyWith({
    String? themeMode,
    int? defaultDurationMinutes,
    bool? reminderEnabled,
    String? reminderTime,
    String? preferredCategoryId,
    bool? breathingSoundEnabled,
    bool? onboardingCompleted,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultDurationMinutes: defaultDurationMinutes ?? this.defaultDurationMinutes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      preferredCategoryId: preferredCategoryId ?? this.preferredCategoryId,
      breathingSoundEnabled: breathingSoundEnabled ?? this.breathingSoundEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
