import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../models/race_model.dart';
import 'car_base.dart';
import 'road_manager.dart';

class OpponentCar extends CarBase {
  final String driverName;
  final String? playerUid;
  final bool isRemoteMultiplayer;
  final RaceDifficulty difficulty;
  final RoadManager roadManager;
  final int startingGridIndex;

  double targetTrackX = 0.0;
  double aiDecisionTimer = 0.0;
  double nitroTimer = 0.0;
  double distanceDrivenMeters = 0.0;
  final math.Random _random = math.Random();

  // Remote player interpolation targets
  double targetRemoteZ = 0.0;
  double targetRemoteX = 0.0;
  double targetRemoteSpeed = 0.0;
  double targetRemoteSteering = 0.0;
  bool targetRemoteNitro = false;
  bool hasReceivedFirstTelemetry = false;

  OpponentCar({
    required super.position,
    required this.driverName,
    this.playerUid,
    this.isRemoteMultiplayer = false,
    required this.difficulty,
    required this.roadManager,
    required this.startingGridIndex,
    required Color color,
    required Color underglowColor,
    CarBodyStyle? bodyStyle,
  }) : super(
          primaryColor: color,
          neonGlowColor: underglowColor,
          hasUnderglow: true,
          bodyStyle: bodyStyle ?? CarBodyStyle.values[(startingGridIndex) % CarBodyStyle.values.length],
        ) {
    // Generous starting grid spacing so cars never spawn too close or glitch at race start
    trackZ = 220.0 + (startingGridIndex * 180.0);
    // Staggered left/right starting slots
    final gridSlots = [0.45, -0.45, 0.32, -0.32, 0.52, -0.52];
    trackX = gridSlots[(startingGridIndex - 1) % gridSlots.length];
    targetTrackX = trackX;
    targetRemoteZ = trackZ;
    targetRemoteX = trackX;

    switch (difficulty) {
      case RaceDifficulty.easy:
        maxSpeed = 220.0 * 32.0;
        accelerationRate = 1900.0;
        break;
      case RaceDifficulty.normal:
        maxSpeed = 260.0 * 32.0;
        accelerationRate = 2200.0;
        break;
      case RaceDifficulty.hard:
        maxSpeed = 295.0 * 32.0;
        accelerationRate = 2500.0;
        break;
      case RaceDifficulty.expert:
        maxSpeed = 340.0 * 32.0;
        accelerationRate = 2900.0;
        break;
    }
  }

  void updateRemoteTelemetry({
    required double remoteZ,
    required double remoteX,
    required double remoteSpeedKmH,
    required double remoteSteering,
    required bool remoteNitro,
  }) {
    hasReceivedFirstTelemetry = true;
    targetRemoteZ = remoteZ;
    targetRemoteX = remoteX;
    targetRemoteSpeed = remoteSpeedKmH;
    targetRemoteSteering = remoteSteering;
    targetRemoteNitro = remoteNitro;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 1. Remote Live Human Opponent (Controlled via Real-Time WebSocket)
    if (isRemoteMultiplayer) {
      if (hasReceivedFirstTelemetry) {
        // High-precision smooth network interpolation for live peer racer
        trackZ = trackZ + (targetRemoteZ - trackZ) * (18.0 * dt).clamp(0.0, 1.0);
        trackX = trackX + (targetRemoteX - trackX) * (20.0 * dt).clamp(0.0, 1.0);
        speedKmH = targetRemoteSpeed;
        speed = speedKmH * 32.0;
        steeringAngle = targetRemoteSteering;
        isNitroActive = targetRemoteNitro;
        distanceDrivenMeters = trackZ / 32.0;
      } else {
        // Starting roll on grid
        speedKmH = 40.0;
        speed = speedKmH * 32.0;
        trackZ += speed * dt;
        distanceDrivenMeters += (speed * dt) / 32.0;
      }

      if (trackZ >= roadManager.trackLength && roadManager.trackLength > 0) {
        trackZ -= roadManager.trackLength;
      }
      return;
    }

    // 2. AI Bot tactical decision making (Single player)
    aiDecisionTimer += dt;
    if (aiDecisionTimer > 1.4 + _random.nextDouble() * 1.5) {
      aiDecisionTimer = 0.0;
      final currentSegment = roadManager.findSegment(trackZ);

      // Aim for inside curve apex
      if (currentSegment.curve < -0.3) {
        targetTrackX = -0.55;
      } else if (currentSegment.curve > 0.3) {
        targetTrackX = 0.55;
      } else {
        final lanes = [-0.6, 0.0, 0.6];
        targetTrackX = lanes[_random.nextInt(lanes.length)];
      }
    }

    // Nitro Bursts
    nitroTimer += dt;
    if (nitroTimer > 7.0 + _random.nextDouble() * 4.0) {
      nitroTimer = 0.0;
      isNitroActive = _random.nextDouble() < 0.45;
    }

    final effectiveMax = isNitroActive ? maxSpeed * 1.25 : maxSpeed;
    if (speed < effectiveMax) {
      speed += accelerationRate * (isNitroActive ? 1.5 : 1.0) * dt;
    }

    speedKmH = speed / 32.0;

    // Continuous cumulative distance tracking across laps
    final deltaDist = (speed * dt) / 32.0;
    distanceDrivenMeters += deltaDist;

    // Move forward in 3D track space
    trackZ += speed * dt;

    if (trackZ >= roadManager.trackLength && roadManager.trackLength > 0) {
      trackZ -= roadManager.trackLength;
    }

    // Smooth lateral movement towards target lane
    final dx = targetTrackX - trackX;
    if (dx.abs() > 0.02) {
      trackX += dx.sign * 0.85 * dt;
      steeringAngle = (dx.sign * 0.12).clamp(-0.25, 0.25);
    } else {
      trackX = targetTrackX;
      steeringAngle = 0.0;
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
    super.render3D(
      canvas,
      screenX: screenX,
      screenY: screenY,
      scale: scale,
      rollAngle: rollAngle,
    );

    // Render Driver Name Tag & Rival Badge above car when visible
    if (scale > 0.18) {
      _renderDriverBadge(canvas, screenX, screenY, scale);
    }
  }

  void _renderDriverBadge(
    Canvas canvas,
    double screenX,
    double screenY,
    double scale,
  ) {
    final h = carHeight * scale;
    final badgeY = screenY - (h * 0.62);

    final textSpan = TextSpan(
      text: driverName,
      style: TextStyle(
        color: Colors.white,
        fontSize: math.max(8.0, 11.0 * scale),
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final pillW = textPainter.width + 16.0 * scale + 10.0;
    final pillH = textPainter.height + 6.0 * scale;

    final pillRect = Rect.fromCenter(
      center: Offset(screenX, badgeY),
      width: pillW,
      height: pillH,
    );

    // Badge Background Pill
    final bgPaint = Paint()
      ..color = const Color(0xDD0B0F19)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(pillRect, Radius.circular(pillH / 2)), bgPaint);

    // Glowing Outline with Opponent Primary Color
    final borderPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, 1.5 * scale);
    canvas.drawRRect(RRect.fromRectAndRadius(pillRect, Radius.circular(pillH / 2)), borderPaint);

    // Small Colored Dot
    final dotRadius = math.max(2.0, 3.0 * scale);
    final dotPaint = Paint()..color = primaryColor;
    canvas.drawCircle(Offset(pillRect.left + 7.0 * scale + dotRadius, badgeY), dotRadius, dotPaint);

    // Driver Name Text
    textPainter.paint(
      canvas,
      Offset(pillRect.left + 12.0 * scale + (dotRadius * 2), badgeY - (textPainter.height / 2)),
    );
  }
}
