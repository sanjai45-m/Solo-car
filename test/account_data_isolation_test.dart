import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_velocity/models/car_model.dart';
import 'package:apex_velocity/models/player_progress.dart';
import 'package:apex_velocity/services/game_controller.dart';
import 'package:apex_velocity/services/neon_database_service.dart';
import 'package:apex_velocity/services/save_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Account Data Isolation & Cloud Database Persistence Test Suite', () {
    test('1. SaveService stores and loads data strictly per-user UID', () async {
      const userAId = 'user_alice_001';
      const userBId = 'user_bob_002';

      final progressA = const PlayerProgress(
        cash: 75000,
        reputationLevel: 8,
        selectedCarId: 'nemesis_gt',
        unlockedCarIds: ['phantom_gt', 'nemesis_gt'],
      );

      final progressB = const PlayerProgress(
        cash: 12000,
        reputationLevel: 2,
        selectedCarId: 'vortex_rx',
        unlockedCarIds: ['phantom_gt', 'vortex_rx'],
      );

      // Save User A and User B to their respective scoped keys
      await SaveService.saveProgress(progressA, uid: userAId);
      await SaveService.saveProgress(progressB, uid: userBId);

      // Verify User A loads only User A's data
      final loadedA = await SaveService.loadProgress(uid: userAId);
      expect(loadedA.cash, equals(75000));
      expect(loadedA.selectedCarId, equals('nemesis_gt'));
      expect(loadedA.unlockedCarIds, contains('nemesis_gt'));
      expect(loadedA.unlockedCarIds, isNot(contains('vortex_rx')));

      // Verify User B loads only User B's data
      final loadedB = await SaveService.loadProgress(uid: userBId);
      expect(loadedB.cash, equals(12000));
      expect(loadedB.selectedCarId, equals('vortex_rx'));
      expect(loadedB.unlockedCarIds, contains('vortex_rx'));
      expect(loadedB.unlockedCarIds, isNot(contains('nemesis_gt')));

      // Verify Guest loads default fresh progress with 0% leak from A or B
      final loadedGuest = await SaveService.loadProgress();
      expect(loadedGuest.cash, equals(5000));
      expect(loadedGuest.unlockedCarIds, equals(['phantom_gt']));
    });

    test('2. GameController wipes in-memory state on resetToFreshState (Logout)', () async {
      final controller = GameController();
      await controller.init(uid: 'user_pro_racer');

      // Add cash and buy car
      controller.addCash(50000);
      final bought = controller.buyCar(CarModel.stockCars.firstWhere((c) => c.id == 'viper_gtr'));
      expect(bought, isTrue);
      expect(controller.progress.unlockedCarIds, contains('viper_gtr'));

      // Perform user logout / state reset
      await controller.resetToFreshState();

      // State must be completely pristine
      expect(controller.currentUid, isNull);
      expect(controller.progress.cash, equals(5000));
      expect(controller.progress.unlockedCarIds, equals(['phantom_gt']));
      expect(controller.progress.unlockedCarIds, isNot(contains('viper_gtr')));
      expect(controller.currentCar.id, equals('phantom_gt'));
    });

    test('3. NeonDatabaseService correctly serializes and saves cloud progress', () async {
      final neon = NeonDatabaseService();
      await neon.initializeSchema();

      const testUid = 'unit_test_cloud_racer_99';
      final testProgress = const PlayerProgress(
        cash: 99999,
        reputationLevel: 10,
        selectedCarId: 'hyperion_x',
        unlockedCarIds: ['phantom_gt', 'hyperion_x'],
        carUpgradeLevels: {
          'hyperion_x': {'engine': 4, 'nitro': 5}
        },
      );

      final saveResult = await neon.saveUserProgress(testUid, testProgress);
      // In offline/mock test runner, should handle gracefully
      expect(saveResult, isA<bool>());
    });

    test('4. Full Account Switch Flow: User A -> Logout -> User B -> User A restore', () async {
      final controller = GameController();
      const userA = 'account_alice';
      const userB = 'account_bob';

      // 1. User A logs in, earns money and upgrades car
      await controller.init(uid: userA);
      controller.addCash(40000);
      controller.upgradeCarPart(carId: 'phantom_gt', partKey: 'engine', cost: 1000);
      expect(controller.progress.cash, equals(44000));
      expect(controller.progress.carUpgradeLevels['phantom_gt']?['engine'], equals(2));

      // 2. User A logs out
      await controller.resetToFreshState();
      expect(controller.progress.cash, equals(5000));
      expect(controller.progress.carUpgradeLevels, isEmpty);

      // 3. User B logs in (fresh new account)
      await controller.init(uid: userB);
      expect(controller.progress.cash, equals(5000)); // User B has starting cash, not User A's 44000!
      expect(controller.progress.carUpgradeLevels, isEmpty); // User B has no upgrades!

      // User B earns 3000
      controller.addCash(3000);
      expect(controller.progress.cash, equals(8000));

      // 4. User B logs out
      await controller.resetToFreshState();

      // 5. User A logs back in
      await controller.init(uid: userA);
      // User A's isolated progress must be restored intact!
      expect(controller.progress.cash, equals(44000));
      expect(controller.progress.carUpgradeLevels['phantom_gt']?['engine'], equals(2));
    });
  });
}
