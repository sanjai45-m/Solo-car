import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum PickupType { nitroRefill, cashBonus, repairKit }

class PickupItem extends PositionComponent {
  final PickupType type;
  double trackZ;
  double trackX;
  double pulseTimer = 0.0;

  PickupItem({
    required super.position,
    required this.type,
    required this.trackZ,
    required this.trackX,
  }) : super(
          size: Vector2(40.0, 40.0),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    pulseTimer += dt * 4.0;
  }

  void render3D(
    Canvas canvas, {
    required double screenX,
    required double screenY,
    required double scale,
  }) {
    if (scale <= 0.001) return;

    final baseRadius = 32.0 * scale;
    final pulseScale = 1.0 + math.sin(pulseTimer) * 0.15;
    final r = baseRadius * pulseScale;

    if (r < 1.0) return;

    canvas.save();
    canvas.translate(screenX, screenY - r);

    Color glowColor;
    Color coreColor;

    switch (type) {
      case PickupType.nitroRefill:
        glowColor = const Color(0xFF00E5FF);
        coreColor = const Color(0xFF00B0FF);
        break;
      case PickupType.cashBonus:
        glowColor = const Color(0xFFFFD600);
        coreColor = const Color(0xFFFFAB00);
        break;
      case PickupType.repairKit:
        glowColor = const Color(0xFF00E676);
        coreColor = const Color(0xFF00C853);
        break;
    }

    // Outer Glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.6)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(2.0, r * 0.6));
    canvas.drawCircle(Offset.zero, r * 1.4, glowPaint);

    // Core Orb
    final corePaint = Paint()..color = coreColor;
    canvas.drawCircle(Offset.zero, r, corePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, r * 0.15);
    canvas.drawCircle(Offset.zero, r, borderPaint);

    canvas.restore();
  }
}
