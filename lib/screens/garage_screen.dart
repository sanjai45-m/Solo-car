import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/car_model.dart';
import '../services/game_controller.dart';
import '../widgets/common/glass_container.dart';
import '../widgets/common/neon_button.dart';

class GarageScreen extends StatefulWidget {
  final GameController gameController;

  const GarageScreen({super.key, required this.gameController});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  int _selectedCarIndex = 0;
  int _activeTab = 0; // 0: Upgrades, 1: Paint Customization

  final List<Color> _paintPalette = [
    const Color(0xFF00E5FF), // Cyan
    const Color(0xFFFF1744), // Crimson
    const Color(0xFFFFD600), // Electric Yellow
    const Color(0xFF7C4DFF), // Purple
    const Color(0xFF00E676), // Acid Green
    const Color(0xFFFF6D00), // Blaze Orange
    const Color(0xFFFFFFFF), // Pure White
    const Color(0xFF212121), // Stealth Dark
  ];

  @override
  void initState() {
    super.initState();
    final currentId = widget.gameController.currentCar.id;
    final idx = widget.gameController.allCars.indexWhere((c) => c.id == currentId);
    if (idx != -1) _selectedCarIndex = idx;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameController,
      builder: (context, _) {
        final cars = widget.gameController.allCars;
        final selectedCar = cars[_selectedCarIndex];
        final isUnlocked = widget.gameController.progress.unlockedCarIds.contains(selectedCar.id);
        final isSelected = widget.gameController.progress.selectedCarId == selectedCar.id;
        final cash = widget.gameController.progress.cash;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E17),
          body: Stack(
            children: [
              // Ambient Neon Background Glow
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedCar.bodyColor.withValues(alpha: 0.18),
                    boxShadow: [
                      BoxShadow(
                        color: selectedCar.bodyColor.withValues(alpha: 0.25),
                        blurRadius: 90,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Top App Bar: Back Button, Title, Cash Balance
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'GARAGE & TUNING',
                                style: GoogleFonts.orbitron(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          // Cash Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0x990A0E17),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Color(0xFF00E676), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '\$$cash',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 16,
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

                    Expanded(
                      child: Row(
                        children: [
                          // Left Panel: Car Showcase & Selector
                          Expanded(
                            flex: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Car Preview Graphic with Underglow
                                Container(
                                  height: 220,
                                  alignment: Alignment.center,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Turntable shadow & glow
                                      Container(
                                        width: 260,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: selectedCar.neonUnderglowColor.withValues(alpha: 0.3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: selectedCar.neonUnderglowColor.withValues(alpha: 0.4),
                                              blurRadius: 40,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Render 2D Vector Car Preview
                                      CustomPaint(
                                        size: const Size(120, 200),
                                        painter: _CarShowcasePainter(car: selectedCar),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),
                                // Car Name & Class
                                Text(
                                  selectedCar.name.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  '${selectedCar.brand} • ${selectedCar.carClass.name.toUpperCase()} CLASS',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF90A4AE),
                                  ),
                                ),

                                const SizedBox(height: 18),
                                // Car Switcher Controls
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left, color: Color(0xFF00E5FF), size: 36),
                                      onPressed: () {
                                        setState(() {
                                          _selectedCarIndex = (_selectedCarIndex - 1 + cars.length) % cars.length;
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    if (!isUnlocked)
                                      NeonButton(
                                        text: 'Buy (\$${selectedCar.price})',
                                        icon: Icons.shopping_cart,
                                        width: 190,
                                        primaryColor: const Color(0xFFFFD600),
                                        onPressed: cash >= selectedCar.price
                                            ? () {
                                                widget.gameController.buyCar(selectedCar);
                                              }
                                            : null,
                                      )
                                    else if (!isSelected)
                                      NeonButton(
                                        text: 'Select Car',
                                        icon: Icons.check,
                                        width: 170,
                                        primaryColor: const Color(0xFF00E5FF),
                                        onPressed: () {
                                          widget.gameController.selectCar(selectedCar.id);
                                        },
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00E676).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFF00E676)),
                                        ),
                                        child: Text(
                                          'ACTIVE CAR',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF00E676),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right, color: Color(0xFF00E5FF), size: 36),
                                      onPressed: () {
                                        setState(() {
                                          _selectedCarIndex = (_selectedCarIndex + 1) % cars.length;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Right Panel: Performance Upgrades & Paint Studio
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24, top: 8, bottom: 20),
                              child: GlassContainer(
                                backgroundColor: const Color(0xE60D131F),
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tabs: Upgrades vs Paint
                                    Row(
                                      children: [
                                        _buildTabButton('PERFORMANCE', 0),
                                        const SizedBox(width: 12),
                                        _buildTabButton('CUSTOM PAINT', 1),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    Expanded(
                                      child: _activeTab == 0
                                          ? _buildUpgradesTab(selectedCar, isUnlocked, cash)
                                          : _buildPaintTab(selectedCar, isUnlocked),
                                    ),
                                  ],
                                ),
                              ),
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
        );
      },
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00E5FF).withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF00E5FF) : Colors.white24,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isActive ? const Color(0xFF00E5FF) : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradesTab(CarModel car, bool isUnlocked, int cash) {
    return ListView(
      children: [
        _buildUpgradeItem(
          label: 'ENGINE (TOP SPEED & ACCEL)',
          level: car.engineUpgrade.level,
          statValue: '${car.topSpeedKmH.toInt()} KM/H',
          cost: car.engineUpgrade.costPerLevel,
          canUpgrade: isUnlocked && car.engineUpgrade.level < 5 && cash >= car.engineUpgrade.costPerLevel,
          onUpgrade: () {
            widget.gameController.upgradeCarPart(
              carId: car.id,
              partKey: 'engine',
              cost: car.engineUpgrade.costPerLevel,
            );
          },
        ),
        _buildUpgradeItem(
          label: 'HANDLING & TIRES',
          level: car.handlingUpgrade.level,
          statValue: '${(car.handlingRate * 10).toInt()} GRIP',
          cost: car.handlingUpgrade.costPerLevel,
          canUpgrade: isUnlocked && car.handlingUpgrade.level < 5 && cash >= car.handlingUpgrade.costPerLevel,
          onUpgrade: () {
            widget.gameController.upgradeCarPart(
              carId: car.id,
              partKey: 'handling',
              cost: car.handlingUpgrade.costPerLevel,
            );
          },
        ),
        _buildUpgradeItem(
          label: 'BRAKE CALIPERS',
          level: car.brakeUpgrade.level,
          statValue: '${(car.brakingRate * 10).toInt()} POWER',
          cost: car.brakeUpgrade.costPerLevel,
          canUpgrade: isUnlocked && car.brakeUpgrade.level < 5 && cash >= car.brakeUpgrade.costPerLevel,
          onUpgrade: () {
            widget.gameController.upgradeCarPart(
              carId: car.id,
              partKey: 'brakes',
              cost: car.brakeUpgrade.costPerLevel,
            );
          },
        ),
        _buildUpgradeItem(
          label: 'NITROUS OXIDE',
          level: car.nitroUpgrade.level,
          statValue: '${car.nitroCapacity.toInt()} NOS',
          cost: car.nitroUpgrade.costPerLevel,
          canUpgrade: isUnlocked && car.nitroUpgrade.level < 5 && cash >= car.nitroUpgrade.costPerLevel,
          onUpgrade: () {
            widget.gameController.upgradeCarPart(
              carId: car.id,
              partKey: 'nitro',
              cost: car.nitroUpgrade.costPerLevel,
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpgradeItem({
    required String label,
    required int level,
    required String statValue,
    required int cost,
    required bool canUpgrade,
    required VoidCallback onUpgrade,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x66101B2B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      statValue,
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF00E5FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 5-Level Progress Pip Row
                Row(
                  children: List.generate(5, (idx) {
                    final isFilled = idx < level;
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isFilled ? const Color(0xFF00E5FF) : const Color(0xFF263238),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: isFilled
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (level < 5)
            NeonButton(
              text: '+\$$cost',
              width: 100,
              height: 36,
              fontSize: 11,
              primaryColor: const Color(0xFF00E676),
              onPressed: canUpgrade ? onUpgrade : null,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD600).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFFD600)),
              ),
              child: Text(
                'MAX',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaintTab(CarModel car, bool isUnlocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT BODY PAINT COLOR',
          style: GoogleFonts.orbitron(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF90A4AE),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _paintPalette.map((color) {
            final isSelected = car.bodyColor.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: isUnlocked
                  ? () {
                      widget.gameController.customizeCarColor(
                        carId: car.id,
                        color: color,
                      );
                    }
                  : null,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white30,
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: isSelected ? 0.6 : 0.2),
                      blurRadius: isSelected ? 12 : 4,
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 22)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CarShowcasePainter extends CustomPainter {
  final CarModel car;
  _CarShowcasePainter({required this.car});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const w = 65.0;
    const h = 135.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Neon Glow
    final glowPaint = Paint()
      ..color = car.neonUnderglowColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w + 16, height: h + 16),
        const Radius.circular(20),
      ),
      glowPaint,
    );

    // Tires
    final tirePaint = Paint()..color = const Color(0xFF151515);
    canvas.drawRect(Rect.fromLTWH(-w * 0.52, -h * 0.35, 10, 24), tirePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.52 - 10, -h * 0.35, 10, 24), tirePaint);
    canvas.drawRect(Rect.fromLTWH(-w * 0.52, h * 0.22, 10, 24), tirePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.52 - 10, h * 0.22, 10, 24), tirePaint);

    // Chassis Path
    final bodyPath = Path();
    bodyPath.moveTo(-w * 0.36, -h * 0.48);
    bodyPath.quadraticBezierTo(0, -h * 0.54, w * 0.36, -h * 0.48);
    bodyPath.lineTo(w * 0.48, -h * 0.36);
    bodyPath.quadraticBezierTo(w * 0.42, 0, w * 0.48, h * 0.36);
    bodyPath.lineTo(w * 0.42, h * 0.48);
    bodyPath.quadraticBezierTo(0, h * 0.52, -w * 0.42, h * 0.48);
    bodyPath.lineTo(-w * 0.48, h * 0.36);
    bodyPath.quadraticBezierTo(-w * 0.42, 0, -w * 0.48, -h * 0.36);
    bodyPath.close();

    // Body Paint
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [car.bodyColor.withValues(alpha: 0.9), car.bodyColor, car.bodyColor.withValues(alpha: 0.7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(-w / 2, -h / 2, w, h));
    canvas.drawPath(bodyPath, bodyPaint);

    // Racing Stripe
    final stripePaint = Paint()..color = car.stripeColor.withValues(alpha: 0.85);
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w * 0.18, height: h * 0.84), stripePaint);

    // Windshield & Glass
    final glassPaint = Paint()..color = const Color(0xFF101B2B);
    final windshieldPath = Path()
      ..moveTo(-w * 0.30, -h * 0.22)
      ..lineTo(w * 0.30, -h * 0.22)
      ..lineTo(w * 0.24, -h * 0.04)
      ..lineTo(-w * 0.24, -h * 0.04)
      ..close();
    canvas.drawPath(windshieldPath, glassPaint);

    final roofRect = Rect.fromCenter(center: Offset(0, h * 0.08), width: w * 0.48, height: h * 0.24);
    canvas.drawRRect(RRect.fromRectAndRadius(roofRect, const Radius.circular(4)), Paint()..color = car.bodyColor.withValues(alpha: 0.8));

    // Spoiler
    final spoilerPaint = Paint()..color = const Color(0xFF212121);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, h * 0.44), width: w * 0.82, height: 8), const Radius.circular(2)),
      spoilerPaint,
    );

    // Headlights
    final headlightPaint = Paint()..color = const Color(0xFFE0F7FA)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(-w * 0.30, -h * 0.45), 4, headlightPaint);
    canvas.drawCircle(Offset(w * 0.30, -h * 0.45), 4, headlightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
