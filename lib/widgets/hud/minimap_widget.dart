import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/apex_racing_game.dart';

class MinimapWidget extends StatelessWidget {
  final ApexRacingGame? game;

  const MinimapWidget({super.key, this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xCC090D16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cyber background grid
          Positioned.fill(
            child: CustomPaint(
              painter: _MinimapPainter(game: game),
            ),
          ),
          // Top Header Title
          Positioned(
            top: 5,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COURSE MAP',
                  style: GoogleFonts.orbitron(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF00E5FF),
                    letterSpacing: 1.0,
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  final ApexRacingGame? game;
  _MinimapPainter({this.game});

  @override
  void paint(Canvas canvas, Size size) {
    if (game == null || !game!.isInitialized) return;

    final player = game!.playerCar;
    final opponents = game!.opponents;
    final traffic = game!.trafficList;
    final roadMgr = game!.roadManager;
    final points = roadMgr.fullTrackPoints;

    if (points.isEmpty) return;

    // 1. Subtle Radar background grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.4)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), gridPaint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), gridPaint);

    // 2. Full Circuit Road Path
    final trackPath = Path();
    trackPath.moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (int i = 1; i < points.length; i++) {
      trackPath.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    trackPath.close();

    // 2a. Outer Neon Halo
    final haloPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawPath(trackPath, haloPaint);

    // 2b. Solid Asphalt Track Line
    final roadPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(trackPath, roadPaint);

    // 2c. Inner Bright Centerline
    final centerLinePaint = Paint()
      ..color = const Color(0xFF80DEEA).withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(trackPath, centerLinePaint);

    // 3. Start / Finish Line Marker
    final startPt = Offset(points.first.dx * size.width, points.first.dy * size.height);
    final finishPaint = Paint()
      ..color = const Color(0xFFFFD600)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;
    canvas.drawCircle(startPt, 3.5, finishPaint);

    // 4. Traffic Vehicles (Small Yellow-White dots)
    final trafficPaint = Paint()..color = const Color(0xFFFFE082);
    for (final t in traffic) {
      final pos = roadMgr.getMapPosition(t.trackZ);
      final tx = pos.dx * size.width;
      final ty = pos.dy * size.height;
      canvas.drawCircle(Offset(tx, ty), 1.8, trafficPaint);
    }

    // 5. Opponent Cars (Red-Orange Beacon Dots)
    final oppPaint = Paint()..color = const Color(0xFFFF1744);
    final oppGlow = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    for (final opp in opponents) {
      final pos = roadMgr.getMapPosition(opp.trackZ);
      final ox = pos.dx * size.width;
      final oy = pos.dy * size.height;
      canvas.drawCircle(Offset(ox, oy), 3.5, oppGlow);
      canvas.drawCircle(Offset(ox, oy), 2.5, oppPaint);
    }

    // 6. Player Beacon (Cyan Super-Beacon with Animated Outer Halo Ring)
    final playerPos = roadMgr.getMapPosition(player.trackZ);
    final px = playerPos.dx * size.width;
    final py = playerPos.dy * size.height;

    final playerHaloPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(px, py), 6.5, playerHaloPaint);

    final playerPaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(px, py), 3.8, playerPaint);
    canvas.drawCircle(Offset(px, py), 1.6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
