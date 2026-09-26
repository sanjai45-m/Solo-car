import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/glass_container.dart';
import '../common/neon_button.dart';

class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        width: 340,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        borderColor: const Color(0xFF00E5FF),
        backgroundColor: const Color(0xE60A0E17),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME PAUSED',
              style: GoogleFonts.orbitron(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            NeonButton(
              text: 'Resume',
              icon: Icons.play_arrow,
              width: 260,
              primaryColor: const Color(0xFF00E5FF),
              onPressed: onResume,
            ),
            const SizedBox(height: 14),
            NeonButton(
              text: 'Restart Race',
              icon: Icons.refresh,
              width: 260,
              isSecondary: true,
              primaryColor: const Color(0xFFFFD600),
              onPressed: onRestart,
            ),
            const SizedBox(height: 14),
            NeonButton(
              text: 'Exit to Menu',
              icon: Icons.home,
              width: 260,
              isSecondary: true,
              primaryColor: const Color(0xFFFF5252),
              onPressed: onQuit,
            ),
          ],
        ),
      ),
    );
  }
}
