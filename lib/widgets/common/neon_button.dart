import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/audio_service.dart';

/// Tactile 3D Cyberpunk Button with physical extrusion depth and micro-press mechanics
class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final IconData? icon;
  final double? width;
  final double height;
  final double fontSize;
  final bool isSecondary;
  final double depth3D;
  final EdgeInsetsGeometry? padding;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.primaryColor = const Color(0xFF00E5FF),
    this.icon,
    this.width,
    this.height = 48,
    this.fontSize = 13,
    this.isSecondary = false,
    this.depth3D = 4.0,
    this.padding,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final activeColor = enabled ? widget.primaryColor : const Color(0xFF424242);
    final darkBevelColor = HSLColor.fromColor(activeColor)
        .withLightness((HSLColor.fromColor(activeColor).lightness * 0.45).clamp(0.0, 1.0))
        .toColor();
    final highlightColor = HSLColor.fromColor(activeColor)
        .withLightness((HSLColor.fromColor(activeColor).lightness * 1.35).clamp(0.0, 1.0))
        .toColor();

    final pressOffset = _isPressed ? (widget.depth3D - 1.0) : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _isPressed = false);
                AudioService().playButtonClick();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
        child: SizedBox(
          width: widget.width,
          height: widget.height + widget.depth3D,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. 3D Bottom Extrusion Shadow & Bevel Base
              Positioned(
                top: widget.depth3D,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.isSecondary
                        ? darkBevelColor.withValues(alpha: 0.3)
                        : darkBevelColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (enabled)
                        BoxShadow(
                          color: activeColor.withValues(alpha: _isHovered ? 0.45 : 0.25),
                          blurRadius: _isHovered ? 16 : 8,
                          offset: Offset(0, _isHovered ? 5 : 3),
                          spreadRadius: _isHovered ? 1 : 0,
                        ),
                    ],
                  ),
                ),
              ),

              // 2. Physical 3D Top Cap (Translates downward on press)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 60),
                curve: Curves.easeOutQuad,
                top: pressOffset,
                left: 0,
                right: 0,
                height: widget.height,
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: widget.isSecondary
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              activeColor.withValues(alpha: _isHovered ? 0.25 : 0.15),
                              activeColor.withValues(alpha: 0.05),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              highlightColor,
                              activeColor,
                              HSLColor.fromColor(activeColor)
                                  .withLightness((HSLColor.fromColor(activeColor).lightness * 0.85).clamp(0.0, 1.0))
                                  .toColor(),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                    border: Border.all(
                      color: widget.isSecondary
                          ? activeColor.withValues(alpha: _isHovered ? 1.0 : 0.6)
                          : highlightColor.withValues(alpha: 0.9),
                      width: widget.isSecondary ? 1.5 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: widget.isSecondary ? 0.1 : 0.4),
                        offset: const Offset(0, 1.5),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.isSecondary ? activeColor : Colors.black,
                            size: widget.fontSize + 4,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.text.toUpperCase(),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.orbitron(
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: widget.isSecondary ? activeColor : Colors.black,
                              shadows: [
                                if (!widget.isSecondary)
                                  Shadow(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    blurRadius: 2,
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
      ),
    );
  }
}
