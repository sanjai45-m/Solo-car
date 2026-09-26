import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandscapeGuard extends StatefulWidget {
  final Widget child;

  const LandscapeGuard({super.key, required this.child});

  @override
  State<LandscapeGuard> createState() => _LandscapeGuardState();
}

class _LandscapeGuardState extends State<LandscapeGuard> with SingleTickerProviderStateMixin {
  late AnimationController _rotateAnim;

  @override
  void initState() {
    super.initState();
    _rotateAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotateAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxHeight > constraints.maxWidth && constraints.maxWidth < 650;

        if (isPortrait && kIsWeb) {
          return Scaffold(
            backgroundColor: const Color(0xFF070B14),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.1,
                  colors: [Color(0xFF101B34), Color(0xFF04060B)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Rotating Device Icon
                  AnimatedBuilder(
                    animation: _rotateAnim,
                    builder: (context, child) {
                      final angle = _rotateAnim.value * 1.5708; // 0 to 90 degrees
                      return Transform.rotate(
                        angle: angle,
                        child: Container(
                          width: 80,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF00E5FF), width: 3),
                            color: const Color(0x3300E5FF),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 8,
                                child: Container(
                                  width: 24,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white38,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.screen_rotation,
                                color: Color(0xFFFFD600),
                                size: 36,
                              ),
                              Positioned(
                                bottom: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white38,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  Text(
                    'PLEASE ROTATE YOUR DEVICE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00E5FF),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Apex Velocity is optimized for Horizontal Widescreen Arcade Racing.\nTurn your phone sideways to race!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x22FFD600),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD600).withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.screen_lock_landscape, color: Color(0xFFFFD600), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'LANDSCAPE MODE REQUIRED',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD600),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return widget.child;
      },
    );
  }
}
