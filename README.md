# Find Your Calm - Guided Meditation App

Find Your Calm is a complete, beginner-friendly, offline-first guided meditation and mindfulness mobile application built for Android and iOS using Flutter and Dart.

---

## Key Features

- **Offline-First Architecture**: All core features, local SQLite database, sample audio sessions, and progress tracking work completely offline without external backend requirements.
- **Splash & Onboarding**: Smooth splash screen and a 3-step onboarding flow allowing users to set default meditation session length preferences (3, 5, or 10 minutes) with skip & back options.
- **Home Hub**: Displays time-based greetings, daily featured meditation recommendation, quick breathing break launcher, category cards, and continue listening history.
- **Explore & Search Library**: Offline search by title or description, category filtering (6 categories), duration filtering (<5m, 5-10m, >10m), favorites filter, and title/duration sorting.
- **Guided Meditation Player**: Reliable audio player built on `just_audio` with play, pause, resume, seek slider, ±10 second skips, progress position, favorite toggle, and completion triggers.
- **Interactive Breathing Exercise**: Animated expanding and contracting circle driven by customizable timers (1, 3, 5, 10 min), step instructions (Inhale deeply / Exhale slowly), gentle chime sound cues, and full pause/resume/stop controls.
- **Session Completion**: Celebration screen showing actual time completed, status logging, and return home navigation.
- **Progress & Statistics**: Displays total meditation minutes, total completed sessions, today's sessions, weekly total minutes, a visual 7-day activity bar chart, and detailed session history log.
- **Settings & Theme Customization**: Supports Light Mode, Dark Mode, and System Default themes using configurable nature-inspired palette tokens (Primary Sage `#829985`, Deep Forest `#304C3B`, Soft Cream `#F7F5EE`, etc.). Includes preference toggles, local history clearance, and Privacy & Wellbeing disclosures.

---

## Architecture & Project Structure

Organized into clean, testable layers using **Flutter Riverpod** and **SQLite (`sqflite`)**:

```text
lib/
├── main.dart                      # Application entry point & theme state container
├── core/
│   ├── theme/
│   │   └── app_theme.dart         # Color tokens, Light & Dark ThemeData configurations
├── models/
│   ├── category.dart              # Category data model
│   ├── favorite.dart              # Favorite entity data model
│   ├── meditation_session.dart    # Meditation session data model
│   ├── session_history.dart       # History log & status enums
│   └── user_settings.dart         # Settings model (theme, duration, audio toggles)
├── data/
│   ├── database/
│   │   └── database_helper.dart   # SQLite database schema, indexes & queries
│   ├── seed/
│   │   └── seed_data.dart         # Pre-seeded categories and meditation content
│   └── repositories/
│       └── providers.dart         # Riverpod state notifiers & repository providers
├── services/
│   └── audio_service.dart         # Singleton wrapping just_audio player
├── features/
│   ├── splash/                    # Animated splash screen
│   ├── onboarding/                # 3-screen onboarding sequence
│   ├── home/                      # Home dashboard & daily recommendations
│   ├── explore/                   # Library search, filter & sort screen
│   ├── player/                    # Audio playback interface
│   ├── breathing/                 # Interactive animated breathwork screen
│   ├── completion/                # Session completion screen
│   ├── progress/                  # Statistics & 7-day activity chart screen
│   └── settings/                  # App preferences & storage management
└── shared/
    └── widgets/
        └── reusable_widgets.dart  # CalmButton, SectionHeader, SessionCard, EmptyStateWidget
```

---

## Replacing Sample Audio Assets

The project includes pre-packaged WAV audio files located in `assets/audio/`.

To replace sample audio with production recordings:
1. Place your licensed `.mp3` or `.wav` files into the `assets/audio/` directory.
2. Update the `audioSource` path field in `lib/data/seed/seed_data.dart`:
   ```dart
   MeditationSession(
     id: 'session_morning_clarity',
     categoryId: 'cat_beginner',
     title: 'Morning Clarity',
     description: 'Start your morning with a gentle 3-minute breath check-in.',
     durationSeconds: 180,
     audioSource: 'assets/audio/your_custom_recording.mp3',
     artworkPath: 'assets/images/morning_clarity.png',
     transcript: '...',
   ),
   ```
3. If necessary, add any new audio file paths to the `assets:` declaration in `pubspec.yaml`.

---

## How to Run & Build

### Prerequisites
- Flutter SDK (3.11.0 or higher recommended)
- Android SDK / Xcode for target devices

### Dependency Setup
```bash
flutter pub get
```

### Running Tests
```bash
flutter test
```

### Static Analysis
```bash
flutter analyze
```

### Running the Application
- **Android**:
  ```bash
  flutter run -d android
  ```
- **iOS**:
  ```bash
  flutter run -d ios
  ```

### Build Release Packages
- **Android APK**:
  ```bash
  flutter build apk --release
  ```
- **Android App Bundle (AAB)**:
  ```bash
  flutter build appbundle --release
  ```
- **iOS IPA**:
  ```bash
  flutter build ipa --release
  ```

---

## Troubleshooting

- **Database Issues on Desktop/Testing**: Unit and widget tests utilize `sqflite_common_ffi` initialized with `sqfliteFfiInit()` to run SQLite in desktop/CI environments.
- **Audio Loading Failure**: Ensure audio asset files exist at the relative path declared in `pubspec.yaml`. If an audio asset fails to load, `PlayerScreen` safely displays an inline warning banner without crashing the application.
