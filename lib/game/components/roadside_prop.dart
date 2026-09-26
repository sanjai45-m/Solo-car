import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/race_model.dart';

enum PropType {
  streetLamp,
  billboard,
  skyscraper,
  cyberTower,
  commercialComplex,
  overheadGantry,
  palmTree,
  pineTree,
  mountainRock,
  barrier,
  rockCactus,
}

class RoadsideProp {
  final PropType type;
  final double sideOffset; // Negative for left (e.g. -1.4), positive for right (e.g. 1.4)
  final double baseHeight;
  final double baseWidth;
  final Color primaryColor;
  final Color secondaryColor;
  final String label;

  const RoadsideProp({
    required this.type,
    required this.sideOffset,
    required this.baseHeight,
    required this.baseWidth,
    required this.primaryColor,
    required this.secondaryColor,
    this.label = '',
  });

  void render3D(
    Canvas canvas, {
    required double screenX,
    required double screenY,
    required double scale,
    required double roadWidthOnScreen,
    required EnvironmentType env,
    required TimeOfDayType timeOfDay,
  }) {
    final propX = screenX + (sideOffset * roadWidthOnScreen);
    final propY = screenY;
    final w = baseWidth * scale * 3.8;
    final h = baseHeight * scale * 3.8;

    if (w < 1 || h < 1) return; // Culling tiny objects

    canvas.save();
    canvas.translate(propX, propY);

    switch (type) {
      case PropType.skyscraper:
        _render3DSkyscraper(canvas, w, h, timeOfDay);
        break;
      case PropType.cyberTower:
        _render3DCyberTower(canvas, w, h, timeOfDay);
        break;
      case PropType.commercialComplex:
        _render3DCommercialComplex(canvas, w, h, timeOfDay);
        break;
      case PropType.overheadGantry:
        _renderOverheadGantry(canvas, w, h, roadWidthOnScreen);
        break;
      case PropType.billboard:
        _renderBillboard(canvas, w, h, timeOfDay);
        break;
      case PropType.streetLamp:
        _renderStreetLamp(canvas, w, h, timeOfDay);
        break;
      case PropType.pineTree:
        _renderPineTree(canvas, w, h);
        break;
      case PropType.mountainRock:
        _renderMountainRock(canvas, w, h);
        break;
      case PropType.palmTree:
        _renderPalmTree(canvas, w, h);
        break;
      case PropType.barrier:
        _renderBarrier(canvas, w, h);
        break;
      case PropType.rockCactus:
        _renderRockCactus(canvas, w, h);
        break;
    }

    canvas.restore();
  }

  // 1. True 3D Volumetric Skyscraper with visible 3D extruded side face & roof
  void _render3DSkyscraper(Canvas canvas, double w, double h, TimeOfDayType timeOfDay) {
    final isLeft = sideOffset < 0;
    final depthW = w * 0.35; // 3D perspective depth extrusion

    // Ground Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.55)..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(2.0, w * 0.1));
    canvas.drawRect(Rect.fromCenter(center: Offset(0, 0), width: w * 1.4, height: h * 0.08), shadowPaint);

    // 3D Side Extrusion Face (facing the road)
    final sidePath = Path()
      ..moveTo(isLeft ? w / 2 : -w / 2, -h)
      ..lineTo(isLeft ? (w / 2 + depthW) : (-w / 2 - depthW), -h + (h * 0.05))
      ..lineTo(isLeft ? (w / 2 + depthW) : (-w / 2 - depthW), 0)
      ..lineTo(isLeft ? w / 2 : -w / 2, 0)
      ..close();
    final sideShadeColor = Color.lerp(primaryColor, Colors.black, 0.45)!;
    canvas.drawPath(sidePath, Paint()..color = sideShadeColor);

    // Front Face
    final frontRect = Rect.fromLTWH(-w / 2, -h, w, h);
    final frontPaint = Paint()..color = primaryColor;
    canvas.drawRect(frontRect, frontPaint);

    // Rooftop Slab / Helipad
    final roofPath = Path()
      ..moveTo(-w / 2, -h)
      ..lineTo(w / 2, -h)
      ..lineTo(isLeft ? (w / 2 + depthW) : (w / 2 - depthW), -h - (h * 0.03))
      ..lineTo(isLeft ? (-w / 2 + depthW) : (-w / 2 - depthW), -h - (h * 0.03))
      ..close();
    canvas.drawPath(roofPath, Paint()..color = Color.lerp(primaryColor, Colors.white, 0.25)!);

    // Rooftop Radio Mast Antenna with Blinking Beacon Light
    final antennaH = h * 0.22;
    canvas.drawLine(
      Offset(0, -h),
      Offset(0, -h - antennaH),
      Paint()..color = const Color(0xFFCFD8DC)..strokeWidth = math.max(1.5, w * 0.02),
    );
    final beaconGlow = Paint()..color = const Color(0xFFFF1744)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(0, -h - antennaH), math.max(2.5, w * 0.03), beaconGlow);

    // Illuminated Animated Window Matrix
    final isNight = timeOfDay == TimeOfDayType.night;
    final winW = math.max(2.0, w * 0.10);
    final winH = math.max(3.0, h * 0.05);
    final stepX = math.max(3.5, w * 0.18);
    final stepY = math.max(4.5, h * 0.08);

    final litWinPaint = Paint()..color = isNight ? secondaryColor.withValues(alpha: 0.9) : const Color(0xFF81D4FA);
    final litWarmPaint = Paint()..color = isNight ? const Color(0xFFFFD54F) : const Color(0xFFECEFF1);
    final darkWinPaint = Paint()..color = const Color(0xFF1A2332);

    for (double x = -w / 2 + stepX * 0.4; x < w / 2 - winW; x += stepX) {
      for (double y = -h + stepY * 0.6; y < -stepY * 0.4; y += stepY) {
        final hash = (x.toInt() * 73 + y.toInt() * 31).abs();
        Paint p;
        if (hash % 5 == 0) {
          p = litWinPaint;
        } else if (hash % 5 == 1) {
          p = litWarmPaint;
        } else {
          p = darkWinPaint;
        }
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, winW, winH), const Radius.circular(1)), p);
      }
    }

    // Neon Rooftop Crown Signage
    final crownRect = Rect.fromLTWH(-w * 0.4, -h + (h * 0.04), w * 0.8, h * 0.06);
    final crownGlow = Paint()..color = secondaryColor.withValues(alpha: 0.8)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(RRect.fromRectAndRadius(crownRect, const Radius.circular(2)), crownGlow);
  }

  // 2. 3D Cyber Tower with Stepped Tiers & Vertical Neon Light Bars
  void _render3DCyberTower(Canvas canvas, double w, double h, TimeOfDayType timeOfDay) {
    final isLeft = sideOffset < 0;
    final depthW = w * 0.3;

    // 3 Tiers (Base, Mid, Spire)
    for (int tier = 0; tier < 3; tier++) {
      final tierProgress = tier / 3.0;
      final tierW = w * (1.0 - (tierProgress * 0.35));
      final tierH = h * (0.45 - (tierProgress * 0.10));
      final double tierY = -(tier == 0 ? 0.0 : (h * 0.40 + (tier == 2 ? h * 0.30 : 0.0)));

      // Side extrusion
      final sidePath = Path()
        ..moveTo(isLeft ? tierW / 2 : -tierW / 2, tierY - tierH)
        ..lineTo(isLeft ? (tierW / 2 + depthW) : (-tierW / 2 - depthW), tierY - tierH + (tierH * 0.06))
        ..lineTo(isLeft ? (tierW / 2 + depthW) : (-tierW / 2 - depthW), tierY)
        ..lineTo(isLeft ? tierW / 2 : -tierW / 2, tierY)
        ..close();
      canvas.drawPath(sidePath, Paint()..color = Color.lerp(primaryColor, Colors.black, 0.4)!);

      // Front Face
      final frontRect = Rect.fromLTWH(-tierW / 2, tierY - tierH, tierW, tierH);
      canvas.drawRect(frontRect, Paint()..color = primaryColor);

      // Vertical Neon Light Strip
      final neonPaint = Paint()..color = secondaryColor..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRect(Rect.fromLTWH(-tierW * 0.06, tierY - tierH, tierW * 0.12, tierH), neonPaint);
    }
  }

  // 3. 3D Modern Commercial Complex with Glass Atrium
  void _render3DCommercialComplex(Canvas canvas, double w, double h, TimeOfDayType timeOfDay) {
    final isLeft = sideOffset < 0;
    final depthW = w * 0.4;

    // Side face
    final sidePath = Path()
      ..moveTo(isLeft ? w / 2 : -w / 2, -h)
      ..lineTo(isLeft ? (w / 2 + depthW) : (-w / 2 - depthW), -h + (h * 0.08))
      ..lineTo(isLeft ? (w / 2 + depthW) : (-w / 2 - depthW), 0)
      ..lineTo(isLeft ? w / 2 : -w / 2, 0)
      ..close();
    canvas.drawPath(sidePath, Paint()..color = const Color(0xFF1E2838));

    // Front Face
    final frontRect = Rect.fromLTWH(-w / 2, -h, w, h);
    canvas.drawRect(frontRect, Paint()..color = const Color(0xFF263238));

    // Glass Atrium Facade (Cyan glass with reflection)
    final glassRect = Rect.fromLTWH(-w * 0.4, -h * 0.85, w * 0.8, h * 0.70);
    final glassPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF00E5FF).withValues(alpha: 0.7), const Color(0xFF0D47A1).withValues(alpha: 0.9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(glassRect);
    canvas.drawRRect(RRect.fromRectAndRadius(glassRect, const Radius.circular(2)), glassPaint);

    // Entrance Lobby
    final lobbyRect = Rect.fromLTWH(-w * 0.25, -h * 0.15, w * 0.50, h * 0.15);
    canvas.drawRect(lobbyRect, Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.9));
  }

  // 4. Overhead Highway Gantry Sign Truss
  void _renderOverheadGantry(Canvas canvas, double w, double h, double roadWidthOnScreen) {
    final spanW = roadWidthOnScreen * 2.4;
    final gantryH = h * 0.9;

    // Steel Pillars on Left & Right
    final pillarPaint = Paint()..color = const Color(0xFF455A64);
    canvas.drawRect(Rect.fromLTWH(-spanW / 2, -gantryH, w * 0.08, gantryH), pillarPaint);
    canvas.drawRect(Rect.fromLTWH(spanW / 2 - (w * 0.08), -gantryH, w * 0.08, gantryH), pillarPaint);

    // Cross Truss Bar
    final trussRect = Rect.fromLTWH(-spanW / 2, -gantryH, spanW, gantryH * 0.25);
    canvas.drawRRect(RRect.fromRectAndRadius(trussRect, const Radius.circular(2)), pillarPaint);

    // Overhead Digital Signs (Left & Right lane guidance)
    final signW = spanW * 0.35;
    final signH = gantryH * 0.20;
    final signY = -gantryH + (gantryH * 0.025);

    // Left Sign
    final signLeftRect = Rect.fromLTWH(-spanW * 0.40, signY, signW, signH);
    canvas.drawRRect(RRect.fromRectAndRadius(signLeftRect, const Radius.circular(2)), Paint()..color = const Color(0xFF00C853));
    // Right Sign
    final signRightRect = Rect.fromLTWH(spanW * 0.05, signY, signW, signH);
    canvas.drawRRect(RRect.fromRectAndRadius(signRightRect, const Radius.circular(2)), Paint()..color = const Color(0xFF00B0FF));
  }

  void _renderBillboard(Canvas canvas, double w, double h, TimeOfDayType timeOfDay) {
    final framePaint = Paint()..color = const Color(0xFF212121);
    final boardRect = Rect.fromLTWH(-w / 2, -h, w, h * 0.7);

    // Pillars
    canvas.drawRect(Rect.fromLTWH(-w * 0.35, -h * 0.35, w * 0.08, h * 0.35), framePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.27, -h * 0.35, w * 0.08, h * 0.35), framePaint);

    // Board outline & background
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect, const Radius.circular(3)), framePaint);

    final posterRect = boardRect.deflate(math.max(1.5, w * 0.04));
    final posterPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(posterRect);
    canvas.drawRect(posterRect, posterPaint);

    if (timeOfDay == TimeOfDayType.night) {
      final glowPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, math.max(3.0, w * 0.08));
      canvas.drawRect(boardRect, glowPaint);
    }
  }

  void _renderStreetLamp(Canvas canvas, double w, double h, TimeOfDayType timeOfDay) {
    final polePaint = Paint()..color = const Color(0xFF757575);
    final armDir = sideOffset < 0 ? 1.0 : -1.0;
    final lampArm = armDir * (w * 0.7);

    // Pole
    canvas.drawRect(Rect.fromLTWH(-w * 0.08, -h, w * 0.16, h), polePaint);
    // Arm
    final armPath = Path()
      ..moveTo(0, -h)
      ..quadraticBezierTo(lampArm * 0.5, -h - (h * 0.08), lampArm, -h + (h * 0.05));
    canvas.drawPath(
      armPath,
      Paint()
        ..color = const Color(0xFF9E9E9E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.0, w * 0.12),
    );

    // Lamp fixture
    final bulbCenter = Offset(lampArm, -h + (h * 0.05));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: bulbCenter, width: w * 0.35, height: h * 0.08),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF424242),
    );

    if (timeOfDay == TimeOfDayType.night || timeOfDay == TimeOfDayType.sunset) {
      final glowRadius = math.max(10.0, h * 0.55);
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF9C4).withValues(alpha: 0.8),
            const Color(0xFFFFD54F).withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: bulbCenter, radius: glowRadius),
        );
      canvas.drawCircle(bulbCenter, glowRadius, glowPaint);
    }
  }

  void _renderPineTree(Canvas canvas, double w, double h) {
    // Tree Shadow on grass
    final shadowPaint = Paint()..color = const Color(0x33000000);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.1, 0), width: w * 0.9, height: h * 0.15),
      shadowPaint,
    );

    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w * 0.08, -h * 0.25, w * 0.16, h * 0.25),
        const Radius.circular(2),
      ),
      trunkPaint,
    );

    // Tiered Pine Foliage (3 layered cones with shading)
    final darkGreen = const Color(0xFF1B5E20);
    final lightGreen = const Color(0xFF2E7D32);
    final highlightGreen = const Color(0xFF43A047);

    for (int i = 0; i < 4; i++) {
      final tierProgress = i / 3.0;
      final tierY = -h * 0.20 - (tierProgress * h * 0.65);
      final tierW = w * (1.0 - (tierProgress * 0.35));
      final tierH = h * 0.32;

      // Dark side (left)
      final leftPath = Path()
        ..moveTo(0, tierY - tierH)
        ..lineTo(-tierW / 2, tierY)
        ..lineTo(0, tierY - (tierH * 0.15))
        ..close();
      canvas.drawPath(leftPath, Paint()..color = (i % 2 == 0) ? darkGreen : const Color(0xFF134E17));

      // Light side (right)
      final rightPath = Path()
        ..moveTo(0, tierY - tierH)
        ..lineTo(tierW / 2, tierY)
        ..lineTo(0, tierY - (tierH * 0.15))
        ..close();
      canvas.drawPath(rightPath, Paint()..color = (i == 3) ? highlightGreen : lightGreen);
    }
  }

  void _renderMountainRock(Canvas canvas, double w, double h) {
    final rockShadow = Paint()..color = const Color(0x40000000);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.05, 0), width: w * 1.1, height: h * 0.25),
      rockShadow,
    );

    // Faceted boulder polygons
    final darkRock = const Color(0xFF455A64);
    final midRock = const Color(0xFF607D8B);
    final lightRock = const Color(0xFF78909C);

    // Base boulder
    final baseRock = Path()
      ..moveTo(-w * 0.45, 0)
      ..lineTo(-w * 0.5, -h * 0.4)
      ..lineTo(-w * 0.2, -h * 0.9)
      ..lineTo(w * 0.25, -h * 0.85)
      ..lineTo(w * 0.48, -h * 0.35)
      ..lineTo(w * 0.42, 0)
      ..close();
    canvas.drawPath(baseRock, Paint()..color = midRock);

    // Shadow facet
    final shadowFacet = Path()
      ..moveTo(-w * 0.45, 0)
      ..lineTo(-w * 0.5, -h * 0.4)
      ..lineTo(-w * 0.2, -h * 0.9)
      ..lineTo(0, -h * 0.4)
      ..lineTo(-w * 0.1, 0)
      ..close();
    canvas.drawPath(shadowFacet, Paint()..color = darkRock);

    // Highlight facet
    final highlightFacet = Path()
      ..moveTo(-w * 0.2, -h * 0.9)
      ..lineTo(w * 0.25, -h * 0.85)
      ..lineTo(w * 0.1, -h * 0.45)
      ..lineTo(0, -h * 0.4)
      ..close();
    canvas.drawPath(highlightFacet, Paint()..color = lightRock);
  }

  void _renderPalmTree(Canvas canvas, double w, double h) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = math.max(3.0, w * 0.16)
      ..strokeCap = StrokeCap.round;
    final bend = (sideOffset < 0 ? 1 : -1) * (w * 0.25);
    canvas.drawLine(Offset.zero, Offset(bend, -h), trunkPaint);

    final frondPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..strokeWidth = math.max(2.0, w * 0.12)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 7; i++) {
      final angle = (i * 51) * math.pi / 180;
      canvas.drawLine(
        Offset(bend, -h),
        Offset(bend + math.cos(angle) * w * 0.65, -h + math.sin(angle) * h * 0.28),
        frondPaint,
      );
    }
  }

  void _renderBarrier(Canvas canvas, double w, double h) {
    final barrierRect = Rect.fromLTWH(-w / 2, -h, w, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barrierRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFFCFD8DC),
    );
    canvas.drawRect(
      Rect.fromLTWH(-w / 2, -h + h * 0.25, w, h * 0.35),
      Paint()..color = const Color(0xFFFFC107),
    );
  }

  void _renderRockCactus(Canvas canvas, double w, double h) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w * 0.18, -h, w * 0.36, h),
        Radius.circular(w * 0.15),
      ),
      Paint()..color = const Color(0xFF2E7D32),
    );
  }
}


