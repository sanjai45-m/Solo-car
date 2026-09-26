import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/power_up_model.dart';

/// Interactive 3D HUD Power-Up Trigger Button
class PowerUpButton extends StatelessWidget {
  final PowerUpType? powerUp;
  final VoidCallback onActivate;

  const PowerUpButton({
    super.key,
    required this.powerUp,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final hasItem = powerUp != null;
    final itemColor = powerUp?.primaryColor ?? const Color(0xFF546E7A);

    return GestureDetector(
      onTap: hasItem ? onActivate : null,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: const Color(0xE6070B14),
          shape: BoxShape.circle,
          border: Border.all(
            color: hasItem ? itemColor : Colors.white24,
            width: hasItem ? 2.5 : 1.2,
          ),
          boxShadow: hasItem
              ? [
                  BoxShadow(
                    color: itemColor.withValues(alpha: 0.5),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              powerUp?.icon ?? Icons.lock_outline,
              color: hasItem ? itemColor : Colors.white38,
              size: 28,
            ),
            const SizedBox(height: 2),
            Text(
              hasItem ? powerUp!.displayName.split(' ').first : 'EMPTY',
              style: GoogleFonts.orbitron(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: hasItem ? Colors.white : Colors.white38,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
