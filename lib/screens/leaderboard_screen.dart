import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/neon_database_service.dart';
import '../widgets/common/app_background.dart';
import '../widgets/common/glass_container.dart';
import '../widgets/common/neon_button.dart';

/// Global Live Cloud Leaderboard Screen
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NeonDatabaseService _neonDb = NeonDatabaseService();
  final AuthService _authService = AuthService();

  List<UserProfile> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final data = await _neonDb.getGlobalLeaderboard(limit: 50);
      if (mounted) {
        setState(() {
          _leaderboard = data.isNotEmpty ? data : _getFallbackLeaderboard();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _leaderboard = _getFallbackLeaderboard();
          _isLoading = false;
        });
      }
    }
  }

  List<UserProfile> _getFallbackLeaderboard() {
    final now = DateTime.now();
    return [
      UserProfile(uid: 'p1', displayName: 'CyberPhantom_X', isGuest: false, eloRating: 2450, totalMultiplayerWins: 142, totalMultiplayerRaces: 160, trophies: 88, createdAt: now, lastActive: now),
      UserProfile(uid: 'p2', displayName: 'ApexOverlord', isGuest: false, eloRating: 2280, totalMultiplayerWins: 118, totalMultiplayerRaces: 135, trophies: 72, createdAt: now, lastActive: now),
      UserProfile(uid: 'p3', displayName: 'NeonViper99', isGuest: false, eloRating: 2110, totalMultiplayerWins: 94, totalMultiplayerRaces: 110, trophies: 60, createdAt: now, lastActive: now),
      UserProfile(uid: 'p4', displayName: 'NitroSpectre', isGuest: false, eloRating: 1980, totalMultiplayerWins: 76, totalMultiplayerRaces: 95, trophies: 45, createdAt: now, lastActive: now),
      UserProfile(uid: 'p5', displayName: 'StreetKing_07', isGuest: false, eloRating: 1850, totalMultiplayerWins: 62, totalMultiplayerRaces: 80, trophies: 38, createdAt: now, lastActive: now),
      UserProfile(uid: 'p6', displayName: 'TamilRacer45', isGuest: false, eloRating: 1720, totalMultiplayerWins: 48, totalMultiplayerRaces: 65, trophies: 29, createdAt: now, lastActive: now),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: AppBackground(
        overlayOpacity: 0.78,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00E5FF)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'GLOBAL LEADERBOARD',
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            shadows: const [
                              Shadow(color: Color(0xFF00E5FF), blurRadius: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF00E5FF)),
                      tooltip: 'Refresh Neon DB',
                      onPressed: _loadLeaderboard,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tab Bar
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xCC0D1424),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w900),
                    tabs: const [
                      Tab(text: 'RANKED ELO'),
                      Tab(text: 'TOTAL WINS'),
                      Tab(text: 'TROPHIES'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Leaderboard List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRankList((a, b) => b.eloRating.compareTo(a.eloRating), 'ELO', currentUid),
                            _buildRankList((a, b) => b.totalMultiplayerWins.compareTo(a.totalMultiplayerWins), 'WINS', currentUid),
                            _buildRankList((a, b) => b.trophies.compareTo(a.trophies), 'TROPHIES', currentUid),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankList(int Function(UserProfile, UserProfile) sorter, String metricLabel, String? currentUid) {
    final sorted = List<UserProfile>.from(_leaderboard)..sort(sorter);
    if (sorted.isEmpty) return const SizedBox.shrink();

    final top3 = sorted.take(3).toList();
    final remaining = sorted.skip(3).toList();

    return Column(
      children: [
        // 1. Top 3 Podium Showcase Stage
        if (top3.length >= 3)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0E1726).withValues(alpha: 0.90),
                  const Color(0xFF070B14).withValues(alpha: 0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.35)),
              boxShadow: const [
                BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2nd Place (Silver)
                _buildPodiumPillar(
                  racer: top3[1],
                  rank: 2,
                  height: 68,
                  pillarColor: const Color(0xFFB0BEC5),
                  isMe: top3[1].uid == currentUid,
                  metricLabel: metricLabel,
                ),
                // 1st Place (Gold)
                _buildPodiumPillar(
                  racer: top3[0],
                  rank: 1,
                  height: 90,
                  pillarColor: const Color(0xFFFFD600),
                  isMe: top3[0].uid == currentUid,
                  metricLabel: metricLabel,
                ),
                // 3rd Place (Bronze)
                _buildPodiumPillar(
                  racer: top3[2],
                  rank: 3,
                  height: 54,
                  pillarColor: const Color(0xFFCD7F32),
                  isMe: top3[2].uid == currentUid,
                  metricLabel: metricLabel,
                ),
              ],
            ),
          ),

        // 2. Remaining Ranks (4+)
        Expanded(
          child: ListView.separated(
            itemCount: remaining.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final racer = remaining[index];
              final rank = index + 4;
              final isMe = racer.uid == currentUid;

              String metricValue = '';
              if (metricLabel == 'ELO') metricValue = '${racer.eloRating} ELO';
              if (metricLabel == 'WINS') metricValue = '${racer.totalMultiplayerWins} W';
              if (metricLabel == 'TROPHIES') metricValue = '${racer.trophies} 🏆';

              return GlassContainer(
                borderRadius: 12.0,
                borderColor: isMe ? const Color(0xFF00E5FF) : Colors.white12,
                borderWidth: isMe ? 1.8 : 1.0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Rank Number
                    SizedBox(
                      width: 38,
                      child: Text(
                        '#$rank',
                        style: GoogleFonts.orbitron(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    // Avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1C2638),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Center(
                        child: Text(
                          racer.displayName.isNotEmpty ? racer.displayName.substring(0, 1).toUpperCase() : 'R',
                          style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white70),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Racer Name & Win Rate
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  racer.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isMe ? const Color(0xFF00E5FF) : Colors.white,
                                  ),
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
                                    style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.w900, color: const Color(0xFF00E5FF)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Win Rate: ${racer.winRate.toStringAsFixed(0)}% (${racer.totalMultiplayerWins}/${racer.totalMultiplayerRaces} Races)',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF90A4AE),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Metric Score Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131E33),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        metricValue,
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumPillar({
    required UserProfile racer,
    required int rank,
    required double height,
    required Color pillarColor,
    required bool isMe,
    required String metricLabel,
  }) {
    String metricValue = '';
    if (metricLabel == 'ELO') metricValue = '${racer.eloRating}';
    if (metricLabel == 'WINS') metricValue = '${racer.totalMultiplayerWins} W';
    if (metricLabel == 'TROPHIES') metricValue = '${racer.trophies} 🏆';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown / Rank Icon
        if (rank == 1)
          const Icon(Icons.emoji_events, color: Color(0xFFFFD600), size: 24)
        else
          Icon(Icons.military_tech, color: pillarColor, size: 20),
        const SizedBox(height: 2),

        // Avatar
        Container(
          width: rank == 1 ? 42 : 36,
          height: rank == 1 ? 42 : 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF162032),
            border: Border.all(color: pillarColor, width: rank == 1 ? 2.2 : 1.5),
            boxShadow: [
              BoxShadow(color: pillarColor.withValues(alpha: 0.4), blurRadius: 10),
            ],
          ),
          child: Center(
            child: Text(
              racer.displayName.isNotEmpty ? racer.displayName.substring(0, 1).toUpperCase() : 'R',
              style: GoogleFonts.orbitron(
                fontSize: rank == 1 ? 16 : 13,
                fontWeight: FontWeight.w900,
                color: pillarColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Name
        SizedBox(
          width: 90,
          child: Text(
            racer.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isMe ? const Color(0xFF00E5FF) : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Metric
        Text(
          metricValue,
          style: GoogleFonts.orbitron(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: pillarColor,
          ),
        ),
        const SizedBox(height: 6),

        // Pedestal Block
        Container(
          width: 76,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                pillarColor.withValues(alpha: 0.35),
                pillarColor.withValues(alpha: 0.10),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: pillarColor.withValues(alpha: 0.6)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: GoogleFonts.orbitron(
                fontSize: rank == 1 ? 18 : 14,
                fontWeight: FontWeight.w900,
                color: pillarColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
