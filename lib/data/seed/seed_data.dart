import '../../models/category.dart';
import '../../models/meditation_session.dart';

class SeedData {
  static const List<Category> categories = [
    Category(
      id: 'cat_beginner',
      name: 'Beginner Meditation',
      description: 'Simple guided sessions for those starting their mindfulness journey.',
      sortOrder: 1,
    ),
    Category(
      id: 'cat_mindfulness',
      name: 'Mindfulness',
      description: 'Cultivate presence, awareness, and acceptance in daily life.',
      sortOrder: 2,
    ),
    Category(
      id: 'cat_stress',
      name: 'Stress Relief',
      description: 'Release tension, calm your mind, and restore inner peace.',
      sortOrder: 3,
    ),
    Category(
      id: 'cat_focus',
      name: 'Focus and Concentration',
      description: 'Sharpen your attention and clear mental noise.',
      sortOrder: 4,
    ),
    Category(
      id: 'cat_body',
      name: 'Body Relaxation',
      description: 'Connect with your body through gentle scans and relaxation.',
      sortOrder: 5,
    ),
    Category(
      id: 'cat_sleep',
      name: 'Sleep Preparation',
      description: 'Soothing guided practices to help you unwind and rest deeply.',
      sortOrder: 6,
    ),
  ];

  static const List<MeditationSession> sessions = [
    MeditationSession(
      id: 'session_morning_clarity',
      categoryId: 'cat_beginner',
      title: 'Morning Clarity',
      description: 'Start your morning with a gentle 3-minute breath check-in.',
      durationSeconds: 180,
      audioSource: 'assets/audio/morning_clarity.wav',
      artworkPath: 'assets/images/morning_clarity.png',
      transcript: 'Welcome to your morning clarity practice. Sit comfortably, close your eyes softly, and take a deep breath in...',
      isDownloadable: false,
    ),
    MeditationSession(
      id: 'session_breathing_space',
      categoryId: 'cat_mindfulness',
      title: 'Breathing Space',
      description: 'A 5-minute pause to reset your mind and anchor yourself in the present moment.',
      durationSeconds: 300,
      audioSource: 'assets/audio/breathing_space.wav',
      artworkPath: 'assets/images/breathing_space.png',
      transcript: 'Allow yourself to pause. Bring full attention to the physical sensation of breathing...',
      isDownloadable: false,
    ),
    MeditationSession(
      id: 'session_stress_release',
      categoryId: 'cat_stress',
      title: 'Unwind & Let Go',
      description: 'Ease mental stress and release shoulder tension in 5 soothing minutes.',
      durationSeconds: 300,
      audioSource: 'assets/audio/stress_release.wav',
      artworkPath: 'assets/images/stress_release.png',
      transcript: 'Notice where you might be holding tension. As you exhale, imagine that tension melting away...',
      isDownloadable: false,
    ),
    MeditationSession(
      id: 'session_deep_focus',
      categoryId: 'cat_focus',
      title: 'Deep Focus & Flow',
      description: 'A 10-minute session to quiet distractions and cultivate clear concentration.',
      durationSeconds: 600,
      audioSource: 'assets/audio/deep_focus.wav',
      artworkPath: 'assets/images/deep_focus.png',
      transcript: 'Focus your mind on a single point of attention. When thoughts arise, acknowledge them gently and return to the breath...',
      isDownloadable: false,
    ),
    MeditationSession(
      id: 'session_body_scan',
      categoryId: 'cat_body',
      title: 'Gentle Body Scan',
      description: 'Relax from head to toe with a relaxing 7-minute body awareness exercise.',
      durationSeconds: 450,
      audioSource: 'assets/audio/body_scan.wav',
      artworkPath: 'assets/images/body_scan.png',
      transcript: 'Bring your awareness to the top of your head. Slowly move your attention downward...',
      isDownloadable: false,
    ),
    MeditationSession(
      id: 'session_sleep_unwind',
      categoryId: 'cat_sleep',
      title: 'Evening Peace & Unwind',
      description: 'Prepare your mind and body for restorative sleep with gentle audio guidance.',
      durationSeconds: 720,
      audioSource: 'assets/audio/sleep_unwind.wav',
      artworkPath: 'assets/images/sleep_unwind.png',
      transcript: 'Let go of everything that happened today. Tonight is for rest and restoration...',
      isDownloadable: false,
    ),
  ];
}
