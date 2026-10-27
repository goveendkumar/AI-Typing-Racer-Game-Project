import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import '../../models/session_history.dart';
import '../../services/audio_service.dart';

class BreathingScreen extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final Function(String title, int completedDurationSeconds) onCompleted;

  const BreathingScreen({
    super.key,
    required this.onClose,
    required this.onCompleted,
  });

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _circleAnimation;
  Timer? _countdownTimer;

  int _selectedDurationMinutes = 3;
  int _remainingSeconds = 180;
  int _totalSeconds = 180;
  int _elapsedSeconds = 0;

  bool _isActive = false;
  bool _isPaused = false;
  String _currentInstruction = 'Inhale deeply...';
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4s inhale, 4s exhale cycle
    );

    _circleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (!_isActive || _isPaused) return;

      if (status == AnimationStatus.completed) {
        setState(() {
          _currentInstruction = 'Exhale slowly...';
        });
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _currentInstruction = 'Inhale deeply...';
        });
        _animationController.forward();
      }
    });

    final defaultMins = ref.read(settingsNotifierProvider).defaultDurationMinutes;
    _setDuration(defaultMins);
  }

  void _setDuration(int minutes) {
    if (_isActive) return;
    setState(() {
      _selectedDurationMinutes = minutes;
      _totalSeconds = minutes * 60;
      _remainingSeconds = minutes * 60;
      _elapsedSeconds = 0;
    });
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _isPaused = false;
      _currentInstruction = 'Inhale deeply...';
      _startedAt = DateTime.now().toUtc();
    });

    _animationController.forward(from: 0.0);

    // Play chime sound cue if enabled
    if (ref.read(settingsNotifierProvider).breathingSoundEnabled) {
      AudioPlayerService.instance.playAsset('assets/audio/chime.wav').catchError((_) {});
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isPaused) return;

      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
          _elapsedSeconds++;
        });
      } else {
        _finishBreathing(isCompleted: true);
      }
    });
  }

  void _pauseBreathing() {
    setState(() {
      _isPaused = true;
    });
    _animationController.stop();
  }

  void _resumeBreathing() {
    setState(() {
      _isPaused = false;
    });
    if (_animationController.status == AnimationStatus.reverse) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _finishBreathing({required bool isCompleted}) async {
    _countdownTimer?.cancel();
    _animationController.stop();

    if (isCompleted && _elapsedSeconds > 0) {
      final completedAt = DateTime.now().toUtc();
      final history = SessionHistory(
        id: 'hist_breath_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: 'session_breathing_exercise',
        startedAt: _startedAt.toIso8601String(),
        completedAt: completedAt.toIso8601String(),
        actualDurationSeconds: _elapsedSeconds + 1,
        status: SessionStatus.completed,
        sessionType: SessionType.breathingExercise,
      );

      await ref.read(historyNotifierProvider.notifier).addHistoryRecord(history);

      if (mounted) {
        widget.onCompleted('Guided Breathing Exercise', _elapsedSeconds + 1);
      }
    } else {
      setState(() {
        _isActive = false;
        _isPaused = false;
        _remainingSeconds = _totalSeconds;
        _elapsedSeconds = 0;
        _currentInstruction = 'Ready when you are';
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindful Breathing'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Duration selectors (if not active)
              if (!_isActive) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [1, 3, 5, 10].map((mins) {
                    final isSelected = _selectedDurationMinutes == mins;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text('$mins min'),
                        selected: isSelected,
                        onSelected: (_) => _setDuration(mins),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              const Spacer(),

              // Animated Breathing Circle
              AnimatedBuilder(
                animation: _circleAnimation,
                builder: (context, child) {
                  return Container(
                    width: 240 * _circleAnimation.value,
                    height: 240 * _circleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primarySage.withValues(alpha: 0.6),
                          AppColors.deepForest.withValues(alpha: 0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primarySage.withValues(alpha: 0.3 * _circleAnimation.value),
                          blurRadius: 30 * _circleAnimation.value,
                          spreadRadius: 10 * _circleAnimation.value,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.air,
                        size: 60 * _circleAnimation.value,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Instruction Text
              Text(
                _isActive ? _currentInstruction : 'Prepare your mind and body',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primarySage,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Timer Display
              Text(
                _formatTime(_remainingSeconds),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: isDark ? AppColors.mainTextDark : AppColors.mainTextLight,
                ),
              ),

              const Spacer(),

              // Control Buttons
              if (!_isActive) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: AppColors.deepForest,
                  ),
                  onPressed: _startBreathing,
                  child: const Text('Begin Exercise', style: TextStyle(fontSize: 18)),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        onPressed: () => _finishBreathing(isCompleted: false),
                        child: const Text('Stop'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: AppColors.deepForest,
                        ),
                        onPressed: () {
                          if (_isPaused) {
                            _resumeBreathing();
                          } else {
                            _pauseBreathing();
                          }
                        },
                        child: Text(_isPaused ? 'Resume' : 'Pause'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
