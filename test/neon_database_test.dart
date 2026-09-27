import 'package:flutter_test/flutter_test.dart';
import 'package:apex_velocity/services/neon_database_service.dart';
import 'package:apex_velocity/models/user_profile.dart';

void main() {
  test('Neon Cloud PostgreSQL Connection & Schema Initialization', () async {
    final neon = NeonDatabaseService();
    final now = DateTime.now();

    // 1. Initialize tables in Neon Cloud DB
    await neon.initializeSchema();

    // 2. Save a test racer profile
    final testProfile = UserProfile(
      uid: 'test_racer_pilot_01',
      displayName: 'Apex Pro Racer',
      email: 'pilot@example.com',
      photoUrl: null,
      isGuest: false,
      eloRating: 1350,
      totalMultiplayerWins: 12,
      totalMultiplayerRaces: 15,
      trophies: 3,
      createdAt: now,
      lastActive: now,
    );

    final saved = await neon.saveRacerProfile(testProfile);
    expect(saved, isTrue);

    // 3. Test Leaderboard Retrieval
    final leaderboard = await neon.getGlobalLeaderboard(limit: 5);
    expect(leaderboard.isNotEmpty, isTrue);
    expect(leaderboard.any((p) => p.uid == 'test_racer_pilot_01'), isTrue);

    // 4. Test Backend Email Dispatch & Invitation Logging
    final emailSent = await neon.sendEmailInvitation(
      recipientEmail: 'friend@example.com',
      lobbyCode: '7788',
      senderName: 'Apex Pro Racer',
      senderEmail: 'pilot@example.com',
      trackName: 'Neon City Cyber Highway',
    );
    expect(emailSent, isTrue);
  });
}
