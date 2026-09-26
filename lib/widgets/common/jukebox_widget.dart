import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/audio_service.dart';
import '../../services/soundtrack_generator.dart';

/// Compact Cyberpunk Jukebox Player Widget
class JukeboxWidget extends StatefulWidget {
  final bool compact;
  const JukeboxWidget({super.key, this.compact = false});

  @override
  State<JukeboxWidget> createState() => _JukeboxWidgetState();
}

class _JukeboxWidgetState extends State<JukeboxWidget> with SingleTickerProviderStateMixin {
  late AnimationController _eqController;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _eqController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _audioService.addListener(_onAudioStateChanged);
  }

  void _onAudioStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioStateChanged);
    _eqController.dispose();
    super.dispose();
  }

  void _showPlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _PlaylistDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = _audioService.currentTrack;
    final isPlaying = _audioService.isMusicPlaying;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: widget.compact ? 8 : 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE6070B14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Equalizer or Disc Icon
          GestureDetector(
            onTap: () => _showPlaylistDialog(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPlaying)
                  AnimatedBuilder(
                    animation: _eqController,
                    builder: (context, child) {
                      return Row(
                        children: List.generate(3, (index) {
                          final height = 6.0 + 8.0 * ((index + _eqController.value) % 1.0);
                          return Container(
                            width: 3,
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          );
                        }),
                      );
                    },
                  )
                else
                  const Icon(Icons.music_note, color: Color(0xFF00E5FF), size: 16),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Track Title & Click for Playlist
          Flexible(
            child: GestureDetector(
              onTap: () => _showPlaylistDialog(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widget.compact ? 130 : 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentTrack.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (!widget.compact)
                      Text(
                        currentTrack.genre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rajdhani(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00E5FF),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Controls: Previous
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            icon: const Icon(Icons.skip_previous, color: Colors.white70, size: 18),
            tooltip: 'Previous Track',
            onPressed: () => _audioService.previousTrack(),
          ),

          // Controls: Play / Pause
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: const Color(0xFF00E5FF),
              size: 20,
            ),
            tooltip: isPlaying ? 'Pause' : 'Play',
            onPressed: () => _audioService.togglePlayPause(),
          ),

          // Controls: Next
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            icon: const Icon(Icons.skip_next, color: Colors.white70, size: 18),
            tooltip: 'Next Track',
            onPressed: () => _audioService.nextTrack(),
          ),

          // Playlist Selector Button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            icon: const Icon(Icons.queue_music, color: Color(0xFFFFD600), size: 18),
            tooltip: 'Open Tamil & PS2 Playlist',
            onPressed: () => _showPlaylistDialog(context),
          ),
        ],
      ),
    );
  }
}

/// Cyberpunk 3D Playlist Selector Dialog
class _PlaylistDialog extends StatelessWidget {
  const _PlaylistDialog();

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();
    final currentTrack = audioService.currentTrack;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xF2090E1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.album, color: Color(0xFF00E5FF), size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'TAMIL & PS2 JUKEBOX',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Select any background track to blast during menus, garage & high-speed races:',
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: const Color(0xFFB0BEC5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Track List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: GameTrack.allTracks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final track = GameTrack.allTracks[index];
                  final isSelected = track.id == currentTrack.id;

                  return InkWell(
                    onTap: () {
                      audioService.playTrack(track);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00E5FF).withValues(alpha: 0.15) : const Color(0xFF131A2B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00E5FF) : Colors.white12,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Play / Equalizer Icon
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? const Color(0xFF00E5FF) : Colors.white10,
                            ),
                            child: Icon(
                              isSelected ? Icons.graphic_eq : Icons.play_arrow,
                              color: isSelected ? Colors.black : Colors.white70,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Metadata
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected ? const Color(0xFF00E5FF) : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  track.subtitle,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? const Color(0xFFFFD600) : const Color(0xFF90A4AE),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // BPM Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2638),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${track.bpm.toInt()} BPM',
                              style: GoogleFonts.rajdhani(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF69F0AE),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
