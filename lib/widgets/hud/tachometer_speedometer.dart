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
    final isRedlining = rpmRatio > 0.90;
    final primaryGlow = isRedlining ? const Color(0xFFFF1744) : const Color(0xFF00E5FF);

    return Container(
      width: 155,
      height: 155,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xCC060A14),
        border: Border.all(
          color: primaryGlow.withValues(alpha: isRedlining ? 0.8 : 0.35),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGlow.withValues(alpha: isRedlining ? 0.45 : 0.15),
            blurRadius: 20,
            spreadRadius: isRedlining ? 2 : 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Dynamic Tachometer RPM Sweep Arc & Ticks
          CustomPaint(
            size: const Size(155, 155),
            painter: _ModernRpmPainter(rpmRatio: rpmRatio),
          ),

          // 2. Sequential LED Shift Lights (Formula 1 / GT3 Style)
          Positioned(
            top: 22,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(8, (index) {
                final threshold = (index + 1) / 8.0;
                final isActive = rpmRatio >= threshold;
                Color ledColor;
                if (index < 3) {
                  ledColor = const Color(0xFF00E676); // Green
                } else if (index < 6) {
                  ledColor = const Color(0xFFFFD600); // Yellow
                } else {
                  ledColor = const Color(0xFFFF1744); // Red
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  width: 5.5,
                  height: 6.5,
                  decoration: BoxDecoration(
                    color: isActive ? ledColor : Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isActive
                        ? [BoxShadow(color: ledColor.withValues(alpha: 0.8), blurRadius: 6, spreadRadius: 1)]
                        : [],
                  ),
                );
              }),
            ),
          ),

          // 3. Center OLED Digital Speedometer & Gear readout
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Speed Digits
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    speedKmH.toInt().toString().padLeft(3, '0'),
                    style: GoogleFonts.orbitron(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: primaryGlow.withValues(alpha: 0.7),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                'KM/H',
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00E5FF),
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 4),

              // Gear Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: isRedlining ? const Color(0xFFFF1744) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isRedlining ? Colors.white : const Color(0xFF00E5FF).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  'GEAR $currentGear',
                  style: GoogleFonts.orbitron(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
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

class _ModernRpmPainter extends CustomPainter {
  final double rpmRatio;
  _ModernRpmPainter({required this.rpmRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    const startAngle = 135 * math.pi / 180;
    const sweepAngle = 270 * math.pi / 180;

    // 1. Background Arc Track
    final trackPaint = Paint()
      ..color = const Color(0xFF141D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // 2. Active RPM Sweep Arc
    final activePaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          Color(0xFF00E5FF),
          Color(0xFFFFD600),
          Color(0xFFFF1744),
        ],
        stops: const [0.0, 0.65, 1.0],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    final currentSweep = sweepAngle * rpmRatio.clamp(0.0, 1.0);
    if (currentSweep > 0.01) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        currentSweep,
        false,
        activePaint,
      );
    }

    // 3. Dial Tick Markers
    final tickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.2;
    for (int i = 0; i <= 9; i++) {
      final angle = startAngle + (sweepAngle * (i / 9.0));
      final inner = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + (radius - 4) * math.cos(angle),
        center.dy + (radius - 4) * math.sin(angle),
      );
      tickPaint.color = (i >= 7) ? const Color(0xFFFF5252) : Colors.white24;
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ModernRpmPainter oldDelegate) {
    return oldDelegate.rpmRatio != rpmRatio;
  }
}
