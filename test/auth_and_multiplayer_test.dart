import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_velocity/models/car_model.dart';
import 'package:apex_velocity/models/multiplayer_room.dart';
import 'package:apex_velocity/models/race_model.dart';
import 'package:apex_velocity/models/user_profile.dart';
import 'package:apex_velocity/services/auth_service.dart';
import 'package:apex_velocity/services/game_controller.dart';
import 'package:apex_velocity/services/multiplayer_service.dart';
import 'package:apex_velocity/widgets/common/profile_badge.dart';
import 'package:apex_velocity/widgets/dialogs/auth_dialog.dart';
import 'package:apex_velocity/screens/multiplayer_lobby_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Google Auth, Guest Profile & Multiplayer Test Suite', () {
    late AuthService authService;
    late MultiplayerService multiplayerService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      authService = AuthService();
      await authService.init();
      multiplayerService = MultiplayerService();
    });

    test('1. Guest Profile initialization has correct defaults and ELO rating', () {
      final guest = UserProfile.guest();
      expect(guest.isGuest, isTrue);
      expect(guest.eloRating, 1000);
      expect(guest.totalMultiplayerWins, 0);
      expect(guest.totalMultiplayerRaces, 0);
      expect(guest.winRate, 0.0);
      expect(guest.displayName, startsWith('Racer_'));

      // Test serialization
      final jsonStr = guest.toJson();
      final decoded = UserProfile.fromJson(jsonStr);
      expect(decoded.uid, guest.uid);
      expect(decoded.isGuest, isTrue);
    });

    test('2. User Profile statistics calculation and win rate', () {
      final user = UserProfile(
        uid: 'user_123',
        displayName: 'ApexLegend',
        email: 'legend@racing.com',
        isGuest: false,
        eloRating: 1500,
        totalMultiplayerWins: 15,
        totalMultiplayerRaces: 20,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      expect(user.isGuest, isFalse);
      expect(user.winRate, 75.0);
    });

    test('3. AuthService: Guest mode and simulated Google Sign-In', () async {
      // Start as guest
      await authService.signInAsGuest();
      expect(authService.isGuest, isTrue);
      expect(authService.currentUser, isNotNull);

      // Sign in with Google (simulated in test environment)
      final googleUser = await authService.signInWithGoogle();
      expect(googleUser, isNotNull);
      expect(authService.isGuest, isFalse);
      expect(authService.currentUser?.email, isNotEmpty);

      // Update ELO rating after a win
      await authService.updateProfile(isWin: true, eloChange: 30);
      expect(authService.currentUser?.totalMultiplayerWins, greaterThanOrEqualTo(1));

      // Sign out reverts to guest
      await authService.signOut();
      expect(authService.isGuest, isTrue);
    });

    test('4. Multiplayer Room creation and Matchmaking', () async {
      final user = UserProfile(
        uid: 'racer_apex',
        displayName: 'ApexPilot',
        isGuest: false,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      final car = CarModel.stockCars.first;

      // Create Custom Room
      final room = await multiplayerService.createRoom(
        user: user,
        car: car,
        trackId: RaceTrack.defaultTracks.first.id,
      );

      expect(room.players.length, 1);
      expect(room.players.first.displayName, 'ApexPilot');
      expect(room.players.first.isHost, isTrue);
      expect(room.state, RoomState.waiting);

      // Join Room
      await multiplayerService.joinRoom(
        roomCode: '8888',
        user: user,
        car: car,
      );
      expect(multiplayerService.currentRoom?.players.length, greaterThanOrEqualTo(2));

      // Telemetry update
      multiplayerService.startCountdown(() {});
      multiplayerService.updatePlayerTelemetry(
        uid: user.uid,
        trackZ: 500.0,
        trackX: 0.25,
        speedKmH: 220.0,
        steering: 0.1,
        isNitro: true,
      );

      multiplayerService.leaveRoom();
      expect(multiplayerService.currentRoom, isNull);
    });

    testWidgets('5. ProfileBadge & AuthDialog rendering test', (WidgetTester tester) async {
      final guest = UserProfile.guest();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ProfileBadge(
                profile: guest,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ProfileBadge), findsOneWidget);
      expect(find.text('GUEST'), findsOneWidget);

      // Render AuthDialog
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthDialog(
              onProfileChanged: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('RACER'), findsWidgets);
      expect(find.textContaining('GOOGLE'), findsWidgets);
    });

    testWidgets('6. Multiplayer Lobby Screen UI rendering test', (WidgetTester tester) async {
      final gameController = GameController();
      await gameController.init();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiplayerLobbyScreen(
            gameController: gameController,
          ),
        ),
      );

      expect(find.text('MULTIPLAYER RACING'), findsOneWidget);
    });
  });
}
