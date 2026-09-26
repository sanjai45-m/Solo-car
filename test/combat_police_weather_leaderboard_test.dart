import 'package:apex_velocity/game/components/player_car.dart';
import 'package:apex_velocity/game/components/police_car.dart';
import 'package:apex_velocity/game/components/road_manager.dart';
import 'package:apex_velocity/game/systems/combat_system.dart';
import 'package:apex_velocity/game/systems/police_pursuit_system.dart';
import 'package:apex_velocity/game/systems/weather_system.dart';
import 'package:apex_velocity/models/car_model.dart';
import 'package:apex_velocity/models/power_up_model.dart';
import 'package:apex_velocity/models/race_model.dart';
import 'package:apex_velocity/screens/leaderboard_screen.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (call) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async => 1,
    );
  });

  group('Cyberpunk Combat & Power-Up System Tests', () {
    late RoadManager roadManager;
    late PlayerCar playerCar;
    late CombatSystem combatSystem;

    setUp(() {
      final track = RaceTrack.defaultTracks.first;
      roadManager = RoadManager(track: track);
      roadManager.preloadMap();
      final car = CarModel.stockCars.first;
      playerCar = PlayerCar(
        position: Vector2.zero(),
        carModel: car,
        roadManager: roadManager,
      );
      combatSystem = CombatSystem();
    });

    test('1. Combat System power-up types, icons and descriptions', () {
      expect(PowerUpType.values.length, 4);
      expect(PowerUpType.empShockwave.displayName, 'EMP SHOCKWAVE');
      expect(PowerUpType.energyShield.displayName, 'ENERGY SHIELD');
      expect(PowerUpType.turboWarp.displayName, 'TURBO WARP');
      expect(PowerUpType.laserMine.displayName, 'LASER MINE');
    });

    test('2. Power-up collection and activation lifecycle', () {
      final gameComponent = Component();

      // Spawn crate ahead of player
      combatSystem.spawnPickupAhead(playerCar.trackZ + 30.0, playerCar.trackX, gameComponent);
      expect(combatSystem.pickups.length, 1);

      // Simulate player driving through pickup
      combatSystem.update(0.1, playerCar, [], [], []);
      expect(combatSystem.currentPowerUp, isNotNull);

      final collectedType = combatSystem.currentPowerUp!;

      // Activate power-up
      final activated = combatSystem.activatePowerUp(playerCar, [], [], gameComponent);
      expect(activated, isTrue);
      expect(combatSystem.currentPowerUp, isNull);

      if (collectedType == PowerUpType.energyShield) {
        expect(combatSystem.hasShield, isTrue);
      } else if (collectedType == PowerUpType.turboWarp) {
        expect(combatSystem.isTurboWarpActive, isTrue);
      } else if (collectedType == PowerUpType.laserMine) {
        expect(combatSystem.activeMines.length, 1);
      }
    });
  });

  group('Police Pursuit Mode & Heat System Tests', () {
    late RoadManager roadManager;
    late PlayerCar playerCar;
    late PolicePursuitSystem policeSystem;

    setUp(() {
      final track = RaceTrack.defaultTracks.first;
      roadManager = RoadManager(track: track);
      roadManager.preloadMap();
      final car = CarModel.stockCars.first;
      playerCar = PlayerCar(
        position: Vector2.zero(),
        carModel: car,
        roadManager: roadManager,
      );
      policeSystem = PolicePursuitSystem(
        playerCar: playerCar,
        roadManager: roadManager,
      );
    });

    test('1. Heat level accumulation from high speed and nitro', () {
      expect(policeSystem.heatLevel, 1);

      playerCar.speedKmH = 260.0;
      playerCar.isNitroActive = true;

      // Simulate 10 seconds of high-speed nitro driving
      for (int i = 0; i < 50; i++) {
        policeSystem.update(0.2);
      }

      expect(policeSystem.heatScore, greaterThan(1.0));
      expect(policeSystem.heatLevel, inInclusiveRange(1, 5));
    });

    test('2. Police Interceptor specifications scale with Heat Tier', () {
      final copTier1 = PoliceCar(
        position: Vector2.zero(),
        heatTier: 1,
        roadManager: roadManager,
        playerCar: playerCar,
      );
      final copTier5 = PoliceCar(
        position: Vector2.zero(),
        heatTier: 5,
        roadManager: roadManager,
        playerCar: playerCar,
      );

      expect(copTier5.maxSpeed, greaterThan(copTier1.maxSpeed));
      expect(copTier5.hitPoints, greaterThan(copTier1.hitPoints));
    });
  });

  group('Dynamic Weather & Night Environment Engine Tests', () {
    test('1. Weather system provides accurate tire traction physics', () {
      final clearWeather = WeatherSystem(currentWeather: WeatherType.clearNight);
      final rainWeather = WeatherSystem(currentWeather: WeatherType.rain);
      final stormWeather = WeatherSystem(currentWeather: WeatherType.thunderstorm);

      expect(clearWeather.tractionMultiplier, 1.0);
      expect(rainWeather.tractionMultiplier, lessThan(1.0));
      expect(stormWeather.tractionMultiplier, lessThan(rainWeather.tractionMultiplier));
    });
  });

  group('Global Live Leaderboard Widget Tests', () {
    testWidgets('1. LeaderboardScreen renders podium tabs and UI correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LeaderboardScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('GLOBAL LEADERBOARD'), findsOneWidget);
      expect(find.text('RANKED ELO'), findsOneWidget);
      expect(find.text('TOTAL WINS'), findsOneWidget);
      expect(find.text('TROPHIES'), findsOneWidget);
    });
  });
}
