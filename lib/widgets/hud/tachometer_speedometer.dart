import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TachometerSpeedometer extends StatelessWidget {
  final double speedKmH;
  final double rpmRatio; // 0.0 to 1.0

  const TachometerSpeedometer({
    super.key,
    required this.speedKmH,
    required this.rpmRatio,
  });

  int get currentGear {
    if (speedKmH < 5) return 1;
    if (speedKmH < 70) return 1;
    if (speedKmH < 130) return 2;
    if (speedKmH < 190) return 3;
    if (speedKmH < 250) return 4;
    if (speedKmH < 310) return 5;
    return 6;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x990A0E17),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom RPM Arc Painter
          CustomPaint(
            size: const Size(140, 140),
            painter: _RpmGaugePainter(rpmRatio: rpmRatio),
          ),

          // Center Speedometer & Gear readout
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                speedKmH.toInt().toString().padLeft(3, '0'),
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'KM/H',
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00E5FF),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              // Gear badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'GEAR $currentGear',
                  style: GoogleFonts.orbitron(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RpmGaugePainter extends CustomPainter {
  final double rpmRatio;
  _RpmGaugePainter({required this.rpmRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    const startAngle = 135 * math.pi / 180;
    const sweepAngle = 270 * math.pi / 180;

    // Background track arc
    final trackPaint = Paint()
      ..color = const Color(0xFF1E2A38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Active RPM Gradient arc
    final activePaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          Color(0xFF00E5FF),
          Color(0xFFFFD600),
          Color(0xFFFF1744),
        ],
        stops: const [0.0, 0.6, 1.0],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final currentSweep = sweepAngle * rpmRatio.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(_RpmGaugePainter oldDelegate) =>
      oldDelegate.rpmRatio != rpmRatio;
}
