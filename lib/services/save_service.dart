import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_progress.dart';

class SaveService {
  static const String _keyPlayerProgress = 'apex_velocity_player_progress_v1';
  static const String _keySoundVolume = 'apex_sound_volume';
  static const String _keyMusicVolume = 'apex_music_volume';
  static const String _keyControlMode = 'apex_control_mode';

  static Future<PlayerProgress> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_keyPlayerProgress);
      if (data != null && data.isNotEmpty) {
        return PlayerProgress.fromJsonString(data);
      }
    } catch (e) {
      // Fallback to default
    }
    return const PlayerProgress();
  }

  static Future<void> saveProgress(PlayerProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPlayerProgress, progress.toJsonString());
    } catch (_) {}
  }

  static Future<double> getSoundVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keySoundVolume) ?? 0.8;
  }

  static Future<void> setSoundVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySoundVolume, volume);
  }

  static Future<double> getMusicVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMusicVolume) ?? 0.7;
  }

  static Future<void> setMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMusicVolume, volume);
  }

  static Future<String> getControlMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyControlMode) ?? 'touch_buttons';
  }

  static Future<void> setControlMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyControlMode, mode);
  }
}
