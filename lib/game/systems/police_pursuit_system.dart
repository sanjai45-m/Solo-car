import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../services/audio_service.dart';
import '../components/player_car.dart';
import '../components/police_car.dart';
import '../components/road_manager.dart';

class PolicePursuitSystem extends Component {
  final PlayerCar playerCar;
  final RoadManager roadManager;
  final Function(int heatTier)? onHeatLevelChanged;
  final Function(String message, int cashReward)? onPursuitEvaded;
  final Function()? onPlayerBusted;

  double heatScore = 1.0; // 1.0 to 5.0
  int get heatLevel => heatScore.floor().clamp(1, 5);

  final List<PoliceCar> activePolice = [];
  double spawnCooldown = 4.0;
  double sirenCooldown = 2.5;
  double bustedTimer = 0.0;
  double evadeTimer = 0.0;
  bool isPursuitActive = true;

  final math.Random _random = math.Random();

  PolicePursuitSystem({
    required this.playerCar,
    required this.roadManager,
    this.onHeatLevelChanged,
    this.onPursuitEvaded,
    this.onPlayerBusted,
  });

  @override
  void update(double dt) {
    super.update(dt);

    if (!isPursuitActive) return;

    // 1. Heat accumulation based on player driving actions
    if (playerCar.speedKmH > 220) {
      heatScore = math.min(5.0, heatScore + 0.02 * dt);
    }
    if (playerCar.isNitroActive) {
      heatScore = math.min(5.0, heatScore + 0.04 * dt);
    }
    if (playerCar.isDrifting) {
      heatScore = math.min(5.0, heatScore + 0.03 * dt);
    }

    // 2. Police Spawning based on Heat Level
    spawnCooldown -= dt;
    final maxPoliceAllowed = heatLevel >= 4 ? 4 : (heatLevel >= 2 ? 3 : 2);

    // Clean up destroyed or distant police
    activePolice.removeWhere((cop) {
      if (cop.isDestroyed) {
        cop.removeFromParent();
        return true;
      }
      final dist = (cop.trackZ - playerCar.trackZ).abs();
      if (dist > 3000.0) {
        cop.removeFromParent();
        return true;
      }
      return false;
    });

    if (spawnCooldown <= 0 && activePolice.length < maxPoliceAllowed) {
      spawnCooldown = 7.0 - (heatLevel * 0.8) + _random.nextDouble() * 2.0;
      _spawnPoliceUnit();
    }

    // 3. Siren Sound loop when police are close
    sirenCooldown -= dt;
    if (sirenCooldown <= 0 && activePolice.isNotEmpty) {
      sirenCooldown = 3.2;
      // Check if any police is within 600m
      final nearest = activePolice.any((c) => (c.trackZ - playerCar.trackZ).abs() < 600);
      if (nearest) {
        AudioService().playPoliceSirenSound();
      }
    }

    // 4. Busted & Evaded Logic
    _checkPursuitStatus(dt);
  }

  void _spawnPoliceUnit() {
    final isRoadblockSpawn = heatLevel >= 3 && _random.nextDouble() < 0.35;
    final spawnZ = isRoadblockSpawn
        ? playerCar.trackZ + 700.0 + _random.nextDouble() * 400.0
        : playerCar.trackZ - 350.0 - _random.nextDouble() * 200.0;

    final cop = PoliceCar(
      position: Vector2.zero(),
      heatTier: heatLevel,
      roadManager: roadManager,
      playerCar: playerCar,
      isRoadblock: isRoadblockSpawn,
    );
    cop.trackZ = spawnZ;
    cop.trackX = isRoadblockSpawn ? (_random.nextBool() ? 0.35 : -0.35) : (_random.nextDouble() * 1.4 - 0.7);

    activePolice.add(cop);
    parent?.add(cop);
  }

  void _checkPursuitStatus(double dt) {
    if (activePolice.isEmpty) {
      evadeTimer += dt;
      if (evadeTimer > 5.0) {
        evadeTimer = 0.0;
        final bounty = heatLevel * 750;
        onPursuitEvaded?.call('PURSUIT EVADED! + \$$bounty BOUNTY', bounty);
        heatScore = math.max(1.0, heatScore - 1.0);
      }
      return;
    }

    // Check if player is surrounded and stopped (Busted)
    PoliceCar? closestCop;
    double minDistance = double.infinity;
    for (final cop in activePolice) {
      final d = (cop.trackZ - playerCar.trackZ).abs();
      if (d < minDistance) {
        minDistance = d;
        closestCop = cop;
      }
    }

    if (minDistance < 60.0 && playerCar.speedKmH < 45.0) {
      bustedTimer += dt;
      if (bustedTimer >= 3.2) {
        // BUSTED!
        onPlayerBusted?.call();
      }
    } else {
      bustedTimer = math.max(0.0, bustedTimer - dt * 2.0);
    }

    // Evade when distant
    if (minDistance > 1100.0) {
      evadeTimer += dt;
      if (evadeTimer > 6.0) {
        evadeTimer = 0.0;
        final bounty = heatLevel * 1000;
        onPursuitEvaded?.call('PURSUIT EVADED! + \$$bounty BOUNTY', bounty);
        heatScore = math.max(1.0, heatScore - 1.0);
      }
    } else {
      evadeTimer = 0.0;
    }
  }

  void addHeatFromTakedown() {
    heatScore = math.min(5.0, heatScore + 0.6);
  }

  void reset() {
    for (final cop in activePolice) {
      cop.removeFromParent();
    }
    activePolice.clear();
    heatScore = 1.0;
    bustedTimer = 0.0;
    evadeTimer = 0.0;
  }
}
