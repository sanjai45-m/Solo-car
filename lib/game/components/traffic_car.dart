import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'car_base.dart';
import 'road_manager.dart';

enum TrafficType { sedan, taxi, suv, truck, sportsCoupe }

class TrafficCar extends CarBase {
  final TrafficType trafficType;
  final RoadManager roadManager;
  double targetTrackX = 0.0;
  double laneChangeTimer = 0.0;
  final math.Random _random = math.Random();

  TrafficCar({
    required super.position,
    required this.trafficType,
    required this.roadManager,
    required double startTrackZ,
    required double startTrackX,
    required double targetSpeed,
    required Color color,
  }) : super(
          carWidth: trafficType == TrafficType.truck ? 165.0 : (trafficType == TrafficType.suv ? 150.0 : 135.0),
          carHeight: trafficType == TrafficType.truck ? 120.0 : (trafficType == TrafficType.suv ? 95.0 : 80.0),
          primaryColor: color,
          hasUnderglow: false,
        ) {
    trackZ = startTrackZ;
    trackX = startTrackX;
    targetTrackX = trackX;
    speed = targetSpeed;
    speedKmH = speed / 32.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Forward motion along 3D track
    trackZ += speed * dt;
    if (trackZ >= roadManager.trackLength && roadManager.trackLength > 0) {
      trackZ -= roadManager.trackLength;
    }

    // AI Lane change
    laneChangeTimer += dt;
    if (laneChangeTimer > 4.5 + _random.nextDouble() * 4.0) {
      laneChangeTimer = 0.0;
      if (_random.nextDouble() < 0.35) {
        final lanes = [-0.6, 0.0, 0.6];
        targetTrackX = lanes[_random.nextInt(lanes.length)];
      }
    }

    final dx = targetTrackX - trackX;
    if (dx.abs() > 0.02) {
      trackX += dx.sign * 0.45 * dt;
      steeringAngle = (dx.sign * 0.08).clamp(-0.15, 0.15);
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
    if (scale <= 0.001) return;

    if (trafficType == TrafficType.truck) {
      _renderSemiTruck(canvas, screenX, screenY, scale, rollAngle);
    } else if (trafficType == TrafficType.suv) {
      _renderSUV(canvas, screenX, screenY, scale, rollAngle);
    } else if (trafficType == TrafficType.taxi) {
      _renderTaxi(canvas, screenX, screenY, scale, rollAngle);
    } else {
      super.render3D(canvas, screenX: screenX, screenY: screenY, scale: scale, rollAngle: rollAngle);
    }
  }

  void _renderSemiTruck(Canvas canvas, double screenX, double screenY, double scale, double rollAngle) {
    final w = carWidth * scale;
    final h = carHeight * scale;

    canvas.save();
    canvas.translate(screenX, screenY);
    canvas.rotate(rollAngle);

    // 1. Ground Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(3.0, w * 0.1));
    canvas.drawRect(
      Rect.fromCenter(center: Offset(0, h * 0.46), width: w * 1.1, height: h * 0.2),
      shadowPaint,
    );

    // 2. Heavy Dual Rear Truck Tires
    final tirePaint = Paint()..color = const Color(0xFF141414);
    final rimPaint = Paint()..color = const Color(0xFF757575);
    final tireW = w * 0.18;
    final tireH = h * 0.35;

    // Left outer & inner
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-w * 0.42, h * 0.30), width: tireW, height: tireH), const Radius.circular(3)), tirePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-w * 0.26, h * 0.30), width: tireW, height: tireH), const Radius.circular(3)), tirePaint);
    canvas.drawCircle(Offset(-w * 0.42, h * 0.30), tireW * 0.3, rimPaint);
    canvas.drawCircle(Offset(-w * 0.26, h * 0.30), tireW * 0.3, rimPaint);

    // Right outer & inner
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.42, h * 0.30), width: tireW, height: tireH), const Radius.circular(3)), tirePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.26, h * 0.30), width: tireW, height: tireH), const Radius.circular(3)), tirePaint);
    canvas.drawCircle(Offset(w * 0.42, h * 0.30), tireW * 0.3, rimPaint);
    canvas.drawCircle(Offset(w * 0.26, h * 0.30), tireW * 0.3, rimPaint);

    // 3. Mudflaps
    final flapPaint = Paint()..color = const Color(0xFF212121);
    canvas.drawRect(Rect.fromLTWH(-w * 0.48, h * 0.32, w * 0.38, h * 0.14), flapPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.10, h * 0.32, w * 0.38, h * 0.14), flapPaint);

    // 4. White Cargo Box Container
    final boxRect = Rect.fromCenter(center: Offset(0, -h * 0.15), width: w * 0.94, height: h * 0.82);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    // Container Steel Frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(3)),
      Paint()
        ..color = const Color(0xFF9E9E9E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, w * 0.02),
    );

    // Container Corrugation lines & Rear Door Seam
    final seamPaint = Paint()..color = const Color(0xFFBDBDBD)..strokeWidth = math.max(1.0, w * 0.012);
    canvas.drawLine(Offset(0, -h * 0.55), Offset(0, h * 0.25), seamPaint);

    // Door Lock Bars (Chrome vertical poles)
    final lockPaint = Paint()..color = const Color(0xFF757575)..strokeWidth = math.max(1.5, w * 0.018);
    canvas.drawLine(Offset(-w * 0.18, -h * 0.52), Offset(-w * 0.18, h * 0.22), lockPaint);
    canvas.drawLine(Offset(w * 0.18, -h * 0.52), Offset(w * 0.18, h * 0.22), lockPaint);

    // 5. Red Tractor Cab Visible Bottom / Sides
    final cabPaint = Paint()..color = primaryColor;
    canvas.drawRect(Rect.fromLTWH(-w * 0.46, h * 0.24, w * 0.92, h * 0.08), cabPaint);

    // 6. Hazard Stripes on Bumper
    final stripeH = math.max(3.0, h * 0.06);
    canvas.drawRect(Rect.fromLTWH(-w * 0.45, h * 0.20, w * 0.90, stripeH), Paint()..color = const Color(0xFFFFD600));

    // 7. Taillights
    final tailPaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawRect(Rect.fromLTWH(-w * 0.44, h * 0.16, w * 0.12, h * 0.06), tailPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.32, h * 0.16, w * 0.12, h * 0.06), tailPaint);

    canvas.restore();
  }

  void _renderSUV(Canvas canvas, double screenX, double screenY, double scale, double rollAngle) {
    final w = carWidth * scale;
    final h = carHeight * scale;

    canvas.save();
    canvas.translate(screenX, screenY);
    canvas.rotate(rollAngle);

    // Ground Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.65)..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(2.5, w * 0.09));
    canvas.drawOval(Rect.fromCenter(center: Offset(0, h * 0.46), width: w * 1.2, height: h * 0.35), shadowPaint);

    // Tires
    final tirePaint = Paint()..color = const Color(0xFF1E1E1E);
    final rimPaint = Paint()..color = const Color(0xFF9E9E9E);
    final tireW = w * 0.22;
    final tireH = h * 0.52;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-w * 0.42, h * 0.22), width: tireW, height: tireH), const Radius.circular(3)), tirePaint);
    canvas.drawCircle(Offset(-w * 0.42, h * 0.22), tireW * 0.26, rimPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.42, h * 0.22), width: tireW, height: tireH), const Radius.circular(3)), tirePaint);
    canvas.drawCircle(Offset(w * 0.42, h * 0.22), tireW * 0.26, rimPaint);

    // Tall SUV Box Body
    final bodyPath = Path()
      ..moveTo(-w * 0.46, h * 0.36)
      ..lineTo(w * 0.46, h * 0.36)
      ..lineTo(w * 0.44, -h * 0.10)
      ..lineTo(w * 0.38, -h * 0.48)
      ..lineTo(-w * 0.38, -h * 0.48)
      ..lineTo(-w * 0.44, -h * 0.10)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = primaryColor);

    // Roof Rails
    final railPaint = Paint()..color = const Color(0xFF757575)..strokeWidth = math.max(2.0, w * 0.025);
    canvas.drawLine(Offset(-w * 0.35, -h * 0.50), Offset(-w * 0.35, -h * 0.30), railPaint);
    canvas.drawLine(Offset(w * 0.35, -h * 0.50), Offset(w * 0.35, -h * 0.30), railPaint);

    // Rear Windshield
    final glassPath = Path()
      ..moveTo(-w * 0.34, -h * 0.44)
      ..lineTo(w * 0.34, -h * 0.44)
      ..lineTo(w * 0.38, -h * 0.12)
      ..lineTo(-w * 0.38, -h * 0.12)
      ..close();
    canvas.drawPath(glassPath, Paint()..color = const Color(0xFF102027));

    // LED Taillights
    final tailPaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w * 0.42, -h * 0.08, w * 0.16, h * 0.18), const Radius.circular(2)), tailPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.26, -h * 0.08, w * 0.16, h * 0.18), const Radius.circular(2)), tailPaint);

    canvas.restore();
  }

  void _renderTaxi(Canvas canvas, double screenX, double screenY, double scale, double rollAngle) {
    // Render base car first
    super.render3D(canvas, screenX: screenX, screenY: screenY, scale: scale, rollAngle: rollAngle);

    final w = carWidth * scale;
    final h = carHeight * scale;

    canvas.save();
    canvas.translate(screenX, screenY);
    canvas.rotate(rollAngle);

    // Roof TAXI sign
    final signRect = Rect.fromCenter(center: Offset(0, -h * 0.52), width: w * 0.32, height: h * 0.14);
    canvas.drawRRect(RRect.fromRectAndRadius(signRect, const Radius.circular(2)), Paint()..color = const Color(0xFFFFF9C4));
    canvas.drawRRect(
      RRect.fromRectAndRadius(signRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF424242)..style = PaintingStyle.stroke..strokeWidth = 1.0,
    );

    // Checkered stripe across rear
    final checkW = w * 0.08;
    for (int i = -4; i <= 3; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(Rect.fromLTWH(i * checkW, h * 0.02, checkW, h * 0.06), Paint()..color = Colors.black);
      }
    }

    canvas.restore();
  }
}

