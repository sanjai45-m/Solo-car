import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum ParticleType {
  nitroFlame,
  tireSmoke,
  collisionSpark,
  speedLine,
  ambientDust,
}

class VisualParticle {
  Vector2 position;
  Vector2 velocity;
  double life;
  final double maxLife;
  final double size;
  final Color color;
  final ParticleType type;

  VisualParticle({
    required this.position,
    required this.velocity,
    required this.maxLife,
    required this.size,
    required this.color,
    required this.type,
  }) : life = maxLife;

  bool update(double dt) {
    life -= dt;
    position += velocity * dt;

    if (type == ParticleType.tireSmoke) {
      velocity *= 0.90;
    } else if (type == ParticleType.collisionSpark) {
      velocity.y += 300 * dt;
    }
    return life > 0;
  }

  void render(Canvas canvas) {
    final progress = (life / maxLife).clamp(0.0, 1.0);
    final alpha = (progress * 255).toInt().clamp(0, 255);
    final screenPos = Offset(position.x, position.y);

    switch (type) {
      case ParticleType.nitroFlame:
        final flamePaint = Paint()
          ..color = color.withAlpha(alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(screenPos, size * progress, flamePaint);
        break;

      case ParticleType.tireSmoke:
        final smokePaint = Paint()
          ..color = color.withAlpha((alpha * 0.45).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(screenPos, size * (1.6 - progress * 0.6), smokePaint);
        break;

      case ParticleType.collisionSpark:
        final sparkPaint = Paint()
          ..color = color.withAlpha(alpha)
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;
        final tail = screenPos - Offset(velocity.x * 0.04, velocity.y * 0.04);
        canvas.drawLine(screenPos, tail, sparkPaint);
        break;

      case ParticleType.speedLine:
        final linePaint = Paint()
          ..color = Colors.white.withAlpha((alpha * 0.4).toInt())
          ..strokeWidth = size
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          screenPos,
          screenPos + Offset(0, 60 + progress * 40),
          linePaint,
        );
        break;

      case ParticleType.ambientDust:
        final dustPaint = Paint()..color = color.withAlpha((alpha * 0.25).toInt());
        canvas.drawCircle(screenPos, size, dustPaint);
        break;
    }
  }
}

class ApexParticleSystem extends Component {
  final List<VisualParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void update(double dt) {
    super.update(dt);
    _particles.removeWhere((p) => !p.update(dt));
  }

  void emitNitroFlames({
    required double carScreenX,
    required double carScreenY,
    required double carScale,
  }) {
    final w = 145.0 * carScale;
    final h = 90.0 * carScale;

    final leftExhaust = Vector2(carScreenX - w * 0.22, carScreenY + h * 0.40);
    final rightExhaust = Vector2(carScreenX + w * 0.22, carScreenY + h * 0.40);

    for (int i = 0; i < 2; i++) {
      final origin = i == 0 ? leftExhaust : rightExhaust;

      // Outer Flame Cone (Cyan / Blue / Orange)
      _particles.add(
        VisualParticle(
          position: origin.clone(),
          velocity: Vector2((_random.nextDouble() - 0.5) * 20, 140 + _random.nextDouble() * 160),
          maxLife: 0.18 + _random.nextDouble() * 0.10,
          size: (12.0 + _random.nextDouble() * 10.0) * carScale,
          color: _random.nextBool() ? const Color(0xFF00E5FF) : const Color(0xFFFF6D00),
          type: ParticleType.nitroFlame,
        ),
      );

      // Inner Core Flame (Intense White / Yellow Plasma)
      _particles.add(
        VisualParticle(
          position: origin.clone(),
          velocity: Vector2((_random.nextDouble() - 0.5) * 10, 180 + _random.nextDouble() * 140),
          maxLife: 0.12 + _random.nextDouble() * 0.08,
          size: (6.0 + _random.nextDouble() * 5.0) * carScale,
          color: const Color(0xFFFFFF8D),
          type: ParticleType.nitroFlame,
        ),
      );
    }
  }

  void emitDriftSmoke({
    required double carScreenX,
    required double carScreenY,
    required double carScale,
    required double intensity,
  }) {
    if (_random.nextDouble() > intensity.clamp(0.2, 0.95)) return;

    final w = 145.0 * carScale;
    final h = 90.0 * carScale;

    final leftTire = Vector2(carScreenX - w * 0.44, carScreenY + h * 0.28);
    final rightTire = Vector2(carScreenX + w * 0.44, carScreenY + h * 0.28);

    for (final tire in [leftTire, rightTire]) {
      final vx = (_random.nextDouble() - 0.5) * 60;
      final vy = 10 + _random.nextDouble() * 30;

      _particles.add(
        VisualParticle(
          position: tire.clone(),
          velocity: Vector2(vx, vy),
          maxLife: 0.40 + _random.nextDouble() * 0.30,
          size: (22.0 + _random.nextDouble() * 18.0) * carScale,
          color: const Color(0xFFEEEEEE),
          type: ParticleType.tireSmoke,
        ),
      );
    }
  }

  void emitSpeedLines({
    required Size screenSize,
  }) {
    if (_random.nextDouble() > 0.40) return;

    final x = _random.nextDouble() * screenSize.width;
    final y = _random.nextDouble() * (screenSize.height * 0.6);

    _particles.add(
      VisualParticle(
        position: Vector2(x, y),
        velocity: Vector2(0, 1100),
        maxLife: 0.22,
        size: 1.8 + _random.nextDouble() * 2.2,
        color: Colors.white,
        type: ParticleType.speedLine,
      ),
    );
  }

  void renderParticles(Canvas canvas) {
    for (final p in _particles) {
      p.render(canvas);
    }
  }
}
