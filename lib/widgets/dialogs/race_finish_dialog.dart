import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/race_model.dart';
import '../common/glass_container.dart';
import '../common/neon_button.dart';

class RaceFinishDialog extends StatelessWidget {
  final RaceTrack track;
  final int finishPosition;
  final int raceTimeMs;
  final int earnedCash;
  final double driftScore;
  final VoidCallback onNextRace;
  final VoidCallback onRetry;
  final VoidCallback onGarage;

  const RaceFinishDialog({
    super.key,
    required this.track,
    required this.finishPosition,
    required this.raceTimeMs,
    required this.earnedCash,
    required this.driftScore,
    required this.onNextRace,
    required this.onRetry,
    required this.onGarage,
  });

  String _formatTime(int ms) {
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    final hundredths = (ms % 1000) ~/ 10;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundredths.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isVictory = finishPosition <= 3;
    final resultColor = finishPosition == 1
        ? const Color(0xFFFFD600)
        : (finishPosition == 2
            ? const Color(0xFFE0E0E0)
            : (finishPosition == 3 ? const Color(0xFFFFAB00) : const Color(0xFFFF5252)));

    final titleText = finishPosition == 1
        ? 'VICTORY!'
        : (isVictory ? 'PODIUM FINISH!' : 'RACE OVER');

    return Center(
      child: GlassContainer(
        width: 380,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        borderColor: resultColor,
        backgroundColor: const Color(0xF20A0E17),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              titleText,
              style: GoogleFonts.orbitron(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: resultColor,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: resultColor.withValues(alpha: 0.8),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              track.name.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            // Placement Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: resultColor, width: 1.5),
              ),
              child: Text(
                'POSITION: #$finishPosition',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: resultColor,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Stats breakdown
            _buildStatRow('TIME', _formatTime(raceTimeMs), Colors.white),
            const SizedBox(height: 8),
            _buildStatRow('DRIFT POINTS', '${driftScore.toInt()}', const Color(0xFFFFD600)),
            const SizedBox(height: 8),
            _buildStatRow('CASH EARNED', '+\$$earnedCash', const Color(0xFF00E676)),

            const SizedBox(height: 24),

            // Action Buttons
            if (isVictory) ...[
              NeonButton(
                text: 'Next Race',
                icon: Icons.fast_forward,
                width: double.infinity,
                height: 50,
                fontSize: 14,
                primaryColor: const Color(0xFF00E676),
                onPressed: onNextRace,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: NeonButton(
                    text: 'Retry',
                    icon: Icons.refresh,
                    height: 48,
                    fontSize: 13,
                    isSecondary: true,
                    primaryColor: const Color(0xFFFFD600),
                    onPressed: onRetry,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeonButton(
                    text: 'Garage',
                    icon: Icons.build,
                    height: 48,
                    fontSize: 13,
                    isSecondary: true,
                    primaryColor: const Color(0xFF00E5FF),
                    onPressed: onGarage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF90A4AE),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
