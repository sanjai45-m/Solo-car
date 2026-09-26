import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_menu_screen.dart';
import 'services/audio_service.dart';
import 'services/game_controller.dart';

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
  final gameController = GameController();
  await gameController.init();
  await AudioService().init();

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
      home: MainMenuScreen(gameController: gameController),
    );
  }
}
