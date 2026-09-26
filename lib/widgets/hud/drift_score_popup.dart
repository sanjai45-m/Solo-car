import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriftScorePopup extends StatelessWidget {
  final double driftPoints;
  final double multiplier;
  final bool isDrifting;
  final String? alertMessage;

  const DriftScorePopup({
    super.key,
    required this.driftPoints,
    required this.multiplier,
    required this.isDrifting,
    this.alertMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDrifting && (alertMessage == null || alertMessage!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (alertMessage != null && alertMessage!.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF007F), Color(0xFF7C4DFF)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFFF007F),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              alertMessage!.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        if (isDrifting) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xCC000000),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD600),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFFFD600),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DRIFT ',
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFD600),
                  ),
                ),
                Text(
                  '+${driftPoints.toInt()}',
                  style: GoogleFonts.orbitron(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1744),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'x${multiplier.toStringAsFixed(1)}',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
