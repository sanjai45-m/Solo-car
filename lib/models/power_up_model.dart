import 'package:flutter/material.dart';

/// Available Cyberpunk Combat Power-Up Types
enum PowerUpType {
  empShockwave,
  energyShield,
  turboWarp,
  laserMine,
}

extension PowerUpTypeExtension on PowerUpType {
  String get displayName {
    switch (this) {
      case PowerUpType.empShockwave:
        return 'EMP SHOCKWAVE';
      case PowerUpType.energyShield:
        return 'ENERGY SHIELD';
      case PowerUpType.turboWarp:
        return 'TURBO WARP';
      case PowerUpType.laserMine:
        return 'LASER MINE';
    }
  }

  String get description {
    switch (this) {
      case PowerUpType.empShockwave:
        return 'Disables nearby rival engines for 3s';
      case PowerUpType.energyShield:
        return 'Absorbs 1 collision impact completely';
      case PowerUpType.turboWarp:
        return 'Unleashes 2.5x warp velocity burst';
      case PowerUpType.laserMine:
        return 'Deploys an explosive road trap behind you';
    }
  }

  IconData get icon {
    switch (this) {
      case PowerUpType.empShockwave:
        return Icons.electric_bolt;
      case PowerUpType.energyShield:
        return Icons.shield;
      case PowerUpType.turboWarp:
        return Icons.rocket_launch;
      case PowerUpType.laserMine:
        return Icons.crisis_alert;
    }
  }

  Color get primaryColor {
    switch (this) {
      case PowerUpType.empShockwave:
        return const Color(0xFF00E5FF); // Neon Cyan
      case PowerUpType.energyShield:
        return const Color(0xFF69F0AE); // Neon Green
      case PowerUpType.turboWarp:
        return const Color(0xFFE040FB); // Neon Purple / Magenta
      case PowerUpType.laserMine:
        return const Color(0xFFFF3D00); // Neon Orange / Red
    }
  }
}
