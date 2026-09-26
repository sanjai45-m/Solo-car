import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../models/player_progress.dart';
import '../models/race_model.dart';
import 'save_service.dart';

class GameController extends ChangeNotifier {
  PlayerProgress _progress = const PlayerProgress();
  List<CarModel> _allCars = CarModel.stockCars;
  RaceTrack _selectedTrack = RaceTrack.defaultTracks.first;
  bool _isInitialized = false;

  PlayerProgress get progress => _progress;
  List<CarModel> get allCars => _allCars;
  RaceTrack get selectedTrack => _selectedTrack;
  bool get isInitialized => _isInitialized;

  CarModel get currentCar {
    final car = _allCars.firstWhere(
      (c) => c.id == _progress.selectedCarId,
      orElse: () => _allCars.first,
    );
    return car;
  }

  Future<void> init() async {
    _progress = await SaveService.loadProgress();
    _applyProgressToCars();
    _isInitialized = true;
    notifyListeners();
  }

  void selectTrack(RaceTrack track) {
    _selectedTrack = track;
    notifyListeners();
  }

  void selectCar(String carId) {
    if (_progress.unlockedCarIds.contains(carId)) {
      _progress = _progress.copyWith(selectedCarId: carId);
      SaveService.saveProgress(_progress);
      notifyListeners();
    }
  }

  bool buyCar(CarModel car) {
    if (_progress.cash >= car.price &&
        !_progress.unlockedCarIds.contains(car.id)) {
      final updatedCash = _progress.cash - car.price;
      final updatedUnlocked = List<String>.from(_progress.unlockedCarIds)
        ..add(car.id);

      _progress = _progress.copyWith(
        cash: updatedCash,
        unlockedCarIds: updatedUnlocked,
        selectedCarId: car.id,
      );

      _applyProgressToCars();
      SaveService.saveProgress(_progress);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool upgradeCarPart({
    required String carId,
    required String partKey, // 'engine', 'handling', 'brakes', 'nitro'
    required int cost,
  }) {
    if (_progress.cash < cost) return false;

    final currentCarUpgrades = Map<String, int>.from(
      _progress.carUpgradeLevels[carId] ?? {},
    );
    final currentLvl = currentCarUpgrades[partKey] ?? 1;
    if (currentLvl >= 5) return false;

    currentCarUpgrades[partKey] = currentLvl + 1;

    final updatedCarUpgrades =
        Map<String, Map<String, int>>.from(_progress.carUpgradeLevels);
    updatedCarUpgrades[carId] = currentCarUpgrades;

    _progress = _progress.copyWith(
      cash: _progress.cash - cost,
      carUpgradeLevels: updatedCarUpgrades,
    );

    _applyProgressToCars();
    SaveService.saveProgress(_progress);
    notifyListeners();
    return true;
  }

  void customizeCarColor({
    required String carId,
    required Color color,
  }) {
    final updatedColors = Map<String, int>.from(_progress.carColors);
    updatedColors[carId] = color.toARGB32();

    _progress = _progress.copyWith(carColors: updatedColors);
    _applyProgressToCars();
    SaveService.saveProgress(_progress);
    notifyListeners();
  }

  void addCash(int amount) {
    _progress = _progress.copyWith(cash: _progress.cash + amount);
    SaveService.saveProgress(_progress);
    notifyListeners();
  }

  void addReputation(int amount) {
    _progress = _progress.copyWith(reputationLevel: _progress.reputationLevel + amount);
    SaveService.saveProgress(_progress);
    notifyListeners();
  }

  void recordRaceResult({
    required RaceTrack track,
    required int finishPosition,
    required int raceTimeMs,
    required int earnedCash,
    required int driftScore,
  }) {
    // Add cash & compute stage unlocks
    int newCash = _progress.cash + earnedCash;
    List<String> updatedUnlockedTracks =
        List<String>.from(_progress.unlockedTrackIds);

    // If placed in top 3, unlock the next track
    if (finishPosition <= 3) {
      final currentTrackIdx =
          RaceTrack.defaultTracks.indexWhere((t) => t.id == track.id);
      if (currentTrackIdx != -1 &&
          currentTrackIdx + 1 < RaceTrack.defaultTracks.length) {
        final nextTrack = RaceTrack.defaultTracks[currentTrackIdx + 1];
        if (!updatedUnlockedTracks.contains(nextTrack.id)) {
          updatedUnlockedTracks.add(nextTrack.id);
        }
      }
    }

    // Record best lap / race time
    final updatedBestTimes =
        Map<String, int>.from(_progress.trackBestTimesMs);
    final prevBest = updatedBestTimes[track.id] ?? 99999999;
    if (raceTimeMs < prevBest) {
      updatedBestTimes[track.id] = raceTimeMs;
    }

    _progress = _progress.copyWith(
      cash: newCash,
      unlockedTrackIds: updatedUnlockedTracks,
      trackBestTimesMs: updatedBestTimes,
      reputationLevel: _progress.reputationLevel + (finishPosition == 1 ? 2 : 1),
    );

    SaveService.saveProgress(_progress);
    notifyListeners();
  }

  void _applyProgressToCars() {
    _allCars = CarModel.stockCars.map((stockCar) {
      final isUnlocked = _progress.unlockedCarIds.contains(stockCar.id);
      final upgrades = _progress.carUpgradeLevels[stockCar.id] ?? {};
      final savedColorValue = _progress.carColors[stockCar.id];

      final engineLvl = upgrades['engine'] ?? 1;
      final handlingLvl = upgrades['handling'] ?? 1;
      final brakeLvl = upgrades['brakes'] ?? 1;
      final nitroLvl = upgrades['nitro'] ?? 1;

      return stockCar.copyWith(
        isUnlocked: isUnlocked,
        engineUpgrade: stockCar.engineUpgrade.copyWith(level: engineLvl),
        handlingUpgrade: stockCar.handlingUpgrade.copyWith(level: handlingLvl),
        brakeUpgrade: stockCar.brakeUpgrade.copyWith(level: brakeLvl),
        nitroUpgrade: stockCar.nitroUpgrade.copyWith(level: nitroLvl),
        bodyColor:
            savedColorValue != null ? Color(savedColorValue) : stockCar.bodyColor,
      );
    }).toList();
  }
}
