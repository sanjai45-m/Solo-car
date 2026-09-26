import 'package:flutter_test/flutter_test.dart';
import 'package:apex_velocity/services/neon_database_service.dart';

void main() async {
  test('Live Real-Time Email Dispatch via Gmail SMTP to sanjaikrishnan05@gmail.com', () async {
    final neon = NeonDatabaseService();
    final success = await neon.sendEmailInvitation(
      recipientEmail: 'sanjaikrishnan05@gmail.com',
      lobbyCode: '1291',
      senderName: 'Sanjai M',
      senderEmail: 'sanjaim202@gmail.com',
      trackName: 'Neon City Cyber Highway',
    );
    expect(success, isTrue);
  });
}
