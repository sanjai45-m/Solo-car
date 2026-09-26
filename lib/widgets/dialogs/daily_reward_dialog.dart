import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/audio_service.dart';
import '../../services/game_controller.dart';
import '../common/neon_button.dart';

class DailyRewardDialog extends StatefulWidget {
  final GameController gameController;

  const DailyRewardDialog({super.key, required this.gameController});

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog> with SingleTickerProviderStateMixin {
  late AnimationController _crateAnim;
  bool _isOpened = false;
  int _rewardCash = 12500;
  int _rewardRep = 350;

  @override
  void initState() {
    super.initState();
    _crateAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _crateAnim.dispose();
    super.dispose();
  }

  void _openCrate() {
    if (_isOpened) return;
    setState(() => _isOpened = true);
    _crateAnim.forward();
    AudioService().playFinishCheer();

    widget.gameController.addCash(_rewardCash);
    widget.gameController.addReputation(_rewardRep);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF090E1B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD600).withValues(alpha: 0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD600).withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: Color(0xFFFFD600), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'DAILY MYSTERY CRATE',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD600),
                        letterSpacing: 1.2,
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
            const SizedBox(height: 16),

            // 3D Animated Crate Showcase
            GestureDetector(
              onTap: _isOpened ? null : _openCrate,
              child: AnimatedBuilder(
                animation: _crateAnim,
                builder: (context, _) {
                  final wobble = sin(_crateAnim.value * pi * 4) * 0.1;
                  final scale = 1.0 + sin(_crateAnim.value * pi) * 0.15;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateZ(_isOpened ? wobble : 0.0)
                      ..scale(scale),
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _isOpened
                                ? const Color(0xFFFFD600).withValues(alpha: 0.4)
                                : const Color(0xFF00E5FF).withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isOpened
                                ? const Color(0xFFFFD600).withValues(alpha: 0.4)
                                : const Color(0xFF00E5FF).withValues(alpha: 0.2),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFF131C30),
                            border: Border.all(
                              color: _isOpened ? const Color(0xFFFFD600) : const Color(0xFF00E5FF),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF000000).withValues(alpha: 0.8),
                                offset: const Offset(0, 6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isOpened ? Icons.lock_open : Icons.lock,
                            size: 40,
                            color: _isOpened ? const Color(0xFFFFD600) : const Color(0xFF00E5FF),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            if (!_isOpened) ...[
              Text(
                'TAP THE 3D CRATE TO UNLOCK YOUR DAILY REWARDS!',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              NeonButton(
                text: 'OPEN 3D CRATE',
                icon: Icons.lock_open,
                width: 220,
                height: 46,
                primaryColor: const Color(0xFFFFD600),
                onPressed: _openCrate,
              ),
            ] else ...[
              Text(
                'REWARDS UNLOCKED!',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00E676),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF101B2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Color(0xFF00E676), size: 22),
                        const SizedBox(width: 6),
                        Text(
                          '+\$$_rewardCash',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF00E676),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFD600), size: 22),
                        const SizedBox(width: 6),
                        Text(
                          '+$_rewardRep REP',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFD600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              NeonButton(
                text: 'CLAIM & RETURN',
                icon: Icons.check,
                width: 220,
                height: 46,
                primaryColor: const Color(0xFF00E5FF),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
