import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';

/// Next-Gen AAA Cyber-Neumorphic 3D Action Button
/// Features convex metallic depth, dual specular highlights, extrusion drop shadows,
/// tactile press physics, shimmer sweep, and auto-scaled zero-truncation typography.
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
  final bool? showChevron;
  final bool? showIndicator;
  final MainAxisAlignment? contentAlignment;

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
    this.showChevron,
    this.showIndicator,
    this.contentAlignment,
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
    final color = enabled ? widget.primaryColor : const Color(0xFF455A64);
    final hasSubtitle = widget.subtitle != null && widget.subtitle!.isNotEmpty;
    final showChevron = widget.showChevron ?? hasSubtitle;
    final showIndicator = widget.showIndicator ?? hasSubtitle;
    final alignment = widget.contentAlignment ??
        (hasSubtitle ? MainAxisAlignment.start : MainAxisAlignment.center);

    return MouseRegion(
      onEnter: (_) {
        if (!enabled) return;
        setState(() => _isHovered = true);
        _shimmerController.forward(from: 0.0);
      },
      onExit: (_) {
        if (!enabled) return;
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
          scale: _isPressed ? 0.965 : (_isHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.width,
            height: widget.height,
            padding: widget.padding ??
                EdgeInsets.symmetric(
                  horizontal: widget.width != null && widget.width! < 130 ? 8 : 14,
                  vertical: 4,
                ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // Multi-tone Neumorphic 3D Surface Gradient (Consistent 3 Colors for AnimatedContainer lerp)
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: !enabled
                    ? const [
                        Color(0xFF181F2C),
                        Color(0xFF121722),
                        Color(0xFF0C1017),
                      ]
                    : _isPressed
                        ? [
                            const Color(0xFF080C14),
                            color.withValues(alpha: 0.14),
                            const Color(0xFF06090F),
                          ]
                        : widget.isSecondary
                            ? [
                                _isHovered
                                    ? const Color(0xFF1E2B42)
                                    : const Color(0xFF141C2B),
                                const Color(0xFF0E1522),
                                const Color(0xFF080D16),
                              ]
                            : [
                                _isHovered
                                    ? color.withValues(alpha: 0.40)
                                    : color.withValues(alpha: 0.22),
                                const Color(0xFF0D1422),
                                const Color(0xFF080C14),
                              ],
              ),
              // 3D Bevel Rim Border
              border: Border.all(
                color: !enabled
                    ? Colors.white10
                    : _isPressed
                        ? color.withValues(alpha: 0.8)
                        : _isHovered
                            ? color
                            : widget.isSecondary
                                ? color.withValues(alpha: 0.35)
                                : color.withValues(alpha: 0.65),
                width: _isHovered ? 1.6 : 1.2,
              ),
              // Deep Neumorphic 3D Dual Shadows
              boxShadow: [
                // Bottom-right dark extrusion shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isPressed ? 0.4 : 0.85),
                  offset: _isPressed ? const Offset(1, 2) : const Offset(3, 5),
                  blurRadius: _isPressed ? 4 : 10,
                  spreadRadius: 1,
                ),
                // Top-left specular 3D light reflection
                if (enabled)
                  BoxShadow(
                    color: _isHovered
                        ? color.withValues(alpha: 0.45)
                        : (widget.isSecondary
                            ? Colors.white.withValues(alpha: 0.08)
                            : color.withValues(alpha: 0.22)),
                    offset: _isPressed ? const Offset(0, 0) : const Offset(-2, -2),
                    blurRadius: _isHovered ? 10 : 5,
                    spreadRadius: 0,
                  ),
                // Ambient glow around the button
                if (enabled && _isHovered)
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  // Top Surface Specular Gloss Arc
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: widget.height * 0.45,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(
                              alpha: !enabled ? 0.03 : (_isHovered ? 0.20 : 0.10),
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Light Shimmer Sweep
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

                  // Content Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisSize: widget.width == null ? MainAxisSize.min : MainAxisSize.max,
                      mainAxisAlignment: alignment,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Glowing 3D Pill Bar
                        if (showIndicator) ...[
                          Container(
                            width: 3.5,
                            height: (widget.height * 0.48).clamp(16.0, 24.0),
                            decoration: BoxDecoration(
                              color: _isHovered ? color : color.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: _isHovered ? 0.8 : 0.4),
                                  blurRadius: _isHovered ? 8 : 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Leading Icon
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: !enabled
                                ? Colors.white30
                                : _isHovered
                                    ? color
                                    : (widget.isSecondary ? Colors.white70 : color),
                            size: (widget.fontSize + 5).clamp(14.0, 22.0),
                            shadows: enabled && _isHovered
                                ? [Shadow(color: color, blurRadius: 10)]
                                : [],
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Main Text & Optional Subtitle with Auto-Scaling (Never Truncates!)
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: hasSubtitle
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: hasSubtitle
                                    ? Alignment.centerLeft
                                    : Alignment.center,
                                child: Text(
                                  widget.text.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: widget.fontSize,
                                    fontWeight: FontWeight.w900,
                                    color: !enabled
                                        ? Colors.white38
                                        : Colors.white,
                                    letterSpacing: widget.width != null && widget.width! < 120
                                        ? 0.4
                                        : 1.0,
                                    shadows: enabled
                                        ? [
                                            const Shadow(
                                              color: Color(0xCC000000),
                                              offset: Offset(1, 2),
                                              blurRadius: 3,
                                            ),
                                            if (_isHovered)
                                              Shadow(
                                                color: color,
                                                blurRadius: 12,
                                              ),
                                          ]
                                        : [],
                                  ),
                                ),
                              ),
                              if (hasSubtitle) ...[
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.subtitle!.toUpperCase(),
                                    style: GoogleFonts.rajdhani(
                                      fontSize: (widget.fontSize * 0.78).clamp(9.0, 12.0),
                                      fontWeight: FontWeight.w700,
                                      color: _isHovered
                                          ? color
                                          : const Color(0xFFA0B2C6),
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Optional Right Chevron Arrow
                        if (showChevron) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: _isHovered ? color : Colors.white24,
                            size: (widget.fontSize * 0.85).clamp(10.0, 14.0),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
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

    final shimmerWidth = size.width * 0.45;
    final startX = -shimmerWidth + (size.width + shimmerWidth * 2) * progress;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.35),
          color.withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(startX, 0, shimmerWidth, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) => true;
}
