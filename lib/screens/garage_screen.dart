import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/graphics/car_3d_renderer.dart';
import '../models/car_model.dart';
import '../services/game_controller.dart';
import '../widgets/common/app_background.dart';
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
  double _carRotationAngle = 0.0; // Interactive 360 degree turntable

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
          body: AppBackground(
            overlayOpacity: 0.78,
            child: Stack(
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
                                // Interactive 360 Turntable Car Graphic with Underglow
                                GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    setState(() {
                                      _carRotationAngle += details.primaryDelta! * 0.015;
                                    });
                                  },
                                  child: Container(
                                    height: 240,
                                    alignment: Alignment.center,
                                    child: CustomPaint(
                                      size: const Size(280, 210),
                                      painter: _CarShowcasePainter(
                                        car: selectedCar,
                                        rotationAngle: _carRotationAngle,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),
                                // Hint
                                Text(
                                  'DRAG HORIZONTALLY TO ROTATE 360°',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Car Name & Class
                                Text(
                                  selectedCar.name.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 22,
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

                                const SizedBox(height: 16),
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
        ),
      );
    },
  );
  }

  Widget _buildTabButton(String title, int index) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00E5FF).withValues(alpha: 0.2) : const Color(0xFF101726),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0xFF00E5FF) : Colors.white12,
            width: isActive ? 1.8 : 1.0,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 3),
              )
            else
              const BoxShadow(
                color: Color(0x66000000),
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
          ],
        ),
        child: Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isActive ? const Color(0xFF00E5FF) : Colors.white54,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xE610192A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x3300E5FF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x1A00E5FF),
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
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
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isFilled ? const Color(0xFF00E5FF) : const Color(0xFF1E2838),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: isFilled
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                                    blurRadius: 6,
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
  final double rotationAngle;

  _CarShowcasePainter({required this.car, this.rotationAngle = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    Car3DRenderer.render3DShowcase(
      canvas: canvas,
      size: size,
      car: car,
      yawAngle: rotationAngle,
      pitchAngle: 0.22,
      bounceY: 0.0,
      glowPulse: 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _CarShowcasePainter oldDelegate) {
    return oldDelegate.car != car || oldDelegate.rotationAngle != rotationAngle;
  }
}
