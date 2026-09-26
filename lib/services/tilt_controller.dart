import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum SteeringControlMode { touch, tilt, auto }

class TiltController {
  static final TiltController _instance = TiltController._internal();
  factory TiltController() => _instance;
  TiltController._internal();

  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  bool isTiltEnabled = true;
  bool isSensorAvailable = false;
  double _rawSteering = 0.0;
  double _smoothSteering = 0.0;

  // Configuration
  double deadZone = 0.08;
  double sensitivity = 1.35;
  double smoothingFactor = 0.25;

  double get currentSteering => isTiltEnabled && isSensorAvailable ? _smoothSteering : 0.0;

  void init({bool isTest = false}) {
    if (isTest || kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      isSensorAvailable = false;
      return;
    }

    try {
      _accelSubscription?.cancel();
      _accelSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          isSensorAvailable = true;
          // In Landscape orientation:
          // Tilting phone left/right corresponds to accelerometer Y-axis
          final tiltY = event.y; // Positive = tilt right, Negative = tilt left

          // Normalize: 0 to ~7 m/s^2 maps to 0.0 to 1.0
          double normalized = (tiltY / 6.0) * sensitivity;

          // Apply deadzone
          if (normalized.abs() < deadZone) {
            normalized = 0.0;
          } else {
            normalized = (normalized.sign * (normalized.abs() - deadZone) / (1.0 - deadZone)).clamp(-1.0, 1.0);
          }

          _rawSteering = normalized;
          // Exponential moving average for smooth steering
          _smoothSteering += (_rawSteering - _smoothSteering) * smoothingFactor;
        },
        onError: (e) {
          isSensorAvailable = false;
        },
        cancelOnError: true,
      );
    } catch (e) {
      isSensorAvailable = false;
    }
  }

  void setTiltEnabled(bool enabled) {
    isTiltEnabled = enabled;
  }

  void dispose() {
    _accelSubscription?.cancel();
    _accelSubscription = null;
  }
}
