import 'package:flutter/foundation.dart';
import '../../models/race_model.dart';
import '../components/player_car.dart';
import '../components/opponent_car.dart';

enum RaceState { countdown, inProgress, finished }

class RacerStanding {
  final String name;
  final bool isPlayer;
  final double distanceDriven;
  final double speedKmH;
  final int position;

  const RacerStanding({
    required this.name,
    required this.isPlayer,
    required this.distanceDriven,
    required this.speedKmH,
    required this.position,
  });
}

class RaceManager {
  final RaceTrack track;
  final PlayerCar player;
  final List<OpponentCar> opponents;

  RaceState state = RaceState.countdown;
  double countdownTimer = 3.8; // 3.8s total countdown
  int countdownDisplayNumber = 3;

  double raceTimeSeconds = 0.0;
  int playerPosition = 1;
  int currentLap = 1;
  int totalLaps = 2;
  double trackLengthMeters = 3000;

  List<RacerStanding> currentStandings = [];

  final Function(int count)? onCountdownTick;
  final VoidCallback? onRaceStart;
  final Function(int position, int timeMs, int cashEarned)? onRaceFinish;

  RaceManager({
    required this.track,
    required this.player,
    required this.opponents,
    this.onCountdownTick,
    this.onRaceStart,
    this.onRaceFinish,
  }) {
    totalLaps = track.mode == RaceMode.circuit ? track.laps : 1;
    trackLengthMeters = track.trackDistanceMeters;
  }

  void update(double dt) {
    if (state == RaceState.countdown) {
      countdownTimer -= dt;
      final currentNum = countdownTimer.ceil();

      if (currentNum != countdownDisplayNumber && currentNum >= 0) {
        countdownDisplayNumber = currentNum;
        onCountdownTick?.call(currentNum);
      }

      if (countdownTimer <= 0) {
        state = RaceState.inProgress;
        onRaceStart?.call();
      }
      return;
    }

    if (state == RaceState.inProgress) {
      raceTimeSeconds += dt;
      _updateStandings();
      _checkFinishConditions();
    }
  }

  void _updateStandings() {
    final allRacers = <Map<String, dynamic>>[];

    // Add Player
    allRacers.add({
      'name': 'YOU',
      'isPlayer': true,
      'distance': player.distanceDrivenMeters,
      'speed': player.speedKmH,
    });

    // Add Opponents
    for (final opp in opponents) {
      allRacers.add({
        'name': opp.driverName,
        'isPlayer': false,
        'distance': opp.distanceDrivenMeters,
        'speed': opp.speedKmH,
      });
    }

    // Sort descending by distance driven
    allRacers.sort((a, b) => (b['distance'] as double).compareTo(a['distance'] as double));

    currentStandings = List.generate(allRacers.length, (idx) {
      final r = allRacers[idx];
      final isPlayer = r['isPlayer'] as bool;
      if (isPlayer) {
        playerPosition = idx + 1;
      }
      return RacerStanding(
        name: r['name'] as String,
        isPlayer: isPlayer,
        distanceDriven: r['distance'] as double,
        speedKmH: r['speed'] as double,
        position: idx + 1,
      );
    });

    // Compute current lap
    if (track.mode == RaceMode.circuit) {
      final lap = (player.distanceDrivenMeters / (trackLengthMeters / totalLaps)).floor() + 1;
      currentLap = lap.clamp(1, totalLaps);
    }
  }

  void _checkFinishConditions() {
    final totalRaceDistance = trackLengthMeters;
    if (player.distanceDrivenMeters >= totalRaceDistance) {
      state = RaceState.finished;

      // Calculate Cash reward factoring in placement & drift score
      int earnedCash = 0;
      if (playerPosition == 1) {
        earnedCash = track.cashReward;
      } else if (playerPosition == 2) {
        earnedCash = (track.cashReward * 0.75).toInt();
      } else if (playerPosition == 3) {
        earnedCash = (track.cashReward * 0.50).toInt();
      } else {
        earnedCash = (track.cashReward * 0.25).toInt();
      }

      // Drift bonus cash
      final driftCash = (player.driftScore * 0.1).toInt();
      earnedCash += driftCash;

      final raceTimeMs = (raceTimeSeconds * 1000).toInt();
      onRaceFinish?.call(playerPosition, raceTimeMs, earnedCash);
    }
  }
}
