import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import '../../models/meditation_session.dart';
import '../../models/session_history.dart';
import '../../services/audio_service.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final MeditationSession session;
  final VoidCallback onClose;
  final Function(MeditationSession session, int completedDurationSeconds) onCompleted;

  const PlayerScreen({
    super.key,
    required this.session,
    required this.onClose,
    required this.onCompleted,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  final AudioPlayerService _audioService = AudioPlayerService.instance;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now().toUtc();
    _totalDuration = Duration(seconds: widget.session.durationSeconds);
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (widget.session.audioSource.startsWith('assets/')) {
        await _audioService.playAsset(widget.session.audioSource);
      } else {
        await _audioService.playFilePath(widget.session.audioSource);
      }

      _positionSubscription = _audioService.player.positionStream.listen((pos) {
        if (mounted) {
          setState(() {
            _position = pos;
          });
        }
      });

      _playerStateSubscription = _audioService.player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });

          if (state.processingState == ProcessingState.completed) {
            _onSessionCompleted();
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _onSessionCompleted() async {
    final completedAt = DateTime.now().toUtc();
    final actualDuration = _position.inSeconds > 0 ? _position.inSeconds : widget.session.durationSeconds;

    final history = SessionHistory(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: widget.session.id,
      startedAt: _startedAt.toIso8601String(),
      completedAt: completedAt.toIso8601String(),
      actualDurationSeconds: actualDuration,
      status: SessionStatus.completed,
      sessionType: SessionType.guidedMeditation,
    );

    await ref.read(historyNotifierProvider.notifier).addHistoryRecord(history);
    await _audioService.stop();

    if (mounted) {
      widget.onCompleted(widget.session, actualDuration);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioService.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favorites = ref.watch(favoritesNotifierProvider);
    final isFav = favorites.contains(widget.session.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: widget.onClose,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : null,
            ),
            onPressed: () {
              ref.read(favoritesNotifierProvider.notifier).toggleFavorite(widget.session.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(),
              // Artwork / Illustration
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.primarySage.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.self_improvement,
                  size: 100,
                  color: AppColors.deepForest,
                ),
              ),
              const SizedBox(height: 36),

              // Title & Description
              Text(
                widget.session.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.session.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              if (_hasError) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Unable to play audio. Sample file might be missing or unreadable.',
                    style: TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Progress slider
              Slider(
                value: _position.inSeconds.toDouble().clamp(0.0, _totalDuration.inSeconds.toDouble()),
                max: _totalDuration.inSeconds > 0 ? _totalDuration.inSeconds.toDouble() : 1.0,
                onChanged: (value) {
                  final newPos = Duration(seconds: value.toInt());
                  setState(() => _position = newPos);
                  _audioService.seek(newPos);
                },
                activeColor: AppColors.primarySage,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_position)),
                    Text(_formatDuration(_totalDuration)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.replay_10),
                    onPressed: () {
                      final newPos = _position - const Duration(seconds: 10);
                      _audioService.seek(newPos < Duration.zero ? Duration.zero : newPos);
                    },
                  ),
                  const SizedBox(width: 24),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: AppColors.deepForest,
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(18.0),
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : IconButton(
                            iconSize: 36,
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (_isPlaying) {
                                _audioService.pause();
                              } else {
                                _audioService.resume();
                              }
                            },
                          ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.forward_10),
                    onPressed: () {
                      final newPos = _position + const Duration(seconds: 10);
                      _audioService.seek(newPos > _totalDuration ? _totalDuration : newPos);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
