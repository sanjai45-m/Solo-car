import 'package:flutter/material.dart';
import '../../services/haptic_service.dart';
import '../components/car_base.dart';
import '../components/player_car.dart';
import '../components/traffic_car.dart';
import '../components/opponent_car.dart';
import '../components/pickup_item.dart';
import 'particle_effects.dart';

class CollisionSystem {
  final VoidCallback? onCameraShake;
  final Function(String message, int cashBonus)? onNearMiss;
  final Function(PickupType type)? onPickupCollected;
  final Function(double severity)? onCrash;

  final Map<int, double> _collisionCooldowns = {};
  final Set<int> _creditedNearMissCarIds = {};
  double raceElapsedTime = 0.0;

  CollisionSystem({
    this.onCameraShake,
    this.onNearMiss,
    this.onPickupCollected,
    this.onCrash,
  });

  void update(double dt) {
    raceElapsedTime += dt;
  }

  void checkCollisions({
    required PlayerCar player,
    required List<TrafficCar> trafficList,
    required List<OpponentCar> opponents,
    required List<PickupItem> pickups,
    required ApexParticleSystem particles,
  }) {
    // 1. Player vs Traffic (dz < 55.0, dx < 0.32)
    for (final traffic in trafficList) {
      final dz = (player.trackZ - traffic.trackZ).abs();
      final dx = (player.trackX - traffic.trackX).abs();

      if (dz < 55.0 && dx < 0.32) {
        _resolveVehicleCollision(
          player: player,
          other: traffic,
          particles: particles,
        );
      } else if (dz < 120.0 && dx >= 0.32 && dx <= 0.70) {
        _checkNearMiss(player, traffic);
      }
    }

    // 2. Player vs Opponents (Launch ghosting: ignore for first 3.5s of race launch)
    if (raceElapsedTime > 3.5) {
      for (final opponent in opponents) {
        final dz = (player.trackZ - opponent.trackZ).abs();
        final dx = (player.trackX - opponent.trackX).abs();

        if (dz < 55.0 && dx < 0.32) {
          _resolveVehicleCollision(
            player: player,
            other: opponent,
            particles: particles,
          );
        } else if (dz < 120.0 && dx >= 0.32 && dx <= 0.70) {
          _checkNearMiss(player, opponent);
        }
      }
    }

    // 3. Player vs Pickups
    for (int i = pickups.length - 1; i >= 0; i--) {
      final pickup = pickups[i];
      final dz = (player.trackZ - pickup.trackZ).abs();
      final dx = (player.trackX - pickup.trackX).abs();

      if (dz < 75.0 && dx < 0.45) {
        if (pickup.type == PickupType.nitroRefill) {
          player.currentNitro = player.maxNitro;
        } else if (pickup.type == PickupType.repairKit) {
          player.health = 100.0;
        }
        onPickupCollected?.call(pickup.type);
        pickups.removeAt(i);
        pickup.removeFromParent();
      }
    }
  }

  void _resolveVehicleCollision({
    required PlayerCar player,
    required CarBase other,
    required ApexParticleSystem particles,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastHit = _collisionCooldowns[other.hashCode] ?? 0;
    if (now - lastHit < 750) {
      // Prevent multi-frame collision locking
      return;
    }
    _collisionCooldowns[other.hashCode] = now.toDouble();

    // Ignore collisions during launch at low speed (< 40 km/h)
    if (player.speedKmH < 40 && other.speedKmH < 40) {
      return;
    }

    final speedDiff = (player.speed - other.speed).abs() / 32.0;
    final severity = (speedDiff / 100.0).clamp(0.10, 0.60);
    final xDiff = player.trackX - other.trackX;
    final xPush = (xDiff.sign == 0 ? 1 : xDiff.sign) * (0.04 + severity * 0.06);
    final speedLossRatio = 0.08 + (severity * 0.12);

    player.handleCollisionImpulse(speedLossRatio, xPush * 100);
    other.speed *= 0.88;

    // Trigger Camera Shake & Audio only on substantial impact
    if (speedDiff > 50) {
      onCameraShake?.call();
      onCrash?.call(severity);
      HapticService().collisionHeavy();
    } else {
      HapticService().gearShift();
    }
  }

  void _checkNearMiss(PlayerCar player, CarBase other) {
    if (player.speedKmH < 120) return;

    final carHashCode = other.hashCode;
    if (_creditedNearMissCarIds.contains(carHashCode)) return;

    _creditedNearMissCarIds.add(carHashCode);
    player.addNearMissReward();
    HapticService().nearMiss();
    onNearMiss?.call('NEAR MISS! +25 NITRO', 75);
  }

  void clearOldNearMissCache() {
    if (_creditedNearMissCarIds.length > 50) {
      _creditedNearMissCarIds.clear();
    }
  }
}
