import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import '../services/game_controller.dart';
import '../services/save_service.dart';
import '../widgets/common/glass_container.dart';
import '../widgets/common/neon_button.dart';

class SettingsScreen extends StatefulWidget {
  final GameController gameController;

  const SettingsScreen({super.key, required this.gameController});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _soundVolume = 0.8;
  double _musicVolume = 0.6;
  String _controlMode = 'touch_buttons';

  @override
  void initState() {
    super.initState();
    _soundVolume = AudioService().soundVolume;
    _musicVolume = AudioService().musicVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SETTINGS',
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: Center(
                      child: GlassContainer(
                        width: 500,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sound Effects Volume
                            Text(
                              'SOUND EFFECTS VOLUME',
                              style: GoogleFonts.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF90A4AE),
                              ),
                            ),
                            Slider(
                              value: _soundVolume,
                              activeColor: const Color(0xFF00E5FF),
                              inactiveColor: const Color(0xFF263238),
                              onChanged: (val) {
                                setState(() => _soundVolume = val);
                                AudioService().setSoundVolume(val);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Music Volume
                            Text(
                              'MUSIC VOLUME',
                              style: GoogleFonts.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF90A4AE),
                              ),
                            ),
                            Slider(
                              value: _musicVolume,
                              activeColor: const Color(0xFFFF007F),
                              inactiveColor: const Color(0xFF263238),
                              onChanged: (val) {
                                setState(() => _musicVolume = val);
                                AudioService().setMusicVolume(val);
                              },
                            ),
                            const SizedBox(height: 24),

                            // Controls Scheme
                            Text(
                              'INPUT SCHEME',
                              style: GoogleFonts.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF90A4AE),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildControlOption('TOUCH BUTTONS', 'touch_buttons'),
                                const SizedBox(width: 12),
                                _buildControlOption('TILT / GYRO', 'tilt'),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Reset Career Data
                            Center(
                              child: NeonButton(
                                text: 'RESET PROGRESS',
                                icon: Icons.delete_forever,
                                width: 220,
                                height: 42,
                                fontSize: 11,
                                isSecondary: true,
                                primaryColor: const Color(0xFFFF5252),
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  await SaveService.saveProgress(const PlayerProgress());
                                  await widget.gameController.init();
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      const SnackBar(content: Text('Career progress reset to initial stock.')),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlOption(String title, String key) {
    final isSelected = _controlMode == key;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _controlMode = key);
          SaveService.setControlMode(key);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E5FF).withValues(alpha: 0.2) : const Color(0x66101B2B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF00E5FF) : Colors.white24,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? const Color(0xFF00E5FF) : Colors.white60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
