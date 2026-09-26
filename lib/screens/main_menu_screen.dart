import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/graphics/car_3d_renderer.dart';
import '../models/car_model.dart';
import '../models/race_model.dart';
import '../models/user_profile.dart';
import '../services/audio_service.dart';
import '../services/auth_service.dart';
import '../services/game_controller.dart';
import '../widgets/common/app_background.dart';
import '../widgets/common/glass_container.dart';
import '../widgets/common/neon_button.dart';
import '../widgets/common/profile_badge.dart';
import '../widgets/dialogs/auth_dialog.dart';
import '../widgets/dialogs/daily_reward_dialog.dart';
import 'garage_screen.dart';
import 'leaderboard_screen.dart';
import 'multiplayer_lobby_screen.dart';
import 'race_game_screen.dart';
import 'race_selection_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final GameController gameController;

  const MainMenuScreen({super.key, required this.gameController});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with TickerProviderStateMixin {
  late AnimationController _ambientController;
  late AnimationController _entranceController;
  late AnimationController _turntableController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _turntableController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _slideAnimation = CurvedAnimation(
      parent: _ambientController,
      curve: Curves.easeInOutSine,
    );

    AudioService().playMenuMusic();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _entranceController.dispose();
    _turntableController.dispose();
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
          backgroundColor: const Color(0xFF060912),
          body: AppBackground(
            overlayOpacity: 0.70,
            child: Stack(
              children: [
                // 1. Subtle Cyber Ambient Horizon Glow & Floor Grid
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ModernCyberBackgroundPainter(
                      glowColor: currentCar.neonUnderglowColor,
                      animValue: _ambientController.value,
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      children: [
                        // Top Header Bar
                        _buildHeader(cash, repLevel),
                        const SizedBox(height: 12),

                        // Main Content: Left Navigation Tiles & Right Showroom Stage
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left Action Tiles with Staggered Entrance (Flex 4)
                              Expanded(
                                flex: 4,
                                child: _buildAnimatedMenuTiles(),
                              ),
                              const SizedBox(width: 20),

                              // Right Car Showcase & Performance Telemetry (Flex 6)
                              Expanded(
                                flex: 6,
                                child: _buildCarShowroomStage(currentCar),
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
          ),
        );
      },
    );
  }

  Widget _buildHeader(int cash, int repLevel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Game Brand Title & Logo
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/app_logo_3d.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF0D1524),
                    child: const Icon(Icons.sports_motorsports_rounded, color: Color(0xFF00E5FF), size: 24),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'APEX VELOCITY',
                  style: GoogleFonts.orbitron(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.2,
                    shadows: const [
                      Shadow(color: Color(0xFF00E5FF), blurRadius: 16),
                    ],
                  ),
                ),
                Text(
                  'STREET RACING SYNDICATE // PRO SERIES',
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00E5FF),
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Wallet, Rep & Profile Badges
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileBadge(
                profile: AuthService().currentUser ?? UserProfile.guest(),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AuthDialog(
                      onProfileChanged: () => setState(() {}),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),

              // Crate Reward
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => DailyRewardDialog(
                      gameController: widget.gameController,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D2E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFD600), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD600).withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.card_giftcard, color: Color(0xFFFFD600), size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'CRATE',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Reputation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x990A101C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF9100), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFF9100), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'REP $repLevel',
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFF9100),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Credits
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x990A101C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00E676), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Color(0xFF00E676), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '\$$cash',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
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
    );
  }

  Widget _buildAnimatedMenuTiles() {
    final currentCar = widget.gameController.currentCar;

    final List<Widget> tiles = [
      NeonButton(
        text: 'Quick Race',
        subtitle: 'Single Player AI Duel',
        icon: Icons.play_arrow_rounded,
        height: 52,
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
      NeonButton(
        text: 'Online Multiplayer',
        subtitle: '1v1 Live Room & Cloud Match',
        icon: Icons.public_rounded,
        height: 52,
        primaryColor: const Color(0xFF00E676),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiplayerLobbyScreen(
                gameController: widget.gameController,
              ),
            ),
          );
        },
      ),
      NeonButton(
        text: 'Career Circuits',
        subtitle: 'Syndicate Campaign Tracks',
        icon: Icons.flag_rounded,
        height: 48,
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
      NeonButton(
        text: 'Garage & Tuning',
        subtitle: 'Custom Paint & Upgrades',
        icon: Icons.build_rounded,
        height: 48,
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
      NeonButton(
        text: 'Leaderboard',
        subtitle: 'Global ELO & Podium Ranks',
        icon: Icons.leaderboard_rounded,
        height: 48,
        isSecondary: true,
        primaryColor: const Color(0xFFFF9100),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LeaderboardScreen(),
            ),
          );
        },
      ),
      NeonButton(
        text: 'Settings',
        subtitle: 'Controls & Audio Calibration',
        icon: Icons.settings_rounded,
        height: 48,
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
    ];

    return Center(
      child: SingleChildScrollView(
        child: AnimatedBuilder(
          animation: _entranceController,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(tiles.length, (index) {
                final start = (index * 0.10).clamp(0.0, 0.70);
                final end = (start + 0.40).clamp(0.0, 1.0);
                final curvedVal = CurvedAnimation(
                  parent: _entranceController,
                  curve: Interval(start, end, curve: Curves.easeOutCubic),
                ).value;

                return Opacity(
                  opacity: curvedVal.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(-30 * (1.0 - curvedVal), 0),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: index < tiles.length - 1 ? 8 : 0),
                      child: tiles[index],
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarShowroomStage(CarModel currentCar) {
    return GlassContainer(
      borderRadius: 16.0,
      backgroundColor: const Color(0xCC090F1C),
      borderColor: currentCar.neonUnderglowColor.withValues(alpha: 0.5),
      borderWidth: 1.5,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vehicle Name & Class Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00E676),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.8), blurRadius: 6),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SHOWROOM ACTIVE',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00E5FF),
                          letterSpacing: 1.2,
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
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: currentCar.neonUnderglowColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: currentCar.neonUnderglowColor, width: 1.2),
                ),
                child: Text(
                  currentCar.carClass.toString().split('.').last.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: currentCar.neonUnderglowColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 3D Visual Turntable Stage with Live 3D Rotation & Floating Hover
          Expanded(
            flex: 5,
            child: AnimatedBuilder(
              animation: Listenable.merge([_slideAnimation, _turntableController]),
              builder: (context, _) {
                final floatY = math.sin(_ambientController.value * math.pi) * 3.5;
                final yaw = _turntableController.value * 2 * math.pi;

                return CustomPaint(
                  size: const Size(260, 160),
                  painter: _Car3DShowroomPainter(
                    car: currentCar,
                    yawAngle: yaw,
                    bounceY: floatY,
                    glowPulse: _ambientController.value,
                  ),
                );
              },
            ),
          ),

          // Performance Specs Telemetry Bars with smooth fill
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBar('TOP SPEED', currentCar.topSpeedNormalized, '${currentCar.topSpeedKmH.toInt()} KM/H', const Color(0xFF00E5FF)),
                _buildStatBar('ACCELERATION', currentCar.accelerationNormalized, '${(currentCar.accelerationRate).toInt()}', const Color(0xFFFFD600)),
                _buildStatBar('HANDLING', currentCar.handlingNormalized, '${(currentCar.handlingRate * 10).toInt()}%', const Color(0xFF00E676)),
                _buildStatBar('NITRO THRUST', currentCar.nitroNormalized, '${(currentCar.nitroCapacity).toInt()} PSI', const Color(0xFFFF007F)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double ratio, String valueStr, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            Text(
              valueStr,
              style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 5,
            decoration: const BoxDecoration(color: Colors.white10),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0.05, 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.6), color],
                  ),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModernCyberBackgroundPainter extends CustomPainter {
  final Color glowColor;
  final double animValue;
  _ModernCyberBackgroundPainter({required this.glowColor, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.55;

    // Perspective Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    final centerX = size.width * 0.65;
    for (double x = -size.width; x < size.width * 2; x += 60) {
      canvas.drawLine(Offset(centerX, horizonY), Offset(x, size.height), gridPaint);
    }

    // Horizontal Lines
    for (int i = 0; i < 8; i++) {
      final yProgress = math.pow(i / 7.0, 2.0);
      final y = horizonY + yProgress * (size.height - horizonY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ModernCyberBackgroundPainter oldDelegate) => false;
}

class _ShowroomTurntablePainter extends CustomPainter {
  final Color glowColor;
  final double pulse;
  _ShowroomTurntablePainter({required this.glowColor, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.70);
    final width = size.width * 0.85;
    final height = size.height * 0.38;

    // Ground Neon Underglow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.35 + pulse * 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawOval(Rect.fromCenter(center: center, width: width * 1.1, height: height * 1.2), glowPaint);

    // Turntable Edge Ring
    final ringPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(Rect.fromCenter(center: center, width: width, height: height), ringPaint);

    // Core Ring
    final corePaint = Paint()
      ..color = const Color(0xFF10192A)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: center, width: width * 0.95, height: height * 0.95), corePaint);
  }

  @override
  bool shouldRepaint(covariant _ShowroomTurntablePainter oldDelegate) => true;
}

class _Car3DShowroomPainter extends CustomPainter {
  final CarModel car;
  final double yawAngle;
  final double bounceY;
  final double glowPulse;

  _Car3DShowroomPainter({
    required this.car,
    required this.yawAngle,
    this.bounceY = 0.0,
    this.glowPulse = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Car3DRenderer.render3DShowcase(
      canvas: canvas,
      size: size,
      car: car,
      yawAngle: yawAngle,
      pitchAngle: 0.18,
      bounceY: bounceY,
      glowPulse: glowPulse,
    );
  }

  @override
  bool shouldRepaint(covariant _Car3DShowroomPainter oldDelegate) {
    return oldDelegate.car != car ||
        oldDelegate.yawAngle != yawAngle ||
        oldDelegate.bounceY != bounceY ||
        oldDelegate.glowPulse != glowPulse;
  }
}
