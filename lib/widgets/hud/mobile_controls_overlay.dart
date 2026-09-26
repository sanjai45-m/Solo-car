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
    final scale = _isPressed ? 0.92 : 1.0;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        transform: Matrix4.diagonal3Values(scale, scale, 1.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isPressed
              ? widget.color.withValues(alpha: 0.6)
              : const Color(0x990A0E17),
          border: Border.all(
            color: widget.color.withValues(alpha: _isPressed ? 1.0 : 0.6),
            width: 2,
          ),
          boxShadow: [
            if (_isPressed)
              BoxShadow(
                color: widget.color.withValues(alpha: 0.6),
                blurRadius: 16,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: _isPressed ? Colors.black : widget.color,
                size: widget.size * 0.42,
              ),
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: _isPressed ? Colors.black : widget.color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
