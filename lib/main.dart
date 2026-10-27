import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/providers.dart';
import 'features/breathing/breathing_screen.dart';
import 'features/completion/completion_screen.dart';
import 'features/explore/explore_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/player/player_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'models/meditation_session.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: FindYourCalmApp(),
    ),
  );
}

class FindYourCalmApp extends ConsumerWidget {
  const FindYourCalmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    ThemeMode mode;
    if (settings.themeMode == 'light') {
      mode = ThemeMode.light;
    } else if (settings.themeMode == 'dark') {
      mode = ThemeMode.dark;
    } else {
      mode = ThemeMode.system;
    }

    return MaterialApp(
      title: 'Find Your Calm',
      debugShowCheckedModeBanner: false,
      theme: AppColors.lightTheme,
      darkTheme: AppColors.darkTheme,
      themeMode: mode,
      home: const MainAppFlowContainer(),
    );
  }
}

class MainAppFlowContainer extends ConsumerStatefulWidget {
  const MainAppFlowContainer({super.key});

  @override
  ConsumerState<MainAppFlowContainer> createState() => _MainAppFlowContainerState();
}

enum AppStateMode {
  splash,
  onboarding,
  mainNav,
  player,
  breathing,
  completion,
}

class _MainAppFlowContainerState extends ConsumerState<MainAppFlowContainer> {
  AppStateMode _currentMode = AppStateMode.splash;
  int _currentTabIndex = 0;

  MeditationSession? _activeSession;
  String? _exploreInitialCategoryId;

  // Completion data
  String _completedTitle = '';
  int _completedDurationSeconds = 0;
  MeditationSession? _completedSession;

  void _onSplashInitialized() {
    final settings = ref.read(settingsNotifierProvider);
    if (!settings.onboardingCompleted) {
      setState(() {
        _currentMode = AppStateMode.onboarding;
      });
    } else {
      setState(() {
        _currentMode = AppStateMode.mainNav;
      });
    }
  }

  void _onOnboardingFinished() {
    setState(() {
      _currentMode = AppStateMode.mainNav;
    });
  }

  void _openPlayer(MeditationSession session) {
    setState(() {
      _activeSession = session;
      _currentMode = AppStateMode.player;
    });
  }

  void _openBreathing() {
    setState(() {
      _currentMode = AppStateMode.breathing;
    });
  }

  void _onSessionCompleted(MeditationSession session, int durationSeconds) {
    setState(() {
      _completedSession = session;
      _completedTitle = session.title;
      _completedDurationSeconds = durationSeconds;
      _currentMode = AppStateMode.completion;
    });
  }

  void _onBreathingCompleted(String title, int durationSeconds) {
    setState(() {
      _completedSession = null;
      _completedTitle = title;
      _completedDurationSeconds = durationSeconds;
      _currentMode = AppStateMode.completion;
    });
  }

  void _returnHome() {
    setState(() {
      _currentMode = AppStateMode.mainNav;
      _currentTabIndex = 0;
    });
  }

  void _selectCategoryInExplore(String categoryId) {
    setState(() {
      _exploreInitialCategoryId = categoryId;
      _currentTabIndex = 1; // Explore tab
      _currentMode = AppStateMode.mainNav;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentMode) {
      case AppStateMode.splash:
        return SplashScreen(onInitialized: _onSplashInitialized);

      case AppStateMode.onboarding:
        return OnboardingScreen(onOnboardingCompleted: _onOnboardingFinished);

      case AppStateMode.player:
        if (_activeSession == null) {
          return const SizedBox.shrink();
        }
        return PlayerScreen(
          session: _activeSession!,
          onClose: () {
            setState(() {
              _currentMode = AppStateMode.mainNav;
            });
          },
          onCompleted: _onSessionCompleted,
        );

      case AppStateMode.breathing:
        return BreathingScreen(
          onClose: () {
            setState(() {
              _currentMode = AppStateMode.mainNav;
            });
          },
          onCompleted: _onBreathingCompleted,
        );

      case AppStateMode.completion:
        return CompletionScreen(
          session: _completedSession,
          title: _completedTitle,
          durationSeconds: _completedDurationSeconds,
          onReturnHome: _returnHome,
        );

      case AppStateMode.mainNav:
        return Scaffold(
          body: IndexedStack(
            index: _currentTabIndex,
            children: [
              HomeScreen(
                onSelectSession: _openPlayer,
                onStartBreathing: _openBreathing,
                onSelectCategory: _selectCategoryInExplore,
                onOpenSettings: () {
                  setState(() {
                    _currentTabIndex = 3; // Settings tab
                  });
                },
              ),
              ExploreScreen(
                initialCategoryId: _exploreInitialCategoryId,
                onSelectSession: _openPlayer,
                onStartBreathing: _openBreathing,
              ),
              const ProgressScreen(),
              const SettingsScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insert_chart_outlined),
                activeIcon: Icon(Icons.insert_chart),
                label: 'Progress',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
    }
  }
}
