enum SessionStatus {
  completed,
  interrupted,
  abandoned;

  static SessionStatus fromString(String status) {
    return SessionStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => SessionStatus.completed,
    );
  }
}

enum SessionType {
  guidedMeditation('guided_meditation'),
  breathingExercise('breathing_exercise');

  final String value;
  const SessionType(this.value);

  static SessionType fromString(String type) {
    return SessionType.values.firstWhere(
      (e) => e.value == type || e.name == type,
      orElse: () => SessionType.guidedMeditation,
    );
  }
}

class SessionHistory {
  final String id;
  final String sessionId;
  final String startedAt;
  final String completedAt;
  final int actualDurationSeconds;
  final SessionStatus status;
  final SessionType sessionType;

  const SessionHistory({
    required this.id,
    required this.sessionId,
    required this.startedAt,
    required this.completedAt,
    required this.actualDurationSeconds,
    required this.status,
    required this.sessionType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'actualDurationSeconds': actualDurationSeconds,
      'status': status.name,
      'sessionType': sessionType.value,
    };
  }

  factory SessionHistory.fromMap(Map<String, dynamic> map) {
    return SessionHistory(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      startedAt: map['startedAt'] as String,
      completedAt: map['completedAt'] as String,
      actualDurationSeconds: (map['actualDurationSeconds'] as num).toInt(),
      status: SessionStatus.fromString(map['status'] as String),
      sessionType: SessionType.fromString(map['sessionType'] as String),
    );
  }
}
