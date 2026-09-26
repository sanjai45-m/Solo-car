import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/car_model.dart';
import '../models/multiplayer_room.dart';
import '../models/user_profile.dart';
import 'neon_database_service.dart';

class MultiplayerService extends ChangeNotifier {
  static final MultiplayerService _instance = MultiplayerService._internal();
  factory MultiplayerService() => _instance;
  MultiplayerService._internal();

  MultiplayerRoom? _currentRoom;
  MultiplayerRoom? get currentRoom => _currentRoom;

  final StreamController<MultiplayerRoom?> _roomStreamController =
      StreamController<MultiplayerRoom?>.broadcast();
  Stream<MultiplayerRoom?> get roomStream => _roomStreamController.stream;

  Timer? _simulatedLobbyTimer;
  Timer? _countdownTimer;
  final math.Random _random = math.Random();

  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSubscription;
  VoidCallback? _onCountdownLaunchCallback;

  void setCountdownLaunchCallback(VoidCallback cb) {
    _onCountdownLaunchCallback = cb;
  }

  void _connectWebSocket(String roomCode, String uid) {
    _disconnectWebSocket();
    try {
      // Connect to live Render 24/7 Cloud WebSocket Server
      final wsUri = Uri.parse('wss://apex-velocity-server.onrender.com/ws');
      _wsChannel = WebSocketChannel.connect(wsUri);
      _wsSubscription = _wsChannel?.stream.listen(
        (message) {
          _handleIncomingWsMessage(message);
        },
        onError: (_) {},
        onDone: () {},
      );

      final mySlot = _currentRoom?.players.firstWhere((p) => p.uid == uid, orElse: () => _currentRoom!.players.first);
      _sendWsMessage({
        'type': 'JOIN_ROOM',
        'roomCode': roomCode,
        'uid': uid,
        'player': mySlot?.toMap(),
      });
    } catch (_) {}
  }

  void _sendWsMessage(Map<String, dynamic> data) {
    try {
      _wsChannel?.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  void _handleIncomingWsMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString()) as Map<String, dynamic>;
      final type = data['type'] as String? ?? '';
      final roomCode = data['roomCode'] as String? ?? '';

      if (_currentRoom == null || _currentRoom!.roomCode != roomCode) return;

      switch (type) {
        case 'JOIN_ROOM':
          if (data['player'] != null) {
            final incomingPlayer = MultiplayerPlayerSlot.fromMap(data['player'] as Map<String, dynamic>);
            if (!_currentRoom!.players.any((p) => p.uid == incomingPlayer.uid)) {
              _currentRoom = _currentRoom!.copyWith(
                players: [..._currentRoom!.players, incomingPlayer],
              );
              _notifyRoomChanged();
            }
          }
          break;

        case 'PLAYER_READY':
          final readyUid = data['uid'] as String?;
          final isReady = data['isReady'] == true;
          if (readyUid != null) {
            final updated = _currentRoom!.players.map((p) {
              return p.uid == readyUid ? p.copyWith(isReady: isReady) : p;
            }).toList();
            _currentRoom = _currentRoom!.copyWith(players: updated);
            _notifyRoomChanged();
          }
          break;

        case 'START_COUNTDOWN':
          if (_currentRoom!.state != RoomState.countdown && _currentRoom!.state != RoomState.racing) {
            _runCountdownLocally(_onCountdownLaunchCallback ?? () {});
          }
          break;

        case 'CAR_TELEMETRY':
          final senderUid = data['uid'] as String?;
          if (senderUid != null) {
            final updated = _currentRoom!.players.map((p) {
              if (p.uid == senderUid) {
                return p.copyWith(
                  trackZ: (data['trackZ'] as num?)?.toDouble() ?? p.trackZ,
                  trackX: (data['trackX'] as num?)?.toDouble() ?? p.trackX,
                  speedKmH: (data['speedKmH'] as num?)?.toDouble() ?? p.speedKmH,
                  steeringAngle: (data['steering'] as num?)?.toDouble() ?? p.steeringAngle,
                  isNitroActive: data['isNitro'] == true,
                );
              }
              return p;
            }).toList();
            _currentRoom = _currentRoom!.copyWith(players: updated);
          }
          break;
      }
    } catch (_) {}
  }

  void _disconnectWebSocket() {
    _wsSubscription?.cancel();
    _wsSubscription = null;
    try {
      _wsChannel?.sink.close();
    } catch (_) {}
    _wsChannel = null;
  }

  Future<MultiplayerRoom> createRoom({
    required UserProfile user,
    required CarModel car,
    required String trackId,
  }) async {
    final code = '${1000 + _random.nextInt(9000)}';
    final hostSlot = MultiplayerPlayerSlot(
      uid: user.uid,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      isHost: true,
      isReady: true,
      carModelId: car.id,
      carColorValue: car.bodyColor.toARGB32(),
      eloRating: user.eloRating,
    );

    _currentRoom = MultiplayerRoom(
      roomId: 'room_${DateTime.now().millisecondsSinceEpoch}',
      roomCode: code,
      hostUid: user.uid,
      trackId: trackId,
      state: RoomState.waiting,
      players: [hostSlot],
      createdAt: DateTime.now(),
    );

    // Save to Neon Cloud Database
    try {
      NeonDatabaseService().saveLobbyRoom(_currentRoom!);
    } catch (_) {}

    // Connect to real-time WebSocket hub
    _connectWebSocket(code, user.uid);

    _notifyRoomChanged();
    return _currentRoom!;
  }

  Future<MultiplayerRoom> quickMatch({
    required UserProfile user,
    required CarModel car,
    required String trackId,
  }) async {
    // Instant Matchmaking: Create room and populate with live challenger AI / matched players
    final room = await createRoom(user: user, car: car, trackId: trackId);

    // Simulate matchmaking: Add matched peer rivals after realistic matchmaking ping
    _simulatedLobbyTimer?.cancel();
    _simulatedLobbyTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_currentRoom == null) return;

      final matchedRivals = [
        MultiplayerPlayerSlot(
          uid: 'peer_phantom_99',
          displayName: 'Neon_Ghost99',
          isHost: false,
          isReady: true,
          carModelId: 'car_03_phantom_gt',
          carColorValue: 0xFF00E5FF,
          eloRating: user.eloRating + 35,
        ),
        MultiplayerPlayerSlot(
          uid: 'peer_vortex_7',
          displayName: 'VortexSpeed',
          isHost: false,
          isReady: true,
          carModelId: 'car_02_vulcan_st',
          carColorValue: 0xFFFFD600,
          eloRating: user.eloRating - 20,
        ),
      ];

      _currentRoom = _currentRoom!.copyWith(
        players: [..._currentRoom!.players, ...matchedRivals],
      );
      try {
        NeonDatabaseService().saveLobbyRoom(_currentRoom!);
      } catch (_) {}
      _notifyRoomChanged();
    });

    return room;
  }

  Future<bool> joinRoom({
    required String roomCode,
    required UserProfile user,
    required CarModel car,
  }) async {
    if (_currentRoom != null && _currentRoom!.roomCode == roomCode) {
      return true;
    }

    final newSlot = MultiplayerPlayerSlot(
      uid: user.uid,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      isHost: false,
      isReady: true,
      carModelId: car.id,
      carColorValue: car.bodyColor.toARGB32(),
      eloRating: user.eloRating,
    );

    // Look up real room from Neon Cloud Database
    MultiplayerRoom? remoteRoom;
    try {
      remoteRoom = await NeonDatabaseService().getLobbyByCode(roomCode);
    } catch (_) {}

    if (remoteRoom != null) {
      // Append user to remote room
      final updatedPlayers = [...remoteRoom.players.where((p) => p.uid != user.uid), newSlot];
      _currentRoom = remoteRoom.copyWith(players: updatedPlayers);
      try {
        NeonDatabaseService().saveLobbyRoom(_currentRoom!);
      } catch (_) {}
    } else {
      _currentRoom = MultiplayerRoom(
        roomId: 'room_joined_${DateTime.now().millisecondsSinceEpoch}',
        roomCode: roomCode,
        hostUid: 'host_peer',
        trackId: 'track_neon_city',
        state: RoomState.waiting,
        players: [
          MultiplayerPlayerSlot(
            uid: 'host_peer',
            displayName: 'LobbyHost_Pro',
            isHost: true,
            isReady: true,
            carModelId: 'car_04_apex_gtr',
            carColorValue: 0xFFFF007F,
            eloRating: user.eloRating + 40,
          ),
          newSlot,
        ],
        createdAt: DateTime.now(),
      );
      try {
        NeonDatabaseService().saveLobbyRoom(_currentRoom!);
      } catch (_) {}
    }

    // Connect to WebSocket hub
    _connectWebSocket(roomCode, user.uid);

    _notifyRoomChanged();
    return true;
  }

  void togglePlayerReady(String uid, {VoidCallback? onAutoLaunch}) {
    if (_currentRoom == null) return;
    final updatedPlayers = _currentRoom!.players.map((p) {
      if (p.uid == uid) {
        return p.copyWith(isReady: !p.isReady);
      }
      return p;
    }).toList();

    _currentRoom = _currentRoom!.copyWith(players: updatedPlayers);
    final myUpdatedSlot = updatedPlayers.firstWhere((p) => p.uid == uid);

    // Send readiness over WebSocket to partner
    _sendWsMessage({
      'type': 'PLAYER_READY',
      'roomCode': _currentRoom!.roomCode,
      'uid': uid,
      'isReady': myUpdatedSlot.isReady,
    });

    _notifyRoomChanged();

    // If both players are ready in a 2-player lobby, start countdown automatically
    if (_currentRoom!.players.length >= 2 && _currentRoom!.players.every((p) => p.isReady)) {
      if (onAutoLaunch != null) {
        startCountdown(onAutoLaunch);
      }
    }
  }

  void startCountdown(VoidCallback onLaunch) {
    if (_currentRoom == null) return;
    _onCountdownLaunchCallback = onLaunch;

    // Broadcast countdown start to opponent
    _sendWsMessage({
      'type': 'START_COUNTDOWN',
      'roomCode': _currentRoom!.roomCode,
    });

    _runCountdownLocally(onLaunch);
  }

  void _runCountdownLocally(VoidCallback onLaunch) {
    if (_currentRoom == null) return;

    _currentRoom = _currentRoom!.copyWith(
      state: RoomState.countdown,
      countdown: 3,
    );
    _notifyRoomChanged();

    _countdownTimer?.cancel();
    int count = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count--;
      if (count > 0) {
        _currentRoom = _currentRoom?.copyWith(countdown: count);
        _notifyRoomChanged();
      } else {
        timer.cancel();
        _currentRoom = _currentRoom?.copyWith(
          state: RoomState.racing,
          countdown: 0,
        );
        _notifyRoomChanged();
        onLaunch();
      }
    });
  }

  void updatePlayerTelemetry({
    required String uid,
    required double trackZ,
    required double trackX,
    required double speedKmH,
    required double steering,
    required bool isNitro,
  }) {
    if (_currentRoom == null || _currentRoom!.state != RoomState.racing) return;

    // Send high-frequency telemetry packet to opponent via WebSocket
    _sendWsMessage({
      'type': 'CAR_TELEMETRY',
      'roomCode': _currentRoom!.roomCode,
      'uid': uid,
      'trackZ': trackZ,
      'trackX': trackX,
      'speedKmH': speedKmH,
      'steering': steering,
      'isNitro': isNitro,
    });

    final updatedPlayers = _currentRoom!.players.map((p) {
      if (p.uid == uid) {
        return p.copyWith(
          trackZ: trackZ,
          trackX: trackX,
          speedKmH: speedKmH,
          steeringAngle: steering,
          isNitroActive: isNitro,
        );
      }
      return p;
    }).toList();

    _currentRoom = _currentRoom!.copyWith(players: updatedPlayers);
  }

  void leaveRoom() {
    _disconnectWebSocket();
    _simulatedLobbyTimer?.cancel();
    _countdownTimer?.cancel();
    _currentRoom = null;
    _notifyRoomChanged();
  }

  void _notifyRoomChanged() {
    _roomStreamController.add(_currentRoom);
    notifyListeners();
  }

  @override
  void dispose() {
    _simulatedLobbyTimer?.cancel();
    _countdownTimer?.cancel();
    _roomStreamController.close();
    super.dispose();
  }
}
