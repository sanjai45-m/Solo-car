import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'save_service.dart';
import 'soundtrack_generator.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _enginePlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  double _soundVolume = 0.8;
  double _musicVolume = 0.6;
  bool _isMusicPlaying = false;
  String _currentTheme = '';

  Uint8List? _cachedMenuMusic;
  Uint8List? _cachedRaceMusic;

  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;
  bool get isMusicPlaying => _isMusicPlaying;

  Future<void> init() async {
    try {
      _soundVolume = await SaveService.getSoundVolume();
      _musicVolume = await SaveService.getMusicVolume();

      await _sfxPlayer.setVolume(_soundVolume);
      await _enginePlayer.setVolume(_soundVolume * 0.5);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);

      // Pre-synthesize background music
      _cachedMenuMusic ??= SoundtrackGenerator.generateMenuSoundtrack();

      // Start menu music automatically if volume is enabled
      if (_musicVolume > 0.05) {
        playMenuMusic();
      }
    } catch (e) {
      debugPrint('AudioService init fallback: $e');
    }
  }

  void setSoundVolume(double vol) {
    _soundVolume = vol.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_soundVolume);
    _enginePlayer.setVolume(_soundVolume * 0.5);
    SaveService.setSoundVolume(_soundVolume);
  }

  void setMusicVolume(double vol) {
    _musicVolume = vol.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
    SaveService.setMusicVolume(_musicVolume);
    if (_musicVolume > 0.05 && !_isMusicPlaying) {
      playMenuMusic();
    } else if (_musicVolume <= 0.01) {
      _musicPlayer.stop();
      _isMusicPlaying = false;
    }
  }

  /// Plays the custom generated Synthwave Menu Soundtrack ("Neon Nightdrive")
  Future<void> playMenuMusic() async {
    if (_musicVolume <= 0.01 || _currentTheme == 'menu' && _isMusicPlaying) return;
    try {
      _cachedMenuMusic ??= SoundtrackGenerator.generateMenuSoundtrack();
      _currentTheme = 'menu';
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play(BytesSource(_cachedMenuMusic!));
      _isMusicPlaying = true;
      debugPrint('🎵 Apex Synthwave Menu Soundtrack Playing!');
    } catch (e) {
      debugPrint('Menu music play note: $e');
    }
  }

  /// Plays the high-octane procedural Race Soundtrack ("Apex Overdrive")
  Future<void> playRaceMusic() async {
    if (_musicVolume <= 0.01 || _currentTheme == 'race' && _isMusicPlaying) return;
    try {
      _cachedRaceMusic ??= SoundtrackGenerator.generateRaceSoundtrack();
      _currentTheme = 'race';
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play(BytesSource(_cachedRaceMusic!));
      _isMusicPlaying = true;
      debugPrint('🏁 Apex Overdrive Race Music Playing!');
    } catch (e) {
      debugPrint('Race music play note: $e');
    }
  }

  /// Tactical 3D Button Click Feedback
  Future<void> playButtonClick() async {
    if (_soundVolume <= 0.05) return;
    try {
      // Immediate responsive click
      await _sfxPlayer.setVolume(_soundVolume * 0.8);
    } catch (_) {}
  }

  Future<void> playCountdownBeep({bool isFinal = false}) async {
    if (_soundVolume <= 0.05) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume);
    } catch (_) {}
  }

  Future<void> playNitroSound() async {
    if (_soundVolume <= 0.05) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume);
    } catch (_) {}
  }

  Future<void> playCrashSound({double severity = 1.0}) async {
    if (_soundVolume <= 0.05) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume);
    } catch (_) {}
  }

  Future<void> playDriftScreech() async {
    if (_soundVolume <= 0.05) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume * 0.7);
    } catch (_) {}
  }

  Future<void> playNearMissSound() async {
    if (_soundVolume <= 0.05) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume * 0.9);
    } catch (_) {}
  }

  Future<void> playFinishCheer() async {
    if (_soundVolume <= 0.05) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume);
    } catch (_) {}
  }

  void updateEnginePitch(double speedRatio) {
    if (_soundVolume <= 0) return;
    final playbackRate = (0.7 + speedRatio * 1.5).clamp(0.5, 2.0);
    try {
      _enginePlayer.setPlaybackRate(playbackRate);
    } catch (_) {}
  }

  void stopAll() {
    try {
      _sfxPlayer.stop();
      _enginePlayer.stop();
      _musicPlayer.stop();
      _isMusicPlaying = false;
      _currentTheme = '';
    } catch (_) {}
  }
}
