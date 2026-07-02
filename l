import 'package:audioplayers/audioplayers.dart';

/// Central audio manager for Ludi.
/// Handles SFX (short sounds) and BGM (looping background music).
/// Both can be toggled independently via [setSfxEnabled] / [setBgmEnabled].
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _sfxEnabled = true;
  bool _bgmEnabled = true;

  AudioPlayer? _bgmPlayer;
  bool _bgmPlaying = false;

  bool get sfxEnabled => _sfxEnabled;
  bool get bgmEnabled => _bgmEnabled;

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  void setBgmEnabled(bool enabled) {
    _bgmEnabled = enabled;
    if (enabled) {
      startBgm();
    } else {
      stopBgm();
    }
  }

  void _play(String assetPath, {double volume = 0.5}) async {
    if (!_sfxEnabled) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(volume);
      await player.play(AssetSource(assetPath));
      Future.delayed(const Duration(milliseconds: 800), () {
        player.dispose();
      });
    } catch (_) {}
  }

  Future<void> playTap() => _play('audio/tap.wav', volume: 0.3);
  Future<void> playCorrect() => _play('audio/correct.wav', volume: 0.4);
  Future<void> playWrong() => _play('audio/wrong.wav', volume: 0.4);
  Future<void> playAchievement() => _play('audio/achievement.wav', volume: 0.5);
  Future<void> playStageComplete() => _play('audio/stage_complete.wav', volume: 0.5);
  Future<void> playTileClick() => _play('audio/tile_click.wav', volume: 0.3);

  // ── BGM ──
  void startBgm() {
    if (!_bgmEnabled || _bgmPlaying) return;
    _bgmPlayer ??= AudioPlayer();
    _bgmPlaying = true;
    try {
      _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      _bgmPlayer!.setVolume(0.15);
      _bgmPlayer!.play(AssetSource('audio/bgm.wav'));
    } catch (_) {
      _bgmPlaying = false;
    }
  }

  void stopBgm() {
    _bgmPlaying = false;
    _bgmPlayer?.stop();
  }

  void dispose() {
    _bgmPlayer?.dispose();
    _bgmPlayer = null;
  }
}
