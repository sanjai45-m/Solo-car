import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/multiplayer_room.dart';
import '../services/auth_service.dart';
import '../services/game_controller.dart';
import '../services/multiplayer_service.dart';
import '../services/neon_database_service.dart';
import '../widgets/common/app_background.dart';
import '../widgets/common/neon_button.dart';
import '../widgets/dialogs/auth_dialog.dart';
import '../widgets/multiplayer/lobby_chat_widget.dart';
import 'race_game_screen.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  final GameController gameController;

  const MultiplayerLobbyScreen({super.key, required this.gameController});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final AuthService _authService = AuthService();
  final MultiplayerService _multiplayerService = MultiplayerService();
  final TextEditingController _roomCodeController = TextEditingController();

  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _multiplayerService.setCountdownLaunchCallback(_launchRace);
  }

  void _openAuthModal({VoidCallback? onSuccess}) {
    showDialog(
      context: context,
      builder: (_) => AuthDialog(
        onProfileChanged: () {
          setState(() {});
          if (_authService.currentUser != null && !_authService.currentUser!.isGuest) {
            onSuccess?.call();
          }
        },
      ),
    );
  }

  Future<void> _startQuickMatch() async {
    final user = _authService.currentUser;
    if (user == null || user.isGuest) {
      _openAuthModal(onSuccess: _startQuickMatch);
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    final currentCar = widget.gameController.currentCar;
    final track = widget.gameController.selectedTrack;

    await _multiplayerService.quickMatch(
      user: user,
      car: currentCar,
      trackId: track.id,
    );

    setState(() => _isSearching = false);
  }

  Future<void> _createPrivateLobby() async {
    final user = _authService.currentUser;
    if (user == null || user.isGuest) {
      _openAuthModal(onSuccess: _createPrivateLobby);
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    final currentCar = widget.gameController.currentCar;
    final track = widget.gameController.selectedTrack;

    final room = await _multiplayerService.createRoom(
      user: user,
      car: currentCar,
      trackId: track.id,
    );

    setState(() => _isSearching = false);
    if (mounted) {
      _showEmailInviteDialog(room.roomCode);
    }
  }

  Future<void> _joinWithCode() async {
    final code = _roomCodeController.text.trim();
    if (code.isEmpty) return;

    final user = _authService.currentUser;
    if (user == null || user.isGuest) {
      _openAuthModal(onSuccess: _joinWithCode);
      return;
    }

    final currentCar = widget.gameController.currentCar;
    final success = await _multiplayerService.joinRoom(
      roomCode: code,
      user: user,
      car: currentCar,
    );

    if (!success && mounted) {
      setState(() => _errorMessage = 'Room not found. Check the code.');
    }
  }

  void _copyLobbyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF00E5FF),
        content: Text(
          'LOBBY CODE #$code COPIED TO CLIPBOARD!',
          style: GoogleFonts.orbitron(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _sendInviteEmail(String recipientEmail, String code) async {
    final trackName = widget.gameController.selectedTrack.name;
    final senderName = _authService.currentUser?.displayName ?? 'Your Friend';
    final senderEmail = _authService.currentUser?.email;

    final emailText = 'Hey!\n\n'
        '$senderName has invited you to a live race in Apex Velocity!\n\n'
        '🏁 Circuit: $trackName\n'
        '🔑 Private Lobby Code: #$code\n\n'
        'To join the race:\n'
        '1. Open Apex Velocity.\n'
        '2. Go to Multiplayer Lobby.\n'
        '3. Enter Code #$code and click ENTER LOBBY!\n\n'
        'See you on the track!';

    // 1. Dispatch through Backend Mailer Service & Neon Cloud
    bool backendSent = false;
    if (recipientEmail.isNotEmpty) {
      try {
        backendSent = await NeonDatabaseService().sendEmailInvitation(
          recipientEmail: recipientEmail,
          lobbyCode: code,
          senderName: senderName,
          senderEmail: senderEmail,
          trackName: trackName,
        );
      } catch (_) {}
    }

    // 2. Also copy invite text and lobby code to clipboard for convenience
    Clipboard.setData(ClipboardData(text: emailText));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: backendSent ? const Color(0xFF00E676) : const Color(0xFF00E5FF),
          content: Text(
            backendSent
                ? 'INVITATION DISPATCHED VIA BACKEND TO $recipientEmail!'
                : 'INVITE SAVED & LOBBY CODE #$code COPIED TO CLIPBOARD!',
            style: GoogleFonts.orbitron(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showEmailInviteDialog(String code) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF090E1B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mark_email_read_outlined, color: Color(0xFF00E5FF), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'EMAIL LOBBY INVITE',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD600).withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LOBBY ROOM CODE', style: GoogleFonts.orbitron(fontSize: 9, color: Colors.white60)),
                        Text(
                          '#$code',
                          style: GoogleFonts.orbitron(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFD600),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy, size: 16, color: Colors.black),
                      label: Text('COPY', style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD600),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () => _copyLobbyCode(code),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter friend\'s email address to send them the invite code directly:',
                style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.orbitron(fontSize: 13, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'racer.friend@gmail.com',
                  hintStyle: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white38),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00E5FF)),
                  filled: true,
                  fillColor: const Color(0xFF131B2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                  label: Text(
                    'SEND INVITE EMAIL',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final email = emailController.text.trim();
                    Navigator.pop(ctx);
                    _sendInviteEmail(email, code);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchRace() {
    final room = _multiplayerService.currentRoom;
    if (room == null) return;

    final currentUid = _authService.currentUser?.uid;
    // Exclude current player to get only the opponent player(s) in this lobby (e.g. your invited friend)
    final opponents = room.players.where((p) => p.uid != currentUid).toList();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RaceGameScreen(
            gameController: widget.gameController,
            carModel: widget.gameController.currentCar,
            track: widget.gameController.selectedTrack,
            multiplayerOpponents: opponents,
          ),
        ),
      );
    }
  }

  void _triggerStartCountdown() {
    _multiplayerService.startCountdown(_launchRace);
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isGuest = user == null || user.isGuest;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            _multiplayerService.leaveRoom();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'MULTIPLAYER RACING',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF00E5FF),
            letterSpacing: 1.4,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isGuest ? Icons.person_outline : Icons.account_circle,
              color: isGuest ? const Color(0xFFFFB300) : const Color(0xFF00E5FF),
              size: 28,
            ),
            onPressed: _openAuthModal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AppBackground(
        overlayOpacity: 0.82,
        child: isGuest ? _buildGuestLockedView() : _buildLobbyContent(),
      ),
    );
  }

  Widget _buildGuestLockedView() {
    return Center(
      child: Container(
        width: 480,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xDD090F1C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x2200E5FF),
              ),
              child: const Icon(Icons.sports_motorsports, size: 54, color: Color(0xFF00E5FF)),
            ),
            const SizedBox(height: 16),
            Text(
              'LIVE ONLINE MULTIPLAYER',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sign in with Google to challenge other live players, enter 1v1 and 4-player lobbies, and climb the Global ELO Leaderboard!',
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.flash_on, size: 24, color: Colors.black),
                label: Text(
                  'SIGN IN / AUTHENTICATE RACER',
                  style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.8),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 6,
                ),
                onPressed: _openAuthModal,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFB300),
                side: const BorderSide(color: Color(0xFFFFB300)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'BACK TO SINGLE PLAYER QUICK RACE',
                style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLobbyContent() {
    return AnimatedBuilder(
      animation: _multiplayerService,
      builder: (context, _) {
        final room = _multiplayerService.currentRoom;

        if (room != null) {
          return _buildActiveRoomView(room);
        }

        return _buildMatchmakingMenuView();
      },
    );
  }

  Widget _buildMatchmakingMenuView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Selected Car & Track Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xCC0D1424),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/app_logo_3d.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.gameController.currentCar.name,
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Track: ${widget.gameController.selectedTrack.name} • Top Speed: ${widget.gameController.currentCar.topSpeedKmH.toInt()} km/h',
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              color: const Color(0xFF80D8FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Matchmaking Buttons
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x33FF1744),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFF1744)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              if (_isSearching) ...[
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: Color(0xFF00E5FF)),
                const SizedBox(height: 16),
                Text(
                  'INITIALIZING LOBBY...',
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ] else ...[
                // 1. Quick Match CTA
                NeonButton(
                  width: double.infinity,
                  text: 'QUICK RACE (MATCH LIVE PLAYERS)',
                  icon: Icons.flash_on,
                  height: 52,
                  fontSize: 12,
                  primaryColor: const Color(0xFF00E5FF),
                  onPressed: _startQuickMatch,
                ),
                const SizedBox(height: 14),

                // 2. Create Private Lobby & Invite
                NeonButton(
                  width: double.infinity,
                  text: 'CREATE PRIVATE LOBBY & SEND EMAIL INVITE',
                  icon: Icons.email_outlined,
                  height: 52,
                  fontSize: 11,
                  isSecondary: true,
                  primaryColor: const Color(0xFFFFD600),
                  onPressed: _createPrivateLobby,
                ),
                const SizedBox(height: 20),

                // 3. Custom Room Code Section (Enter Lobby)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xE60D1525),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x3300E5FF), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x99000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENTER LOBBY WITH CODE',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Received a room code by email? Type the 4-digit code to enter the race:',
                        style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white60),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _roomCodeController,
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF00E5FF),
                                letterSpacing: 4.0,
                              ),
                              decoration: InputDecoration(
                                hintText: 'ENTER 4-DIGIT CODE',
                                hintStyle: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  color: Colors.white38,
                                  letterSpacing: 1.0,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF131B2E),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          NeonButton(
                            text: 'ENTER',
                            height: 46,
                            width: 110,
                            fontSize: 11,
                            primaryColor: const Color(0xFFFF007F),
                            onPressed: _joinWithCode,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveRoomView(MultiplayerRoom room) {
    final currentUid = _authService.currentUser?.uid;
    final isHost = room.hostUid == currentUid;
    final isCountdown = room.state == RoomState.countdown;
    final mySlot = room.players.firstWhere((p) => p.uid == currentUid, orElse: () => room.players.first);

    return Center(
      child: Container(
        width: 620,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xEE0A0F1D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCountdown ? const Color(0xFFFFD600) : const Color(0xFF00E5FF).withValues(alpha: 0.6),
            width: isCountdown ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isCountdown
                  ? const Color(0xFFFFD600).withValues(alpha: 0.3)
                  : const Color(0xFF00E5FF).withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Room Header & Code
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1v1 MULTIPLAYER LOBBY',
                      style: GoogleFonts.orbitron(fontSize: 10, color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          'CODE: #${room.roomCode}',
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFD600),
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Color(0xFFFFD600)),
                          tooltip: 'Copy Code',
                          onPressed: () => _copyLobbyCode(room.roomCode),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!isCountdown)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.mail_outline, size: 16, color: Colors.black),
                    label: Text(
                      'EMAIL INVITE',
                      style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showEmailInviteDialog(room.roomCode),
                  ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),

            // COUNTDOWN OVERLAY MODE (Both players stay on screen until count reaches 0)
            if (isCountdown) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1A120B), const Color(0xFF0D1B2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD600).withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      '🏁 1v1 HEAD-TO-HEAD DUEL STARTING',
                      style: GoogleFonts.orbitron(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD600),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${room.countdown > 0 ? room.countdown : "GO!"}',
                      style: GoogleFonts.orbitron(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: room.countdown == 1
                            ? const Color(0xFF00E676)
                            : (room.countdown == 2 ? const Color(0xFFFFD600) : const Color(0xFFFF5252)),
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFFD600).withValues(alpha: 0.8),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'SYNCHRONIZING START GRID FOR BOTH RACERS...',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Player Slots (2 Racers Only)
            ...room.players.map((p) {
              final isMe = p.uid == currentUid;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF182238) : const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isMe
                        ? const Color(0xFF00E5FF)
                        : (p.isHost ? const Color(0xFFFF007F) : Colors.white24),
                    width: isMe ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      p.isHost ? Icons.military_tech : Icons.person,
                      color: p.isHost ? const Color(0xFFFF007F) : const Color(0xFF00E5FF),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                p.displayName,
                                style: GoogleFonts.orbitron(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'YOU',
                                    style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            p.isHost ? 'HOST RACER' : 'CHALLENGER',
                            style: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: p.carColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: p.isReady ? const Color(0x2200E676) : const Color(0x22FFAB00),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: p.isReady ? const Color(0xFF00E676) : const Color(0xFFFFAB00)),
                      ),
                      child: Text(
                        p.isReady ? 'READY' : 'WAITING',
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: p.isReady ? const Color(0xFF00E676) : const Color(0xFFFFAB00),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Live In-Lobby Text Chat & Quick Emotes Ribbon
            if (!isCountdown) ...[
              const LobbyChatWidget(),
              const SizedBox(height: 14),
            ],

            // Control Actions (Only shown when not in countdown)
            if (!isCountdown)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _multiplayerService.leaveRoom(),
                      child: Text('LEAVE LOBBY', style: GoogleFonts.orbitron(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isHost)
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mySlot.isReady ? const Color(0xFFFFAB00) : const Color(0xFF00E676),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (currentUid != null) {
                            _multiplayerService.togglePlayerReady(currentUid, onAutoLaunch: _launchRace);
                          }
                        },
                        child: Text(
                          mySlot.isReady ? 'NOT READY' : 'SET READY (1v1)',
                          style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _triggerStartCountdown,
                        child: Text(
                          room.players.length >= 2 ? 'START 1v1 DUEL' : 'START PRACTICE (WAITING)',
                          style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

