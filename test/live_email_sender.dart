import 'package:flutter_test/flutter_test.dart';
import 'package:apex_velocity/services/neon_database_service.dart';

void main() async {
  test('Live Real-Time Email Dispatch via Mock/Cloud API', () async {
    final neon = NeonDatabaseService();
    final success = await neon.sendEmailInvitation(
      recipientEmail: 'racer.friend@example.com',
      lobbyCode: '1291',
      senderName: 'Apex Racer',
      senderEmail: 'racer@apexvelocity.game',
      trackName: 'Neon City Cyber Highway',
    );
    expect(success, isTrue);
  });
}
