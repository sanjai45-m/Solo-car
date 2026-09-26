import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/race_model.dart';
import '../services/game_controller.dart';
import '../widgets/common/app_background.dart';
import '../widgets/common/glass_container.dart';
import '../widgets/common/neon_button.dart';
import 'race_game_screen.dart';

class RaceSelectionScreen extends StatefulWidget {
  final GameController gameController;

  const RaceSelectionScreen({super.key, required this.gameController});

  @override
  State<RaceSelectionScreen> createState() => _RaceSelectionScreenState();
}

class _RaceSelectionScreenState extends State<RaceSelectionScreen> {
  int _selectedTrackIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameController,
      builder: (context, _) {
        final tracks = RaceTrack.defaultTracks;
        final selectedTrack = tracks[_selectedTrackIndex];
        final isUnlocked = widget.gameController.progress.unlockedTrackIds.contains(selectedTrack.id);
        final bestTimeMs = widget.gameController.progress.trackBestTimesMs[selectedTrack.id];

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E17),
          body: AppBackground(
            overlayOpacity: 0.76,
            child: Stack(
              children: [
              // Ambient Environment Glow
              Positioned(
                bottom: -80,
                right: -80,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedTrack.ambientColors.first.withValues(alpha: 0.22),
                    boxShadow: [
                      BoxShadow(
                        color: selectedTrack.ambientColors.first.withValues(alpha: 0.35),
                        blurRadius: 100,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CAREER RACES',
                                style: GoogleFonts.orbitron(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          // Player Active Car Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0x990A0E17),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF00E5FF)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_car, color: Color(0xFF00E5FF), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  widget.gameController.currentCar.name.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Track Carousel
                    Expanded(
                      child: Row(
                        children: [
                          // Left Track Selection List
                          Expanded(
                            flex: 4,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: tracks.length,
                              itemBuilder: (context, idx) {
                                final track = tracks[idx];
                                final isSelected = idx == _selectedTrackIndex;
                                final trackUnlocked = widget.gameController.progress.unlockedTrackIds.contains(track.id);

                                return GestureDetector(
                                  onTap: () => setState(() => _selectedTrackIndex = idx),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xE6152238) : const Color(0x990E1624),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF00E5FF) : Colors.white12,
                                        width: isSelected ? 1.8 : 1.0,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                                                blurRadius: 12,
                                                offset: const Offset(0, 3),
                                              ),
                                              const BoxShadow(
                                                color: Color(0x66000000),
                                                blurRadius: 6,
                                                offset: Offset(0, 4),
                                              ),
                                            ]
                                          : const [
                                              BoxShadow(
                                                color: Color(0x55000000),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          trackUnlocked ? Icons.sports_score : Icons.lock,
                                          color: isSelected ? const Color(0xFF00E5FF) : (trackUnlocked ? Colors.white60 : const Color(0xFFFF5252)),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'STAGE 0${idx + 1}',
                                                style: GoogleFonts.orbitron(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF00E5FF),
                                                ),
                                              ),
                                              Text(
                                                track.name,
                                                style: GoogleFonts.orbitron(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: trackUnlocked ? Colors.white : Colors.white38,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${track.cashReward}',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF00E676),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Right Track Detail Card
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24, top: 10, bottom: 20),
                              child: GlassContainer(
                                backgroundColor: const Color(0xEE0E1624),
                                borderColor: isUnlocked ? const Color(0xFF00E5FF) : const Color(0xFFFF5252),
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Track Name & Location
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectedTrack.name.toUpperCase(),
                                              style: GoogleFonts.orbitron(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            Text(
                                              selectedTrack.location,
                                              style: GoogleFonts.orbitron(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF90A4AE),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFF00E5FF)),
                                          ),
                                          child: Text(
                                            selectedTrack.mode.name.toUpperCase(),
                                            style: GoogleFonts.orbitron(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF00E5FF),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    Text(
                                      selectedTrack.description,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Track Specs Grid
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildSpecItem(
                                            'DISTANCE',
                                            '${(selectedTrack.trackDistanceMeters / 1000).toStringAsFixed(1)} KM',
                                            Icons.straighten,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildSpecItem(
                                            'DIFFICULTY',
                                            selectedTrack.difficulty.name.toUpperCase(),
                                            Icons.speed,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildSpecItem(
                                            'REWARD',
                                            '\$${selectedTrack.cashReward}',
                                            Icons.attach_money,
                                            valueColor: const Color(0xFF00E676),
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildSpecItem(
                                            'BEST RECORD',
                                            bestTimeMs != null
                                                ? _formatTime(bestTimeMs)
                                                : '--:--.--',
                                            Icons.timer,
                                            valueColor: const Color(0xFFFFD600),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Spacer(),

                                    // Action Button: Start Race or Locked Alert
                                    Center(
                                      child: isUnlocked
                                          ? NeonButton(
                                              text: 'START RACE',
                                              icon: Icons.flag,
                                              width: 320,
                                              height: 52,
                                              fontSize: 16,
                                              primaryColor: const Color(0xFF00E676),
                                              onPressed: () {
                                                widget.gameController.selectTrack(selectedTrack);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => RaceGameScreen(
                                                      gameController: widget.gameController,
                                                      carModel: widget.gameController.currentCar,
                                                      track: selectedTrack,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: const Color(0xFFFF5252)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.lock, color: Color(0xFFFF5252)),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'COMPLETE PREVIOUS STAGE TO UNLOCK',
                                                    style: GoogleFonts.orbitron(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w800,
                                                      color: const Color(0xFFFF5252),
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }

  Widget _buildSpecItem(String label, String value, IconData icon, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0x66101B2B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E5FF), size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF90A4AE),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: valueColor ?? Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int ms) {
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    final hundredths = (ms % 1000) ~/ 10;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundredths.toString().padLeft(2, '0')}';
  }
}
