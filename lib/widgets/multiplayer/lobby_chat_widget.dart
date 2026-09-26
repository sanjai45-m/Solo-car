import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/multiplayer_room.dart';
import '../../services/auth_service.dart';
import '../../services/haptic_service.dart';
import '../../services/multiplayer_service.dart';
import '../common/glass_container.dart';

class LobbyChatWidget extends StatefulWidget {
  const LobbyChatWidget({super.key});

  @override
  State<LobbyChatWidget> createState() => _LobbyChatWidgetState();
}

class _LobbyChatWidgetState extends State<LobbyChatWidget> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MultiplayerService _multiplayerService = MultiplayerService();
  final AuthService _authService = AuthService();

  final List<Map<String, String>> _quickEmotes = [
    {'text': "Let's Race!", 'icon': '🏎️'},
    {'text': "Nitro Ready!", 'icon': '🔥'},
    {'text': "Crown is Mine!", 'icon': '👑'},
    {'text': "Bring It On!", 'icon': '⚡'},
    {'text': "Eat My Dust!", 'icon': '💨'},
    {'text': "Shields Up!", 'icon': '🛡️'},
  ];

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final user = _authService.currentUser;
    if (user == null) return;

    _multiplayerService.sendChatMessage(
      text: text,
      senderUid: user.uid,
      senderName: user.displayName,
    );
    HapticService().buttonClick();
    _msgController.clear();
    _scrollToBottom();
  }

  void _sendEmote(String text, String icon) {
    final user = _authService.currentUser;
    if (user == null) return;

    _multiplayerService.sendQuickEmote(
      emoteText: text,
      emoteIcon: icon,
      senderUid: user.uid,
      senderName: user.displayName,
    );
    HapticService().buttonClick();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _multiplayerService,
      builder: (context, _) {
        final messages = _multiplayerService.chatHistory;
        final currentUid = _authService.currentUser?.uid;

        return GlassContainer(
          borderRadius: 14.0,
          backgroundColor: const Color(0xE6080E1A),
          borderColor: const Color(0xFF00E5FF).withValues(alpha: 0.35),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: Color(0xFF00E5FF), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'LOBBY CHAT & EMOTES',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF00E5FF),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${messages.length} msgs',
                    style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Chat Messages Stream
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0x66050914),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'Send a quick emote or chat to your rival...',
                          style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white38),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderUid == currentUid;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${isMe ? "YOU" : msg.senderName}: ',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isMe ? const Color(0xFF00E5FF) : const Color(0xFFFFD600),
                                  ),
                                ),
                                if (msg.isEmote) ...[
                                  Text(
                                    '${msg.emoteIcon ?? "⚡"} ${msg.message}',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF69F0AE),
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: Text(
                                      msg.message,
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),

              // Quick Emote Ribbon
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickEmotes.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => _sendEmote(e['text']!, e['icon']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131D30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(e['icon']!, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                e['text']!,
                                style: GoogleFonts.orbitron(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Text Input Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: TextField(
                        controller: _msgController,
                        style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type lobby message...',
                          hintStyle: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.black, size: 16),
                      padding: EdgeInsets.zero,
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
