import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeatLevelBadge extends StatefulWidget {
  final int heatLevel;

  const HeatLevelBadge({super.key, required this.heatLevel});

  @override
  State<HeatLevelBadge> createState() => _HeatLevelBadgeState();
}

class _HeatLevelBadgeState extends State<HeatLevelBadge> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heat = widget.heatLevel.clamp(1, 5);
    final heatColor = heat >= 4
        ? const Color(0xFFFF1744)
        : (heat >= 2 ? const Color(0xFFFF9100) : const Color(0xFFFFEA00));

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = 6.0 + _pulseController.value * (heat * 3.0);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xDD0C101A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: heatColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: heatColor.withValues(alpha: 0.45),
                blurRadius: glow,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department, color: heatColor, size: 18),
              const SizedBox(width: 4),
              Text(
                'HEAT $heat',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 6),
              // Flame/Flame Bars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final active = index < heat;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 4,
                    height: 10.0 + index * 2.0,
                    decoration: BoxDecoration(
                      color: active ? heatColor : Colors.white12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
