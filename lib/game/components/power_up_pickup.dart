import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/power_up_model.dart';

/// Holographic 3D Floating Power-Up Box on the track
class PowerUpPickup extends PositionComponent {
  final PowerUpType type;
  double trackZ = 0.0;
  double trackX = 0.0;
  double _time = 0.0;
  bool isCollected = false;

  PowerUpPickup({
    required Vector2 position,
    required this.type,
    this.trackZ = 0.0,
    this.trackX = 0.0,
  }) : super(
          position: position,
          size: Vector2(36, 36),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  void render3D(
    Canvas canvas, {
    required double screenX,
    required double screenY,
    required double scale,
  }) {
    if (isCollected || scale <= 0.001) return;

    final pulse = 0.85 + 0.15 * sin(_time * 6.0);
    final rotation = _time * 2.5;
    final w = 36.0 * scale * pulse;

    canvas.save();
    canvas.translate(screenX, screenY);

    // Outer Neon Aura
    final auraPaint = Paint()
      ..color = type.primaryColor.withValues(alpha: 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, max(4.0, w * 0.4));
    canvas.drawCircle(Offset.zero, w * 0.6, auraPaint);

    // Rotating 3D Diamond / Cube
    canvas.rotate(rotation);
    final boxPaint = Paint()
      ..color = const Color(0xDD070B14)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = type.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.5, scale * 2.0);

    final rect = Rect.fromCenter(center: Offset.zero, width: w * 0.7, height: w * 0.7);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), boxPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), strokePaint);

    // Inner Glyph
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, max(2.0, w * 0.12), innerPaint);

    canvas.restore();
  }

  @override
  void render(Canvas canvas) {
    render3D(canvas, screenX: size.x / 2, screenY: size.y / 2, scale: 1.0);
  }
}
