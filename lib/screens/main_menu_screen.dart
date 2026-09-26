import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                  'assets/images/app_logo_3d.jpg',
                  fit: BoxFit.cover,
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
        height: 48,
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
        height: 48,
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
        height: 44,
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
        height: 44,
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
        height: 44,
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
        height: 44,
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

          // 3D Visual Turntable Stage with Floating Hover
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ground Reflection Oval & Rotating Halo
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(280, 100),
                      painter: _ShowroomTurntablePainter(
                        glowColor: currentCar.neonUnderglowColor,
                        pulse: _ambientController.value,
                      ),
                    );
                  },
                ),

                // 3D Car Vector Body with subtle gentle floating hover
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, _) {
                    final floatY = math.sin(_ambientController.value * math.pi) * 4.0;
                    return Transform.translate(
                      offset: Offset(0, -floatY),
                      child: CustomPaint(
                        size: const Size(190, 110),
                        painter: _CarShowroomVectorPainter(
                          bodyColor: currentCar.bodyColor,
                          underglowColor: currentCar.neonUnderglowColor,
                          stripeColor: currentCar.stripeColor,
                          bodyStyle: currentCar.bodyStyle,
                        ),
                      ),
                    );
                  },
                ),
              ],
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

class _CarShowroomVectorPainter extends CustomPainter {
  final Color bodyColor;
  final Color underglowColor;
  final Color stripeColor;
  final CarBodyStyle bodyStyle;

  _CarShowroomVectorPainter({
    required this.bodyColor,
    required this.underglowColor,
    required this.stripeColor,
    this.bodyStyle = CarBodyStyle.streetTuner,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.50);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Wheels
    final wheelPaint = Paint()..color = const Color(0xFF151515);
    final rimPaint = Paint()..color = const Color(0xFFB0BEC5);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-w * 0.38, h * 0.20), width: w * 0.18, height: h * 0.45), const Radius.circular(4)), wheelPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.38, h * 0.20), width: w * 0.18, height: h * 0.45), const Radius.circular(4)), wheelPaint);
    canvas.drawCircle(Offset(-w * 0.38, h * 0.20), w * 0.05, rimPaint);
    canvas.drawCircle(Offset(w * 0.38, h * 0.20), w * 0.05, rimPaint);

    // 3D Chassis Body based on bodyStyle
    final bodyPath = Path();
    switch (bodyStyle) {
      case CarBodyStyle.leMansHypercar:
        bodyPath.moveTo(-w * 0.48, h * 0.24);
        bodyPath.lineTo(-w * 0.44, h * 0.38);
        bodyPath.lineTo(w * 0.44, h * 0.38);
        bodyPath.lineTo(w * 0.48, h * 0.24);
        bodyPath.lineTo(w * 0.42, -h * 0.10);
        bodyPath.lineTo(w * 0.22, -h * 0.42);
        bodyPath.lineTo(-w * 0.22, -h * 0.42);
        bodyPath.lineTo(-w * 0.42, -h * 0.10);
        bodyPath.close();
        break;

      case CarBodyStyle.exoticSuper:
        bodyPath.moveTo(-w * 0.46, h * 0.22);
        bodyPath.lineTo(-w * 0.42, h * 0.36);
        bodyPath.lineTo(w * 0.42, h * 0.36);
        bodyPath.lineTo(w * 0.46, h * 0.22);
        bodyPath.lineTo(w * 0.40, -h * 0.10);
        bodyPath.lineTo(w * 0.26, -h * 0.40);
        bodyPath.lineTo(-w * 0.26, -h * 0.40);
        bodyPath.lineTo(-w * 0.40, -h * 0.10);
        bodyPath.close();
        break;

      case CarBodyStyle.muscleGtr:
        bodyPath.moveTo(-w * 0.46, h * 0.20);
        bodyPath.lineTo(-w * 0.44, h * 0.38);
        bodyPath.lineTo(w * 0.44, h * 0.38);
        bodyPath.lineTo(w * 0.46, h * 0.20);
        bodyPath.lineTo(w * 0.42, -h * 0.08);
        bodyPath.lineTo(w * 0.32, -h * 0.36);
        bodyPath.lineTo(-w * 0.32, -h * 0.36);
        bodyPath.lineTo(-w * 0.42, -h * 0.08);
        bodyPath.close();
        break;

      case CarBodyStyle.jdmRotary:
        bodyPath.moveTo(-w * 0.47, h * 0.22);
        bodyPath.lineTo(-w * 0.40, h * 0.36);
        bodyPath.lineTo(w * 0.40, h * 0.36);
        bodyPath.lineTo(w * 0.47, h * 0.22);
        bodyPath.lineTo(w * 0.38, -h * 0.10);
        bodyPath.lineTo(w * 0.27, -h * 0.38);
        bodyPath.lineTo(-w * 0.27, -h * 0.38);
        bodyPath.lineTo(-w * 0.38, -h * 0.10);
        bodyPath.close();
        break;

      case CarBodyStyle.streetTuner:
      default:
        bodyPath.moveTo(-w * 0.44, h * 0.22);
        bodyPath.lineTo(-w * 0.40, h * 0.36);
        bodyPath.lineTo(w * 0.40, h * 0.36);
        bodyPath.lineTo(w * 0.44, h * 0.22);
        bodyPath.lineTo(w * 0.38, -h * 0.10);
        bodyPath.lineTo(w * 0.28, -h * 0.38);
        bodyPath.lineTo(-w * 0.28, -h * 0.38);
        bodyPath.lineTo(-w * 0.38, -h * 0.10);
        bodyPath.close();
        break;
    }

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(bodyColor, Colors.white, 0.3)!,
          bodyColor,
          Color.lerp(bodyColor, Colors.black, 0.4)!,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(center: Offset.zero, width: w, height: h));
    canvas.drawPath(bodyPath, bodyPaint);

    // Racing Stripes
    final stripePaint = Paint()..color = stripeColor.withValues(alpha: 0.85);
    if (bodyStyle == CarBodyStyle.muscleGtr || bodyStyle == CarBodyStyle.streetTuner) {
      canvas.drawRect(Rect.fromLTWH(-w * 0.06, -h * 0.37, w * 0.04, h * 0.72), stripePaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.02, -h * 0.37, w * 0.04, h * 0.72), stripePaint);
    } else if (bodyStyle == CarBodyStyle.jdmRotary) {
      canvas.drawRect(Rect.fromLTWH(-w * 0.04, -h * 0.37, w * 0.08, h * 0.72), stripePaint);
    }

    // Central Shark Fin (Le Mans)
    if (bodyStyle == CarBodyStyle.leMansHypercar) {
      canvas.drawRect(Rect.fromCenter(center: Offset(0, -h * 0.25), width: 4, height: h * 0.25), Paint()..color = const Color(0xFF0F172A));
      canvas.drawRect(Rect.fromCenter(center: Offset(0, -h * 0.25), width: 2, height: h * 0.25), Paint()..color = underglowColor);
    }

    // GT Wing Spoiler
    final spoilerPaint = Paint()..color = const Color(0xFF0F172A);
    if (bodyStyle != CarBodyStyle.exoticSuper) {
      final spoilerWidth = (bodyStyle == CarBodyStyle.leMansHypercar || bodyStyle == CarBodyStyle.jdmRotary) ? w * 0.94 : w * 0.85;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -h * 0.22), width: spoilerWidth, height: 6), const Radius.circular(2)), spoilerPaint);
    }

    // LED Taillights
    final tailPaint = Paint()
      ..color = const Color(0xFFFF1744)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, h * 0.05), width: w * 0.72, height: 5), const Radius.circular(2)), tailPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, h * 0.05), width: w * 0.72, height: 5), const Radius.circular(2)), Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CarShowroomVectorPainter oldDelegate) {
    return oldDelegate.bodyColor != bodyColor ||
        oldDelegate.underglowColor != underglowColor ||
        oldDelegate.stripeColor != stripeColor ||
        oldDelegate.bodyStyle != bodyStyle;
  }
}
