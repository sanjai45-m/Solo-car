import 'dart:convert';

class PlayerProgress {
  final int cash;
  final int reputationLevel;
  final String selectedCarId;
  final List<String> unlockedCarIds;
  final List<String> unlockedTrackIds;
  final Map<String, int> trackBestTimesMs;
  final Map<String, Map<String, int>> carUpgradeLevels; // carId -> {engine: lvl, handling: lvl, ...}
  final Map<String, int> carColors; // carId -> color value

  const PlayerProgress({
    this.cash = 5000,
    this.reputationLevel = 1,
    this.selectedCarId = 'phantom_gt',
    this.unlockedCarIds = const ['phantom_gt'],
    this.unlockedTrackIds = const ['track_city_night'],
    this.trackBestTimesMs = const {},
    this.carUpgradeLevels = const {},
    this.carColors = const {},
  });

  PlayerProgress copyWith({
    int? cash,
    int? reputationLevel,
    String? selectedCarId,
    List<String>? unlockedCarIds,
    List<String>? unlockedTrackIds,
    Map<String, int>? trackBestTimesMs,
    Map<String, Map<String, int>>? carUpgradeLevels,
    Map<String, int>? carColors,
  }) {
    return PlayerProgress(
      cash: cash ?? this.cash,
      reputationLevel: reputationLevel ?? this.reputationLevel,
      selectedCarId: selectedCarId ?? this.selectedCarId,
      unlockedCarIds: unlockedCarIds ?? this.unlockedCarIds,
      unlockedTrackIds: unlockedTrackIds ?? this.unlockedTrackIds,
      trackBestTimesMs: trackBestTimesMs ?? this.trackBestTimesMs,
      carUpgradeLevels: carUpgradeLevels ?? this.carUpgradeLevels,
      carColors: carColors ?? this.carColors,
    );
  }

  Map<String, dynamic> toJson() => {
        'cash': cash,
        'reputationLevel': reputationLevel,
        'selectedCarId': selectedCarId,
        'unlockedCarIds': unlockedCarIds,
        'unlockedTrackIds': unlockedTrackIds,
        'trackBestTimesMs': trackBestTimesMs,
        'carUpgradeLevels': carUpgradeLevels,
        'carColors': carColors,
      };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      cash: json['cash'] as int? ?? 5000,
      reputationLevel: json['reputationLevel'] as int? ?? 1,
      selectedCarId: json['selectedCarId'] as String? ?? 'phantom_gt',
      unlockedCarIds: (json['unlockedCarIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['phantom_gt'],
      unlockedTrackIds: (json['unlockedTrackIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['track_city_night'],
      trackBestTimesMs: (json['trackBestTimesMs'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      carUpgradeLevels: (json['carUpgradeLevels'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(
                    k,
                    (v as Map<String, dynamic>)
                        .map((uk, uv) => MapEntry(uk, uv as int)),
                  )) ??
          {},
      carColors: (json['carColors'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory PlayerProgress.fromJsonString(String jsonStr) {
    try {
      return PlayerProgress.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return const PlayerProgress();
    }
  }
}
