import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

abstract class CarBase extends PositionComponent {
  final double carWidth;
  final double carHeight;
  final Color primaryColor;
  final Color neonGlowColor;
  final Color stripeColor;
  final bool hasUnderglow;

  // Track coordinates in Pseudo-3D space
  double trackZ = 0.0; // Distance along track (0 to trackLength)
  double trackX = 0.0; // Lateral position: -1.0 (left edge) to 0.0 (center) to +1.0 (right edge)

  // Physics state
  double speed = 0.0; // Current forward speed (units/sec)
  double speedKmH = 0.0; // Display speed (km/h)
  double maxSpeed = 300.0;
  double accelerationRate = 220.0;
  double brakeForce = 350.0;
  double steeringAngle = 0.0; // Chassis roll/tilt angle (-0.35 to 0.35 rad)
  double lateralVelocity = 0.0;
  double health = 100.0;
  bool isBraking = false;
  bool isNitroActive = false;
  bool isDrifting = false;

  // 3D dynamic suspension & wheel animation
  double _wheelRotationAngle = 0.0;
  double _suspensionBounce = 0.0;

  CarBase({
    required super.position,
    this.carWidth = 145.0,
    this.carHeight = 92.0,
    required this.primaryColor,
    this.neonGlowColor = const Color(0xFF00E5FF),
    this.stripeColor = const Color(0xFFFFFFFF),
    this.hasUnderglow = true,
  }) : super(
          size: Vector2(145.0, 92.0),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    // Dynamic wheel spinning & smooth suspension physics
    _wheelRotationAngle += (speed / 30.0) * dt;
    if (speed > 50) {
      _suspensionBounce = math.sin(_wheelRotationAngle * 0.5) * 0.35;
    } else {
      _suspensionBounce = 0.0;
    }
  }

  // Render vehicle in pure 3D Volumetric Perspective (100% transparent background, ZERO rectangular box)
  void render3D(
    Canvas canvas, {
    required double screenX,
    required double screenY,
    required double scale,
    double rollAngle = 0.0,
  }) {
    if (scale <= 0.001) return;

    final w = carWidth * scale;
    final h = carHeight * scale;

    canvas.save();
    canvas.translate(screenX, screenY + _suspensionBounce);
    canvas.rotate(rollAngle);

    // 1. Soft Realistic Ground Contact Shadow on Asphalt
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(2.5, w * 0.08));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, h * 0.44), width: w * 1.22, height: h * 0.28),
      shadowPaint,
    );

    // 2. Glowing Neon Ground Underglow
    if (hasUnderglow) {
      final glowPaint = Paint()
        ..color = neonGlowColor.withValues(alpha: isNitroActive ? 0.95 : 0.60)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          math.max(4.0, isNitroActive ? w * 0.25 : w * 0.14),
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(0, h * 0.40), width: w * 1.05, height: h * 0.22),
          Radius.circular(w * 0.08),
        ),
        glowPaint,
      );
    }

    // 3. 3D Wide Racing Slick Tires with Alloy Rims & Brake Calipers
    final tirePaint = Paint()..color = const Color(0xFF141414);
    final treadPaint = Paint()..color = const Color(0xFF222222);
    final rimPaint = Paint()..color = const Color(0xFFB0BEC5);
    final rimCorePaint = Paint()..color = const Color(0xFF263238);
    final caliperPaint = Paint()..color = const Color(0xFFFF1744);

    final tireW = w * 0.23;
    final tireH = h * 0.54;

    // Left 3D Wheel
    final leftTireRect = Rect.fromCenter(
      center: Offset(-w * 0.43, h * 0.22),
      width: tireW,
      height: tireH,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(leftTireRect, const Radius.circular(5)), tirePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(leftTireRect.deflate(tireW * 0.16), const Radius.circular(3)), treadPaint);
    canvas.drawCircle(Offset(-w * 0.43, h * 0.22), tireW * 0.32, rimPaint);
    canvas.drawCircle(Offset(-w * 0.43, h * 0.22), tireW * 0.22, rimCorePaint);
    canvas.drawCircle(Offset(-w * 0.43 - tireW * 0.08, h * 0.22 - tireW * 0.08), tireW * 0.10, caliperPaint);

    // Right 3D Wheel
    final rightTireRect = Rect.fromCenter(
      center: Offset(w * 0.43, h * 0.22),
      width: tireW,
      height: tireH,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(rightTireRect, const Radius.circular(5)), tirePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightTireRect.deflate(tireW * 0.16), const Radius.circular(3)), treadPaint);
    canvas.drawCircle(Offset(w * 0.43, h * 0.22), tireW * 0.32, rimPaint);
    canvas.drawCircle(Offset(w * 0.43, h * 0.22), tireW * 0.22, rimCorePaint);
    canvas.drawCircle(Offset(w * 0.43 + tireW * 0.08, h * 0.22 - tireW * 0.08), tireW * 0.10, caliperPaint);

    // 4. 3D Carbon Fiber Aerodynamic Rear Diffuser & Vertical Fins
    final diffuserPaint = Paint()..color = const Color(0xFF141A24);
    final diffuserPath = Path()
      ..moveTo(-w * 0.46, h * 0.44)
      ..lineTo(w * 0.46, h * 0.44)
      ..lineTo(w * 0.42, h * 0.16)
      ..lineTo(-w * 0.42, h * 0.16)
      ..close();
    canvas.drawPath(diffuserPath, diffuserPaint);

    // Diffuser vertical strakes
    final finPaint = Paint()..color = const Color(0xFF080C14);
    for (int i = -3; i <= 3; i++) {
      final finX = i * (w * 0.085);
      canvas.drawRect(Rect.fromLTWH(finX - 1.5, h * 0.18, 3.0, h * 0.24), finPaint);
    }

    // 5. 3D Widebody Supercar Chassis Body
    final bodyPath = Path()
      ..moveTo(-w * 0.49, h * 0.25) // Left wheel arch
      ..lineTo(-w * 0.47, h * 0.42) // Rear bumper low left
      ..lineTo(w * 0.47, h * 0.42) // Rear bumper low right
      ..lineTo(w * 0.49, h * 0.25) // Right wheel arch
      ..lineTo(w * 0.45, -h * 0.06) // Shoulder line right
      ..lineTo(w * 0.33, -h * 0.44) // Roofline right
      ..lineTo(-w * 0.33, -h * 0.44) // Roofline left
      ..lineTo(-w * 0.45, -h * 0.06) // Shoulder line left
      ..close();

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(primaryColor, Colors.white, 0.25)!,
          primaryColor,
          Color.lerp(primaryColor, Colors.black, 0.35)!,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(-w / 2, -h / 2, w, h));
    canvas.drawPath(bodyPath, bodyPaint);

    // Dynamic Metallic Specular Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, w * 0.02);
    canvas.drawPath(bodyPath, highlightPaint);

    // 6. Dual Center Racing Stripes
    final stripePaint = Paint()..color = stripeColor.withValues(alpha: 0.90);
    final stripeW = w * 0.055;
    final gap = w * 0.02;
    canvas.drawRect(Rect.fromLTWH(-gap - stripeW, -h * 0.43, stripeW, h * 0.82), stripePaint);
    canvas.drawRect(Rect.fromLTWH(gap, -h * 0.43, stripeW, h * 0.82), stripePaint);

    // 7. Aerodynamic Tinted Rear Window & Engine Louvers
    final glassPath = Path()
      ..moveTo(-w * 0.27, -h * 0.40)
      ..lineTo(w * 0.27, -h * 0.40)
      ..lineTo(w * 0.37, -h * 0.08)
      ..lineTo(-w * 0.37, -h * 0.08)
      ..close();
    canvas.drawPath(glassPath, Paint()..color = const Color(0xFF090D16));

    // Glass Reflection
    final glossPath = Path()
      ..moveTo(-w * 0.20, -h * 0.38)
      ..lineTo(-w * 0.08, -h * 0.38)
      ..lineTo(-w * 0.16, -h * 0.10)
      ..lineTo(-w * 0.28, -h * 0.10)
      ..close();
    canvas.drawPath(glossPath, Paint()..color = Colors.white.withValues(alpha: 0.28));

    // Louver Slats
    final louverPaint = Paint()..color = const Color(0xFF161E2E);
    for (int i = 0; i < 4; i++) {
      final yProgress = i / 3.0;
      final ly = -h * 0.36 + (yProgress * h * 0.24);
      final lw = w * (0.44 + yProgress * 0.22);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(0, ly), width: lw, height: math.max(2.0, h * 0.035)),
          const Radius.circular(1),
        ),
        louverPaint,
      );
    }

    // 8. 3D Carbon Fiber GT Wing Spoiler with Mounting Struts & Endplates
    final strutPaint = Paint()..color = const Color(0xFF1E2838);
    canvas.drawRect(Rect.fromLTWH(-w * 0.27, -h * 0.22, w * 0.045, h * 0.16), strutPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.225, -h * 0.22, w * 0.045, h * 0.16), strutPaint);

    // Main Spoiler Wing Bar
    final spoilerPaint = Paint()..color = const Color(0xFF0D1117);
    final spoilerRect = Rect.fromCenter(
      center: Offset(0, -h * 0.22),
      width: w * 0.95,
      height: math.max(4.0, h * 0.09),
    );
    canvas.drawRRect(RRect.fromRectAndRadius(spoilerRect, const Radius.circular(2)), spoilerPaint);

    // Spoiler Endplates
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-w * 0.47, -h * 0.22), width: w * 0.035, height: h * 0.18),
        const Radius.circular(1),
      ),
      spoilerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.47, -h * 0.22), width: w * 0.035, height: h * 0.18),
        const Radius.circular(1),
      ),
      spoilerPaint,
    );

    // 9. Continuous Glowing LED Taillight Light Bar
    final tailColor = isBraking ? const Color(0xFFFF1744) : const Color(0xFFFF2B3C);
    final tailPaint = Paint()
      ..color = tailColor
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        math.max(2.5, isBraking ? w * 0.18 : w * 0.08),
      );

    final tailPath = Path()
      ..moveTo(-w * 0.43, h * 0.01)
      ..lineTo(-w * 0.09, h * 0.03)
      ..lineTo(w * 0.09, h * 0.03)
      ..lineTo(w * 0.43, h * 0.01)
      ..lineTo(w * 0.41, h * 0.09)
      ..lineTo(w * 0.09, h * 0.10)
      ..lineTo(-w * 0.09, h * 0.10)
      ..lineTo(-w * 0.41, h * 0.09)
      ..close();
    canvas.drawPath(tailPath, tailPaint);

    // Inner Radiant Core
    final coreTailPaint = Paint()..color = isBraking ? const Color(0xFFFFF59D) : const Color(0xFFFFCDD2);
    canvas.drawPath(tailPath, coreTailPaint);

    // 10. Dual Titanium Exhaust Ports with Glowing Heat Rings
    final exL = Offset(-w * 0.22, h * 0.37);
    final exR = Offset(w * 0.22, h * 0.37);
    final exRadius = math.max(3.5, w * 0.052);

    final exhaustOuterPaint = Paint()..color = const Color(0xFF455A64);
    final exhaustInnerPaint = Paint()..color = const Color(0xFF0F172A);

    canvas.drawCircle(exL, exRadius, exhaustOuterPaint);
    canvas.drawCircle(exL, exRadius * 0.70, exhaustInnerPaint);
    canvas.drawCircle(exR, exRadius, exhaustOuterPaint);
    canvas.drawCircle(exR, exRadius * 0.70, exhaustInnerPaint);

    // Nitro exhaust ring glow
    if (isNitroActive) {
      final nitroGlow = Paint()
        ..color = const Color(0xFF00E5FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(exL, exRadius * 1.7, nitroGlow);
      canvas.drawCircle(exR, exRadius * 1.7, nitroGlow);
    }

    canvas.restore();
  }
}


