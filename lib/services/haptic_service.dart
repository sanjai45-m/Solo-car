import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool isEnabled = true;

  void setEnabled(bool enabled) {
    isEnabled = enabled;
  }

  void buttonClick() {
    if (!isEnabled || kIsWeb) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  void gearShift() {
    if (!isEnabled || kIsWeb) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  void nearMiss() {
    if (!isEnabled || kIsWeb) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  void nitroBurst() {
    if (!isEnabled || kIsWeb) return;
    try {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 120), () {
        if (isEnabled) HapticFeedback.lightImpact();
      });
    } catch (_) {}
  }

  void collisionHeavy() {
    if (!isEnabled || kIsWeb) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  void alertVibrate() {
    if (!isEnabled || kIsWeb) return;
    try {
      HapticFeedback.vibrate();
    } catch (_) {}
  }
}
