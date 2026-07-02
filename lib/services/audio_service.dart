import 'package:audioplayers/audioplayers.dart';

/// Central audio service for SFX + BGM.
/// 
/// #16: Replaced harsh default sounds with softer, pleasant tones.
/// #17: SFX and haptic toggles now actually gate playback.
/// #18/#19: BGM with on/off toggle.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _sfxEnabled = true;
  bool _hapticEnabled = true;
  bool _bgmEnabled = true;

  AudioPlayer? _bgmPlayer;

  bool get sfxEnabled => _sfxEnabled;
  bool get hapticEnabled => _hapticEnabled;
  bool get bgmEnabled => _bgmEnabled;

  void setSfxEnabled(bool v) {
    _sfxEnabled = v;
  }

  void setHapticEnabled(bool v) {
    _hapticEnabled = v;
  }

  // Legacy compat
  bool get isMuted => !_sfxEnabled;
  void toggleMute() => _sfxEnabled = !_sfxEnabled;
  void setMuted(bool muted) => _sfxEnabled = !muted;

  Future<void> _play(String assetPath) async {
    if (!_sfxEnabled) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(0.4);
      await player.play(AssetSource(assetPath));
      Future.delayed(const Duration(milliseconds: 800), () {
        player.dispose();
      });
    } catch (_) {}
  }

  Future<void> playTap() => _play('audio/tap.wav');
  Future<void> playCorrect() => _play('audio/correct.wav');
  Future<void> playWrong() => _play('audio/wrong.wav');
  Future<void> playAchievement() => _play('audio/achievement.wav');
  Future<void> playStageComplete() => _play('audio/stage_complete.wav');
  Future<void> playTileClick() => _play('audio/tile_click.wav');

  // ── BGM (#18/#19) ──
  Future<void> startBgm() async {
    if (!_bgmEnabled) return;
    if (_bgmPlayer != null) return; // already playing
    try {
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.setVolume(0.15);
      await _bgmPlayer!.play(AssetSource('audio/bgm.wav'));
    } catch (_) {
      _bgmPlayer = null;
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer?.stop();
    await _bgmPlayer?.dispose();
    _bgmPlayer = null;
  }

  void setBgmEnabled(bool v) {
    _bgmEnabled = v;
    if (!v) {
      stopBgm();
    } else {
      startBgm();
    }
  }

  void dispose() {
    stopBgm();
  }
}
