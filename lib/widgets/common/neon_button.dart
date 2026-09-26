import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';

/// Modern AAA Racing Game Action Tile with dynamic light sweep, chamfered cuts, and micro-press physics
class NeonButton extends StatefulWidget {
  final String text;
  final String? subtitle;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final IconData? icon;
  final double? width;
  final double height;
  final double fontSize;
  final bool isSecondary;
  final EdgeInsetsGeometry? padding;

  const NeonButton({
    super.key,
    required this.text,
    this.subtitle,
    required this.onPressed,
    this.primaryColor = const Color(0xFF00E5FF),
    this.icon,
    this.width,
    this.height = 50,
    this.fontSize = 12,
    this.isSecondary = false,
    this.padding,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final color = enabled ? widget.primaryColor : const Color(0xFF546E7A);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _shimmerController.forward(from: 0.0);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTapDown: enabled
            ? (_) {
                setState(() => _isPressed = true);
                HapticService().buttonClick();
              }
            : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _isPressed = false);
                AudioService().playButtonClick();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: widget.width,
            height: widget.height,
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isSecondary
                    ? [
                        const Color(0xFF0D1524).withValues(alpha: 0.92),
                        const Color(0xFF070B12).withValues(alpha: 0.96),
                      ]
                    : [
                        color.withValues(alpha: _isHovered ? 0.28 : 0.16),
                        const Color(0xFF0A101C).withValues(alpha: 0.92),
                      ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovered
                    ? color
                    : (widget.isSecondary ? Colors.white12 : color.withValues(alpha: 0.45)),
                width: _isHovered ? 1.6 : 1.0,
              ),
              boxShadow: [
                if (enabled && _isHovered)
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Light Shimmer Sweep on hover
                if (_isHovered && enabled)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _ShimmerPainter(
                            progress: _shimmerController.value,
                            color: color,
                          ),
                        );
                      },
                    ),
                  ),

                Row(
                  mainAxisSize: widget.width == null ? MainAxisSize.min : MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Left Chamfered Accent Indicator Bar
                    Container(
                      width: 3.5,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _isHovered ? color : color.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: _isHovered
                            ? [BoxShadow(color: color, blurRadius: 8, spreadRadius: 1)]
                            : [],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Icon
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: _isHovered ? color : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                    ],

                    // Titles
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.text.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.orbitron(
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w900,
                              color: enabled ? Colors.white : Colors.white38,
                              letterSpacing: 1.2,
                              shadows: _isHovered
                                  ? [Shadow(color: color, blurRadius: 10)]
                                  : [],
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 1),
                            Text(
                              widget.subtitle!.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.rajdhani(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _isHovered ? color : const Color(0xFF90A4AE),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Right Arrow Chevrons
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _isHovered ? color : Colors.white24,
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final shimmerWidth = size.width * 0.4;
    final startX = -shimmerWidth + (size.width + shimmerWidth * 2) * progress;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(startX, 0, shimmerWidth, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) => true;
}
