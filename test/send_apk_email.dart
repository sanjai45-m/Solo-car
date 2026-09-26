import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  final smtpServer = gmail('sanjaim202@gmail.com', 'xptaynwalcovoqtj');
  final message = Message()
    ..from = const Address('sanjaim202@gmail.com', 'Apex Velocity Racing')
    ..recipients.addAll(['sanjaim202@gmail.com', 'sanjaikrishnan05@gmail.com'])
    ..subject = '🏎️ Apex Velocity: 3D UI Update & Direct APK Download'
    ..html = '''
      <div style="background-color: #070B14; color: #ffffff; padding: 28px; font-family: 'Segoe UI', Arial, sans-serif; border-radius: 16px; border: 2px solid #00E5FF; max-width: 540px; margin: 0 auto;">
        <h1 style="color: #00E5FF; margin: 0; font-size: 24px; letter-spacing: 2px;">🏎️ APEX VELOCITY: LATEST 3D RELEASE</h1>
        <p style="font-size: 15px; margin: 16px 0; color: #E0E0E0;">Your latest build with 3D Logo, 3D splash screen, 3D Racing background art, rock-solid 3D cards/buttons, and Google OAuth is ready:</p>
        
        <div style="background-color: #131B2E; padding: 18px; border-radius: 12px; margin: 20px 0; border: 1px solid #00E5FF;">
          <p style="margin: 0 0 10px 0; color: #80D8FF; font-size: 14px;"><strong>⚡ High-Speed Direct Mirrors:</strong></p>
          <ul style="margin: 0; padding-left: 20px; color: #E0E0E0; font-size: 13px; line-height: 1.8;">
            <li><strong>Direct APK Download (55.1 MB):</strong> <a href="https://tmpfiles.org/dl/wvwMpUfDit16/app-release.apk" style="color: #00E5FF; font-weight: bold;">Click to Download APK</a></li>
            <li><strong>Download Mirror Page:</strong> <a href="https://tmpfiles.org/wvwMpUfDit16/app-release.apk" style="color: #FFD600;">tmpfiles.org/wvwMpUfDit16/app-release.apk</a></li>
            <li><strong>Live Web App:</strong> <a href="https://apex-velocity-game.netlify.app" style="color: #69F0AE;">https://apex-velocity-game.netlify.app</a></li>
          </ul>
        </div>

        <div style="text-align: center; margin: 25px 0;">
          <a href="https://tmpfiles.org/dl/wvwMpUfDit16/app-release.apk" style="display: inline-block; background-color: #00E5FF; color: #000000; font-weight: 900; padding: 14px 28px; border-radius: 8px; text-decoration: none; font-size: 14px; letter-spacing: 1px; margin-right: 8px;">📲 DIRECT HIGH-SPEED DOWNLOAD</a>
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
