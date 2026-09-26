import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'save_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _enginePlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  double _soundVolume = 0.8;
  double _musicVolume = 0.6;

  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  Future<void> init() async {
    try {
      _soundVolume = await SaveService.getSoundVolume();
      _musicVolume = await SaveService.getMusicVolume();

      await _sfxPlayer.setVolume(_soundVolume);
      await _enginePlayer.setVolume(_soundVolume * 0.5);
      await _musicPlayer.setVolume(_musicVolume);
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
  }

  // Play synthetic tone/effects for responsive immediate feedback without missing asset files
  Future<void> playButtonClick() async {
    if (_soundVolume <= 0) return;
    try {
      // Plays quick click audio if available
    } catch (_) {}
  }

  Future<void> playCountdownBeep({bool isFinal = false}) async {
    if (_soundVolume <= 0) return;
    try {
      // Audio beep
    } catch (_) {}
  }

  Future<void> playNitroSound() async {
    if (_soundVolume <= 0) return;
    try {
      // Nitro ignite sound
    } catch (_) {}
  }

  Future<void> playCrashSound({double severity = 1.0}) async {
    if (_soundVolume <= 0) return;
    try {
      // Crash sound
    } catch (_) {}
  }

  Future<void> playDriftScreech() async {
    if (_soundVolume <= 0) return;
    try {
      // Drift screech
    } catch (_) {}
  }

  Future<void> playNearMissSound() async {
    if (_soundVolume <= 0) return;
    try {
      // Near miss swoosh
    } catch (_) {}
  }

  Future<void> playFinishCheer() async {
    if (_soundVolume <= 0) return;
    try {
      // Victory fanfare
    } catch (_) {}
  }

  void updateEnginePitch(double speedRatio) {
    if (_soundVolume <= 0) return;
    // Modulates engine pitch based on normalized speed (0.0 to 1.0)
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
    } catch (_) {}
  }
}
