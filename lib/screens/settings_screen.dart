import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import '../services/game_controller.dart';
import '../services/haptic_service.dart';
import '../services/save_service.dart';
import '../services/tilt_controller.dart';
import '../widgets/common/app_background.dart';
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
  bool _hapticEnabled = true;

  @override
  void initState() {
    super.initState();
    _soundVolume = AudioService().soundVolume;
    _musicVolume = AudioService().musicVolume;
    _hapticEnabled = HapticService().isEnabled;
    _controlMode = TiltController().isTiltEnabled ? 'tilt' : 'touch_buttons';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: AppBackground(
        overlayOpacity: 0.80,
        child: Stack(
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
                              'STEERING SCHEME',
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
                                _buildControlOption('TILT GYRO', 'tilt'),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Haptic Feedback Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TACTILE HAPTIC FEEDBACK',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF90A4AE),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Vibrations on nitro, crashes, near-misses',
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 11,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _hapticEnabled,
                                  activeThumbColor: const Color(0xFF00E5FF),
                                  activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                  onChanged: (val) {
                                    setState(() => _hapticEnabled = val);
                                    HapticService().setEnabled(val);
                                    if (val) HapticService().buttonClick();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

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
    ),
  );
}

  Widget _buildControlOption(String title, String key) {
    final isSelected = _controlMode == key;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _controlMode = key);
          TiltController().setTiltEnabled(key == 'tilt');
          SaveService.setControlMode(key);
          HapticService().buttonClick();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      const Color(0xFF00E5FF).withValues(alpha: 0.35),
                      const Color(0xFF0A1828),
                    ]
                  : [
                      const Color(0xFF141D2D),
                      const Color(0xFF090E17),
                    ],
            ),
            border: Border.all(
              color: isSelected ? const Color(0xFF00E5FF) : Colors.white12,
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.75),
                offset: const Offset(2, 4),
                blurRadius: 6,
              ),
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  offset: const Offset(-1, -1),
                  blurRadius: 8,
                ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: isSelected ? const Color(0xFF00E5FF) : Colors.white60,
                shadows: isSelected
                    ? const [Shadow(color: Color(0xFF00E5FF), blurRadius: 8)]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
