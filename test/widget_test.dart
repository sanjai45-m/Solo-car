import 'package:flutter_test/flutter_test.dart';
import 'package:apex_velocity/models/car_model.dart';
import 'package:apex_velocity/models/player_progress.dart';

void main() {
  test('CarModel upgrade calculation test', () {
    final car = CarModel.stockCars.first;
    expect(car.topSpeedKmH, 340.0);

    final upgradedCar = car.copyWith(
      engineUpgrade: car.engineUpgrade.copyWith(level: 2),
    );
    expect(upgradedCar.topSpeedKmH, 355.0);
  });

  test('PlayerProgress JSON serialization test', () {
    const progress = PlayerProgress(
      cash: 12500,
      selectedCarId: 'inferno_x',
    );
    final jsonStr = progress.toJsonString();
    final restored = PlayerProgress.fromJsonString(jsonStr);

    expect(restored.cash, 12500);
    expect(restored.selectedCarId, 'inferno_x');
  });
}
