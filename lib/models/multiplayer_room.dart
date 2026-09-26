import 'dart:convert';
import 'package:flutter/material.dart';

enum RoomState { waiting, countdown, racing, finished }

class MultiplayerPlayerSlot {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final bool isHost;
  final bool isReady;
  final String carModelId;
  final int carColorValue;
  final int eloRating;
  final double trackZ;
  final double trackX;
  final double speedKmH;
  final double steeringAngle;
  final bool isNitroActive;
  final int position;
  final int finishTimeMs;

  const MultiplayerPlayerSlot({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    this.isHost = false,
    this.isReady = false,
    required this.carModelId,
    required this.carColorValue,
    this.eloRating = 1200,
    this.trackZ = 0.0,
    this.trackX = 0.0,
    this.speedKmH = 0.0,
    this.steeringAngle = 0.0,
    this.isNitroActive = false,
    this.position = 1,
    this.finishTimeMs = 0,
  });

  Color get carColor => Color(carColorValue);

  MultiplayerPlayerSlot copyWith({
    String? uid,
    String? displayName,
    String? photoUrl,
    bool? isHost,
    bool? isReady,
    String? carModelId,
    int? carColorValue,
    int? eloRating,
    double? trackZ,
    double? trackX,
    double? speedKmH,
    double? steeringAngle,
    bool? isNitroActive,
    int? position,
    int? finishTimeMs,
  }) {
    return MultiplayerPlayerSlot(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      carModelId: carModelId ?? this.carModelId,
      carColorValue: carColorValue ?? this.carColorValue,
      eloRating: eloRating ?? this.eloRating,
      trackZ: trackZ ?? this.trackZ,
      trackX: trackX ?? this.trackX,
      speedKmH: speedKmH ?? this.speedKmH,
      steeringAngle: steeringAngle ?? this.steeringAngle,
      isNitroActive: isNitroActive ?? this.isNitroActive,
      position: position ?? this.position,
      finishTimeMs: finishTimeMs ?? this.finishTimeMs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isHost': isHost,
      'isReady': isReady,
      'carModelId': carModelId,
      'carColorValue': carColorValue,
      'eloRating': eloRating,
      'trackZ': trackZ,
      'trackX': trackX,
      'speedKmH': speedKmH,
      'steeringAngle': steeringAngle,
      'isNitroActive': isNitroActive,
      'position': position,
      'finishTimeMs': finishTimeMs,
    };
  }

  factory MultiplayerPlayerSlot.fromMap(Map<String, dynamic> map) {
    return MultiplayerPlayerSlot(
      uid: map['uid'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Racer',
      photoUrl: map['photoUrl'] as String?,
      isHost: map['isHost'] as bool? ?? false,
      isReady: map['isReady'] as bool? ?? false,
      carModelId: map['carModelId'] as String? ?? 'car_01_specter_r',
      carColorValue: (map['carColorValue'] as num?)?.toInt() ?? 0xFFFF3B30,
      eloRating: (map['eloRating'] as num?)?.toInt() ?? 1200,
      trackZ: (map['trackZ'] as num?)?.toDouble() ?? 0.0,
      trackX: (map['trackX'] as num?)?.toDouble() ?? 0.0,
      speedKmH: (map['speedKmH'] as num?)?.toDouble() ?? 0.0,
      steeringAngle: (map['steeringAngle'] as num?)?.toDouble() ?? 0.0,
      isNitroActive: map['isNitroActive'] as bool? ?? false,
      position: (map['position'] as num?)?.toInt() ?? 1,
      finishTimeMs: (map['finishTimeMs'] as num?)?.toInt() ?? 0,
    );
  }
}

class MultiplayerRoom {
  final String roomId;
  final String roomCode;
  final String hostUid;
  final String trackId;
  final RoomState state;
  final int maxPlayers;
  final List<MultiplayerPlayerSlot> players;
  final int countdown;
  final DateTime createdAt;

  const MultiplayerRoom({
    required this.roomId,
    required this.roomCode,
    required this.hostUid,
    required this.trackId,
    this.state = RoomState.waiting,
    this.maxPlayers = 4,
    required this.players,
    this.countdown = 3,
    required this.createdAt,
  });

  bool get isFull => players.length >= maxPlayers;
  bool get allReady => players.isNotEmpty && players.every((p) => p.isReady);

  MultiplayerRoom copyWith({
    String? roomId,
    String? roomCode,
    String? hostUid,
    String? trackId,
    RoomState? state,
    int? maxPlayers,
    List<MultiplayerPlayerSlot>? players,
    int? countdown,
    DateTime? createdAt,
  }) {
    return MultiplayerRoom(
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      hostUid: hostUid ?? this.hostUid,
      trackId: trackId ?? this.trackId,
      state: state ?? this.state,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      players: players ?? this.players,
      countdown: countdown ?? this.countdown,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'roomCode': roomCode,
      'hostUid': hostUid,
      'trackId': trackId,
      'state': state.name,
      'maxPlayers': maxPlayers,
      'players': players.map((p) => p.toMap()).toList(),
      'countdown': countdown,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MultiplayerRoom.fromMap(Map<String, dynamic> map) {
    final playerMaps = (map['players'] as List<dynamic>?) ?? [];
    return MultiplayerRoom(
      roomId: map['roomId'] as String? ?? '',
      roomCode: map['roomCode'] as String? ?? '0000',
      hostUid: map['hostUid'] as String? ?? '',
      trackId: map['trackId'] as String? ?? 'track_neon_city',
      state: RoomState.values.firstWhere(
        (s) => s.name == (map['state'] as String?),
        orElse: () => RoomState.waiting,
      ),
      maxPlayers: (map['maxPlayers'] as num?)?.toInt() ?? 4,
      players: playerMaps
          .map((p) => MultiplayerPlayerSlot.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList(),
      countdown: (map['countdown'] as num?)?.toInt() ?? 3,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MultiplayerRoom.fromJson(String source) =>
      MultiplayerRoom.fromMap(json.decode(source) as Map<String, dynamic>);
}
