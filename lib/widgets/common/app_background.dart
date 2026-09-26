import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Cinematic 3D Car Racing Background Wallpaper with live animated floating cyber particles and ambient glow
class AppBackground extends StatefulWidget {
  final Widget child;
  final double overlayOpacity;

  const AppBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.75,
  });

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground> with SingleTickerProviderStateMixin {
  late AnimationController _particleController;
  final List<_CyberParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize 24 subtle ambient floating particles
    for (int i = 0; i < 24; i++) {
      _particles.add(
        _CyberParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.15 + _random.nextDouble() * 0.35,
          radius: 1.0 + _random.nextDouble() * 2.2,
          opacity: 0.15 + _random.nextDouble() * 0.40,
          color: i % 3 == 0
              ? const Color(0xFF00E5FF)
              : (i % 3 == 1 ? const Color(0xFFFF007F) : const Color(0xFFFFD600)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. High-Resolution 3D Supercar Racing Artwork
        Image.asset(
          'assets/images/splash_art_3d.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF070B12),
          ),
        ),

        // 2. Dark Cyberpunk Atmospheric Tint & Vignette Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(7, 11, 20, widget.overlayOpacity),
                Color.fromRGBO(3, 5, 10, (widget.overlayOpacity + 0.12).clamp(0.0, 0.96)),
              ],
            ),
          ),
        ),

        // 3. Live Animated Ambient Particle Layer
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, _) {
            return CustomPaint(
              painter: _AmbientParticlesPainter(
                particles: _particles,
                progress: _particleController.value,
              ),
            );
          },
        ),

        // 4. Subtle Ambient Corner Glows
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.10),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF007F).withValues(alpha: 0.08),
            ),
          ),
        ),

        // 5. Foreground Screen Content
        widget.child,
      ],
    );
  }
}

class _CyberParticle {
  double x;
  double y;
  final double speed;
  final double radius;
  final double opacity;
  final Color color;

  _CyberParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.opacity,
    required this.color,
  });
}

class _AmbientParticlesPainter extends CustomPainter {
  final List<_CyberParticle> particles;
  final double progress;

  _AmbientParticlesPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final curY = (p.y - progress * p.speed) % 1.0;
      final curX = (p.x + math.sin(progress * 2 * math.pi + p.speed * 10) * 0.02) % 1.0;

      final px = curX * size.width;
      final py = curY * size.height;

      paint.color = p.color.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(px, py), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlesPainter oldDelegate) => true;
}
