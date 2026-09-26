import 'dart:math';
import 'package:flame/components.dart';
import '../../models/power_up_model.dart';
import '../../services/audio_service.dart';
import '../components/laser_mine.dart';
import '../components/opponent_car.dart';
import '../components/player_car.dart';
import '../components/police_car.dart';
import '../components/power_up_pickup.dart';
import '../components/traffic_car.dart';

/// Cyberpunk Combat & Power-Up Management System
class CombatSystem {
  PowerUpType? currentPowerUp;
  bool hasShield = false;
  bool isTurboWarpActive = false;
  double _turboWarpTimer = 0.0;

  final List<PowerUpPickup> pickups = [];
  final List<LaserMine> activeMines = [];
  final Random _random = Random();

  void Function(PowerUpType?)? onPowerUpInventoryChanged;
  void Function(String eventText, PowerUpType type)? onCombatEventTriggered;

  void update(
    double dt,
    PlayerCar player,
    List<OpponentCar> opponents,
    List<TrafficCar> trafficList,
    List<PoliceCar> policeList,
  ) {
    // 1. Update Turbo Warp Timer
    if (isTurboWarpActive) {
      _turboWarpTimer -= dt;
      if (_turboWarpTimer <= 0) {
        isTurboWarpActive = false;
      }
    }

    // 2. Check Pickup Collisions with Player (TrackZ and TrackX distance)
    for (final pickup in pickups) {
      if (!pickup.isCollected) {
        final dz = (pickup.trackZ - player.trackZ).abs();
        final dx = (pickup.trackX - player.trackX).abs();
        if (dz < 80.0 && dx < 0.35) {
          pickup.isCollected = true;
          currentPowerUp = pickup.type;
          onPowerUpInventoryChanged?.call(currentPowerUp);
          onCombatEventTriggered?.call('COLLECTED ${pickup.type.displayName.toUpperCase()}!', pickup.type);
          AudioService().playButtonClick();
        }
      }
    }

    // Clean up collected or distant pickups behind player
    pickups.removeWhere((p) => p.isCollected || (player.trackZ - p.trackZ > 1200.0));

    // 3. Check Laser Mine Collisions
    for (final mine in activeMines) {
      if (!mine.isDetonated) {
        // Check rivals
        for (final opp in opponents) {
          final dz = (mine.trackZ - opp.trackZ).abs();
          final dx = (mine.trackX - opp.trackX).abs();
          if (dz < 70.0 && dx < 0.32) {
            mine.isDetonated = true;
            opp.speedKmH *= 0.3;
            opp.speed = opp.speedKmH * 32.0;
            onCombatEventTriggered?.call('💥 RIVAL HIT LASER MINE!', PowerUpType.laserMine);
            AudioService().playExplosionSound();
            break;
          }
        }

        // Check police
        for (final cop in policeList) {
          final dz = (mine.trackZ - cop.trackZ).abs();
          final dx = (mine.trackX - cop.trackX).abs();
          if (dz < 70.0 && dx < 0.32) {
            mine.isDetonated = true;
            cop.takeDamage(100.0);
            onCombatEventTriggered?.call('💥 POLICE INTERCEPTOR NEUTRALIZED!', PowerUpType.laserMine);
            AudioService().playExplosionSound();
            break;
          }
        }
      }
    }
    activeMines.removeWhere((m) => m.isDetonated || (player.trackZ - m.trackZ > 1500.0));
  }

  /// Activate current inventory power-up
  bool activatePowerUp(
    PlayerCar player,
    List<OpponentCar> opponents,
    List<PoliceCar> policeList,
    Component gameRef,
  ) {
    if (currentPowerUp == null) return false;

    final type = currentPowerUp!;
    switch (type) {
      case PowerUpType.empShockwave:
        _triggerEmpShockwave(player, opponents, policeList);
        AudioService().playEmpSound();
        break;
      case PowerUpType.energyShield:
        hasShield = true;
        onCombatEventTriggered?.call('🛡️ ENERGY SHIELD ENGAGED!', type);
        AudioService().playShieldSound();
        break;
      case PowerUpType.turboWarp:
        isTurboWarpActive = true;
        _turboWarpTimer = 4.0;
        player.speed = player.maxSpeed * 1.35;
        player.speedKmH = player.speed / 32.0;
        onCombatEventTriggered?.call('⚡ HYPER WARP BOOST ENGAGED!', type);
        AudioService().playNitroSound();
        break;
      case PowerUpType.laserMine:
        _deployLaserMine(player, gameRef);
        AudioService().playMineDeploySound();
        break;
    }

    currentPowerUp = null;
    onPowerUpInventoryChanged?.call(null);
    return true;
  }

  void _triggerEmpShockwave(
    PlayerCar player,
    List<OpponentCar> opponents,
    List<PoliceCar> policeList,
  ) {
    int affected = 0;
    for (final opp in opponents) {
      final dz = (opp.trackZ - player.trackZ).abs();
      if (dz < 1200.0) {
        opp.speedKmH *= 0.25;
        opp.speed = opp.speedKmH * 32.0;
        affected++;
      }
    }
    for (final cop in policeList) {
      final dz = (cop.trackZ - player.trackZ).abs();
      if (dz < 1200.0) {
        cop.takeDamage(60.0);
        affected++;
      }
    }

    onCombatEventTriggered?.call(
      affected > 0 ? '⚡ EMP BLAST: $affected VEHICLES STUNNED!' : '⚡ EMP SHOCKWAVE DISCHARGED!',
      PowerUpType.empShockwave,
    );
  }

  void _deployLaserMine(PlayerCar player, Component gameRef) {
    final mine = LaserMine(
      position: Vector2.zero(),
      isPlayerMine: true,
      trackZ: player.trackZ - 80.0,
      trackX: player.trackX,
    );
    activeMines.add(mine);
    gameRef.add(mine);
    onCombatEventTriggered?.call('🚨 LASER MINE DEPLOYED!', PowerUpType.laserMine);
  }

  /// Spawn random pickup crate ahead of player
  void spawnPickupAhead(double spawnZ, double spawnX, Component gameRef) {
    final type = PowerUpType.values[_random.nextInt(PowerUpType.values.length)];
    final pickup = PowerUpPickup(
      position: Vector2.zero(),
      type: type,
      trackZ: spawnZ,
      trackX: spawnX,
    );
    pickups.add(pickup);
    gameRef.add(pickup);
  }

  void reset() {
    currentPowerUp = null;
    hasShield = false;
    isTurboWarpActive = false;
    _turboWarpTimer = 0.0;
    for (final p in pickups) {
      p.removeFromParent();
    }
    pickups.clear();
    for (final m in activeMines) {
      m.removeFromParent();
    }
    activeMines.clear();
  }
}
