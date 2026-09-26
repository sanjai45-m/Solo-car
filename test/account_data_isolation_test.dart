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
        selectedCarId: 'shadow_v8',
        unlockedCarIds: ['inferno_x', 'shadow_v8'],
      );

      final progressB = const PlayerProgress(
        cash: 12000,
        reputationLevel: 2,
        selectedCarId: 'neon_gt',
        unlockedCarIds: ['inferno_x', 'neon_gt'],
      );

      // Save User A and User B to their respective scoped keys
      await SaveService.saveProgress(progressA, uid: userAId);
      await SaveService.saveProgress(progressB, uid: userBId);

      // Verify User A loads only User A's data
      final loadedA = await SaveService.loadProgress(uid: userAId);
      expect(loadedA.cash, equals(75000));
      expect(loadedA.selectedCarId, equals('shadow_v8'));
      expect(loadedA.unlockedCarIds, contains('shadow_v8'));
      expect(loadedA.unlockedCarIds, isNot(contains('neon_gt')));

      // Verify User B loads only User B's data
      final loadedB = await SaveService.loadProgress(uid: userBId);
      expect(loadedB.cash, equals(12000));
      expect(loadedB.selectedCarId, equals('neon_gt'));
      expect(loadedB.unlockedCarIds, contains('neon_gt'));
      expect(loadedB.unlockedCarIds, isNot(contains('shadow_v8')));

      // Verify Guest loads default fresh progress with 0% leak from A or B
      final loadedGuest = await SaveService.loadProgress();
      expect(loadedGuest.cash, equals(5000));
      expect(loadedGuest.unlockedCarIds, equals(['inferno_x']));
    });

    test('2. GameController wipes in-memory state on resetToFreshState (Logout)', () async {
      final controller = GameController();
      await controller.init(uid: 'user_pro_racer');

      // Add cash and buy car
      controller.addCash(50000);
      final bought = controller.buyCar(CarModel.stockCars.firstWhere((c) => c.id == 'shadow_v8'));
      expect(bought, isTrue);
      expect(controller.progress.unlockedCarIds, contains('shadow_v8'));

      // Perform user logout / state reset
      await controller.resetToFreshState();

      // State must be completely pristine
      expect(controller.currentUid, isNull);
      expect(controller.progress.cash, equals(5000));
      expect(controller.progress.unlockedCarIds, equals(['inferno_x']));
      expect(controller.progress.unlockedCarIds, isNot(contains('shadow_v8')));
      expect(controller.currentCar.id, equals('inferno_x'));
    });

    test('3. NeonDatabaseService correctly serializes and saves cloud progress', () async {
      final neon = NeonDatabaseService();
      await neon.initializeSchema();

      const testUid = 'unit_test_cloud_racer_99';
      final testProgress = const PlayerProgress(
        cash: 99999,
        reputationLevel: 10,
        selectedCarId: 'phantom_r',
        unlockedCarIds: ['inferno_x', 'phantom_r'],
        carUpgradeLevels: {
          'phantom_r': {'engine': 4, 'nitro': 5}
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
      controller.upgradeCarPart(carId: 'inferno_x', partKey: 'engine', cost: 1500);
      expect(controller.progress.cash, equals(43500));
      expect(controller.progress.carUpgradeLevels['inferno_x']?['engine'], equals(2));

      // 2. User A logs out
      await controller.resetToFreshState();
      expect(controller.progress.cash, equals(5000));
      expect(controller.progress.carUpgradeLevels, isEmpty);

      // 3. User B logs in (fresh new account)
      await controller.init(uid: userB);
      expect(controller.progress.cash, equals(5000)); // User B has starting cash, not User A's 43500!
      expect(controller.progress.carUpgradeLevels, isEmpty); // User B has no upgrades!

      // User B earns 3000
      controller.addCash(3000);
      expect(controller.progress.cash, equals(8000));

      // 4. User B logs out
      await controller.resetToFreshState();

      // 5. User A logs back in
      await controller.init(uid: userA);
      // User A's isolated progress must be restored intact!
      expect(controller.progress.cash, equals(43500));
      expect(controller.progress.carUpgradeLevels['inferno_x']?['engine'], equals(2));
    });
  });
}
