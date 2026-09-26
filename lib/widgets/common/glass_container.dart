import 'dart:ui';
import 'package:flutter/material.dart';

/// Solid 3D Cyberpunk Card with physical layered elevation, metallic bevels, and radiant rim illumination
class GlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final double blur;
  final double elevation3D;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.borderColor = const Color(0xFF00E5FF),
    this.borderWidth = 1.2,
    this.backgroundColor = const Color(0xDD0D1525),
    this.blur = 12.0,
    this.elevation3D = 6.0,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeBorder = widget.borderColor;
    final highlightBevel = HSLColor.fromColor(activeBorder)
        .withLightness((HSLColor.fromColor(activeBorder).lightness * 1.3).clamp(0.0, 1.0))
        .toColor();
    const darkShadow = Color(0xFF020408);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            // 1. Deep 3D Bottom Drop Shadow
            BoxShadow(
              color: darkShadow.withValues(alpha: 0.9),
              offset: Offset(0, widget.elevation3D),
              blurRadius: 18,
              spreadRadius: 2,
            ),
            // 2. Physical Bottom Ledge Shadow
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.7),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
            // 3. Radiant Ambient Neon Edge Glow
            BoxShadow(
              color: activeBorder.withValues(alpha: _isHovered ? 0.35 : 0.15),
              offset: Offset.zero,
              blurRadius: _isHovered ? 24 : 12,
              spreadRadius: _isHovered ? 1 : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                // Carbon / Glass Surface Gradient with top specular highlight
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.backgroundColor,
                    Color.lerp(widget.backgroundColor, Colors.black, 0.45)!,
                  ],
                ),
                border: Border.all(
                  color: _isHovered ? highlightBevel : activeBorder.withValues(alpha: 0.75),
                  width: widget.borderWidth,
                ),
              ),
              child: Stack(
                children: [
                  // Top Edge Specular Rim Sheen
                  Positioned(
                    top: 0,
                    left: 20,
                    right: 20,
                    height: 1.5,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            highlightBevel.withValues(alpha: _isHovered ? 0.8 : 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Child Content
                  widget.child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
