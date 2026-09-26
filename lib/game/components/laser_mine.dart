import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Laser Road Mine deployed on the track
class LaserMine extends PositionComponent {
  final bool isPlayerMine;
  double trackZ = 0.0;
  double trackX = 0.0;
  double _lifeTime = 0.0;
  bool isDetonated = false;

  LaserMine({
    required Vector2 position,
    this.isPlayerMine = true,
    this.trackZ = 0.0,
    this.trackX = 0.0,
  }) : super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTime += dt;
  }

  void render3D(
    Canvas canvas, {
    required double screenX,
    required double screenY,
    required double scale,
  }) {
    if (isDetonated || scale <= 0.001) return;

    final pulse = 0.8 + 0.2 * sin(_lifeTime * 10.0);
    final w = 32.0 * scale;

    canvas.save();
    canvas.translate(screenX, screenY);

    // Hazard Area Ring
    final ringPaint = Paint()
      ..color = const Color(0xFFFF3D00).withValues(alpha: 0.35 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.2, scale * 1.5);
    canvas.drawCircle(Offset.zero, w * 0.75 * pulse, ringPaint);

    // Core Mine Base
    final corePaint = Paint()
      ..color = const Color(0xFF1E0A0A)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFFFF3D00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.5, scale * 2.0);

    canvas.drawCircle(Offset.zero, w * 0.45, corePaint);
    canvas.drawCircle(Offset.zero, w * 0.45, strokePaint);

    // Pulsing Red Laser Center
    final centerPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, max(3.0, w * 0.2));
    canvas.drawCircle(Offset.zero, max(2.0, w * 0.22 * pulse), centerPaint);

    canvas.restore();
  }

  @override
  void render(Canvas canvas) {
    render3D(canvas, screenX: size.x / 2, screenY: size.y / 2, scale: 1.0);
  }
}
