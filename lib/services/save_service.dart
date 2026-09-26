import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_progress.dart';

class SaveService {
  static const String _keySoundVolume = 'apex_sound_volume';
  static const String _keyMusicVolume = 'apex_music_volume';
  static const String _keyControlMode = 'apex_control_mode';

  static String _keyForUser(String? uid) {
    final clean = uid?.trim();
    if (clean == null || clean.isEmpty) return 'apex_player_progress_guest';
    return 'apex_player_progress_$clean';
  }

  /// Loads locally cached progress strictly for the given user UID
  static Future<PlayerProgress> loadProgress({String? uid}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyForUser(uid);
      final data = prefs.getString(key);
      if (data != null && data.isNotEmpty) {
        return PlayerProgress.fromJsonString(data);
      }
    } catch (_) {
      // Fallback to fresh defaults
    }
    return const PlayerProgress();
  }

  /// Saves local progress strictly for the given user UID
  static Future<void> saveProgress(PlayerProgress progress, {String? uid}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyForUser(uid);
      await prefs.setString(key, progress.toJsonString());
    } catch (_) {}
  }

  /// Clears local storage strictly for a given user UID (e.g. on cache purge)
  static Future<void> clearUserProgress(String? uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyForUser(uid);
      await prefs.remove(key);
    } catch (_) {}
  }

  /// Clears active guest / session caches on logout to prevent data residue
  static Future<void> clearActiveGuestSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('apex_player_progress_guest');
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
