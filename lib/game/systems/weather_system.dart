import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum WeatherType {
  clearNight,
  rain,
  thunderstorm,
  cyberFog,
}

class RainDrop {
  double x;
  double y;
  double length;
  double speed;
  double opacity;

  RainDrop({
    required this.x,
    required this.y,
    required this.length,
    required this.speed,
    required this.opacity,
  });
}

class WeatherSystem extends Component {
  WeatherType currentWeather;
  final math.Random _random = math.Random();

  final List<RainDrop> _rainDrops = [];
  double _lightningTimer = 0.0;
  double _lightningAlpha = 0.0;
  double _fogPulseTimer = 0.0;
  double _windAngle = 0.15; // Radians slant

  WeatherSystem({this.currentWeather = WeatherType.clearNight}) {
    _initRainDrops();
  }

  void _initRainDrops() {
    _rainDrops.clear();
    final count = currentWeather == WeatherType.thunderstorm
        ? 220
        : (currentWeather == WeatherType.rain ? 120 : 0);

    for (int i = 0; i < count; i++) {
      _rainDrops.add(
        RainDrop(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          length: 12.0 + _random.nextDouble() * 18.0,
          speed: 1.2 + _random.nextDouble() * 1.5,
          opacity: 0.25 + _random.nextDouble() * 0.55,
        ),
      );
    }
  }

  void setWeather(WeatherType type) {
    currentWeather = type;
    _initRainDrops();
  }

  double get tractionMultiplier {
    switch (currentWeather) {
      case WeatherType.clearNight:
        return 1.0;
      case WeatherType.cyberFog:
        return 0.92;
      case WeatherType.rain:
        return 0.82;
      case WeatherType.thunderstorm:
        return 0.70;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 1. Update rain particle coordinates
    if (currentWeather == WeatherType.rain || currentWeather == WeatherType.thunderstorm) {
      for (final drop in _rainDrops) {
        drop.y += drop.speed * dt * 2.2;
        drop.x += _windAngle * drop.speed * dt * 0.8;

        if (drop.y > 1.0) {
          drop.y = -0.05;
          drop.x = _random.nextDouble();
        }
        if (drop.x > 1.0) drop.x = 0.0;
        if (drop.x < 0.0) drop.x = 1.0;
      }
    }

    // 2. Thunderstorm Lightning Strike Generator
    if (currentWeather == WeatherType.thunderstorm) {
      _lightningTimer += dt;
      if (_lightningTimer > 4.5 + _random.nextDouble() * 6.0) {
        _lightningTimer = 0.0;
        _lightningAlpha = 0.85; // Flash flash
      }
    }

    if (_lightningAlpha > 0.0) {
      _lightningAlpha = math.max(0.0, _lightningAlpha - 4.5 * dt);
    }

    // 3. Cyber Fog Pulsing
    if (currentWeather == WeatherType.cyberFog) {
      _fogPulseTimer += dt;
    }
  }

  /// Renders weather overlay directly onto the game viewport
  void renderWeather(Canvas canvas, Size screenSize) {
    if (screenSize.width <= 0 || screenSize.height <= 0) return;

    // A. Rain Particles
    if (currentWeather == WeatherType.rain || currentWeather == WeatherType.thunderstorm) {
      final rainPaint = Paint()
        ..color = const Color(0xFF80D8FF)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;

      for (final drop in _rainDrops) {
        final startX = drop.x * screenSize.width;
        final startY = drop.y * screenSize.height;
        final endX = startX + math.sin(_windAngle) * drop.length;
        final endY = startY + math.cos(_windAngle) * drop.length;

        rainPaint.color = Color.fromRGBO(179, 229, 252, drop.opacity);
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rainPaint);
      }

      // Wet road specular reflection tint
      final wetPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF00E5FF).withValues(alpha: 0.08),
            const Color(0xFF0D47A1).withValues(alpha: 0.15),
          ],
        ).createShader(Rect.fromLTWH(0, screenSize.height * 0.45, screenSize.width, screenSize.height * 0.55));
      canvas.drawRect(Rect.fromLTWH(0, screenSize.height * 0.45, screenSize.width, screenSize.height * 0.55), wetPaint);
    }

    // B. Cyber Fog Overlay
    if (currentWeather == WeatherType.cyberFog) {
      final fogOpacity = 0.18 + math.sin(_fogPulseTimer * 1.5) * 0.06;
      final fogPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: fogOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
      canvas.drawRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height), fogPaint);
    }

    // C. Lightning Flash Screen Glow
    if (_lightningAlpha > 0.01) {
      final flashPaint = Paint()..color = const Color(0xFFE1F5FE).withValues(alpha: _lightningAlpha);
      canvas.drawRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height), flashPaint);
    }
  }
}
