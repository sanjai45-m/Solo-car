import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RacePositionBadge extends StatelessWidget {
  final int position;
  final int totalRacers;
  final int currentLap;
  final int totalLaps;
  final double trackProgress; // 0.0 to 1.0

  const RacePositionBadge({
    super.key,
    required this.position,
    required this.totalRacers,
    required this.currentLap,
    required this.totalLaps,
    required this.trackProgress,
  });

  String get positionSuffix {
    if (position == 1) return 'ST';
    if (position == 2) return 'ND';
    if (position == 3) return 'RD';
    return 'TH';
  }

  Color get positionColor {
    if (position == 1) return const Color(0xFFFFD600); // Gold
    if (position == 2) return const Color(0xFFE0E0E0); // Silver
    if (position == 3) return const Color(0xFFFFAB00); // Bronze
    return const Color(0xFF00E5FF);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Position Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x990A0E17),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: positionColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: positionColor.withValues(alpha: 0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'POS',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF90A4AE),
                ),
              ),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$position',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: positionColor,
                      ),
                    ),
                    TextSpan(
                      text: positionSuffix,
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: positionColor,
                      ),
                    ),
                    TextSpan(
                      text: ' / $totalRacers',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Lap Counter & Track Progress
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x990A0E17),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white24,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LAP $currentLap / $totalLaps',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              // Track Progress Bar
              Container(
                width: 110,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF263238),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: trackProgress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
