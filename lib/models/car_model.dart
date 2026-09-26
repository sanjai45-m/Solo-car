import 'package:flutter/material.dart';

enum CarClass { street, sport, superCar, hyperCar }

enum CarBodyStyle {
  streetTuner,   // Fastback tuner with dual stripes, lip spoiler, quad exhaust
  jdmRotary,     // Widebody drift coupe with high-mount GT wing, single titanium can
  muscleGtr,     // Aggressive widebody muscle with dual bonnet vents, big downforce wing
  exoticSuper,   // Low-slung European wedge supercar with ducktail & hexagon rear deck
  leMansHypercar,// Le Mans prototype hypercar with central shark fin & jet thruster halo
}

class CarUpgrade {
  final int level;
  final int maxLevel;
  final int costPerLevel;

  const CarUpgrade({
    this.level = 1,
    this.maxLevel = 5,
    this.costPerLevel = 1000,
  });

  CarUpgrade copyWith({int? level}) {
    return CarUpgrade(
      level: level ?? this.level,
      maxLevel: maxLevel,
      costPerLevel: costPerLevel,
    );
  }

  Map<String, dynamic> toJson() => {'level': level};

  factory CarUpgrade.fromJson(Map<String, dynamic> json, int costPerLevel) {
    return CarUpgrade(
      level: json['level'] as int? ?? 1,
      maxLevel: 5,
      costPerLevel: costPerLevel,
    );
  }
}

class CarModel {
  final String id;
  final String name;
  final String brand;
  final CarClass carClass;
  final CarBodyStyle bodyStyle;
  final int price;
  final bool isUnlocked;

  // Base stats (Scale 1 - 100)
  final double baseTopSpeed; // Max km/h base (~180 to 380)
  final double baseAcceleration; // 0-100 km/h rate
  final double baseHandling; // Cornering agility & grip
  final double baseBraking; // Stopping power
  final double baseNitro; // Nitro boost multiplier & capacity

  // Upgrades (Level 1 to 5)
  final CarUpgrade engineUpgrade;
  final CarUpgrade handlingUpgrade;
  final CarUpgrade brakeUpgrade;
  final CarUpgrade nitroUpgrade;

  // Visual Customization
  final Color bodyColor;
  final Color neonUnderglowColor;
  final Color stripeColor;
  final bool hasUnderglow;

  const CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.carClass,
    this.bodyStyle = CarBodyStyle.streetTuner,
    required this.price,
    this.isUnlocked = false,
    required this.baseTopSpeed,
    required this.baseAcceleration,
    required this.baseHandling,
    required this.baseBraking,
    required this.baseNitro,
    this.engineUpgrade = const CarUpgrade(costPerLevel: 1500),
    this.handlingUpgrade = const CarUpgrade(costPerLevel: 1200),
    this.brakeUpgrade = const CarUpgrade(costPerLevel: 1000),
    this.nitroUpgrade = const CarUpgrade(costPerLevel: 1800),
    this.bodyColor = const Color(0xFFE50914), // Crimson Red
    this.neonUnderglowColor = const Color(0xFF00E5FF), // Cyan Glow
    this.stripeColor = const Color(0xFFFFFFFF),
    this.hasUnderglow = true,
  });

  // Effective calculated stats factoring in upgrades
  double get topSpeedKmH =>
      baseTopSpeed + (engineUpgrade.level - 1) * 15.0; // e.g. up to +60 km/h
  double get accelerationRate =>
      baseAcceleration + (engineUpgrade.level - 1) * 0.18;
  double get handlingRate =>
      baseHandling + (handlingUpgrade.level - 1) * 0.15;
  double get brakingRate =>
      baseBraking + (brakeUpgrade.level - 1) * 0.20;
  double get nitroCapacity =>
      100.0 + (nitroUpgrade.level - 1) * 20.0;
  double get nitroMultiplier =>
      1.35 + (nitroUpgrade.level - 1) * 0.08;

  // Visual rating between 0.0 and 1.0 for UI stat bars
  double get topSpeedNormalized => (topSpeedKmH / 420.0).clamp(0.1, 1.0);
  double get accelerationNormalized =>
      ((accelerationRate * 10) / 100.0).clamp(0.1, 1.0);
  double get handlingNormalized =>
      ((handlingRate * 10) / 100.0).clamp(0.1, 1.0);
  double get brakingNormalized =>
      ((brakingRate * 10) / 100.0).clamp(0.1, 1.0);
  double get nitroNormalized =>
      ((nitroCapacity) / 200.0).clamp(0.1, 1.0);

  CarModel copyWith({
    bool? isUnlocked,
    CarUpgrade? engineUpgrade,
    CarUpgrade? handlingUpgrade,
    CarUpgrade? brakeUpgrade,
    CarUpgrade? nitroUpgrade,
    Color? bodyColor,
    Color? neonUnderglowColor,
    Color? stripeColor,
    bool? hasUnderglow,
    CarBodyStyle? bodyStyle,
  }) {
    return CarModel(
      id: id,
      name: name,
      brand: brand,
      carClass: carClass,
      bodyStyle: bodyStyle ?? this.bodyStyle,
      price: price,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      baseTopSpeed: baseTopSpeed,
      baseAcceleration: baseAcceleration,
      baseHandling: baseHandling,
      baseBraking: baseBraking,
      baseNitro: baseNitro,
      engineUpgrade: engineUpgrade ?? this.engineUpgrade,
      handlingUpgrade: handlingUpgrade ?? this.handlingUpgrade,
      brakeUpgrade: brakeUpgrade ?? this.brakeUpgrade,
      nitroUpgrade: nitroUpgrade ?? this.nitroUpgrade,
      bodyColor: bodyColor ?? this.bodyColor,
      neonUnderglowColor: neonUnderglowColor ?? this.neonUnderglowColor,
      stripeColor: stripeColor ?? this.stripeColor,
      hasUnderglow: hasUnderglow ?? this.hasUnderglow,
    );
  }

  // Stock Car Roster
  // Stock Car Roster - Official 3D Racing Lineup
  static List<CarModel> get stockCars => [
        const CarModel(
          id: 'inferno_x',
          name: 'Inferno X',
          brand: 'Apex Hypercars',
          carClass: CarClass.superCar,
          bodyStyle: CarBodyStyle.exoticSuper,
          price: 0,
          isUnlocked: true,
          baseTopSpeed: 340,
          baseAcceleration: 8.9,
          baseHandling: 8.8,
          baseBraking: 8.6,
          baseNitro: 8.5,
          bodyColor: Color(0xFFD50000), // Deep Glossy Crimson Red
          neonUnderglowColor: Color(0xFFFF1744),
          stripeColor: Color(0xFF111111),
        ),
        const CarModel(
          id: 'neon_gt',
          name: 'Neon GT',
          brand: 'Kurogane Street Works',
          carClass: CarClass.street,
          bodyStyle: CarBodyStyle.streetTuner,
          price: 18000,
          isUnlocked: false,
          baseTopSpeed: 275,
          baseAcceleration: 7.2,
          baseHandling: 8.2,
          baseBraking: 7.4,
          baseNitro: 7.5,
          bodyColor: Color(0xFF00B0FF), // Metallic Electric Blue
          neonUnderglowColor: Color(0xFF00E5FF),
          stripeColor: Color(0xFF00E5FF),
        ),
        const CarModel(
          id: 'shadow_v8',
          name: 'Shadow V8',
          brand: 'Detroit Performance',
          carClass: CarClass.sport,
          bodyStyle: CarBodyStyle.muscleGtr,
          price: 42000,
          isUnlocked: false,
          baseTopSpeed: 310,
          baseAcceleration: 8.2,
          baseHandling: 7.6,
          baseBraking: 7.8,
          baseNitro: 8.0,
          bodyColor: Color(0xFF1E2128), // Matte Black / Dark Metallic
          neonUnderglowColor: Color(0xFFFF3D00),
          stripeColor: Color(0xFFFF1744),
        ),
        const CarModel(
          id: 'viper_rs',
          name: 'Viper RS',
          brand: 'Stuttgart Track Division',
          carClass: CarClass.sport,
          bodyStyle: CarBodyStyle.jdmRotary,
          price: 85000,
          isUnlocked: false,
          baseTopSpeed: 360,
          baseAcceleration: 9.2,
          baseHandling: 9.4,
          baseBraking: 9.2,
          baseNitro: 8.8,
          bodyColor: Color(0xFF76FF03), // Lime Green Track Acid
          neonUnderglowColor: Color(0xFF00E676),
          stripeColor: Color(0xFF111111),
        ),
        const CarModel(
          id: 'phantom_r',
          name: 'Phantom R',
          brand: 'Kronos Prototype',
          carClass: CarClass.hyperCar,
          bodyStyle: CarBodyStyle.leMansHypercar,
          price: 195000,
          isUnlocked: false,
          baseTopSpeed: 410,
          baseAcceleration: 9.9,
          baseHandling: 9.6,
          baseBraking: 9.8,
          baseNitro: 9.8,
          bodyColor: Color(0xFFF0F4F8), // Pearl White Metallic
          neonUnderglowColor: Color(0xFF00E5FF),
          stripeColor: Color(0xFF00E5FF),
        ),
      ];
}
