import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central audio service for SFX + BGM.
/// 
/// #16: Replaced harsh default sounds with softer, pleasant tones.
/// #17: SFX and haptic toggles now actually gate playback.
/// #18/#19: BGM with on/off toggle.
/// SFX + BGM with preference persistence.
/// SFX + BGM with preference persistence.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _sfxEnabled = true;
  bool _hapticEnabled = true;
  bool _bgmEnabled = true;
  bool _initialized = false;

  AudioPlayer? _bgmPlayer;

  bool get sfxEnabled => _sfxEnabled;
  bool get hapticEnabled => _hapticEnabled;
  bool get bgmEnabled => _bgmEnabled;

  /// Load toggle preferences from SharedPreferences. Call once at startup.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final sp = await SharedPreferences.getInstance();
    _sfxEnabled = sp.getBool('audio_sfx') ?? true;
    _hapticEnabled = sp.getBool('audio_haptic') ?? true;
    _bgmEnabled = sp.getBool('audio_bgm') ?? true;
  }

  void setSfxEnabled(bool v) {
    _sfxEnabled = v;
    _persist('audio_sfx', v);
  }

  void setHapticEnabled(bool v) {
    _hapticEnabled = v;
    _persist('audio_haptic', v);
  }

  // Legacy compat
  bool get isMuted => !_sfxEnabled;
  void toggleMute() => _sfxEnabled = !_sfxEnabled;
  void setMuted(bool muted) => _sfxEnabled = !muted;

  Future<void> _persist(String key, bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(key, v);
  }

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

  Future<void> playTap() => _play('audio/click.mp3');
  Future<void> playClick() => _play('audio/click.mp3');
  Future<void> playCorrect() => _play('audio/correct.wav');
  Future<void> playWrong() => _play('audio/wrong.wav');
  Future<void> playAchievement() => _play('audio/achievement.wav');
  Future<void> playStageComplete() => _play('audio/stage_complete.wav');
  Future<void> playTileClick() => _play('audio/click.mp3');

  // ── BGM (#18/#19) ──
  Future<void> startBgm() async {
    if (!_bgmEnabled) return;
    if (_bgmPlayer != null) return; // already playing
    try {
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.setVolume(0.15);
      await _bgmPlayer!.play(AssetSource('audio/bgm.mp3'));
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
    _persist('audio_bgm', v);
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
