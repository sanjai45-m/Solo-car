import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/car_model.dart';

/// Ultra-High-Definition 3D Vector Math & Perspective Studio Engine for Supercars
class Car3DRenderer {
  /// Render full 3D rotating supercar on Canvas with real 3D perspective,
  /// metallic PBR shading, sculpted wheel arches, multi-spoke alloy wheels,
  /// aerodynamic canopy, GT wing, and neon underglow.
  static void render3DShowcase({
    required Canvas canvas,
    required Size size,
    required CarModel car,
    required double yawAngle, // 0 to 2*PI rotation around vertical Y axis
    double pitchAngle = 0.22, // Refined 3/4 supercar studio perspective angle
    double bounceY = 0.0,     // Suspension hover breathing
    double glowPulse = 1.0,
  }) {
    final center = Offset(size.width / 2, size.height / 2 + bounceY);
    final scale = math.min(size.width, size.height) * 0.46;

    // 1. Setup 3D Camera / Perspective Math
    final cosY = math.cos(yawAngle);
    final sinY = math.sin(yawAngle);
    final cosP = math.cos(pitchAngle);
    final sinP = math.sin(pitchAngle);

    // 3D Projection: (x: left/right, y: up/down, z: front/rear) -> Screen 2D Offset + depth
    _Point3D project(double x, double y, double z) {
      // Y-axis rotation (Yaw)
      final x1 = x * cosY + z * sinY;
      final y1 = y;
      final z1 = -x * sinY + z * cosY;

      // X-axis rotation (Pitch)
      final x2 = x1;
      final y2 = y1 * cosP - z1 * sinP;
      final z2 = y1 * sinP + z1 * cosP;

      // Perspective divide
      const fov = 4.8;
      final depthFactor = fov / (fov + z2 * 0.44);
      final sx = center.dx + x2 * scale * depthFactor;
      final sy = center.dy + y2 * scale * depthFactor;

      return _Point3D(Offset(sx, sy), z2, depthFactor);
    }

    // 2. Draw Ground Contact Shadow & Neon Cyber Turntable Halo
    _drawTurntableFloor(canvas, center, scale, car.neonUnderglowColor, glowPulse, yawAngle);

    // 3. Render 3D Wheels based on Depth (Back wheels rendered first, Front wheels rendered after body)
    final wheels = _computeWheelPositions(car);
    final projectedWheels = wheels.map((w) {
      final pos = w.pos;
      final proj = project(pos[0], pos[1], pos[2]);
      return _WheelInstance(w.isFront, w.isLeft, proj, pos);
    }).toList();

    // Separate background wheels (depth > 0) from foreground wheels (depth <= 0)
    final backWheels = projectedWheels.where((w) => w.proj.depth > 0).toList();
    final frontWheels = projectedWheels.where((w) => w.proj.depth <= 0).toList();

    // Render Far Wheels
    for (final w in backWheels) {
      _drawSingleWheel(canvas, w, scale, car);
    }

    // 4. Render Main Sculpted 3D Supercar Body & Multi-layer Panels
    _drawSculpted3DSupercar(canvas, project, car, scale, yawAngle);

    // 5. Render Near Wheels
    for (final w in frontWheels) {
      _drawSingleWheel(canvas, w, scale, car);
    }

    // 6. Render Aero Elements: Carbon GT Wing, Shark Fin & Splitters
    _draw3DAerodynamics(canvas, project, car, scale);

    // 7. Render High-Tech Optics: LED Headlights, Taillight Bar & Exhausts
    _drawOpticsAndExhausts(canvas, project, car, scale, yawAngle);
  }

  // ─── Ground Effects & Neon Turntable ───────────────────────────────────────
  static void _drawTurntableFloor(
    Canvas canvas,
    Offset center,
    double scale,
    Color neonColor,
    double pulse,
    double yawAngle,
  ) {
    final floorCenter = Offset(center.dx, center.dy + scale * 0.38);
    final shadowRect = Rect.fromCenter(
      center: floorCenter,
      width: scale * 2.35,
      height: scale * 0.82,
    );

    // Soft Ambient Occlusion Underbody Shadow
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.90),
          Colors.black.withValues(alpha: 0.45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(shadowRect);
    canvas.drawOval(shadowRect, shadowPaint);

    // Glowing Neon Stage Ring
    final ringRect = Rect.fromCenter(
      center: floorCenter,
      width: scale * 2.55 * (0.96 + pulse * 0.04),
      height: scale * 0.90 * (0.96 + pulse * 0.04),
    );

    final neonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = neonColor.withValues(alpha: 0.35 + pulse * 0.25);
    canvas.drawOval(ringRect, neonPaint);

    // Rotating Grid Tech Markers
    for (int i = 0; i < 8; i++) {
      final a = yawAngle + (i * math.pi / 4);
      final px = floorCenter.dx + math.cos(a) * (scale * 1.24);
      final py = floorCenter.dy + math.sin(a) * (scale * 0.44);
      canvas.drawCircle(
        Offset(px, py),
        3.2,
        Paint()..color = neonColor.withValues(alpha: 0.85),
      );
    }
  }

  // ─── 3D Wheel Calculation & Rendering ─────────────────────────────────────
  static List<_WheelDef> _computeWheelPositions(CarModel car) {
    final isMuscle = car.id == 'shadow_v8' || car.bodyStyle == CarBodyStyle.muscleGtr;
    final isTrack = car.id == 'viper_rs';
    final rearTrack = (isMuscle || isTrack) ? 0.86 : 0.82;
    final frontTrack = 0.78;
    final wheelbase = 0.72;
    final wheelY = 0.20; // Ground height

    return [
      _WheelDef(true, true, [-frontTrack, wheelY, wheelbase]),   // Front Left
      _WheelDef(true, false, [frontTrack, wheelY, wheelbase]),   // Front Right
      _WheelDef(false, true, [-rearTrack, wheelY, -wheelbase]),  // Rear Left
      _WheelDef(false, false, [rearTrack, wheelY, -wheelbase]),  // Rear Right
    ];
  }

  static void _drawSingleWheel(
    Canvas canvas,
    _WheelInstance wheel,
    double scale,
    CarModel car,
  ) {
    final pt = wheel.proj.pt;
    final depthFactor = wheel.proj.depthFactor;
    final isWideRear = !wheel.isFront;

    final wheelRadius = scale * 0.19 * depthFactor;
    final wheelWidth = scale * (isWideRear ? 0.11 : 0.09) * depthFactor;

    // 1. Tire Tread (Deep Charcoal Rubber)
    final tireRect = Rect.fromCenter(
      center: pt,
      width: wheelWidth * 1.6,
      height: wheelRadius * 2.0,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tireRect, Radius.circular(wheelWidth * 0.45)),
      Paint()..color = const Color(0xFF141518),
    );

    // Tire Tread Edge
    canvas.drawRRect(
      RRect.fromRectAndRadius(tireRect, Radius.circular(wheelWidth * 0.45)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF2C323B),
    );

    // 2. Machined Alloy Rim Barrel (Radial Metallic Gradient)
    final rimRect = Rect.fromCenter(
      center: pt,
      width: wheelWidth * 1.25,
      height: wheelRadius * 1.65,
    );
    canvas.drawOval(
      rimRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF546E7A), Color(0xFF1E262C), Color(0xFF78909C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rimRect),
    );

    // 3. Drilled Carbon-Ceramic Brake Rotor & Red Brembo Caliper
    canvas.drawCircle(pt, wheelRadius * 0.50, Paint()..color = const Color(0xFF78909C));
    canvas.drawArc(
      Rect.fromCircle(center: pt, radius: wheelRadius * 0.54),
      -math.pi / 2.8,
      math.pi / 1.8,
      false,
      Paint()
        ..color = const Color(0xFFFF1744) // Red Caliper
        ..strokeWidth = 4.5 * depthFactor
        ..style = PaintingStyle.stroke,
    );

    // 4. Multi-Spoke CNC Machined Spokes
    final spokeCount = (car.id == 'viper_rs' || car.id == 'phantom_r') ? 6 : 5;
    for (int i = 0; i < spokeCount; i++) {
      final angle = (i * math.pi * 2 / spokeCount);
      final sx = pt.dx + math.cos(angle) * (wheelWidth * 0.50);
      final sy = pt.dy + math.sin(angle) * (wheelRadius * 0.68);
      canvas.drawLine(
        pt,
        Offset(sx, sy),
        Paint()
          ..color = (car.id == 'shadow_v8') ? const Color(0xFFB0BEC5) : const Color(0xFFECEFF1)
          ..strokeWidth = 2.0 * depthFactor,
      );
    }

    // 5. Center Lock Wheel Hub
    canvas.drawCircle(pt, wheelRadius * 0.18, Paint()..color = car.neonUnderglowColor);
  }

  // ─── Sculpted 3D Supercar Multi-Panel Body ────────────────────────────────
  static void _drawSculpted3DSupercar(
    Canvas canvas,
    _Point3D Function(double, double, double) project,
    CarModel car,
    double scale,
    double yawAngle,
  ) {
    final baseColor = car.bodyColor;
    final highlight = Color.lerp(baseColor, Colors.white, 0.45)!;
    final shadow = Color.lerp(baseColor, Colors.black, 0.60)!;
    final deepShadow = Color.lerp(baseColor, Colors.black, 0.85)!;

    final isMuscle = car.id == 'shadow_v8' || car.bodyStyle == CarBodyStyle.muscleGtr;
    final isHyper = car.id == 'inferno_x' || car.id == 'phantom_r' || car.bodyStyle == CarBodyStyle.leMansHypercar;
    final isTrack = car.id == 'viper_rs';

    // Model-tailored key dimensions
    final noseZ = isHyper ? 1.42 : (isMuscle ? 1.28 : 1.34);
    final tailZ = isHyper ? -1.35 : -1.25;
    final noseW = isMuscle ? 0.66 : (isHyper ? 0.54 : 0.58);
    final cabinW = 0.42;
    final rearW = (isMuscle || isTrack) ? 0.88 : 0.82;
    final roofH = isHyper ? -0.42 : -0.46;
    final beltlineH = -0.06;
    final floorH = 0.18;

    // ── Key 3D Vertices ──
    // Front Nose / Splitter
    final vNoseCenter = project(0.0, floorH, noseZ);
    final vNoseLeft = project(-noseW, floorH, noseZ - 0.10);
    final vNoseRight = project(noseW, floorH, noseZ - 0.10);

    // Front Bumper Upper Lip / Hood Tip
    final vHoodTipCenter = project(0.0, 0.04, noseZ - 0.12);
    final vHoodTipLeft = project(-noseW * 0.9, 0.04, noseZ - 0.16);
    final vHoodTipRight = project(noseW * 0.9, 0.04, noseZ - 0.16);

    // Front Fenders (Arches over front wheels)
    final vFenderFL = project(-0.80, beltlineH - 0.04, 0.74);
    final vFenderFR = project(0.80, beltlineH - 0.04, 0.74);

    // Hood / Windshield Base
    final vCowlCenter = project(0.0, beltlineH - 0.08, 0.28);
    final vCowlLeft = project(-cabinW, beltlineH - 0.04, 0.32);
    final vCowlRight = project(cabinW, beltlineH - 0.04, 0.32);

    // Windshield Top & Roof
    final vRoofFrontCenter = project(0.0, roofH, 0.02);
    final vRoofFrontLeft = project(-cabinW * 0.78, roofH, 0.04);
    final vRoofFrontRight = project(cabinW * 0.78, roofH, 0.04);

    final vRoofRearCenter = project(0.0, roofH + 0.04, -0.48);
    final vRoofRearLeft = project(-cabinW * 0.82, roofH + 0.04, -0.46);
    final vRoofRearRight = project(cabinW * 0.82, roofH + 0.04, -0.46);

    // Rear Haunches (Wide Muscular Hips over rear wheels)
    final vHaunchRL = project(-rearW, beltlineH - 0.06, -0.74);
    final vHaunchRR = project(rearW, beltlineH - 0.06, -0.74);

    // Rear Deck / Engine Bay & Spoiler Base
    final vDeckCenter = project(0.0, beltlineH - 0.04, -0.96);
    final vDeckLeft = project(-cabinW * 0.9, beltlineH - 0.02, -0.96);
    final vDeckRight = project(cabinW * 0.9, beltlineH - 0.02, -0.96);

    // Rear Tail Fascia / Diffuser Top
    final vTailCenter = project(0.0, 0.06, tailZ);
    final vTailLeft = project(-rearW * 0.92, 0.06, tailZ + 0.08);
    final vTailRight = project(rearW * 0.92, 0.06, tailZ + 0.08);

    // Lower Side Skirts (with wheel arch cutouts)
    final vSkirtFrontL = project(-0.76, floorH, 0.52);
    final vSkirtFrontR = project(0.76, floorH, 0.52);
    final vSkirtRearL = project(-rearW, floorH, -0.52);
    final vSkirtRearR = project(rearW, floorH, -0.52);
    final vDiffuserL = project(-rearW * 0.85, floorH, tailZ);
    final vDiffuserR = project(rearW * 0.85, floorH, tailZ);

    // ── Panel 1: Carbon Aerodynamic Side Skirts & Undercarriage Floor ──
    final skirtL = Path()
      ..moveTo(vNoseLeft.pt.dx, vNoseLeft.pt.dy)
      ..lineTo(vSkirtFrontL.pt.dx, vSkirtFrontL.pt.dy)
      ..lineTo(vSkirtRearL.pt.dx, vSkirtRearL.pt.dy)
      ..lineTo(vDiffuserL.pt.dx, vDiffuserL.pt.dy)
      ..lineTo(vTailLeft.pt.dx, vTailLeft.pt.dy)
      ..lineTo(vHaunchRL.pt.dx, vHaunchRL.pt.dy)
      ..lineTo(vFenderFL.pt.dx, vFenderFL.pt.dy)
      ..close();
    canvas.drawPath(skirtL, Paint()..color = const Color(0xFF101418));

    final skirtR = Path()
      ..moveTo(vNoseRight.pt.dx, vNoseRight.pt.dy)
      ..lineTo(vSkirtFrontR.pt.dx, vSkirtFrontR.pt.dy)
      ..lineTo(vSkirtRearR.pt.dx, vSkirtRearR.pt.dy)
      ..lineTo(vDiffuserR.pt.dx, vDiffuserR.pt.dy)
      ..lineTo(vTailRight.pt.dx, vTailRight.pt.dy)
      ..lineTo(vHaunchRR.pt.dx, vHaunchRR.pt.dy)
      ..lineTo(vFenderFR.pt.dx, vFenderFR.pt.dy)
      ..close();
    canvas.drawPath(skirtR, Paint()..color = const Color(0xFF101418));

    // ── Panel 2: Front Bumper & Aggressive Radiator Air Dams ──
    final bumperPath = Path()
      ..moveTo(vNoseLeft.pt.dx, vNoseLeft.pt.dy)
      ..lineTo(vNoseCenter.pt.dx, vNoseCenter.pt.dy)
      ..lineTo(vNoseRight.pt.dx, vNoseRight.pt.dy)
      ..lineTo(vHoodTipRight.pt.dx, vHoodTipRight.pt.dy)
      ..lineTo(vHoodTipCenter.pt.dx, vHoodTipCenter.pt.dy)
      ..lineTo(vHoodTipLeft.pt.dx, vHoodTipLeft.pt.dy)
      ..close();

    canvas.drawPath(
      bumperPath,
      Paint()
        ..shader = LinearGradient(
          colors: [deepShadow, shadow, baseColor],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(bumperPath.getBounds()),
    );

    // Black Mesh Honeycomb Air Intakes
    final intakeL = project(-noseW * 0.55, 0.10, noseZ - 0.06);
    final intakeR = project(noseW * 0.55, 0.10, noseZ - 0.06);
    canvas.drawCircle(intakeL.pt, scale * 0.045, Paint()..color = const Color(0xFF0B0E14));
    canvas.drawCircle(intakeR.pt, scale * 0.045, Paint()..color = const Color(0xFF0B0E14));

    // ── Panel 3: Sculpted Hood / Bonnet with Center Power Crease ──
    final hoodPath = Path()
      ..moveTo(vHoodTipLeft.pt.dx, vHoodTipLeft.pt.dy)
      ..lineTo(vHoodTipCenter.pt.dx, vHoodTipCenter.pt.dy)
      ..lineTo(vHoodTipRight.pt.dx, vHoodTipRight.pt.dy)
      ..lineTo(vFenderFR.pt.dx, vFenderFR.pt.dy)
      ..lineTo(vCowlRight.pt.dx, vCowlRight.pt.dy)
      ..lineTo(vCowlCenter.pt.dx, vCowlCenter.pt.dy)
      ..lineTo(vCowlLeft.pt.dx, vCowlLeft.pt.dy)
      ..lineTo(vFenderFL.pt.dx, vFenderFL.pt.dy)
      ..close();

    canvas.drawPath(
      hoodPath,
      Paint()
        ..shader = LinearGradient(
          colors: [highlight, baseColor, shadow],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(hoodPath.getBounds()),
    );

    // Center Hood Power Spine Line
    canvas.drawLine(
      vHoodTipCenter.pt,
      vCowlCenter.pt,
      Paint()
        ..color = highlight.withValues(alpha: 0.7)
        ..strokeWidth = 2.0,
    );

    // Distinct Hood Air Extractor Scoops / Muscle Bulge
    if (isMuscle) {
      // Cowl induction scoop
      final scoop1 = project(-0.22, beltlineH - 0.12, 0.65);
      final scoop2 = project(0.22, beltlineH - 0.12, 0.65);
      canvas.drawLine(scoop1.pt, scoop2.pt, Paint()..color = const Color(0xFF0F172A)..strokeWidth = 4.5);
    } else {
      // Twin carbon heat extractors
      final vVentL1 = project(-0.28, beltlineH - 0.05, 0.82);
      final vVentL2 = project(-0.14, beltlineH - 0.05, 0.58);
      final vVentR1 = project(0.28, beltlineH - 0.05, 0.82);
      final vVentR2 = project(0.14, beltlineH - 0.05, 0.58);
      canvas.drawLine(vVentL1.pt, vVentL2.pt, Paint()..color = const Color(0xFF141922)..strokeWidth = 3.5);
      canvas.drawLine(vVentR1.pt, vVentR2.pt, Paint()..color = const Color(0xFF141922)..strokeWidth = 3.5);
    }

    // Racing Livery Stripes
    if (car.id == 'neon_gt' || car.id == 'shadow_v8') {
      for (final offset in [-0.07, 0.07]) {
        final p1 = project(offset, 0.04, noseZ - 0.12);
        final p2 = project(offset, beltlineH - 0.08, 0.28);
        canvas.drawLine(
          p1.pt,
          p2.pt,
          Paint()
            ..color = car.stripeColor.withValues(alpha: 0.85)
            ..strokeWidth = scale * 0.035,
        );
      }
    }

    // ── Panel 4: Sculpted Side Doors & Intercooler Air Scoops ──
    final sideL = Path()
      ..moveTo(vFenderFL.pt.dx, vFenderFL.pt.dy)
      ..lineTo(vCowlLeft.pt.dx, vCowlLeft.pt.dy)
      ..lineTo(vRoofRearLeft.pt.dx, vRoofRearLeft.pt.dy)
      ..lineTo(vHaunchRL.pt.dx, vHaunchRL.pt.dy)
      ..lineTo(vSkirtRearL.pt.dx, vSkirtRearL.pt.dy)
      ..lineTo(vSkirtFrontL.pt.dx, vSkirtFrontL.pt.dy)
      ..close();

    canvas.drawPath(
      sideL,
      Paint()
        ..shader = LinearGradient(
          colors: [highlight.withValues(alpha: 0.85), baseColor, deepShadow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(sideL.getBounds()),
    );

    final sideR = Path()
      ..moveTo(vFenderFR.pt.dx, vFenderFR.pt.dy)
      ..lineTo(vCowlRight.pt.dx, vCowlRight.pt.dy)
      ..lineTo(vRoofRearRight.pt.dx, vRoofRearRight.pt.dy)
      ..lineTo(vHaunchRR.pt.dx, vHaunchRR.pt.dy)
      ..lineTo(vSkirtRearR.pt.dx, vSkirtRearR.pt.dy)
      ..lineTo(vSkirtFrontR.pt.dx, vSkirtFrontR.pt.dy)
      ..close();

    canvas.drawPath(
      sideR,
      Paint()
        ..shader = LinearGradient(
          colors: [highlight.withValues(alpha: 0.85), baseColor, deepShadow],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ).createShader(sideR.getBounds()),
    );

    // Deep Side Intercooler Scoops
    final scoopDoorL = project(-cabinW * 1.05, 0.02, -0.15);
    final scoopDoorR = project(cabinW * 1.05, 0.02, -0.15);
    canvas.drawOval(Rect.fromCenter(center: scoopDoorL.pt, width: scale * 0.04, height: scale * 0.09), Paint()..color = const Color(0xFF0F172A));
    canvas.drawOval(Rect.fromCenter(center: scoopDoorR.pt, width: scale * 0.04, height: scale * 0.09), Paint()..color = const Color(0xFF0F172A));

    // ── Panel 5: Teardrop Aerodynamic Cockpit Glass & Horizon Sheen ──
    final windshieldPath = Path()
      ..moveTo(vCowlLeft.pt.dx, vCowlLeft.pt.dy)
      ..lineTo(vCowlCenter.pt.dx, vCowlCenter.pt.dy)
      ..lineTo(vCowlRight.pt.dx, vCowlRight.pt.dy)
      ..lineTo(vRoofFrontRight.pt.dx, vRoofFrontRight.pt.dy)
      ..lineTo(vRoofFrontCenter.pt.dx, vRoofFrontCenter.pt.dy)
      ..lineTo(vRoofFrontLeft.pt.dx, vRoofFrontLeft.pt.dy)
      ..close();

    canvas.drawPath(
      windshieldPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF38BDF8).withValues(alpha: 0.70), // Sky horizon reflection
            const Color(0xFF020617),
          ],
          stops: const [0.0, 0.45, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(windshieldPath.getBounds()),
    );

    // Windshield Specular Glare Line
    canvas.drawLine(
      Offset(vCowlLeft.pt.dx + 8, vCowlLeft.pt.dy - 4),
      Offset(vRoofFrontRight.pt.dx - 8, vRoofFrontRight.pt.dy + 4),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 2.0,
    );

    // Carbon Fiber Roof Panel
    final roofPath = Path()
      ..moveTo(vRoofFrontLeft.pt.dx, vRoofFrontLeft.pt.dy)
      ..lineTo(vRoofFrontCenter.pt.dx, vRoofFrontCenter.pt.dy)
      ..lineTo(vRoofFrontRight.pt.dx, vRoofFrontRight.pt.dy)
      ..lineTo(vRoofRearRight.pt.dx, vRoofRearRight.pt.dy)
      ..lineTo(vRoofRearCenter.pt.dx, vRoofRearCenter.pt.dy)
      ..lineTo(vRoofRearLeft.pt.dx, vRoofRearLeft.pt.dy)
      ..close();

    canvas.drawPath(
      roofPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(roofPath.getBounds()),
    );

    // ── Panel 6: Rear Haunches & Engine Deck ──
    final rearDeckPath = Path()
      ..moveTo(vRoofRearLeft.pt.dx, vRoofRearLeft.pt.dy)
      ..lineTo(vRoofRearCenter.pt.dx, vRoofRearCenter.pt.dy)
      ..lineTo(vRoofRearRight.pt.dx, vRoofRearRight.pt.dy)
      ..lineTo(vHaunchRR.pt.dx, vHaunchRR.pt.dy)
      ..lineTo(vDeckRight.pt.dx, vDeckRight.pt.dy)
      ..lineTo(vDeckCenter.pt.dx, vDeckCenter.pt.dy)
      ..lineTo(vDeckLeft.pt.dx, vDeckLeft.pt.dy)
      ..lineTo(vHaunchRL.pt.dx, vHaunchRL.pt.dy)
      ..close();

    canvas.drawPath(
      rearDeckPath,
      Paint()
        ..shader = LinearGradient(
          colors: [highlight, baseColor, shadow],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rearDeckPath.getBounds()),
    );

    // Rear Fascia & Diffuser
    final rearFascia = Path()
      ..moveTo(vDeckLeft.pt.dx, vDeckLeft.pt.dy)
      ..lineTo(vDeckCenter.pt.dx, vDeckCenter.pt.dy)
      ..lineTo(vDeckRight.pt.dx, vDeckRight.pt.dy)
      ..lineTo(vTailRight.pt.dx, vTailRight.pt.dy)
      ..lineTo(vTailCenter.pt.dx, vTailCenter.pt.dy)
      ..lineTo(vTailLeft.pt.dx, vTailLeft.pt.dy)
      ..close();

    canvas.drawPath(
      rearFascia,
      Paint()
        ..shader = LinearGradient(
          colors: [shadow, deepShadow, const Color(0xFF0B0E14)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rearFascia.getBounds()),
    );
  }

  // ─── 3D Aerodynamics & GT Wings ───────────────────────────────────────────
  static void _draw3DAerodynamics(
    Canvas canvas,
    _Point3D Function(double, double, double) project,
    CarModel car,
    double scale,
  ) {
    // 1. High-Downforce GT Carbon Wing
    final isTrackOrHyper = car.id == 'viper_rs' || car.id == 'inferno_x' || car.id == 'shadow_v8';
    final wingSpan = isTrackOrHyper ? 1.05 : 0.88;
    final wingH = isTrackOrHyper ? -0.52 : -0.42;

    final pWingL = project(-wingSpan, wingH, -1.06);
    final pWingR = project(wingSpan, wingH, -1.06);
    final pMountL = project(-0.32, -0.06, -0.92);
    final pMountR = project(0.32, -0.06, -0.92);

    // CNC Machined Wing Uprights / Struts
    final mountPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.2;
    canvas.drawLine(pMountL.pt, pWingL.pt, mountPaint);
    canvas.drawLine(pMountR.pt, pWingR.pt, mountPaint);

    // Carbon Wing Blade
    final wingBlade = Path()
      ..moveTo(pWingL.pt.dx, pWingL.pt.dy - 4)
      ..lineTo(pWingR.pt.dx, pWingR.pt.dy - 4)
      ..lineTo(pWingR.pt.dx, pWingR.pt.dy + 4)
      ..lineTo(pWingL.pt.dx, pWingL.pt.dy + 4)
      ..close();

    canvas.drawPath(
      wingBlade,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF0F172A), Color(0xFF475569)],
        ).createShader(wingBlade.getBounds()),
    );

    // Wing Aerodynamic Endplates
    final endplateColor = (car.id == 'viper_rs')
        ? car.bodyColor
        : (car.id == 'shadow_v8' ? const Color(0xFFFF1744) : car.neonUnderglowColor);
    canvas.drawLine(
      Offset(pWingL.pt.dx, pWingL.pt.dy - 9),
      Offset(pWingL.pt.dx, pWingL.pt.dy + 9),
      Paint()..color = endplateColor..strokeWidth = 3.6,
    );
    canvas.drawLine(
      Offset(pWingR.pt.dx, pWingR.pt.dy - 9),
      Offset(pWingR.pt.dx, pWingR.pt.dy + 9),
      Paint()..color = endplateColor..strokeWidth = 3.6,
    );

    // 2. Central Le Mans Shark Fin (Phantom R & Hypercar Protos)
    if (car.bodyStyle == CarBodyStyle.leMansHypercar || car.id == 'phantom_r') {
      final pFin1 = project(0.0, -0.46, 0.02);
      final pFin2 = project(0.0, -0.56, -0.96);
      final pFinBase = project(0.0, -0.16, -0.52);

      final fin = Path()
        ..moveTo(pFin1.pt.dx, pFin1.pt.dy)
        ..lineTo(pFin2.pt.dx, pFin2.pt.dy)
        ..lineTo(pFinBase.pt.dx, pFinBase.pt.dy)
        ..close();

      canvas.drawPath(
        fin,
        Paint()
          ..shader = LinearGradient(
            colors: [const Color(0xFF0F172A), car.neonUnderglowColor.withValues(alpha: 0.85)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(fin.getBounds()),
      );
    }
  }

  // ─── 3D Optics & Exhausts ──────────────────────────────────────────────────
  static void _drawOpticsAndExhausts(
    Canvas canvas,
    _Point3D Function(double, double, double) project,
    CarModel car,
    double scale,
    double yawAngle,
  ) {
    // 1. Angular LED Headlight Strips (DRLs)
    final pLightFL = project(-0.48, 0.02, 1.26);
    final pLightFR = project(0.48, 0.02, 1.26);

    final ledColor = (car.id == 'neon_gt')
        ? const Color(0xFF00E5FF)
        : (car.id == 'shadow_v8' ? const Color(0xFFFF5252) : const Color(0xFFE0F7FA));

    final ledPaint = Paint()
      ..color = ledColor
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = ledColor.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawLine(pLightFL.pt, Offset(pLightFL.pt.dx + 14, pLightFL.pt.dy - 5), ledPaint);
    canvas.drawLine(pLightFL.pt, Offset(pLightFL.pt.dx + 14, pLightFL.pt.dy - 5), glowPaint);

    canvas.drawLine(pLightFR.pt, Offset(pLightFR.pt.dx - 14, pLightFR.pt.dy - 5), ledPaint);
    canvas.drawLine(pLightFR.pt, Offset(pLightFR.pt.dx - 14, pLightFR.pt.dy - 5), glowPaint);

    // 2. Full-Width Cyber Taillight LED Lightbar
    final pTailL = project(-0.74, -0.02, -1.22);
    final pTailR = project(0.74, -0.02, -1.22);

    final tailColor = (car.id == 'phantom_r') ? const Color(0xFF00E5FF) : const Color(0xFFFF1744);

    canvas.drawLine(
      pTailL.pt,
      pTailR.pt,
      Paint()
        ..color = tailColor
        ..strokeWidth = 3.6
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      pTailL.pt,
      pTailR.pt,
      Paint()
        ..color = tailColor.withValues(alpha: 0.85)
        ..strokeWidth = 8.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 3. Titanium Exhaust Ports
    final isQuadExhaust = car.id == 'inferno_x' || car.id == 'shadow_v8';
    final exhaustPositions = isQuadExhaust
        ? [-0.22, -0.08, 0.08, 0.22]
        : [-0.18, 0.18];

    for (final offX in exhaustPositions) {
      final p = project(offX, 0.14, -1.24);
      canvas.drawCircle(p.pt, 5.2, Paint()..color = const Color(0xFF0F172A));
      canvas.drawCircle(
        p.pt,
        4.0,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFFFF9100), Color(0xFF00E5FF), Color(0xFF263238)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: p.pt, radius: 4.0)),
      );
    }
  }
}

class _WheelDef {
  final bool isFront;
  final bool isLeft;
  final List<double> pos;
  _WheelDef(this.isFront, this.isLeft, this.pos);
}

class _WheelInstance {
  final bool isFront;
  final bool isLeft;
  final _Point3D proj;
  final List<double> pos;
  _WheelInstance(this.isFront, this.isLeft, this.proj, this.pos);
}

class _Point3D {
  final Offset pt;
  final double depth;
  final double depthFactor;
  const _Point3D(this.pt, this.depth, this.depthFactor);
}
