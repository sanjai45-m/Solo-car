import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'save_service.dart';
import 'soundtrack_generator.dart';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _enginePlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  double _soundVolume = 0.8;
  double _musicVolume = 0.6;
  bool _isMusicPlaying = false;

  final Map<String, Uint8List> _trackCache = {};
  int _currentTrackIndex = 0;

  List<GameTrack> get playlist => GameTrack.allTracks;
  GameTrack get currentTrack => GameTrack.allTracks[_currentTrackIndex];
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

      // Pre-synthesize default high-energy PS2/Tamil track
      _trackCache[currentTrack.id] = SoundtrackGenerator.generateTrack(currentTrack.id);

      if (_musicVolume > 0.05) {
        playTrack(currentTrack);
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
    notifyListeners();
  }

  void setMusicVolume(double vol) {
    _musicVolume = vol.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
    SaveService.setMusicVolume(_musicVolume);
    if (_musicVolume > 0.05 && !_isMusicPlaying) {
      playTrack(currentTrack);
    } else if (_musicVolume <= 0.01) {
      _musicPlayer.stop();
      _isMusicPlaying = false;
    }
    notifyListeners();
  }

  /// Plays a specific soundtrack track
  Future<void> playTrack(GameTrack track) async {
    final index = GameTrack.allTracks.indexWhere((t) => t.id == track.id);
    if (index != -1) {
      _currentTrackIndex = index;
    }

    if (_musicVolume <= 0.01) {
      _isMusicPlaying = false;
      notifyListeners();
      return;
    }

    try {
      if (!_trackCache.containsKey(track.id)) {
        _trackCache[track.id] = SoundtrackGenerator.generateTrack(track.id);
      }
      final wavData = _trackCache[track.id]!;

      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play(BytesSource(wavData));
      _isMusicPlaying = true;
      debugPrint('🎵 Now Playing: ${track.title} (${track.genre})');
      notifyListeners();
    } catch (e) {
      debugPrint('Track play exception: $e');
    }
  }

  /// Skip to next track in playlist
  void nextTrack() {
    _currentTrackIndex = (_currentTrackIndex + 1) % GameTrack.allTracks.length;
    playTrack(GameTrack.allTracks[_currentTrackIndex]);
  }

  /// Skip to previous track in playlist
  void previousTrack() {
    _currentTrackIndex = (_currentTrackIndex - 1 + GameTrack.allTracks.length) % GameTrack.allTracks.length;
    playTrack(GameTrack.allTracks[_currentTrackIndex]);
  }

  /// Toggle Play / Pause
  Future<void> togglePlayPause() async {
    if (_isMusicPlaying) {
      await _musicPlayer.pause();
      _isMusicPlaying = false;
    } else {
      if (_musicVolume <= 0.05) {
        setMusicVolume(0.6);
      }
      await playTrack(currentTrack);
    }
    notifyListeners();
  }

  /// Legacy methods for menu & race
  Future<void> playMenuMusic() async => playTrack(currentTrack);
  Future<void> playRaceMusic() async {
    // If on default menu synth, switch to high-octane race theme or keep playing user selected song
    if (currentTrack.id == 'neon_nightdrive') {
      playTrack(GameTrack.allTracks.firstWhere((t) => t.id == 'ps2_smackdown_machi'));
    }
  }

  /// Tactical 3D Button Click Feedback
  Future<void> playButtonClick() async {
    if (_soundVolume <= 0.05) return;
    try {
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
    } catch (_) {}
  }
}
