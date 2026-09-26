import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/car_model.dart';
import '../models/multiplayer_room.dart';
import '../models/race_model.dart';
import '../services/auth_service.dart';
import '../services/multiplayer_service.dart';
import 'components/opponent_car.dart';
import 'components/pickup_item.dart';
import 'components/player_car.dart';
import 'components/road_manager.dart';
import 'components/traffic_car.dart';
import 'systems/collision_system.dart';
import 'systems/particle_effects.dart';
import 'systems/race_manager.dart';

class ApexRacingGame extends FlameGame with KeyboardEvents {
  final CarModel carModel;
  final RaceTrack track;

  // Callback hooks for Flutter HUD & Overlays
  void Function(int position, int totalRacers)? onPositionUpdate;
  void Function(double speedKmH, double rpmRatio)? onSpeedUpdate;
  void Function(double nitroPercent)? onNitroUpdate;
  void Function(double progressRatio, int currentLap, int totalLaps)? onLapUpdate;
  void Function(int count)? onCountdown;
  void Function(String title, int bonus)? onAlertMessage;
  void Function(double driftPoints, double multiplier, bool isDrifting)? onDriftUpdate;
  void Function(int position, int timeMs, int cashEarned)? onRaceFinish;
  VoidCallback? onPauseRequest;

  late final RoadManager roadManager;
  late final PlayerCar playerCar;
  late final ApexParticleSystem particleSystem;
  late final CollisionSystem collisionSystem;
  late final RaceManager raceManager;

  final List<OpponentCar> opponents = [];
  final List<TrafficCar> trafficList = [];
  final List<PickupItem> pickups = [];

  // Pseudo-3D Camera constants matching mobile hill climbing racer
  final double cameraHeight = 1400.0;
  final double cameraDepth = 0.85; // 1.0 / tan(FOV / 2)

  double shakeIntensity = 0.0;
  final math.Random _random = math.Random();
  double pickupSpawnTimer = 0.0;
  bool isInitialized = false;
  final bool enforceTrackBoundary;
  final List<MultiplayerPlayerSlot>? multiplayerOpponents;

  ApexRacingGame({
    required this.carModel,
    required this.track,
    this.multiplayerOpponents,
    this.enforceTrackBoundary = true,
    this.onPositionUpdate,
    this.onSpeedUpdate,
    this.onNitroUpdate,
    this.onLapUpdate,
    this.onCountdown,
    this.onAlertMessage,
    this.onDriftUpdate,
    this.onRaceFinish,
    this.onPauseRequest,
  }) {
    roadManager = RoadManager(track: track);
    roadManager.preloadMap();
    particleSystem = ApexParticleSystem();

    playerCar = PlayerCar(
      position: Vector2.zero(),
      carModel: carModel,
      roadManager: roadManager,
      enforceTrackBoundary: enforceTrackBoundary,
    );

    _spawnOpponents();
    _initTrafficFleet();

    collisionSystem = CollisionSystem(
      onCameraShake: triggerScreenShake,
      onNearMiss: (msg, bonus) => onAlertMessage?.call(msg, bonus),
      onPickupCollected: (type) {
        if (type == PickupType.nitroRefill) {
          onAlertMessage?.call('NITRO REFILLED!', 0);
        } else if (type == PickupType.cashBonus) {
          onAlertMessage?.call('CASH BUNDLE +\$250!', 250);
        } else if (type == PickupType.repairKit) {
          onAlertMessage?.call('CAR REPAIRED!', 0);
        }
      },
    );

    raceManager = RaceManager(
      track: track,
      player: playerCar,
      opponents: opponents,
      onCountdownTick: (count) => onCountdown?.call(count),
      onRaceStart: () => onCountdown?.call(0),
      onRaceFinish: (pos, timeMs, cash) => onRaceFinish?.call(pos, timeMs, cash),
    );

    isInitialized = true;
  }

  void _spawnOpponents() {
    opponents.clear();

    // 1. If in real multiplayer lobby, spawn EXACT opponent player cars from lobby slots
    if (multiplayerOpponents != null && multiplayerOpponents!.isNotEmpty) {
      for (int i = 0; i < multiplayerOpponents!.length; i++) {
        final slot = multiplayerOpponents![i];
        final opponent = OpponentCar(
          position: Vector2.zero(),
          driverName: slot.displayName,
          playerUid: slot.uid,
          isRemoteMultiplayer: true,
          difficulty: track.difficulty,
          roadManager: roadManager,
          startingGridIndex: i + 1,
          color: slot.carColor,
          underglowColor: slot.carColor,
        );
        opponents.add(opponent);
      }
      return;
    }

    // 2. Single-player / Practice AI fleet
    final rivalNames = [
      'Viper_99',
      'ApexPhantom',
      'NeonSpecter',
      'KuroganeRacer',
      'VelocityX',
      'TitanDrifter',
      'ShadowTuner'
    ];

    final colors = [
      const Color(0xFFFF5252),
      const Color(0xFFFFD600),
      const Color(0xFF7C4DFF),
      const Color(0xFF00E676),
      const Color(0xFFFF4081),
      const Color(0xFF448AFF),
      const Color(0xFFFF6E40),
    ];

    for (int i = 0; i < track.opponentCount; i++) {
      final opponent = OpponentCar(
        position: Vector2.zero(),
        driverName: rivalNames[i % rivalNames.length],
        difficulty: track.difficulty,
        roadManager: roadManager,
        startingGridIndex: i + 1,
        color: colors[i % colors.length],
        underglowColor: colors[(i + 2) % colors.length],
      );
      opponents.add(opponent);
    }
  }

  void _initTrafficFleet() {
    trafficList.clear();

    // In 2-player / multiplayer head-to-head duel, no computer cars or traffic
    if (multiplayerOpponents != null && multiplayerOpponents!.isNotEmpty) {
      return;
    }

    final trafficTypes = TrafficType.values;
    final colors = [
      const Color(0xFFE0E0E0),
      const Color(0xFF1E88E5),
      const Color(0xFF43A047),
      const Color(0xFFFFB300),
      const Color(0xFFE53935),
      const Color(0xFF424242),
    ];

    final lanes = [-0.6, 0.0, 0.6];
    final count = track.trafficDensity * 4;

    for (int i = 0; i < count; i++) {
      // Traffic starts well ahead of the starting grid straightaway
      final z = 2400.0 + (i * 1200.0);
      final lane = lanes[i % lanes.length];
      final type = trafficTypes[i % trafficTypes.length];
      final speed = (70 + _random.nextDouble() * 50) * 32.0;

      final traffic = TrafficCar(
        position: Vector2.zero(),
        trafficType: type,
        roadManager: roadManager,
        startTrackZ: z,
        startTrackX: lane,
        targetSpeed: speed,
        color: colors[i % colors.length],
      );
      trafficList.add(traffic);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (raceManager.state == RaceState.countdown) {
      playerCar.speed = 0.0;
      playerCar.speedKmH = 0.0;

      for (final opp in opponents) {
        opp.speed = 0.0;
        opp.speedKmH = 0.0;
      }

      particleSystem.update(dt);
      raceManager.update(dt);
      return;
    }

    playerCar.update(dt);

    // 1. In multiplayer match, broadcast YOUR car position & sync opponent car positions
    if (multiplayerOpponents != null && multiplayerOpponents!.isNotEmpty) {
      final myUid = AuthService().currentUser?.uid ?? 'me';
      MultiplayerService().updatePlayerTelemetry(
        uid: myUid,
        trackZ: playerCar.trackZ,
        trackX: playerCar.trackX,
        speedKmH: playerCar.speedKmH,
        steering: playerCar.steeringAngle,
        isNitro: playerCar.isNitroActive,
      );

      final room = MultiplayerService().currentRoom;
      if (room != null) {
        for (final opp in opponents) {
          if (opp.isRemoteMultiplayer && opp.playerUid != null) {
            final peerSlot = room.players.firstWhere(
              (p) => p.uid == opp.playerUid,
              orElse: () => room.players.first,
            );
            if (peerSlot.trackZ > 0 || peerSlot.speedKmH > 0 || peerSlot.trackX != 0) {
              opp.updateRemoteTelemetry(
                remoteZ: peerSlot.trackZ,
                remoteX: peerSlot.trackX,
                remoteSpeedKmH: peerSlot.speedKmH,
                remoteSteering: peerSlot.steeringAngle,
                remoteNitro: peerSlot.isNitroActive,
              );
            }
          }
        }
      }
    }

    for (final opp in opponents) {
      opp.update(dt);
    }
    for (final t in trafficList) {
      t.update(dt);
    }
    for (final p in pickups) {
      p.update(dt);
    }
    particleSystem.update(dt);
    raceManager.update(dt);

    // Screen Shake decay
    if (shakeIntensity > 0) {
      shakeIntensity = (shakeIntensity - 8.0 * dt).clamp(0.0, 15.0);
    }

    // Player particle effects
    final screenW = hasLayout ? size.x : 800.0;
    final screenH = hasLayout ? size.y : 600.0;
    final playerScreenX = (screenW / 2) + (playerCar.trackX * (screenW * 0.15));
    final playerScreenY = screenH * 0.82;
    const playerScale = 1.25;

    if (playerCar.isNitroActive) {
      particleSystem.emitNitroFlames(
        carScreenX: playerScreenX,
        carScreenY: playerScreenY,
        carScale: playerScale,
      );
      if (playerCar.speedKmH > 230) {
        particleSystem.emitSpeedLines(screenSize: Size(screenW, screenH));
      }
    }

    if (playerCar.isDrifting) {
      particleSystem.emitDriftSmoke(
        carScreenX: playerScreenX,
        carScreenY: playerScreenY,
        carScale: playerScale,
        intensity: (playerCar.speedKmH / 180).clamp(0.3, 1.0),
      );
    }

    // Pickups spawner along track
    _updatePickupSpawner(dt);

    // Collision Detection
    collisionSystem.checkCollisions(
      player: playerCar,
      trafficList: trafficList,
      opponents: opponents,
      pickups: pickups,
      particles: particleSystem,
    );

    // Dispatch HUD updates
    onPositionUpdate?.call(raceManager.playerPosition, opponents.length + 1);
    final rpmRatio = (playerCar.speed / playerCar.maxSpeed).clamp(0.0, 1.0);
    onSpeedUpdate?.call(playerCar.speedKmH, rpmRatio);
    onNitroUpdate?.call(playerCar.currentNitro / playerCar.maxNitro);

    final progressRatio = (playerCar.distanceDrivenMeters / track.trackDistanceMeters).clamp(0.0, 1.0);
    onLapUpdate?.call(progressRatio, raceManager.currentLap, raceManager.totalLaps);

    onDriftUpdate?.call(
      playerCar.currentDriftPoints,
      playerCar.driftMultiplier,
      playerCar.isDrifting,
    );
  }

  void _updatePickupSpawner(double dt) {
    pickupSpawnTimer += dt;
    if (pickupSpawnTimer > 5.0) {
      pickupSpawnTimer = 0.0;
      final lanes = [-0.6, 0.0, 0.6];
      final types = PickupType.values;

      final spawnZ = playerCar.trackZ + 1600.0 + _random.nextDouble() * 1200.0;
      final spawnX = lanes[_random.nextInt(lanes.length)];

      final pickup = PickupItem(
        position: Vector2.zero(),
        type: types[_random.nextInt(types.length)],
        trackZ: spawnZ,
        trackX: spawnX,
      );
      pickups.add(pickup);
    }

    // Remove pickups far behind player
    pickups.removeWhere((p) {
      final dz = playerCar.trackZ - p.trackZ;
      return dz > 500.0 && dz < (roadManager.trackLength - 500.0);
    });
  }

  void triggerScreenShake({double intensity = 6.0}) {
    shakeIntensity = intensity;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();

    // 1. Camera Shake offset
    final shakeX = (shakeIntensity > 0) ? (_random.nextDouble() - 0.5) * shakeIntensity : 0.0;
    final shakeY = (shakeIntensity > 0) ? (_random.nextDouble() - 0.5) * shakeIntensity : 0.0;
    canvas.translate(shakeX, shakeY);

    final screenSize = size.toSize();

    // 2. Parallax Sky & Horizon Background
    _renderParallaxBackground(canvas, screenSize);

    // 3. Render 3D Curved Road & Roadside Props
    roadManager.render3D(
      canvas,
      screenSize: screenSize,
      playerZ: playerCar.trackZ,
      playerX: playerCar.trackX,
      cameraHeight: cameraHeight,
      cameraDepth: cameraDepth,
    );

    // 4. Render 3D AI Opponents & Traffic Vehicles (Depth-sorted Far to Near)
    _renderOtherVehiclesAndPickups(canvas, screenSize);

    // 5. Render Player Car (Bottom Center in 3D perspective)
    _renderPlayerCar(canvas, screenSize);

    // 6. Render Particle System (Nitro Flames, Tire Smoke, Sparks, Speed lines)
    particleSystem.renderParticles(canvas);

    // 7. Day/Night Lighting Overlay & Headlight Beam
    _renderAtmosphericOverlay(canvas, screenSize);

    canvas.restore();
  }

  void _renderParallaxBackground(Canvas canvas, Size screenSize) {
    final horizonY = screenSize.height * 0.40;
    final panX = -playerCar.trackX * 80.0;

    // Sky Gradient
    List<Color> skyColors;
    switch (track.environment) {
      case EnvironmentType.alpineForest:
        skyColors = const [
          Color(0xFF29B6F6),
          Color(0xFF81D4FA),
          Color(0xFFE1F5FE),
        ];
        break;
      case EnvironmentType.neonCity:
        skyColors = const [Color(0xFF070214), Color(0xFF13092D), Color(0xFF1D0E44)];
        break;
      case EnvironmentType.coastalSunset:
        skyColors = const [Color(0xFF4A154B), Color(0xFFD34F2D), Color(0xFFFF8C42)];
        break;
      case EnvironmentType.desertCanyon:
        skyColors = const [Color(0xFF2C1654), Color(0xFFC85A17), Color(0xFFFFA000)];
        break;
    }

    final skyPaint = Paint()
      ..shader = LinearGradient(
        colors: skyColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, screenSize.width, horizonY));
    canvas.drawRect(Rect.fromLTWH(0, 0, screenSize.width, horizonY), skyPaint);

    // Sun / Moon / Stars
    if (track.environment == EnvironmentType.alpineForest) {
      // Radiant Daylight Sun
      final sunCenter = Offset(screenSize.width * 0.80 + (panX * 0.15), horizonY * 0.30);
      final sunGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF9C4).withValues(alpha: 0.9),
            const Color(0xFFFFD54F).withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: 45));
      canvas.drawCircle(sunCenter, 45, sunGlow);
      canvas.drawCircle(sunCenter, 18, Paint()..color = const Color(0xFFFFFFFD));

      // Fluffy clouds
      final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
      final cloudOffset = (panX * 0.3) % screenSize.width;
      for (int i = 0; i < 3; i++) {
        final cx = ((i * 380) + cloudOffset) % (screenSize.width + 200) - 100;
        final cy = horizonY * (0.25 + (i * 0.15));
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 140, height: 35), cloudPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx + 25, cy - 10), width: 90, height: 40), cloudPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx - 25, cy - 5), width: 80, height: 32), cloudPaint);
      }
    } else {
      // Night Sky: Twinkling Stars Field
      final starRand = math.Random(42);
      final starPaint = Paint()..color = Colors.white;
      for (int i = 0; i < 60; i++) {
        final sx = (starRand.nextDouble() * screenSize.width + (panX * 0.1)) % screenSize.width;
        final sy = starRand.nextDouble() * (horizonY * 0.85);
        final starRadius = 0.8 + starRand.nextDouble() * 1.6;
        final starAlpha = (0.4 + starRand.nextDouble() * 0.6).clamp(0.0, 1.0);
        
        starPaint.color = Colors.white.withValues(alpha: starAlpha);
        canvas.drawCircle(Offset(sx, sy), starRadius, starPaint);

        // Occasional 4-point sparkle cross
        if (i % 8 == 0) {
          final sparklePaint = Paint()
            ..color = const Color(0xFF80D8FF).withValues(alpha: 0.7)
            ..strokeWidth = 1.0;
          canvas.drawLine(Offset(sx - 4, sy), Offset(sx + 4, sy), sparklePaint);
          canvas.drawLine(Offset(sx, sy - 4), Offset(sx, sy + 4), sparklePaint);
        }
      }

      // 3D Luminous Moon with Multi-Layered Atmosphere & Craters
      final moonCenter = Offset(screenSize.width * 0.75 + (panX * 0.12), horizonY * 0.35);

      // Celestial Outer Halo
      final outerHalo = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE0F7FA).withValues(alpha: 0.35),
            const Color(0xFF80DEEA).withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: moonCenter, radius: 55));
      canvas.drawCircle(moonCenter, 55, outerHalo);

      // Moon Body Gradient
      final moonBody = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            const Color(0xFFFFFFFF),
            const Color(0xFFE0F7FA),
            const Color(0xFFB2EBF2),
          ],
        ).createShader(Rect.fromCircle(center: moonCenter, radius: 24));
      canvas.drawCircle(moonCenter, 24, moonBody);

      // Moon Craters
      final craterPaint = Paint()..color = const Color(0xFF80DEEA).withValues(alpha: 0.35);
      canvas.drawCircle(moonCenter + const Offset(-6, -4), 4.5, craterPaint);
      canvas.drawCircle(moonCenter + const Offset(5, 7), 5.5, craterPaint);
      canvas.drawCircle(moonCenter + const Offset(8, -5), 3.5, craterPaint);
      canvas.drawCircle(moonCenter + const Offset(-4, 9), 3.0, craterPaint);
    }

    // Distant Mountain Silhouette Layer 1 (Far jagged peaks)
    final farMountainPaint = Paint()
      ..color = (track.environment == EnvironmentType.alpineForest)
          ? const Color(0xFF457B9D)
          : const Color(0xFF0C1322);
    final farMountainPath = Path()..moveTo(0, horizonY);
    for (double x = -100; x < screenSize.width + 100; x += 50) {
      final h = 35.0 + math.sin((x + panX * 0.25) * 0.025).abs() * 70.0;
      farMountainPath.lineTo(x + panX * 0.25, horizonY - h);
    }
    farMountainPath.lineTo(screenSize.width, horizonY);
    farMountainPath.close();
    canvas.drawPath(farMountainPath, farMountainPaint);

    // Distant Mountain Silhouette Layer 2 (Near rolling mountain slopes with cyber grid highlights)
    final nearMountainPaint = Paint()
      ..color = (track.environment == EnvironmentType.alpineForest)
          ? const Color(0xFF1D5A3A)
          : const Color(0xFF161F30);
    final nearMountainPath = Path()..moveTo(0, horizonY);
    for (double x = -100; x < screenSize.width + 100; x += 60) {
      final h = 20.0 + math.sin((x + panX * 0.45) * 0.035).abs() * 50.0;
      nearMountainPath.lineTo(x + panX * 0.45, horizonY - h);
    }
    nearMountainPath.lineTo(screenSize.width, horizonY);
    nearMountainPath.close();
    canvas.drawPath(nearMountainPath, nearMountainPaint);

    // Ground Plane Base Under Horizon (Clean terrain base before road polygons)
    Color groundBaseColor;
    switch (track.environment) {
      case EnvironmentType.alpineForest:
        groundBaseColor = const Color(0xFF388E3C);
        break;
      case EnvironmentType.neonCity:
        groundBaseColor = const Color(0xFF111827);
        break;
      case EnvironmentType.coastalSunset:
        groundBaseColor = const Color(0xFF8D462E);
        break;
      case EnvironmentType.desertCanyon:
        groundBaseColor = const Color(0xFF6D4C41);
        break;
    }
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, screenSize.width, screenSize.height - horizonY),
      Paint()..color = groundBaseColor,
    );
  }

  Map<String, dynamic>? _projectTrackObject(
    double objTrackZ,
    double objTrackX,
    Size screenSize,
  ) {
    if (roadManager.segments.isEmpty || roadManager.trackLength <= 0) return null;

    double relZ = objTrackZ - playerCar.trackZ;
    while (relZ < -roadManager.trackLength / 2) {
      relZ += roadManager.trackLength;
    }
    while (relZ > roadManager.trackLength / 2) {
      relZ -= roadManager.trackLength;
    }

    final maxDrawDist = (roadManager.drawDistance - 2) * roadManager.segmentLength;
    if (relZ < -150.0 || relZ > maxDrawDist) {
      return null;
    }

    final startSeg = roadManager.findSegment(playerCar.trackZ);
    final startIdx = startSeg.index;

    final segFloat = relZ / roadManager.segmentLength;
    final n = segFloat.floor();
    final percent = (segFloat - n).clamp(0.0, 1.0);

    final segIdx1 = ((startIdx + n) % roadManager.segments.length + roadManager.segments.length) % roadManager.segments.length;
    final segIdx2 = (segIdx1 + 1) % roadManager.segments.length;

    final s1 = roadManager.segments[segIdx1];
    final s2 = roadManager.segments[segIdx2];

    final screenCenterX = s1.p1.screenX + (s2.p1.screenX - s1.p1.screenX) * percent;
    final screenY = s1.p1.screenY + (s2.p1.screenY - s1.p1.screenY) * percent;
    final screenW = s1.p1.screenW + (s2.p1.screenW - s1.p1.screenW) * percent;
    final scale = s1.p1.scale + (s2.p1.scale - s1.p1.scale) * percent;

    if (scale <= 0.00002) return null;

    final horizonY = screenSize.height * 0.40;
    if (screenY < (horizonY - 80) || screenY > (screenSize.height + 250)) {
      return null;
    }

    final screenX = screenCenterX + (objTrackX * screenW);

    return {
      'relZ': relZ,
      'screenX': screenX,
      'screenY': screenY,
      'scale': scale,
      'screenW': screenW,
    };
  }

  void _renderOtherVehiclesAndPickups(Canvas canvas, Size screenSize) {
    final renderQueue = <Map<String, dynamic>>[];

    // 1. Opponents
    for (final opp in opponents) {
      final proj = _projectTrackObject(opp.trackZ, opp.trackX, screenSize);
      if (proj != null) {
        final relZ = proj['relZ'] as double;
        final screenX = proj['screenX'] as double;
        final screenY = proj['screenY'] as double;
        final scale = proj['scale'] as double;
        final carScale = (scale * 1730.0).clamp(0.03, 1.8);

        renderQueue.add({
          'dist': relZ,
          'render': () => opp.render3D(
                canvas,
                screenX: screenX,
                screenY: screenY,
                scale: carScale,
                rollAngle: opp.steeringAngle,
              ),
        });
      }
    }

    // 2. Traffic Cars
    for (final t in trafficList) {
      final proj = _projectTrackObject(t.trackZ, t.trackX, screenSize);
      if (proj != null) {
        final relZ = proj['relZ'] as double;
        final screenX = proj['screenX'] as double;
        final screenY = proj['screenY'] as double;
        final scale = proj['scale'] as double;
        final carScale = (scale * 1600.0).clamp(0.03, 1.8);

        renderQueue.add({
          'dist': relZ,
          'render': () => t.render3D(
                canvas,
                screenX: screenX,
                screenY: screenY,
                scale: carScale,
                rollAngle: t.steeringAngle,
              ),
        });
      }
    }

    // 3. Pickups
    for (final p in pickups) {
      final proj = _projectTrackObject(p.trackZ, p.trackX, screenSize);
      if (proj != null) {
        final relZ = proj['relZ'] as double;
        final screenX = proj['screenX'] as double;
        final screenY = proj['screenY'] as double;
        final scale = proj['scale'] as double;
        final pickupScale = (scale * 2000.0).clamp(0.05, 2.0);

        renderQueue.add({
          'dist': relZ,
          'render': () => p.render3D(
                canvas,
                screenX: screenX,
                screenY: screenY,
                scale: pickupScale,
              ),
        });
      }
    }

    // Sort Far to Near (descending by relative distance)
    renderQueue.sort((a, b) => (b['dist'] as double).compareTo(a['dist'] as double));

    for (final item in renderQueue) {
      (item['render'] as VoidCallback).call();
    }
  }

  void _renderPlayerCar(Canvas canvas, Size screenSize) {
    final playerScreenX = (screenSize.width / 2) + (playerCar.trackX * (screenSize.width * 0.16));
    final playerScreenY = screenSize.height * 0.82;
    const playerScale = 1.30;

    playerCar.render3D(
      canvas,
      screenX: playerScreenX,
      screenY: playerScreenY,
      scale: playerScale,
      rollAngle: playerCar.steeringAngle,
    );
  }

  void _renderAtmosphericOverlay(Canvas canvas, Size screenSize) {
    if (track.timeOfDay == TimeOfDayType.night) {
      // Dark cyber-blue night vignette
      final nightPaint = Paint()
        ..color = const Color(0xFF040612).withValues(alpha: 0.45);
      canvas.drawRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height), nightPaint);

      // Player Headlights Beam on road
      final playerScreenX = (screenSize.width / 2) + (playerCar.trackX * (screenSize.width * 0.16));
      final playerScreenY = screenSize.height * 0.82;

      final headlightPath = Path()
        ..moveTo(playerScreenX - 45, playerScreenY - 20)
        ..lineTo(playerScreenX + 45, playerScreenY - 20)
        ..lineTo(playerScreenX + 160, playerScreenY - 260)
        ..lineTo(playerScreenX - 160, playerScreenY - 260)
        ..close();

      final headlightPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFFDE7).withValues(alpha: 0.35),
            Colors.transparent,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(Rect.fromLTWH(playerScreenX - 160, playerScreenY - 260, 320, 260));

      canvas.drawPath(headlightPath, headlightPaint);
    } else if (track.timeOfDay == TimeOfDayType.sunset) {
      final sunsetPaint = Paint()
        ..color = const Color(0xFFFF6F00).withValues(alpha: 0.14);
      canvas.drawRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height), sunsetPaint);
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.escape)) {
      onPauseRequest?.call();
      return KeyEventResult.handled;
    }

    playerCar.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }
}
