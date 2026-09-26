import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/race_model.dart';
import '../services/game_controller.dart';
import '../widgets/common/glass_container.dart';
import '../widgets/common/neon_button.dart';
import 'garage_screen.dart';
import 'race_game_screen.dart';
import 'race_selection_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final GameController gameController;

  const MainMenuScreen({super.key, required this.gameController});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameController,
      builder: (context, _) {
        final currentCar = widget.gameController.currentCar;
        final cash = widget.gameController.progress.cash;
        final repLevel = widget.gameController.progress.reputationLevel;

        return Scaffold(
          backgroundColor: const Color(0xFF070B12),
          body: Stack(
            children: [
              // 1. Cyberpunk Animated Background Elements
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _MenuGridPainter(animValue: _animController.value),
                  );
                },
              ),

              // Ambient Glow
              Positioned(
                bottom: -50,
                right: 50,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentCar.neonUnderglowColor.withValues(alpha: 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: currentCar.neonUnderglowColor.withValues(alpha: 0.35),
                        blurRadius: 90,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // Top Header Bar: Game Title & Player Wallet
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'APEX VELOCITY',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2.5,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0xFF00E5FF),
                                          blurRadius: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  'STREET RACING SYNDICATE',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF00E5FF),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Status Badges (Reputation & Cash)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0x990A0E17),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFFD600), width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Color(0xFFFFD600), size: 16),
                                      const SizedBox(width: 5),
                                      Text(
                                        'REP LVL $repLevel',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFFFD600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0x990A0E17),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF00E676), width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.monetization_on, color: Color(0xFF00E676), size: 16),
                                      const SizedBox(width: 5),
                                      Text(
                                        '\$$cash',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF00E676),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Center Stage: Menu Buttons & Car Preview
                      Expanded(
                        child: Row(
                          children: [
                            // Left Column: Menu Buttons
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      NeonButton(
                                        text: 'Quick Race',
                                        icon: Icons.play_arrow,
                                        width: 220,
                                        height: 48,
                                        fontSize: 14,
                                        primaryColor: const Color(0xFF00E5FF),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => RaceGameScreen(
                                                gameController: widget.gameController,
                                                carModel: currentCar,
                                                track: RaceTrack.defaultTracks.first,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      NeonButton(
                                        text: 'Career Tracks',
                                        icon: Icons.flag,
                                        width: 220,
                                        height: 44,
                                        fontSize: 13,
                                        isSecondary: true,
                                        primaryColor: const Color(0xFFFFD600),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => RaceSelectionScreen(
                                                gameController: widget.gameController,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      NeonButton(
                                        text: 'Garage & Tuning',
                                        icon: Icons.build,
                                        width: 220,
                                        height: 44,
                                        fontSize: 13,
                                        isSecondary: true,
                                        primaryColor: const Color(0xFFFF007F),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GarageScreen(
                                                gameController: widget.gameController,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      NeonButton(
                                        text: 'Settings',
                                        icon: Icons.settings,
                                        width: 220,
                                        height: 44,
                                        fontSize: 13,
                                        isSecondary: true,
                                        primaryColor: const Color(0xFF90A4AE),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SettingsScreen(
                                                gameController: widget.gameController,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Right Column: Active Car Showcase Card
                            Expanded(
                              flex: 5,
                              child: GlassContainer(
                                backgroundColor: const Color(0x990E1624),
                                borderColor: currentCar.neonUnderglowColor,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'ACTIVE RIDE',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF00E5FF),
                                          ),
                                        ),
                                        Text(
                                          currentCar.carClass.name.toUpperCase(),
                                          style: GoogleFonts.orbitron(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      currentCar.name.toUpperCase(),
                                      style: GoogleFonts.orbitron(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Stat Bars
                                    _buildStatBar('TOP SPEED', currentCar.topSpeedNormalized, '${currentCar.topSpeedKmH.toInt()} KM/H'),
                                    const SizedBox(height: 6),
                                    _buildStatBar('ACCELERATION', currentCar.accelerationNormalized, '${(currentCar.accelerationRate * 10).toInt()} ACC'),
                                    const SizedBox(height: 6),
                                    _buildStatBar('HANDLING', currentCar.handlingNormalized, '${(currentCar.handlingRate * 10).toInt()} G'),
                                    const SizedBox(height: 6),
                                    _buildStatBar('NITROUS', currentCar.nitroNormalized, '${currentCar.nitroCapacity.toInt()} NOS'),

                                    const Spacer(),

                                    Center(
                                      child: NeonButton(
                                        text: 'TUNE IN GARAGE',
                                        icon: Icons.tune,
                                        width: 200,
                                        height: 36,
                                        fontSize: 10,
                                        isSecondary: true,
                                        primaryColor: currentCar.neonUnderglowColor,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GarageScreen(
                                                gameController: widget.gameController,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBar(String label, double ratio, String valueText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF90A4AE),
              ),
            ),
            Text(
              valueText,
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2836),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF),
                borderRadius: BorderRadius.circular(3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF00E5FF),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuGridPainter extends CustomPainter {
  final double animValue;
  _MenuGridPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.05 + animValue * 0.03)
      ..strokeWidth = 1;

    const spacing = 45.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
