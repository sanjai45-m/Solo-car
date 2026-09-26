import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'services/game_controller.dart';
import 'services/tilt_controller.dart';
import 'widgets/common/landscape_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to landscape orientations for authentic arcade racing experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Immersive full-screen mode (hide Android navigation & status bars)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize Global Services & Save Data
  final authService = AuthService();
  await authService.init();

  final gameController = GameController();
  final initialUid = (authService.currentUser != null && !authService.currentUser!.isGuest)
      ? authService.currentUser!.uid
      : null;
  await gameController.init(uid: initialUid);

  // Automatically switch progression when user logs in or out
  authService.authStateChanges.listen((profile) {
    if (profile != null && !profile.isGuest) {
      gameController.switchUser(profile.uid);
    } else {
      gameController.resetToFreshState();
    }
  });

  await AudioService().init();
  TiltController().init();

  runApp(ApexVelocityApp(gameController: gameController));
}

class ApexVelocityApp extends StatelessWidget {
  final GameController gameController;

  const ApexVelocityApp({super.key, required this.gameController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apex Velocity: Arcade 2D Racing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B12),
        primaryColor: const Color(0xFF00E5FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF007F),
          surface: Color(0xFF0E1624),
        ),
        textTheme: GoogleFonts.orbitronTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      builder: (context, child) => LandscapeGuard(child: child ?? const SizedBox.shrink()),
      home: SplashScreen(gameController: gameController),
    );
  }
}
