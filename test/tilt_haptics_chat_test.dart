import 'package:apex_velocity/models/multiplayer_room.dart';
import 'package:apex_velocity/services/haptic_service.dart';
import 'package:apex_velocity/services/tilt_controller.dart';
import 'package:apex_velocity/widgets/multiplayer/lobby_chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tilt-to-Steer Controller Tests', () {
    late TiltController controller;

    setUp(() {
      controller = TiltController();
      controller.init(isTest: true);
    });

    test('1. TiltController gracefully handles desktop/web/test environments', () {
      expect(controller.deadZone, 0.08);
      expect(controller.sensitivity, 1.35);
      // On non-mobile/test environment, sensor is safe and returns zero
      expect(controller.currentSteering, 0.0);
    });

    test('2. TiltController enable/disable toggle', () {
      controller.setTiltEnabled(false);
      expect(controller.isTiltEnabled, isFalse);
      expect(controller.currentSteering, 0.0);

      controller.setTiltEnabled(true);
      expect(controller.isTiltEnabled, isTrue);
    });
  });

  group('Tactile Haptic Feedback Service Tests', () {
    late HapticService hapticService;

    setUp(() {
      hapticService = HapticService();
      hapticService.setEnabled(true);
    });

    test('1. HapticService triggers without uncaught exceptions', () {
      expect(hapticService.isEnabled, isTrue);
      expect(() => hapticService.buttonClick(), returnsNormally);
      expect(() => hapticService.gearShift(), returnsNormally);
      expect(() => hapticService.nearMiss(), returnsNormally);
      expect(() => hapticService.nitroBurst(), returnsNormally);
      expect(() => hapticService.collisionHeavy(), returnsNormally);
      expect(() => hapticService.alertVibrate(), returnsNormally);
    });

    test('2. HapticService toggle off suppresses triggers', () {
      hapticService.setEnabled(false);
      expect(hapticService.isEnabled, isFalse);
      expect(() => hapticService.collisionHeavy(), returnsNormally);
    });
  });

  group('In-Lobby Chat & Quick Emotes Tests', () {
    test('1. LobbyChatMessage serialization and deserialization', () {
      final msg = LobbyChatMessage(
        id: 'chat_123',
        senderUid: 'user_99',
        senderName: 'ApexLegend',
        message: 'Let\'s Race!',
        emoteIcon: '🏎️',
        isEmote: true,
        timestamp: DateTime(2026, 9, 26, 17, 0, 0),
      );

      final map = msg.toMap();
      expect(map['id'], 'chat_123');
      expect(map['senderUid'], 'user_99');
      expect(map['senderName'], 'ApexLegend');
      expect(map['message'], 'Let\'s Race!');
      expect(map['emoteIcon'], '🏎️');
      expect(map['isEmote'], isTrue);

      final restored = LobbyChatMessage.fromMap(map);
      expect(restored.id, msg.id);
      expect(restored.senderUid, msg.senderUid);
      expect(restored.senderName, msg.senderName);
      expect(restored.message, msg.message);
      expect(restored.emoteIcon, msg.emoteIcon);
      expect(restored.isEmote, isTrue);
    });

    testWidgets('2. LobbyChatWidget renders emote chips and text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LobbyChatWidget(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('LOBBY CHAT & EMOTES'), findsOneWidget);
      expect(find.text("Let's Race!"), findsOneWidget);
      expect(find.text("Nitro Ready!"), findsOneWidget);
      expect(find.text("Bring It On!"), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
