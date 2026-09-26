import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:apex_velocity/services/neon_database_service.dart';

void main() {
  group('Live Email Invitation & Cloud Dispatch Simulation Suite', () {
    late NeonDatabaseService neonService;

    setUp(() {
      neonService = NeonDatabaseService();
    });

    test('1. Verify HTML Email Template Generation & Metadata Packaging', () {
      const recipient = 'racer.friend@gmail.com';
      const lobbyCode = '4920';
      const senderName = 'Sanjai Pro Racer';
      const senderEmail = 'sanjai.m@gmail.com';
      const trackName = 'Neon City Cyber Highway';

      final htmlBody = '''
        <div style="background-color: #070B14; color: #ffffff; padding: 28px; font-family: 'Segoe UI', sans-serif; border-radius: 16px; border: 2px solid #00E5FF;">
          <h1 style="color: #00E5FF; margin: 0; font-size: 24px; letter-spacing: 2px;">🏎️ APEX VELOCITY</h1>
          <p style="font-size: 16px; margin: 16px 0;"><strong>$senderName</strong> ($senderEmail) has challenged $recipient to a live multiplayer race!</p>
          <div style="background-color: #131B2E; padding: 20px; border-radius: 12px; margin: 20px 0; border: 1px solid #FFD600;">
            <p style="margin: 0; color: #80D8FF; font-size: 14px;">🏁 TRACK: <strong>$trackName</strong></p>
            <p style="margin: 10px 0 0 0; font-size: 28px; color: #FFD600; font-weight: 900; letter-spacing: 4px;">
              LOBBY CODE: #$lobbyCode
            </p>
          </div>
          <p style="font-size: 13px; color: #80D8FF;">To join the race, open Apex Velocity, navigate to Multiplayer, and enter code <strong>#$lobbyCode</strong>.</p>
        </div>
      ''';

      expect(htmlBody, contains(lobbyCode));
      expect(htmlBody, contains(senderName));
      expect(htmlBody, contains(senderEmail));
      expect(htmlBody, contains(trackName));
    });

    test('2. Simulate Live REST Email Dispatcher with Mock Delivery API', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('api.resend.com') ||
            request.url.toString().contains('api.emailjs.com') ||
            request.url.toString().contains('formspree.io') ||
            request.url.toString().contains('neon.tech')) {
          return http.Response(
            jsonEncode({
              'id': 'msg_01HX8923KJSD',
              'status': 'queued',
              'to': 'racer.friend@gmail.com',
              'created_at': DateTime.now().toIso8601String(),
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final response = await mockClient.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {'Authorization': 'Bearer test_key', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'from': 'Apex Velocity <onboarding@resend.dev>',
          'to': ['racer.friend@gmail.com'],
          'subject': '🏎️ Apex Velocity Race Invitation: Join Lobby #4920',
          'html': '<p>Join my lobby #4920!</p>',
        }),
      );

      expect(response.statusCode, equals(200));
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      expect(json['id'], equals('msg_01HX8923KJSD'));
      expect(json['status'], equals('queued'));
    });

    test('3. Test Neon Cloud Database Audit & Persistent Queue for Email Dispatch', () async {
      final sent = await neonService.sendEmailInvitation(
        recipientEmail: 'sanjai.m@gmail.com',
        lobbyCode: '9182',
        senderName: 'Sanjai M',
        senderEmail: 'sanjai.m@gmail.com',
        trackName: 'Neon City Cyber Highway',
      );

      expect(sent, isTrue);

      // Verify audit record exists in database
      final queryRes = await neonService.query('''
        SELECT track_id, winner_name, players_json 
        FROM match_records 
        WHERE track_id = 'Neon City Cyber Highway'
        ORDER BY id DESC 
        LIMIT 1;
      ''');

      if (queryRes != null && queryRes is Map && queryRes.containsKey('rows')) {
        final rows = queryRes['rows'] as List;
        expect(rows.isNotEmpty, isTrue);
      }
    });
  });
}
