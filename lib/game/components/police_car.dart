import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import 'car_base.dart';
import 'player_car.dart';
import 'road_manager.dart';

enum PoliceState { pursuing, ramming, roadblock, spunOut, destroyed }

class PoliceCar extends CarBase {
  final int heatTier;
  final RoadManager roadManager;
  final PlayerCar playerCar;
  final bool isRoadblock;

  PoliceState state = PoliceState.pursuing;
  double strobeTimer = 0.0;
  bool isStrobeRed = true;
  double pitAttemptTimer = 0.0;
  double spinOutTimer = 0.0;
  double hitPoints = 100.0;
  bool isDestroyed = false;

  final math.Random _random = math.Random();

  PoliceCar({
    required super.position,
    required this.heatTier,
    required this.roadManager,
    required this.playerCar,
    this.isRoadblock = false,
  }) : super(
          primaryColor: const Color(0xFF0D131A), // Matte Cyber Black
          neonGlowColor: const Color(0xFF00E5FF),
          stripeColor: const Color(0xFFFFFFFF),
          hasUnderglow: true,
        ) {
    // Tune police interceptor specs according to heat tier
    switch (heatTier) {
      case 1:
        maxSpeed = 260.0 * 32.0;
        accelerationRate = 2200.0;
        hitPoints = 80.0;
        break;
      case 2:
        maxSpeed = 290.0 * 32.0;
        accelerationRate = 2600.0;
        hitPoints = 110.0;
        break;
      case 3:
        maxSpeed = 320.0 * 32.0;
        accelerationRate = 3000.0;
        hitPoints = 140.0;
        break;
      case 4:
        maxSpeed = 350.0 * 32.0;
        accelerationRate = 3400.0;
        hitPoints = 180.0;
        break;
      case 5:
      default:
        maxSpeed = 380.0 * 32.0; // Hyper Interceptor
        accelerationRate = 4000.0;
        hitPoints = 230.0;
        break;
    }

    if (isRoadblock) {
      state = PoliceState.roadblock;
      speed = 40.0 * 32.0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDestroyed) return;

    // Strobe lightbar flashing animation (rapid 12 Hz police pulse)
    strobeTimer += dt;
    if (strobeTimer > 0.08) {
      strobeTimer = 0.0;
      isStrobeRed = !isStrobeRed;
    }

    if (state == PoliceState.spunOut) {
      spinOutTimer -= dt;
      steeringAngle += 12.0 * dt;
      speed = math.max(0, speed - 3000.0 * dt);
      speedKmH = speed / 32.0;
      trackZ += speed * dt;
      if (spinOutTimer <= 0) {
        state = PoliceState.pursuing;
        steeringAngle = 0.0;
      }
      return;
    }

    if (isRoadblock) {
      // Roadblock unit holds defensive lane
      speedKmH = 30.0;
      speed = speedKmH * 32.0;
      trackZ += speed * dt;
      return;
    }

    // AI Pursuit Controller against Player
    final distanceToPlayer = playerCar.trackZ - trackZ;

    // Tactical AI decision
    if (distanceToPlayer < -500.0) {
      // Player is far ahead: police boosts with max interceptor thrust
      isNitroActive = true;
      if (speed < maxSpeed * 1.15) {
        speed += accelerationRate * 1.4 * dt;
      }
    } else if (distanceToPlayer > 300.0) {
      // Police overshot player: brake slightly to stay in combat zone
      isNitroActive = false;
      if (speed > playerCar.speed * 0.9) {
        speed -= brakeForce * 8.0 * dt;
      }
    } else {
      // In combat radius (-500 to +300): match player and perform tactical flanking / ramming
      isNitroActive = false;
      if (speed < playerCar.speed) {
        speed += accelerationRate * dt;
      } else if (speed > playerCar.speed * 1.05) {
        speed -= brakeForce * 3.0 * dt;
      }
    }

    // Lateral Tracking & PIT Maneuvers
    pitAttemptTimer += dt;
    final lateralDelta = playerCar.trackX - trackX;

    if (pitAttemptTimer > 2.0 && distanceToPlayer.abs() < 120.0) {
      // Trigger PIT maneuver ram sideways
      state = PoliceState.ramming;
      trackX += (lateralDelta.sign * 1.8) * dt;
      if (pitAttemptTimer > 3.5) {
        pitAttemptTimer = 0.0;
        state = PoliceState.pursuing;
      }
    } else {
      // Smooth tracking to cut off player line
      final targetX = playerCar.trackX + (heatTier >= 3 ? 0.0 : (_random.nextDouble() - 0.5) * 0.3);
      trackX += (targetX - trackX) * (2.8 * dt).clamp(-1.0, 1.0);
    }

    trackX = trackX.clamp(-0.85, 0.85);
    speedKmH = speed / 32.0;
    trackZ += speed * dt;

    if (trackZ >= roadManager.trackLength && roadManager.trackLength > 0) {
      trackZ -= roadManager.trackLength;
    }
  }

  void takeDamage(double amount) {
    hitPoints -= amount;
    if (hitPoints <= 0 && !isDestroyed) {
      isDestroyed = true;
      state = PoliceState.destroyed;
      AudioService().playExplosionSound();
    } else {
      // Spin out momentarily on heavy hit
      state = PoliceState.spunOut;
      spinOutTimer = 1.2;
    }
  }

  @override
  void render3D(
    Canvas canvas, {
    required double screenX,
    required double screenY,
    required double scale,
    double rollAngle = 0.0,
  }) {
    if (scale <= 0.001 || isDestroyed) return;

    final w = carWidth * scale;
    final h = carHeight * scale;

    canvas.save();
    canvas.translate(screenX, screenY);
    canvas.rotate(rollAngle + (state == PoliceState.spunOut ? steeringAngle : 0.0));

    // Base Car Rendering
    super.render3D(canvas, screenX: 0, screenY: 0, scale: scale, rollAngle: 0);

    // Cyber Police Livery Overlay (White doors & interceptor decals)
    final doorPaint = Paint()..color = const Color(0xFFF0F4F8);
    final doorW = w * 0.16;
    final doorH = h * 0.46;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-w * 0.36, -h * 0.04), width: doorW, height: doorH), const Radius.circular(2)),
      doorPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.36, -h * 0.04), width: doorW, height: doorH), const Radius.circular(2)),
      doorPaint,
    );

    // Push Bumper Bull-Bar on Front / Rear
    final bullBarPaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.0, w * 0.04);
    canvas.drawRect(Rect.fromCenter(center: Offset(0, h * 0.38), width: w * 0.76, height: h * 0.12), bullBarPaint);

    // 3D Rooftop Police LED Strobe Lightbar with Dynamic Bloom
    final barW = w * 0.62;
    final barH = math.max(4.0, h * 0.08);
    final barCenterY = -h * 0.46;

    // Lightbar housing mount
    final mountPaint = Paint()..color = const Color(0xFF111827);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, barCenterY), width: barW, height: barH), const Radius.circular(2)),
      mountPaint,
    );

    // Strobe LED Modules: Left (Red), Center (White), Right (Blue)
    final redColor = isStrobeRed ? const Color(0xFFFF0033) : const Color(0xFF660011);
    final blueColor = !isStrobeRed ? const Color(0xFF0077FF) : const Color(0xFF001F54);

    final leftStrobeRect = Rect.fromLTWH(-barW * 0.48, barCenterY - barH * 0.4, barW * 0.44, barH * 0.8);
    final rightStrobeRect = Rect.fromLTWH(barW * 0.04, barCenterY - barH * 0.4, barW * 0.44, barH * 0.8);

    // Strobe Glare / Neon Bloom
    final glareRadius = isStrobeRed ? math.max(6.0, w * 0.35) : math.max(6.0, w * 0.35);
    final strobeGlowPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glareRadius * 0.5);

    // Left Glow (Red)
    strobeGlowPaint.color = isStrobeRed ? const Color(0xFFFF0033).withValues(alpha: 0.85) : Colors.transparent;
    canvas.drawCircle(Offset(-barW * 0.26, barCenterY), glareRadius, strobeGlowPaint);

    // Right Glow (Blue)
    strobeGlowPaint.color = !isStrobeRed ? const Color(0xFF00B0FF).withValues(alpha: 0.85) : Colors.transparent;
    canvas.drawCircle(Offset(barW * 0.26, barCenterY), glareRadius, strobeGlowPaint);

    // Solid LED Bars
    canvas.drawRRect(RRect.fromRectAndRadius(leftStrobeRect, const Radius.circular(2)), Paint()..color = redColor);
    canvas.drawRRect(RRect.fromRectAndRadius(rightStrobeRect, const Radius.circular(2)), Paint()..color = blueColor);

    canvas.restore();
  }
}
