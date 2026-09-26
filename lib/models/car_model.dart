import 'package:flutter/material.dart';

enum CarClass { street, sport, superCar, hyperCar }

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
  }) {
    return CarModel(
      id: id,
      name: name,
      brand: brand,
      carClass: carClass,
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
  static List<CarModel> get stockCars => [
        const CarModel(
          id: 'phantom_gt',
          name: 'Phantom GT',
          brand: 'Apex Motors',
          carClass: CarClass.street,
          price: 0,
          isUnlocked: true,
          baseTopSpeed: 210,
          baseAcceleration: 5.2,
          baseHandling: 6.0,
          baseBraking: 5.5,
          baseNitro: 5.0,
          bodyColor: Color(0xFF00E5FF), // Cyber Cyan
          neonUnderglowColor: Color(0xFF00E5FF),
          stripeColor: Color(0xFF111111),
        ),
        const CarModel(
          id: 'vortex_rx',
          name: 'Vortex RX-7',
          brand: 'Kurogane Works',
          carClass: CarClass.sport,
          price: 15000,
          isUnlocked: false,
          baseTopSpeed: 250,
          baseAcceleration: 6.5,
          baseHandling: 7.8,
          baseBraking: 6.8,
          baseNitro: 6.5,
          bodyColor: Color(0xFFFF5252), // Blaze Red
          neonUnderglowColor: Color(0xFFFF1744),
          stripeColor: Color(0xFFFFFFFF),
        ),
        const CarModel(
          id: 'viper_gtr',
          name: 'Viper GTR',
          brand: 'Velocity Dynamics',
          carClass: CarClass.sport,
          price: 38000,
          isUnlocked: false,
          baseTopSpeed: 285,
          baseAcceleration: 7.6,
          baseHandling: 7.2,
          baseBraking: 7.5,
          baseNitro: 7.0,
          bodyColor: Color(0xFFFFD600), // Electric Yellow
          neonUnderglowColor: Color(0xFFFFAB00),
          stripeColor: Color(0xFF000000),
        ),
        const CarModel(
          id: 'nemesis_gt',
          name: 'Nemesis RS',
          brand: 'Stuttgart Racing',
          carClass: CarClass.superCar,
          price: 80000,
          isUnlocked: false,
          baseTopSpeed: 330,
          baseAcceleration: 8.8,
          baseHandling: 8.5,
          baseBraking: 8.7,
          baseNitro: 8.5,
          bodyColor: Color(0xFF7C4DFF), // Ultraviolet
          neonUnderglowColor: Color(0xFF651FFF),
          stripeColor: Color(0xFF00E5FF),
        ),
        const CarModel(
          id: 'hyperion_x',
          name: 'Hyperion Chiron',
          brand: 'Kronos Prototype',
          carClass: CarClass.hyperCar,
          price: 180000,
          isUnlocked: false,
          baseTopSpeed: 395,
          baseAcceleration: 9.8,
          baseHandling: 9.2,
          baseBraking: 9.5,
          baseNitro: 9.5,
          bodyColor: Color(0xFF00E676), // Acid Green
          neonUnderglowColor: Color(0xFF00E676),
          stripeColor: Color(0xFF1A237E),
        ),
      ];
}
