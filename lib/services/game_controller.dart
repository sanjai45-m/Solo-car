import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../models/player_progress.dart';
import '../models/race_model.dart';
import 'neon_database_service.dart';
import 'save_service.dart';

class GameController extends ChangeNotifier {
  PlayerProgress _progress = const PlayerProgress();
  List<CarModel> _allCars = CarModel.stockCars;
  RaceTrack _selectedTrack = RaceTrack.defaultTracks.first;
  bool _isInitialized = false;
  String? _currentUid;

  PlayerProgress get progress => _progress;
  List<CarModel> get allCars => _allCars;
  RaceTrack get selectedTrack => _selectedTrack;
  bool get isInitialized => _isInitialized;
  String? get currentUid => _currentUid;

  CarModel get currentCar {
    final car = _allCars.firstWhere(
      (c) => c.id == _progress.selectedCarId,
      orElse: () => _allCars.first,
    );
    return car;
  }

  /// Initializes or re-initializes progression strictly for the given user UID
  Future<void> init({String? uid}) async {
    _currentUid = uid;
    
    // 1. If signed in, attempt to load authoritative cloud progression from Neon DB
    PlayerProgress? cloudProgress;
    if (uid != null && uid.isNotEmpty) {
      cloudProgress = await NeonDatabaseService().fetchUserProgress(uid);
    }

    if (cloudProgress != null) {
      _progress = cloudProgress;
      // Cache latest cloud state locally for offline resiliency
      await SaveService.saveProgress(_progress, uid: _currentUid);
    } else {
      // 2. Fallback to local user-scoped storage (or fresh defaults)
      _progress = await SaveService.loadProgress(uid: _currentUid);
      // If newly registering a signed-in user, initialize their cloud record
      if (uid != null && uid.isNotEmpty) {
        await NeonDatabaseService().saveUserProgress(uid, _progress);
      }
    }

    _applyProgressToCars();
    _isInitialized = true;
    notifyListeners();
  }

  /// Switches active user session, cleanly loading ONLY their isolated data
  Future<void> switchUser(String? uid) async {
    _isInitialized = false;
    notifyListeners();
    await init(uid: uid);
  }

  /// Completely purges in-memory player state and resets vehicles to stock on sign-out
  Future<void> resetToFreshState() async {
    _currentUid = null;
    _progress = const PlayerProgress();
    _selectedTrack = RaceTrack.defaultTracks.first;
    _applyProgressToCars();
    await SaveService.clearActiveGuestSession();
    _isInitialized = true;
    notifyListeners();
  }

  void _saveAndSync() {
    SaveService.saveProgress(_progress, uid: _currentUid);
    if (_currentUid != null && _currentUid!.isNotEmpty) {
      NeonDatabaseService().saveUserProgress(_currentUid!, _progress);
    }
  }

  void selectTrack(RaceTrack track) {
    _selectedTrack = track;
    notifyListeners();
  }

  void selectCar(String carId) {
    if (_progress.unlockedCarIds.contains(carId)) {
      _progress = _progress.copyWith(selectedCarId: carId);
      _saveAndSync();
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
      _saveAndSync();
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
    _saveAndSync();
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
    _saveAndSync();
    notifyListeners();
  }

  void addCash(int amount) {
    _progress = _progress.copyWith(cash: _progress.cash + amount);
    _saveAndSync();
    notifyListeners();
  }

  void addReputation(int amount) {
    _progress = _progress.copyWith(reputationLevel: _progress.reputationLevel + amount);
    _saveAndSync();
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

    _saveAndSync();
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
