import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  // Preloaded cache
  final Map<String, AudioPlayer> _cache = {};

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  void setMuted(bool muted) {
    _isMuted = muted;
  }

  Future<void> _play(String assetPath) async {
    if (_isMuted) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource(assetPath));
      // Release after short sound plays
      Future.delayed(const Duration(milliseconds: 800), () {
        player.dispose();
      });
    } catch (_) {
      // Silently ignore audio errors
    }
  }

  Future<void> playTap() => _play('audio/tap.wav');
  Future<void> playCorrect() => _play('audio/correct.wav');
  Future<void> playWrong() => _play('audio/wrong.wav');
  Future<void> playAchievement() => _play('audio/achievement.wav');
  Future<void> playStageComplete() => _play('audio/stage_complete.wav');
  Future<void> playTileClick() => _play('audio/tile_click.wav');

  void dispose() {
    _player.dispose();
    for (final p in _cache.values) {
      p.dispose();
    }
    _cache.clear();
  }
}
