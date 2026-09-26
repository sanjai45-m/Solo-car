import 'package:flutter/material.dart';
import '../../game/apex_racing_game.dart';

class MobileControlsOverlay extends StatelessWidget {
  final ApexRacingGame? game;

  const MobileControlsOverlay({super.key, this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left Side: Steering Controls
        Positioned(
          left: 20,
          bottom: 24,
          child: Row(
            children: [
              // Steer Left Button
              _ControlButton(
                icon: Icons.arrow_back_ios_new,
                size: 68,
                color: const Color(0xFF00E5FF),
                onPressStart: () {
                  if (game != null && game!.isInitialized) {
                    game!.playerCar.touchSteerAxis = -1.0;
                  }
                },
                onPressEnd: () {
                  if (game != null && game!.isInitialized) {
                    game!.playerCar.touchSteerAxis = 0.0;
                  }
                },
              ),
              const SizedBox(width: 16),
              // Steer Right Button
              _ControlButton(
                icon: Icons.arrow_forward_ios,
                size: 68,
                color: const Color(0xFF00E5FF),
                onPressStart: () {
                  if (game != null && game!.isInitialized) {
                    game!.playerCar.touchSteerAxis = 1.0;
                  }
                },
                onPressEnd: () {
                  if (game != null && game!.isInitialized) {
                    game!.playerCar.touchSteerAxis = 0.0;
                  }
                },
              ),
            ],
          ),
        ),

        // Right Side: Throttle, Brake, Nitro Controls
        Positioned(
          right: 20,
          bottom: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Nitro Button
              _ControlButton(
                icon: Icons.bolt,
                label: 'NOS',
                size: 60,
                color: const Color(0xFFFF007F),
                onPressStart: () {
                  if (game != null && game!.isInitialized) {
                    game!.playerCar.touchNitro = true;
                  }
                },
                onPressEnd: () {
                  if (game != null && game!.isInitialized) {
                    game!.playerCar.touchNitro = false;
                  }
                },
              ),
              const SizedBox(width: 14),
              // Brake / Handbrake Button
              _ControlButton(
                icon: Icons.pan_tool_alt,
                label: 'BRAKE',
                size: 64,
                color: const Color(0xFFFF1744),
                onPressStart: () {
                  if (game != null && game!.isInitialized) {
                    game!.playerCar.touchBrake = true;
                    game!.playerCar.touchHandbrake = true;
                  }
                },
                onPressEnd: () {
                  if (game != null && game!.isInitialized) {
                    game!.playerCar.touchBrake = false;
                    game!.playerCar.touchHandbrake = false;
                  }
                },
              ),
              const SizedBox(width: 14),
              // Gas / Accelerate Button
              _ControlButton(
                icon: Icons.speed,
                label: 'GAS',
                size: 76,
                color: const Color(0xFF00E676),
                onPressStart: () {
                  if (game != null && game!.isInitialized) {
                    game!.playerCar.touchAccelerate = true;
                  }
                },
                onPressEnd: () {
                  if (game != null && game!.isInitialized) {
                    game!.playerCar.touchAccelerate = false;
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String? label;
  final double size;
  final Color color;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;

  const _ControlButton({
    required this.icon,
    this.label,
    required this.size,
    required this.color,
    required this.onPressStart,
    required this.onPressEnd,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double depth = 5.0;
    final double yOffset = _isPressed ? depth : 0.0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onPressStart();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressEnd();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        widget.onPressEnd();
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size + depth,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // 3D Bottom Base Bevel
            Positioned(
              bottom: 0,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.25),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: _isPressed ? 0.8 : 0.35),
                      blurRadius: _isPressed ? 18 : 8,
                      spreadRadius: _isPressed ? 3 : 1,
                      offset: const Offset(0, 4),
                    ),
                    const BoxShadow(
                      color: Color(0x99000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

            // 3D Top Cap (Translates down when pressed)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOutCubic,
              top: yOffset,
              left: 0,
              right: 0,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isPressed
                        ? [
                            widget.color.withValues(alpha: 0.9),
                            widget.color.withValues(alpha: 0.6),
                          ]
                        : [
                            const Color(0xFF1E2838),
                            const Color(0xFF0C1322),
                          ],
                  ),
                  border: Border.all(
                    color: _isPressed ? Colors.white : widget.color.withValues(alpha: 0.7),
                    width: _isPressed ? 2.5 : 1.8,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: _isPressed ? Colors.black : widget.color,
                        size: widget.size * 0.42,
                        shadows: [
                          if (!_isPressed)
                            Shadow(
                              color: widget.color.withValues(alpha: 0.8),
                              blurRadius: 8,
                            ),
                        ],
                      ),
                      if (widget.label != null)
                        Text(
                          widget.label!,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: _isPressed ? Colors.black : widget.color,
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
    );
  }
}
