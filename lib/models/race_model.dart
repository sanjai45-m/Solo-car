import 'package:flutter/material.dart';

enum EnvironmentType { neonCity, coastalSunset, desertCanyon, alpineForest }

enum TimeOfDayType { day, sunset, night }

enum RaceMode { circuit, sprint, timeAttack, trafficChallenge }

enum RaceDifficulty { easy, normal, hard, expert }

class RaceTrack {
  final String id;
  final String name;
  final String location;
  final String description;
  final EnvironmentType environment;
  final TimeOfDayType timeOfDay;
  final RaceMode mode;
  final RaceDifficulty difficulty;
  final int laps;
  final double trackDistanceMeters;
  final int cashReward;
  final int unlockLevel;
  final List<Color> ambientColors;
  final double baseCurveIntensity;
  final int opponentCount;
  final int trafficDensity; // 1 (light) to 5 (heavy)

  const RaceTrack({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.environment,
    required this.timeOfDay,
    required this.mode,
    required this.difficulty,
    this.laps = 2,
    required this.trackDistanceMeters,
    required this.cashReward,
    required this.unlockLevel,
    required this.ambientColors,
    this.baseCurveIntensity = 1.0,
    this.opponentCount = 5,
    this.trafficDensity = 2,
  });

  // Track Career Roster
  static List<RaceTrack> get defaultTracks => [
        const RaceTrack(
          id: 'track_city_night',
          name: 'Cyber Downtown',
          location: 'Neo Tokyo District',
          description:
              'High-speed neon-lit boulevards lined with towering skyscrapers and flashing billboards.',
          environment: EnvironmentType.neonCity,
          timeOfDay: TimeOfDayType.night,
          mode: RaceMode.circuit,
          difficulty: RaceDifficulty.easy,
          laps: 2,
          trackDistanceMeters: 3200,
          cashReward: 3500,
          unlockLevel: 1,
          baseCurveIntensity: 0.8,
          opponentCount: 5,
          trafficDensity: 2,
          ambientColors: [Color(0xFF0D0221), Color(0xFF190E4F), Color(0xFF00E5FF)],
        ),
        const RaceTrack(
          id: 'track_coastal_sunset',
          name: 'Pacific Coast Highway',
          location: 'Sunset Bay Marina',
          description:
              'Scenic golden hour sprint across ocean bridges and sweeping coastal curves.',
          environment: EnvironmentType.coastalSunset,
          timeOfDay: TimeOfDayType.sunset,
          mode: RaceMode.sprint,
          difficulty: RaceDifficulty.normal,
          laps: 1,
          trackDistanceMeters: 4500,
          cashReward: 6000,
          unlockLevel: 2,
          baseCurveIntensity: 1.2,
          opponentCount: 6,
          trafficDensity: 3,
          ambientColors: [Color(0xFFFF6F00), Color(0xFFFF8F00), Color(0xFF263238)],
        ),
        const RaceTrack(
          id: 'track_desert_rush',
          name: 'Red Rock Canyon',
          location: 'Mojave Outpost',
          description:
              'Brutal straightaways and sharp cliffside turns through baking desert heat.',
          environment: EnvironmentType.desertCanyon,
          timeOfDay: TimeOfDayType.day,
          mode: RaceMode.timeAttack,
          difficulty: RaceDifficulty.hard,
          laps: 1,
          trackDistanceMeters: 5200,
          cashReward: 9500,
          unlockLevel: 3,
          baseCurveIntensity: 1.5,
          opponentCount: 7,
          trafficDensity: 3,
          ambientColors: [Color(0xFFE65100), Color(0xFFFFB300), Color(0xFF5D4037)],
        ),
        const RaceTrack(
          id: 'track_alpine_drift',
          name: 'Blackwood Forest Pass',
          location: 'Northern Highlands',
          description:
              'Technical mountain hairpins flanked by mist-shrouded pines and tight barriers.',
          environment: EnvironmentType.alpineForest,
          timeOfDay: TimeOfDayType.day,
          mode: RaceMode.trafficChallenge,
          difficulty: RaceDifficulty.expert,
          laps: 3,
          trackDistanceMeters: 6000,
          cashReward: 15000,
          unlockLevel: 4,
          baseCurveIntensity: 1.8,
          opponentCount: 7,
          trafficDensity: 4,
          ambientColors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF212121)],
        ),
      ];
}
