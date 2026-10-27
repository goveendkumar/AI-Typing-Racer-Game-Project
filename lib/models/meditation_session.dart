class MeditationSession {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final int durationSeconds;
  final String audioSource;
  final String artworkPath;
  final String transcript;
  final bool isDownloadable;

  const MeditationSession({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.audioSource,
    required this.artworkPath,
    required this.transcript,
    this.isDownloadable = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'durationSeconds': durationSeconds,
      'audioSource': audioSource,
      'artworkPath': artworkPath,
      'transcript': transcript,
      'isDownloadable': isDownloadable ? 1 : 0,
    };
  }

  factory MeditationSession.fromMap(Map<String, dynamic> map) {
    return MeditationSession(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      durationSeconds: (map['durationSeconds'] as num).toInt(),
      audioSource: map['audioSource'] as String,
      artworkPath: map['artworkPath'] as String,
      transcript: map['transcript'] as String,
      isDownloadable: (map['isDownloadable'] as num) == 1,
    );
  }

  MeditationSession copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? description,
    int? durationSeconds,
    String? audioSource,
    String? artworkPath,
    String? transcript,
    bool? isDownloadable,
  }) {
    return MeditationSession(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioSource: audioSource ?? this.audioSource,
      artworkPath: artworkPath ?? this.artworkPath,
      transcript: transcript ?? this.transcript,
      isDownloadable: isDownloadable ?? this.isDownloadable,
    );
  }
}
