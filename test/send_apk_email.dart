import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  final smtpServer = gmail('sanjaim202@gmail.com', 'xptaynwalcovoqtj');
  final message = Message()
    ..from = const Address('sanjaim202@gmail.com', 'Apex Velocity Racing')
    ..recipients.addAll(['sanjaim202@gmail.com', 'sanjaikrishnan05@gmail.com'])
    ..subject = '🏎️ Apex Velocity: AAA Modern UI, Tilt/Gyro Steer, Combat, Police & Leaderboard Release'
    ..html = '''
      <div style="background-color: #070B14; color: #ffffff; padding: 28px; font-family: 'Segoe UI', Arial, sans-serif; border-radius: 16px; border: 2px solid #00E5FF; max-width: 560px; margin: 0 auto;">
        <h1 style="color: #00E5FF; margin: 0; font-size: 24px; letter-spacing: 2px;">🏎️ APEX VELOCITY: AAA PRO GAMING RELEASE</h1>
        <p style="font-size: 15px; margin: 16px 0; color: #E0E0E0;">Your ultimate release featuring modern professional gaming UI, Mobile Gyroscope / Tilt-to-Steer, Tactile Haptics, Cyberpunk Combat Power-Ups, Police Pursuits, Dynamic Weather, Global Live Leaderboard, and In-Lobby Chat/Emotes is ready:</p>
        
        <div style="background-color: #101728; padding: 18px; border-radius: 12px; margin: 20px 0; border: 1px solid #00E5FF;">
          <p style="margin: 0 0 10px 0; color: #80D8FF; font-size: 14px;"><strong>⚡ High-Speed Direct Mirrors:</strong></p>
          <ul style="margin: 0; padding-left: 20px; color: #E0E0E0; font-size: 13px; line-height: 1.8;">
            <li><strong>Direct APK Download (62.1 MB):</strong> <a href="https://tmpfiles.org/dl/w0wfpBcSEE9W/app-release.apk" style="color: #00E5FF; font-weight: bold;">Click to Download APK</a></li>
            <li><strong>Mirror Page:</strong> <a href="https://tmpfiles.org/w0wfpBcSEE9W/app-release.apk" style="color: #FFD600;">tmpfiles.org/w0wfpBcSEE9W</a></li>
            <li><strong>Live Web App:</strong> <a href="https://apex-velocity-game.netlify.app" style="color: #69F0AE;">https://apex-velocity-game.netlify.app</a></li>
          </ul>
        </div>

        <div style="background-color: #0D1322; padding: 16px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #FF007F;">
          <h4 style="margin: 0 0 8px 0; color: #FF007F; font-size: 13px; letter-spacing: 1px;">🎮 NEW AAA FEATURES & UPGRADES:</h4>
          <p style="margin: 0; font-size: 12px; color: #CFD8DC; line-height: 1.6;">
            • 🎨 <strong>HD 3D App Icon & Launcher Branding</strong>: Ultra-crisp neon supercar emblem across Android & Web PWA.<br>
            • 🏎️ <strong>3D Multi-Panel Supercar Vector Geometry</strong>: Full 3D perspective, sculpted fenders, wheel arches & alloy rims.<br>
            • 🔄 <strong>360° Interactive Garage Turntable</strong>: Full horizontal drag inspection with real-time specular sheen.<br>
            • 📱 <strong>Mobile Gyroscope Tilt-to-Steer</strong>: Steer by physically tilting your phone.<br>
            • 📳 <strong>Tactile Haptic Engine</strong>: Vibrations on nitro bursts, gear shifts, near-misses & crashes.<br>
            • ⚡ <strong>Cyberpunk Combat System</strong>: EMP shockwave, Energy Shield, Turbo Warp, Laser Mines.<br>
            • 🚨 <strong>Police Pursuit Mode (NFS Style)</strong>: Dynamic Heat 1-5, interceptor AI & roadblocks.<br>
            • 🌧️ <strong>Dynamic Weather & Night Engine</strong>: Rain particles, wet road specular sheen & traction physics.<br>
            • 🏆 <strong>Global Live Neon PostgreSQL Leaderboard</strong>: Live ELO, total wins & 3-tier podium.<br>
            • 👥 <strong>In-Lobby Chat & Quick Emotes</strong>: Send animated emotes & live chat over 24/7 WebSocket.
          </p>
        </div>

        <div style="text-align: center; margin: 25px 0;">
          <a href="https://tmpfiles.org/dl/w0wfpBcSEE9W/app-release.apk" style="display: inline-block; background-color: #00E5FF; color: #000000; font-weight: 900; padding: 14px 28px; border-radius: 8px; text-decoration: none; font-size: 14px; letter-spacing: 1px; margin-right: 8px;">📲 DIRECT HIGH-SPEED DOWNLOAD</a>
          <a href="https://apex-velocity-game.netlify.app" style="display: inline-block; background-color: #FFD600; color: #000000; font-weight: 900; padding: 14px 28px; border-radius: 8px; text-decoration: none; font-size: 14px; letter-spacing: 1px;">🌐 PLAY ON WEB</a>
        </div>
      </div>
    ''';

  try {
    final sendReport = await send(message, smtpServer);
    print('✅ Email successfully sent: $sendReport');
  } catch (e) {
    print('❌ Failed to send email: $e');
  }
}
