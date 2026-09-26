import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';

class AuthDialog extends StatefulWidget {
  final VoidCallback onProfileChanged;

  const AuthDialog({super.key, required this.onProfileChanged});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  UserProfile get _profile => _authService.currentUser ?? UserProfile.guest();

  @override
  void initState() {
    super.initState();
    if (!_profile.isGuest && _profile.email != null) {
      _emailController.text = _profile.email!;
      _nameController.text = _profile.displayName;
    } else {
      _emailController.text = 'sanjaim202@gmail.com';
      _nameController.text = 'SanjaiRacer';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.signInWithGoogle();
      widget.onProfileChanged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        final errStr = e.toString();
        String displayError = 'Google One-Tap notice: ';
        if (errStr.contains('People API')) {
          displayError += 'Google People API needs activation in Google Console. You can sign in below directly with your Gmail address!';
        } else if (errStr.contains('origin_mismatch')) {
          displayError += 'Web domain is securing OAuth. Enter your Google email below for instant cloud sync!';
        } else {
          displayError += 'Please enter your Google email below to sign in instantly with Neon Cloud DB!';
        }
        setState(() {
          _errorMessage = displayError;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleEmailSignIn() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid Google / Racer email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.signInWithEmail(
        email: email,
        displayName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      );
      widget.onProfileChanged();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage = '✅ Signed in as $email!';
        });
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Sign in error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGuestSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.signInAsGuest();
      widget.onProfileChanged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not switch to guest mode.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    await _authService.signOut();
    widget.onProfileChanged();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        width: 480,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF090D16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sports_motorsports, color: Color(0xFF00E5FF), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'RACER AUTHENTICATION',
                      style: GoogleFonts.orbitron(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF00E5FF),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Profile Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _profile.isGuest
                      ? const Color(0xFFFFB300).withValues(alpha: 0.4)
                      : const Color(0xFF00E5FF).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _profile.isGuest ? const Color(0xFFFFB300) : const Color(0xFF00E5FF),
                      image: (_profile.photoUrl != null && _profile.photoUrl!.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(_profile.photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (_profile.photoUrl == null || _profile.photoUrl!.isEmpty)
                        ? Icon(
                            _profile.isGuest ? Icons.person_outline : Icons.sports_motorsports,
                            size: 26,
                            color: Colors.black,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Name & Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _profile.displayName,
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _profile.isGuest
                                    ? const Color(0xFFFFB300).withValues(alpha: 0.2)
                                    : const Color(0xFF00E5FF).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _profile.isGuest
                                      ? const Color(0xFFFFB300)
                                      : const Color(0xFF00E5FF),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                _profile.isGuest ? 'GUEST' : 'RACER PRO',
                                style: GoogleFonts.orbitron(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: _profile.isGuest
                                      ? const Color(0xFFFFB300)
                                      : const Color(0xFF00E5FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _profile.email ?? 'Offline guest account',
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white60,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Stats Grid
            Row(
              children: [
                _buildStatTile('ELO RATING', '${_profile.eloRating}', const Color(0xFF00E5FF)),
                const SizedBox(width: 8),
                _buildStatTile('WINS', '${_profile.totalMultiplayerWins}', const Color(0xFF00E676)),
                const SizedBox(width: 8),
                _buildStatTile('WIN RATE', '${_profile.winRate.toStringAsFixed(0)}%', const Color(0xFFFFD600)),
              ],
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFFF5252), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.rajdhani(color: const Color(0xFFFF8A80), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (_successMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF00E676), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: GoogleFonts.rajdhani(color: const Color(0xFF69F0AE), fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action Section
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                ),
              )
            else if (_profile.isGuest) ...[
              // Google / Email Input Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1626),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flash_on, color: Color(0xFFFFD600), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'SIGN IN WITH GOOGLE / RACER EMAIL',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFFD600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFF131B2E),
                        hintText: 'Enter your Gmail (e.g. sanjaim202@gmail.com)',
                        hintStyle: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 12),
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF00E5FF), size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFF131B2E),
                        hintText: 'Racer Call-sign / Nickname (Optional)',
                        hintStyle: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 12),
                        prefixIcon: const Icon(Icons.badge, color: Color(0xFF00E5FF), size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login, size: 18, color: Colors.black),
                        label: Text(
                          'SIGN IN & SYNC CLOUD PROFILE',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 4,
                        ),
                        onPressed: _handleEmailSignIn,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // OR divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR', style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white38)),
                  ),
                  const Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 12),

              // Google OAuth One-Tap Popup Button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, size: 26, color: Color(0xFF4285F4)),
                  label: Text(
                    'ONE-TAP GOOGLE POPUP SIGN IN',
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4285F4), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: const Color(0xFF4285F4).withValues(alpha: 0.1),
                  ),
                  onPressed: _handleGoogleSignIn,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cloud profile saves your ELO rating, trophies, and enables 1v1 live multiplayer racing on both Web & Mobile.',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white54),
              ),
            ] else ...[
              // Already Logged in: Switch account or Sign out
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFB300),
                        side: const BorderSide(color: Color(0xFFFFB300)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _handleGuestSignIn,
                      child: Text(
                        'PLAY AS GUEST',
                        style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _handleSignOut,
                      child: Text(
                        'SIGN OUT',
                        style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStatTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1524),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
