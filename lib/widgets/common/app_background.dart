import 'package:flutter/material.dart';

/// Cinematic 3D Car Racing Background Wallpaper with dark cyberpunk overlay
class AppBackground extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;

  const AppBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. High-Resolution 3D Supercar Racing Artwork
        Image.asset(
          'assets/images/splash_art_3d.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF070B12),
          ),
        ),

        // 2. Dark Cyberpunk Atmospheric Tint & Vignette Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(7, 11, 20, overlayOpacity),
                Color.fromRGBO(3, 5, 10, (overlayOpacity + 0.12).clamp(0.0, 0.96)),
              ],
            ),
          ),
        ),

        // 3. Subtle Ambient Neon Glows
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF007F).withValues(alpha: 0.10),
            ),
          ),
        ),

        // 4. Foreground Screen Content
        child,
      ],
    );
  }
}
