import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/audio_service.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final IconData? icon;
  final double width;
  final double height;
  final double fontSize;
  final bool isSecondary;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.primaryColor = const Color(0xFF00E5FF),
    this.icon,
    this.width = 180,
    this.height = 48,
    this.fontSize = 15,
    this.isSecondary = false,
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
    final activeColor = enabled ? widget.primaryColor : const Color(0xFF616161);
    final scale = _isPressed ? 0.96 : (_isHovered ? 1.03 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          AudioService().playButtonClick();
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          height: widget.height,
          transform: Matrix4.diagonal3Values(scale, scale, 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: widget.isSecondary
                ? LinearGradient(
                    colors: [
                      activeColor.withValues(alpha: 0.15),
                      activeColor.withValues(alpha: 0.05),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      activeColor,
                      activeColor.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border.all(
              color: activeColor.withValues(alpha: _isHovered ? 1.0 : 0.7),
              width: widget.isSecondary ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (enabled && (_isHovered || !widget.isSecondary))
                BoxShadow(
                  color: activeColor.withValues(alpha: _isHovered ? 0.5 : 0.3),
                  blurRadius: _isHovered ? 16 : 8,
                  spreadRadius: _isHovered ? 1 : -1,
                ),
            ],
          ),
          child: Row(
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
              Text(
                widget.text.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: widget.isSecondary ? activeColor : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
