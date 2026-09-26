// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

const int port = 8088;
const String senderGmail = 'sanjaim202@gmail.com';
const String appPassword = 'xptaynwalcovoqtj';

/// Active rooms and their connected client sockets: roomCode -> Set of WebSockets
final Map<String, Set<WebSocket>> roomSockets = {};
final Map<WebSocket, String> socketToRoom = {};
final Map<WebSocket, String> socketToUid = {};

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('🚀 Apex Velocity Backend Server (HTTP + WebSocket) running on http://127.0.0.1:$port');
  print('⚡ Real-time Multiplayer WebSocket endpoint ready at ws://127.0.0.1:$port/ws');

  await for (HttpRequest request in server) {
    // Add CORS headers for web browser requests
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    // 1. WebSocket Handler for Real-Time 1v1 Room Sync & Telemetry
    if (request.uri.path == '/ws') {
      try {
        final socket = await WebSocketTransformer.upgrade(request);
        _handleWebSocketClient(socket);
      } catch (e) {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      }
      continue;
    }

    // 2. Health check
    if (request.method == 'GET' && request.uri.path == '/api/health') {
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'status': 'ok', 'service': 'Apex Backend Mailer & WebSocket'}));
      await request.response.close();
      continue;
    }

    // 3. Email Dispatch via Gmail SMTP
    if (request.method == 'POST' && request.uri.path == '/api/send-email') {
      try {
        final content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content) as Map<String, dynamic>;

        final recipientEmail = data['recipientEmail'] as String? ?? '';
        final lobbyCode = data['lobbyCode'] as String? ?? '';
        final senderName = data['senderName'] as String? ?? 'Racer';
        final trackName = data['trackName'] as String? ?? 'Neon City Cyber Highway';

        print('═══════════════════════════════════════════════════════════');
        print('📧 [BACKEND SERVER RECEIVED EMAIL REQUEST]');
        print('  • SENDER    : $senderGmail ($senderName)');
        print('  • RECIPIENT : $recipientEmail');
        print('  • LOBBY     : #$lobbyCode');
        print('  • TRACK     : $trackName');

        final smtpServer = gmail(senderGmail, appPassword.replaceAll(' ', ''));
        final message = Message()
          ..from = Address(senderGmail, 'Apex Velocity Racing')
          ..recipients.add(recipientEmail)
          ..subject = '🏎️ Apex Velocity Race Invitation: Join Lobby #$lobbyCode'
          ..html = '''
            <div style="background-color: #070B14; color: #ffffff; padding: 28px; font-family: 'Segoe UI', Arial, sans-serif; border-radius: 16px; border: 2px solid #00E5FF; max-width: 500px; margin: 0 auto;">
              <h1 style="color: #00E5FF; margin: 0; font-size: 24px; letter-spacing: 2px;">🏎️ APEX VELOCITY RACING</h1>
              <p style="font-size: 15px; margin: 16px 0; color: #E0E0E0;"><strong>$senderName</strong> ($senderGmail) has invited you to a live multiplayer race!</p>
              <div style="background-color: #131B2E; padding: 18px; border-radius: 12px; margin: 20px 0; border: 1px solid #FFD600;">
                <p style="margin: 0; color: #80D8FF; font-size: 13px;">🏁 CIRCUIT: <strong>$trackName</strong></p>
                <p style="margin: 8px 0 0 0; font-size: 26px; color: #FFD600; font-weight: 900; letter-spacing: 4px;">
                  LOBBY CODE: #$lobbyCode
                </p>
              </div>
              <p style="font-size: 13px; color: #B0BEC5; line-height: 1.5;">
                <strong>How to enter the race:</strong><br>
                1. Open Apex Velocity.<br>
                2. Click <strong>Multiplayer Racing</strong>.<br>
                3. Enter Code <strong>#$lobbyCode</strong> and click <strong>ENTER LOBBY</strong>!
              </p>
            </div>
          ''';

        final report = await send(message, smtpServer);
        print('  • SMTP STATUS: ✅ Delivered (${report.toString()})');
        print('═══════════════════════════════════════════════════════════');

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({
          'success': true,
          'message': 'Email invitation delivered to $recipientEmail',
          'lobbyCode': lobbyCode,
        }));
        await request.response.close();
      } catch (e) {
        print('  • SMTP ERROR : ❌ $e');
        print('═══════════════════════════════════════════════════════════');
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
        await request.response.close();
      }
      continue;
    }

    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }
}

/// Handle real-time WebSocket client connection
void _handleWebSocketClient(WebSocket socket) {
  socket.listen(
    (message) {
      try {
        final data = jsonDecode(message.toString()) as Map<String, dynamic>;
        final type = data['type'] as String? ?? '';
        final roomCode = data['roomCode'] as String? ?? '';
        final uid = data['uid'] as String? ?? '';

        if (roomCode.isNotEmpty) {
          roomSockets.putIfAbsent(roomCode, () => <WebSocket>{}).add(socket);
          socketToRoom[socket] = roomCode;
          if (uid.isNotEmpty) socketToUid[socket] = uid;
        }

        switch (type) {
          case 'JOIN_ROOM':
          case 'PLAYER_READY':
          case 'START_COUNTDOWN':
          case 'ROOM_STATE_SYNC':
            // Broadcast to all other peers in the same room
            _broadcastToRoom(roomCode, message.toString(), sender: socket, includeSender: false);
            break;

          case 'CAR_TELEMETRY':
            // High-speed 60fps telemetry broadcast (trackZ, trackX, speed, steering, nitro)
            _broadcastToRoom(roomCode, message.toString(), sender: socket, includeSender: false);
            break;
        }
      } catch (e) {
        print('WebSocket message error: $e');
      }
    },
    onDone: () => _cleanupSocket(socket),
    onError: (e) => _cleanupSocket(socket),
  );
}

void _broadcastToRoom(String roomCode, String message, {WebSocket? sender, bool includeSender = false}) {
  final sockets = roomSockets[roomCode];
  if (sockets == null) return;

  for (final client in sockets) {
    if (!includeSender && client == sender) continue;
    if (client.readyState == WebSocket.open) {
      client.add(message);
    }
  }
}

void _cleanupSocket(WebSocket socket) {
  final roomCode = socketToRoom.remove(socket);
  final uid = socketToUid.remove(socket);

  if (roomCode != null && roomSockets.containsKey(roomCode)) {
    roomSockets[roomCode]!.remove(socket);
    if (roomSockets[roomCode]!.isEmpty) {
      roomSockets.remove(roomCode);
    } else if (uid != null) {
      _broadcastToRoom(roomCode, jsonEncode({'type': 'PLAYER_LEFT', 'roomCode': roomCode, 'uid': uid}));
    }
  }
}
