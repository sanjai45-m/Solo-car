import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NitroGauge extends StatelessWidget {
  final double nitroPercent; // 0.0 to 1.0

  const NitroGauge({
    super.key,
    required this.nitroPercent,
  });

  @override
  Widget build(BuildContext context) {
    final percent = nitroPercent.clamp(0.0, 1.0);
    final isFull = percent >= 0.95;

    return Container(
      width: 155,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x990A0E17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      color: isFull ? const Color(0xFFFF4081) : const Color(0xFF00E5FF),
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'NOS TANK',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: isFull ? const Color(0xFFFF4081) : const Color(0xFF00E5FF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(percent * 100).toInt()}%',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Nitro Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  color: const Color(0xFF152232),
                ),
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isFull
                            ? const [Color(0xFF00E5FF), Color(0xFFFF007F)]
                            : const [Color(0xFF00B0FF), Color(0xFF00E5FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
