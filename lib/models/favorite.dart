class Favorite {
  final String sessionId;
  final String createdAt;

  const Favorite({
    required this.sessionId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'createdAt': createdAt,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      sessionId: map['sessionId'] as String,
      createdAt: map['createdAt'] as String,
    );
  }
}
