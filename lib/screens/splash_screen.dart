import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../services/game_controller.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  final GameController gameController;

  const SplashScreen({super.key, required this.gameController});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoTranslateY;
  late Animation<double> _glowPulse;

  double _loadingProgress = 0.0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _scaleAnimation = Tween<double>(begin: 1.15, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoTranslateY = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _glowPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    for (int i = 1; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 28));
      if (!mounted) return;
      setState(() {
        _loadingProgress = i / 100.0;
      });
    }

    if (mounted) {
      setState(() => _isReady = true);
      // Play menu background soundtrack and transition
      AudioService().playMenuMusic();
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                MainMenuScreen(gameController: widget.gameController),
            transitionDuration: const Duration(milliseconds: 700),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Cinematic 3D Background Artwork with Scale Animation
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Image.asset(
                  'assets/images/splash_art_3d.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Color(0xFF1A2639), Color(0xFF060B12)],
                        radius: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Dark Vignette & Neon Atmosphere Overlays
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),

              // 3. Central 3D Animated Logo Emblem
              Center(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _logoTranslateY.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 3D Glass Hexagonal Emblem with Glow
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.5 * _glowPulse.value),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: const Color(0xFFFF007F)
                                    .withValues(alpha: 0.4 * _glowPulse.value),
                                blurRadius: 60,
                                spreadRadius: 12,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF00E5FF),
                                  width: 2.5,
                                ),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Image.asset(
                                'assets/images/app_logo_3d.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.sports_motorsports,
                                  color: Color(0xFF00E5FF),
                                  size: 70,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title Text with Specular Glow
                        Text(
                          'APEX VELOCITY',
                          style: GoogleFonts.orbitron(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.9),
                                blurRadius: 20,
                              ),
                              Shadow(
                                color: const Color(0xFFFF007F)
                                    .withValues(alpha: 0.6),
                                blurRadius: 35,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'NEXT-GEN ARCADE DRIFT RACING',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                            color: const Color(0xFF80D8FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Bottom High-Tech Telemetry Progress Indicator
              Positioned(
                bottom: 36,
                left: 60,
                right: 60,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF00E5FF),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _isReady
                                    ? 'IGNITION READY • PRESS ACCELERATE'
                                    : 'INITIALIZING PROCEDURAL AUDIO ENGINE...',
                                style: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(_loadingProgress * 100).toInt()}%',
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 3D Extruded Neon Loading Bar
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0x990A111E),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white12,
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66000000),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _loadingProgress.clamp(0.01, 1.0),
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF00E5FF),
                                      Color(0xFFFF007F),
                                      Color(0xFFFFD600),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF00E5FF),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
