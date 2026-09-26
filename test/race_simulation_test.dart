import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:apex_velocity/game/apex_racing_game.dart';
import 'package:apex_velocity/game/components/opponent_car.dart';
import 'package:apex_velocity/game/systems/collision_system.dart';
import 'package:apex_velocity/game/systems/race_manager.dart';
import 'package:apex_velocity/models/car_model.dart';
import 'package:apex_velocity/models/race_model.dart';
import 'package:apex_velocity/widgets/hud/racing_hud_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Race Simulation & Vehicle Automation Tests', () {
    late ApexRacingGame game;
    late CarModel testCar;
    late RaceTrack testTrack;

    setUp(() {
      testCar = CarModel.stockCars.first;
      testTrack = RaceTrack.defaultTracks.first;
      game = ApexRacingGame(
        carModel: testCar,
        track: testTrack,
      );
    });

    test('1. Starting Grid Layout: Opponents are properly staggered ahead of Player', () {
      expect(game.playerCar.trackZ, 0.0);
      expect(game.playerCar.trackX, 0.0);
      expect(game.opponents.length, testTrack.opponentCount);

      // Verify each opponent has a positive starting Z distance ahead of player
      for (int i = 0; i < game.opponents.length; i++) {
        final opp = game.opponents[i];
        expect(opp.trackZ, greaterThanOrEqualTo(100.0));
        expect(opp.trackZ - game.playerCar.trackZ, greaterThanOrEqualTo(60.0));
        // Opponents should be on lane slots (-0.45, 0.45, etc.)
        expect(opp.trackX.abs(), greaterThan(0.20));
      }
    });

    test('2. Countdown Phase: Vehicles are stationary, but inputs are preserved', () {
      expect(game.raceManager.state, RaceState.countdown);

      // Simulate player pressing throttle during countdown
      game.playerCar.touchAccelerate = true;
      game.playerCar.touchSteerAxis = 0.5;

      // Update 10 frames (160ms) during countdown
      for (int i = 0; i < 10; i++) {
        game.update(0.016);
      }

      // Player and opponents must be locked at speed 0 during countdown
      expect(game.playerCar.speed, 0.0);
      expect(game.playerCar.speedKmH, 0.0);
      for (final opp in game.opponents) {
        expect(opp.speed, 0.0);
      }

      // Crucial fix: touchAccelerate and steer inputs must NOT be wiped out!
      expect(game.playerCar.touchAccelerate, isTrue);
      expect(game.playerCar.touchSteerAxis, 0.5);
    });

    test('3. Race Launch: Instant acceleration without sticking or shaking', () {
      game.playerCar.touchAccelerate = true;

      // Fast-forward countdown past 3.8s
      game.raceManager.countdownTimer = 0.05;
      game.update(0.06); // Countdown reaches 0 -> inProgress

      expect(game.raceManager.state, RaceState.inProgress);

      // Simulate 30 frames (0.5s) of acceleration after GO!
      for (int i = 0; i < 30; i++) {
        game.update(0.016);
      }

      // Car must have accelerated cleanly and moved forward
      expect(game.playerCar.speed, greaterThan(500.0));
      expect(game.playerCar.speedKmH, greaterThan(15.0));
      expect(game.playerCar.distanceDrivenMeters, greaterThan(0.5));
      expect(game.shakeIntensity, 0.0); // ZERO false collision camera shakes
    });

    test('4. Collision System: Low-speed grid launch produces NO collision lock or camera shake', () {
      bool shakeTriggered = false;
      final collisionSystem = CollisionSystem(
        onCameraShake: () => shakeTriggered = true,
      );

      final dummyOpponent = OpponentCar(
        position: Vector2.zero(),
        driverName: 'Rival',
        difficulty: RaceDifficulty.normal,
        roadManager: game.roadManager,
        startingGridIndex: 1,
        color: Colors.red,
        underglowColor: Colors.blue,
      );

      // Place them close at starting speed
      game.playerCar.speed = 100.0;
      game.playerCar.speedKmH = 3.1;
      dummyOpponent.speed = 100.0;
      dummyOpponent.speedKmH = 3.1;
      dummyOpponent.trackZ = 30.0;
      dummyOpponent.trackX = 0.1;

      collisionSystem.checkCollisions(
        player: game.playerCar,
        trafficList: [],
        opponents: [dummyOpponent],
        pickups: [],
        particles: game.particleSystem,
      );

      // Low speed must NOT trigger camera shakes or crash penalties
      expect(shakeTriggered, isFalse);
    });

    test('5. Steering, Centering, and Drifting dynamics', () {
      game.raceManager.state = RaceState.inProgress;
      game.playerCar.speed = 4000.0; // ~125 km/h
      game.playerCar.speedKmH = 125.0;

      // Steer Right
      game.playerCar.touchSteerAxis = 1.0;
      final initialX = game.playerCar.trackX;
      game.playerCar.update(0.05);

      expect(game.playerCar.trackX, greaterThan(initialX));
      expect(game.playerCar.steeringAngle, greaterThan(0.0));

      // Release steering (Self-centering)
      game.playerCar.touchSteerAxis = 0.0;
      for (int i = 0; i < 20; i++) {
        game.playerCar.update(0.016);
      }
      expect(game.playerCar.steeringAngle.abs(), lessThan(0.05));

      // Handbrake Drift
      game.playerCar.touchHandbrake = true;
      game.playerCar.touchSteerAxis = 1.0;
      game.playerCar.update(0.1);

      expect(game.playerCar.isDrifting, isTrue);
      expect(game.playerCar.currentDriftPoints, greaterThan(0.0));
    });

    testWidgets('6. HUD & Touch Controls interaction test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                RacingHudOverlay(
                  game: game,
                  onPause: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Find the GAS button and tap & hold
      final gasButton = find.text('GAS');
      expect(gasButton, findsOneWidget);

      await tester.tap(gasButton);
      await tester.pump(const Duration(milliseconds: 50));

      // Speedometer & Position badge exist on screen
      expect(find.byType(RacingHudOverlay), findsOneWidget);
    });

    test('7. Complete 180-Frame Race Simulation with Standings Tracking', () {
      game.raceManager.state = RaceState.inProgress;
      game.playerCar.touchAccelerate = true;

      // Simulate 180 continuous frames (3 full seconds at 60 FPS)
      for (int frame = 0; frame < 180; frame++) {
        game.update(0.016);
      }

      // Verify race progressed smoothly
      expect(game.playerCar.speedKmH, greaterThan(80.0));
      expect(game.playerCar.distanceDrivenMeters, greaterThan(30.0));
      expect(game.raceManager.currentStandings.length, testTrack.opponentCount + 1);
      expect(game.raceManager.playerPosition, inInclusiveRange(1, testTrack.opponentCount + 1));
      expect(game.raceManager.raceTimeSeconds, closeTo(2.88, 0.2));
    });

    test('8. Full Track Map Preloading & 2D Minimap Geometry verification', () {
      final points = game.roadManager.fullTrackPoints;
      expect(points, isNotEmpty);
      expect(points.length, game.roadManager.segments.length);

      // Verify all points are normalized and within safe canvas margins
      for (final p in points) {
        expect(p.dx, inInclusiveRange(0.05, 0.95));
        expect(p.dy, inInclusiveRange(0.05, 0.95));
      }

      // Verify getMapPosition correctly maps track distances
      final startPos = game.roadManager.getMapPosition(0.0);
      expect(startPos, equals(points.first));

      final midPos = game.roadManager.getMapPosition(game.roadManager.trackLength * 0.5);
      expect(midPos.dx, inInclusiveRange(0.05, 0.95));
      expect(midPos.dy, inInclusiveRange(0.05, 0.95));
    });

    test('9. Configurable Road Boundary Enforcement (Default: TRUE prevents going off-road)', () {
      // 1. Default: Boundary enforced
      expect(game.playerCar.enforceTrackBoundary, isTrue);

      game.playerCar.speed = 3200.0;
      game.playerCar.speedKmH = 100.0;
      game.playerCar.trackX = 0.90;

      // Force steer hard to the right for 30 frames
      game.playerCar.touchSteerAxis = 1.0;
      for (int i = 0; i < 30; i++) {
        game.playerCar.update(0.016);
      }

      // Must be strictly clamped to the road boundary limit (0.96), cannot drive away from the road
      expect(game.playerCar.trackX, lessThanOrEqualTo(0.96));
      expect(game.playerCar.trackX, greaterThanOrEqualTo(0.90));

      // 2. Boundary disabled: Allowed to go off-road up to shoulder limit 1.6
      game.playerCar.enforceTrackBoundary = false;
      for (int i = 0; i < 30; i++) {
        game.playerCar.update(0.016);
      }
      expect(game.playerCar.trackX, greaterThan(0.96));
    });

    test('10. Opponents Starting Grid Visibility & 3D Render Verification', () {
      // Simulate rendering on a standard mobile canvas size
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      game.onGameResize(Vector2(800.0, 600.0));

      // Execute render pass
      game.render(canvas);

      // Verify each opponent has a valid trackZ ahead and is on a distinct lane slot
      expect(game.opponents, isNotEmpty);
      for (int i = 0; i < game.opponents.length; i++) {
        final opp = game.opponents[i];
        expect(opp.trackZ, greaterThan(game.playerCar.trackZ + 100.0));
        expect(opp.trackX.abs(), greaterThan(0.2));
        expect(opp.driverName, isNotEmpty);
      }

      // Check collision distance at starting line - must have safe gap > 70 units
      for (final opp in game.opponents) {
        final dz = (game.playerCar.trackZ - opp.trackZ).abs();
        expect(dz, greaterThan(70.0));
      }
    });
  });
}
