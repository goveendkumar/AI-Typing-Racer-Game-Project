import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final AudioPlayerService instance = AudioPlayerService._internal();
  AudioPlayer? _player;

  AudioPlayerService._internal();

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  Future<void> playAsset(String assetPath) async {
    try {
      await player.setAsset(assetPath);
      await player.play();
    } catch (e) {
      debugPrint('Error loading audio asset: $e');
      rethrow;
    }
  }

  Future<void> playFilePath(String filePath) async {
    try {
      await player.setFilePath(filePath);
      await player.play();
    } catch (e) {
      debugPrint('Error loading audio file: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> resume() async {
    await player.play();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> restart() async {
    await player.seek(Duration.zero);
    await player.play();
  }

  Future<void> stop() async {
    await player.stop();
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
