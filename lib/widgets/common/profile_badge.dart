import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_profile.dart';

class ProfileBadge extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onTap;

  const ProfileBadge({
    super.key,
    required this.profile,
    required this.onTap,
  });

  @override
  State<ProfileBadge> createState() => _ProfileBadgeState();
}

class _ProfileBadgeState extends State<ProfileBadge> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final primaryColor = profile.isGuest
        ? const Color(0xFFFFB300)
        : const Color(0xFF00E5FF);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xDD0D1424),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withValues(alpha: _isHovered ? 1.0 : 0.75),
              width: 1.4,
            ),
            boxShadow: [
              // 3D Bottom Ledge Shadow
              BoxShadow(
                color: const Color(0xFF020408).withValues(alpha: 0.9),
                offset: const Offset(0, 3),
                blurRadius: 4,
              ),
              // Radiant Neon Glow
              BoxShadow(
                color: primaryColor.withValues(alpha: _isHovered ? 0.35 : 0.2),
                blurRadius: _isHovered ? 14 : 8,
                spreadRadius: _isHovered ? 1 : 0,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                const Color(0xEE0B1120),
                primaryColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar / Guest Icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  image: (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(profile.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                    ? Icon(
                        profile.isGuest ? Icons.person_outline : Icons.sports_motorsports,
                        size: 16,
                        color: Colors.black,
                      )
                    : null,
              ),
              const SizedBox(width: 8),

              // Name & Status / ELO
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.displayName,
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (profile.isGuest)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFFB300), width: 0.8),
                          ),
                          child: Text(
                            'GUEST',
                            style: GoogleFonts.orbitron(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFFB300),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF00E5FF), width: 0.8),
                          ),
                          child: Text(
                            'PRO',
                            style: GoogleFonts.orbitron(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    'ELO: ${profile.eloRating} • WINS: ${profile.totalMultiplayerWins}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF90CAF9),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
