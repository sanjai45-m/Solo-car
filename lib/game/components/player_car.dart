import 'package:flutter/services.dart';
import '../../models/car_model.dart';
import 'car_base.dart';
import 'road_manager.dart';

class PlayerCar extends CarBase {
  final CarModel carModel;
  final RoadManager roadManager;

  // Input States
  bool keySteerLeft = false;
  bool keySteerRight = false;
  bool keyAccelerate = false;
  bool keyBrake = false;
  bool keyNitro = false;
  bool keyHandbrake = false;

  // Touch Analog Inputs (-1.0 to 1.0)
  double touchSteerAxis = 0.0;
  bool touchAccelerate = false;
  bool touchBrake = false;
  bool touchNitro = false;
  bool touchHandbrake = false;

  // Nitro status
  double currentNitro = 100.0;
  double maxNitro = 100.0;
  double nitroBurnRate = 35.0; // Units/sec
  double nitroRechargeRate = 4.0; // Idle recharge units/sec

  // Drift status & Scoring
  double driftScore = 0.0;
  double currentDriftPoints = 0.0;
  double driftMultiplier = 1.0;
  double driftDuration = 0.0;
  bool isDriftingActive = false;

  // Road distance progress
  double distanceDrivenMeters = 0.0;
  int currentLap = 1;

  // Track Boundary Constraint Configuration (Default: TRUE)
  bool enforceTrackBoundary;

  PlayerCar({
    required super.position,
    required this.carModel,
    required this.roadManager,
    this.enforceTrackBoundary = true,
  }) : super(
          primaryColor: carModel.bodyColor,
          neonGlowColor: carModel.neonUnderglowColor,
          stripeColor: carModel.stripeColor,
          hasUnderglow: carModel.hasUnderglow,
        ) {
    maxSpeed = carModel.topSpeedKmH * 32.0; // Scaled for 3D track world units
    accelerationRate = 1800.0 + (carModel.accelerationRate * 200.0);
    brakeForce = 3800.0 + (carModel.brakingRate * 280.0);
    maxNitro = carModel.nitroCapacity;
    currentNitro = maxNitro;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final isAccelerating = keyAccelerate || touchAccelerate;
    isBraking = keyBrake || touchBrake;
    final wantsNitro = (keyNitro || touchNitro) && currentNitro > 5.0 && isAccelerating;
    final isHandbrakeActive = keyHandbrake || touchHandbrake;

    // 1. Nitro Handling
    if (wantsNitro) {
      isNitroActive = true;
      currentNitro = (currentNitro - (nitroBurnRate * dt)).clamp(0.0, maxNitro);
    } else {
      isNitroActive = false;
      currentNitro = (currentNitro + (nitroRechargeRate * dt)).clamp(0.0, maxNitro);
    }

    final effectiveMaxSpeed =
        isNitroActive ? maxSpeed * carModel.nitroMultiplier : maxSpeed;
    final effectiveAccel =
        isNitroActive ? accelerationRate * 1.8 : accelerationRate;

    // 2. Forward Acceleration & Braking Physics
    if (isAccelerating) {
      if (speed < effectiveMaxSpeed) {
        speed += effectiveAccel * dt;
      } else {
        speed -= 400 * dt;
      }
    } else if (isBraking) {
      speed = (speed - (brakeForce * dt)).clamp(0.0, effectiveMaxSpeed);
    } else {
      // Natural rolling friction / wind drag
      speed = (speed - (350.0 * dt)).clamp(0.0, effectiveMaxSpeed);
    }

    speedKmH = speed / 32.0;

    // 3. Steering & Drift Dynamics (Responsive & Controllable)
    double steerInput = touchSteerAxis;
    if (keySteerLeft) steerInput -= 1.0;
    if (keySteerRight) steerInput += 1.0;
    steerInput = steerInput.clamp(-1.0, 1.0);

    final speedFactor = (speed / maxSpeed).clamp(0.20, 1.0);
    final handlingAgility = 1.85 + (carModel.handlingRate * 0.15);

    // Drift activation when handbrake held or sharp steering at high speed
    final isSharpTurn = steerInput.abs() > 0.7 && speedKmH > 140;
    isDrifting = (isHandbrakeActive || isSharpTurn) && speedKmH > 60;

    if (isDrifting) {
      final targetAngle = steerInput * 0.28;
      steeringAngle += (targetAngle - steeringAngle) * 10.0 * dt;
      trackX += steerInput * (handlingAgility * 1.25) * speedFactor * dt;
      speed *= (1.0 - 0.04 * dt);

      driftDuration += dt;
      isDriftingActive = true;
      currentDriftPoints += (speedKmH * 1.5 * dt);
      driftMultiplier = (1.0 + (driftDuration * 0.5)).clamp(1.0, 5.0);
      currentNitro = (currentNitro + (14.0 * dt)).clamp(0.0, maxNitro);
    } else {
      final targetAngle = steerInput * 0.14;
      steeringAngle += (targetAngle - steeringAngle) * 14.0 * dt;
      
      if (steerInput != 0.0) {
        trackX += steerInput * handlingAgility * speedFactor * dt;
      } else {
        // High stability self-centering damping
        steeringAngle *= (1.0 - 12.0 * dt).clamp(0.0, 1.0);
      }

      if (isDriftingActive) {
        driftScore += currentDriftPoints * driftMultiplier;
        currentDriftPoints = 0.0;
        driftMultiplier = 1.0;
        driftDuration = 0.0;
        isDriftingActive = false;
      }
    }

    // 4. Subtle Gentle Centrifugal Force around Road Curves
    final currentSegment = roadManager.findSegment(trackZ);
    final centrifugalForce = currentSegment.curve * (speed / maxSpeed) * 0.35 * dt;
    trackX -= centrifugalForce;

    // 5. Road Boundaries Constraint (Configurable, default: TRUE prevents leaving the road)
    if (enforceTrackBoundary) {
      if (trackX < -0.96) {
        trackX = -0.96;
        if (keySteerLeft || touchSteerAxis < 0) {
          steeringAngle = (steeringAngle * 0.4).clamp(-0.04, 0.04);
        }
        speed *= (1.0 - 0.10 * dt);
      } else if (trackX > 0.96) {
        trackX = 0.96;
        if (keySteerRight || touchSteerAxis > 0) {
          steeringAngle = (steeringAngle * 0.4).clamp(-0.04, 0.04);
        }
        speed *= (1.0 - 0.10 * dt);
      }
    } else {
      trackX = trackX.clamp(-1.6, 1.6);
      if (trackX.abs() > 1.0) {
        // Gentle slowdown on grass/shoulder
        speed *= (1.0 - 0.15 * dt);
      }
    }

    // 6. Forward Progress along 3D Track
    final deltaDist = (speed * dt) / 32.0;
    distanceDrivenMeters += deltaDist;
    trackZ += speed * dt;

    // Loop around track length
    if (trackZ >= roadManager.trackLength && roadManager.trackLength > 0) {
      trackZ -= roadManager.trackLength;
    }
  }

  void addNearMissReward() {
    currentNitro = (currentNitro + 25.0).clamp(0.0, maxNitro);
    driftScore += 150;
  }

  void handleCollisionImpulse(double speedLossRatio, double xImpulse) {
    speed *= (1.0 - speedLossRatio).clamp(0.2, 1.0);
    trackX += (xImpulse / 100.0);
    health = (health - (speedLossRatio * 20)).clamp(0.0, 100.0);
  }

  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    keySteerLeft = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    keySteerRight = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    keyAccelerate = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    keyBrake = keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);
    keyNitro = keysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
        keysPressed.contains(LogicalKeyboardKey.shiftRight);
    keyHandbrake = keysPressed.contains(LogicalKeyboardKey.space);

    return true;
  }
}
