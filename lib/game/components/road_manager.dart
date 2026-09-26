import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/race_model.dart';
import 'road_segment.dart';
import 'roadside_prop.dart';

class RoadManager extends Component {
  final RaceTrack track;
  final double segmentLength = 200.0;
  final double roadWidth = 2000.0;
  final int drawDistance = 220; // Number of segments projected ahead into horizon

  final List<RoadSegment> segments = [];
  final List<Offset> fullTrackPoints = [];
  double trackLength = 0.0;

  RoadManager({required this.track}) {
    _buildTrack();
    preloadMap();
  }

  void preloadMap() {
    if (segments.isEmpty) {
      _buildTrack();
    }
    // Eagerly preheat segment spatial lookups across entire track
    for (double z = 0.0; z < trackLength; z += 500.0) {
      findSegment(z);
    }
  }

  Offset getMapPosition(double trackZ) {
    if (fullTrackPoints.isEmpty || trackLength <= 0) return const Offset(0.5, 0.5);
    final progress = (trackZ / trackLength) % 1.0;
    final clampedProg = progress < 0 ? progress + 1.0 : progress;
    final index = (clampedProg * (fullTrackPoints.length - 1)).floor().clamp(0, fullTrackPoints.length - 1);
    return fullTrackPoints[index];
  }

  void _buildTrack() {
    segments.clear();
    final totalSegments = (track.trackDistanceMeters * 5.0).toInt().clamp(600, 1600);

    // Procedural track construction
    int segmentIdx = 0;

    void addStraight(int numSegments) {
      for (int i = 0; i < numSegments; i++) {
        final z1 = segmentIdx * segmentLength;
        final z2 = (segmentIdx + 1) * segmentLength;
        final y1 = _getHeight(segmentIdx);
        final y2 = _getHeight(segmentIdx + 1);

        final seg = RoadSegment(
          index: segmentIdx,
          z1: z1,
          z2: z2,
          y1: y1,
          y2: y2,
          curve: 0.0,
          environment: track.environment,
          timeOfDay: track.timeOfDay,
          props: _createPropsForSegment(segmentIdx),
          isFinishLine: segmentIdx == 0 || segmentIdx == totalSegments - 1,
        );
        segments.add(seg);
        segmentIdx++;
      }
    }

    void addCurve(int numSegments, double curve) {
      for (int i = 0; i < numSegments; i++) {
        final z1 = segmentIdx * segmentLength;
        final z2 = (segmentIdx + 1) * segmentLength;
        final y1 = _getHeight(segmentIdx);
        final y2 = _getHeight(segmentIdx + 1);

        // Ease in / ease out curvature
        final progress = i / numSegments;
        final easeCurve = curve * math.sin(progress * math.pi);

        final seg = RoadSegment(
          index: segmentIdx,
          z1: z1,
          z2: z2,
          y1: y1,
          y2: y2,
          curve: easeCurve * track.baseCurveIntensity,
          environment: track.environment,
          timeOfDay: track.timeOfDay,
          props: _createPropsForSegment(segmentIdx),
        );
        segments.add(seg);
        segmentIdx++;
      }
    }

    // Build realistic racing track layout with 100% continuous smooth rolling elevation
    addStraight(40); // Starting straight
    addCurve(60, 2.0); // Gentle right climbing mountain
    addStraight(40); // Mountain crest straight
    addCurve(70, -2.8); // Winding descent left
    addStraight(40); // Valley floor
    addCurve(50, 2.5); // S-turn climb part 1
    addCurve(50, -2.5); // S-turn climb part 2
    addStraight(60); // High scenic ridge
    addCurve(80, 2.8); // Mountain descent hairpin
    addStraight(40);
    addCurve(60, -2.4);
    addStraight(50);

    // Fill remainder to reach totalSegments with continuous smooth curvature
    while (segmentIdx < totalSegments) {
      final rand = math.Random(segmentIdx * 31);
      final curve = (rand.nextBool() ? 1 : -1) * (1.2 + rand.nextDouble() * 1.8);
      addCurve(50, curve);
      addStraight(30);
    }

    trackLength = segments.length * segmentLength;
    _generateFullTrackMap();
  }

  void _generateFullTrackMap() {
    fullTrackPoints.clear();
    if (segments.isEmpty) return;

    double currentAngle = 0.0;
    double currentX = 0.0;
    double currentZ = 0.0;
    final rawPoints = <Offset>[];

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      currentAngle += seg.curve * 0.035;
      currentX += math.sin(currentAngle) * segmentLength;
      currentZ += math.cos(currentAngle) * segmentLength;
      rawPoints.add(Offset(currentX, currentZ));
    }

    // If circuit, smoothly blend loop closure
    if (track.mode == RaceMode.circuit && rawPoints.isNotEmpty) {
      final dx = rawPoints.last.dx;
      final dz = rawPoints.last.dy;
      final n = rawPoints.length;
      for (int i = 0; i < n; i++) {
        final ratio = i / (n - 1);
        final adjX = rawPoints[i].dx - (dx * ratio);
        final adjZ = rawPoints[i].dy - (dz * ratio);
        rawPoints[i] = Offset(adjX, adjZ);
      }
    }

    // Find bounding box to normalize into [0.10, 0.90]
    double minX = double.infinity;
    double maxX = -double.infinity;
    double minZ = double.infinity;
    double maxZ = -double.infinity;

    for (final p in rawPoints) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minZ) minZ = p.dy;
      if (p.dy > maxZ) maxZ = p.dy;
    }

    final spanX = (maxX - minX).abs() < 1.0 ? 1.0 : (maxX - minX);
    final spanZ = (maxZ - minZ).abs() < 1.0 ? 1.0 : (maxZ - minZ);
    final maxSpan = math.max(spanX, spanZ);

    for (final p in rawPoints) {
      final normX = 0.12 + ((p.dx - minX) / maxSpan) * 0.76;
      final normZ = 0.12 + ((p.dy - minZ) / maxSpan) * 0.76;
      fullTrackPoints.add(Offset(normX, normZ));
    }
  }

  // Pure continuous mathematical elevation - zero discontinuities, zero cliff jumps
  double _getHeight(int idx) {
    return math.sin(idx / 26.0) * 850.0 + math.sin(idx / 65.0) * 550.0;
  }

  List<RoadsideProp> _createPropsForSegment(int index) {
    final props = <RoadsideProp>[];
    final rand = math.Random(index * 7919);

    switch (track.environment) {
      case EnvironmentType.alpineForest:
        // Left side pine trees & rocks
        if (index % 2 == 0) {
          props.add(
            RoadsideProp(
              type: PropType.pineTree,
              sideOffset: -1.35 - (rand.nextDouble() * 0.9),
              baseHeight: 250 + rand.nextDouble() * 100,
              baseWidth: 150 + rand.nextDouble() * 50,
              primaryColor: const Color(0xFF1B5E20),
              secondaryColor: const Color(0xFF2E7D32),
            ),
          );
        }
        if (index % 3 == 1) {
          props.add(
            RoadsideProp(
              type: PropType.mountainRock,
              sideOffset: -1.45 - (rand.nextDouble() * 0.6),
              baseHeight: 90 + rand.nextDouble() * 60,
              baseWidth: 120 + rand.nextDouble() * 60,
              primaryColor: const Color(0xFF607D8B),
              secondaryColor: const Color(0xFF455A64),
            ),
          );
        }

        // Right side pine trees & rocks
        if (index % 2 == 1) {
          props.add(
            RoadsideProp(
              type: PropType.pineTree,
              sideOffset: 1.35 + (rand.nextDouble() * 0.9),
              baseHeight: 250 + rand.nextDouble() * 100,
              baseWidth: 150 + rand.nextDouble() * 50,
              primaryColor: const Color(0xFF1B5E20),
              secondaryColor: const Color(0xFF2E7D32),
            ),
          );
        }
        if (index % 4 == 2) {
          props.add(
            RoadsideProp(
              type: PropType.mountainRock,
              sideOffset: 1.45 + (rand.nextDouble() * 0.6),
              baseHeight: 90 + rand.nextDouble() * 60,
              baseWidth: 120 + rand.nextDouble() * 60,
              primaryColor: const Color(0xFF607D8B),
              secondaryColor: const Color(0xFF455A64),
            ),
          );
        }

        // Highway Light poles every 10 segments
        if (index % 10 == 0) {
          props.add(
            const RoadsideProp(
              type: PropType.streetLamp,
              sideOffset: -1.25,
              baseHeight: 200,
              baseWidth: 40,
              primaryColor: Color(0xFF9E9E9E),
              secondaryColor: Color(0xFFFFD54F),
            ),
          );
        }
        break;

      case EnvironmentType.neonCity:
        // Left Side: 3D Skyscrapers, Cyber Towers, Commercial complexes & Streetlights
        if (index % 2 == 0) {
          final isCyber = (index % 4 == 0);
          props.add(
            RoadsideProp(
              type: isCyber ? PropType.cyberTower : PropType.skyscraper,
              sideOffset: -1.9 - (rand.nextDouble() * 1.5),
              baseHeight: 350 + rand.nextDouble() * 300,
              baseWidth: 160 + rand.nextDouble() * 80,
              primaryColor: isCyber ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
              secondaryColor: isCyber ? const Color(0xFF00E5FF) : const Color(0xFFFF007F),
            ),
          );
        }
        if (index % 3 == 1) {
          props.add(
            RoadsideProp(
              type: PropType.commercialComplex,
              sideOffset: -1.6 - (rand.nextDouble() * 0.8),
              baseHeight: 180 + rand.nextDouble() * 80,
              baseWidth: 140 + rand.nextDouble() * 60,
              primaryColor: const Color(0xFF1E293B),
              secondaryColor: const Color(0xFF00E676),
            ),
          );
        }

        // Right Side: 3D Skyscrapers, Cyber Towers & Commercial Complexes
        if (index % 2 == 1) {
          final isCyber = (index % 5 == 1);
          props.add(
            RoadsideProp(
              type: isCyber ? PropType.cyberTower : PropType.skyscraper,
              sideOffset: 1.9 + (rand.nextDouble() * 1.5),
              baseHeight: 350 + rand.nextDouble() * 300,
              baseWidth: 160 + rand.nextDouble() * 80,
              primaryColor: isCyber ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
              secondaryColor: isCyber ? const Color(0xFF7C4DFF) : const Color(0xFFFFD600),
            ),
          );
        }
        if (index % 4 == 2) {
          props.add(
            const RoadsideProp(
              type: PropType.billboard,
              sideOffset: 1.55,
              baseHeight: 140,
              baseWidth: 130,
              primaryColor: Color(0xFFFF007F),
              secondaryColor: Color(0xFF00E5FF),
            ),
          );
        }

        // Streetlamps along inner edge
        if (index % 4 == 0) {
          props.add(
            const RoadsideProp(
              type: PropType.streetLamp,
              sideOffset: -1.25,
              baseHeight: 180,
              baseWidth: 35,
              primaryColor: Color(0xFF757575),
              secondaryColor: Color(0xFFFFD54F),
            ),
          );
          props.add(
            const RoadsideProp(
              type: PropType.streetLamp,
              sideOffset: 1.25,
              baseHeight: 180,
              baseWidth: 35,
              primaryColor: Color(0xFF757575),
              secondaryColor: Color(0xFFFFD54F),
            ),
          );
        }

        // Overhead Highway Gantry every 25 segments
        if (index % 25 == 0 && index > 0) {
          props.add(
            const RoadsideProp(
              type: PropType.overheadGantry,
              sideOffset: 0.0,
              baseHeight: 190,
              baseWidth: 40,
              primaryColor: Color(0xFF455A64),
              secondaryColor: Color(0xFF00E5FF),
            ),
          );
        }
        break;

      case EnvironmentType.coastalSunset:
        if (index % 3 == 0) {
          props.add(
            RoadsideProp(
              type: PropType.palmTree,
              sideOffset: -1.6 - rand.nextDouble() * 0.6,
              baseHeight: 220 + rand.nextDouble() * 60,
              baseWidth: 110,
              primaryColor: const Color(0xFF2E7D32),
              secondaryColor: const Color(0xFF5D4037),
            ),
          );
        }
        if (index % 4 == 1) {
          props.add(
            RoadsideProp(
              type: PropType.commercialComplex,
              sideOffset: -2.4 - rand.nextDouble() * 0.6,
              baseHeight: 160 + rand.nextDouble() * 60,
              baseWidth: 130,
              primaryColor: const Color(0xFF37474F),
              secondaryColor: const Color(0xFFFF9800),
            ),
          );
        }
        if (index % 2 == 0) {
          props.add(
            const RoadsideProp(
              type: PropType.barrier,
              sideOffset: 1.3,
              baseHeight: 45,
              baseWidth: 75,
              primaryColor: Color(0xFFECEFF1),
              secondaryColor: Color(0xFFFF9800),
            ),
          );
        }
        break;

      case EnvironmentType.desertCanyon:
        if (index % 4 == 0) {
          props.add(
            RoadsideProp(
              type: PropType.rockCactus,
              sideOffset: -1.5 - rand.nextDouble() * 0.8,
              baseHeight: 140 + rand.nextDouble() * 80,
              baseWidth: 60,
              primaryColor: const Color(0xFF388E3C),
              secondaryColor: const Color(0xFF8D6E63),
            ),
          );
        }
        if (index % 5 == 2) {
          props.add(
            RoadsideProp(
              type: PropType.mountainRock,
              sideOffset: 1.5 + rand.nextDouble() * 0.8,
              baseHeight: 130 + rand.nextDouble() * 70,
              baseWidth: 100,
              primaryColor: const Color(0xFF8D6E63),
              secondaryColor: const Color(0xFF5D4037),
            ),
          );
        }
        break;
    }
    return props;
  }

  RoadSegment findSegment(double positionZ) {
    if (segments.isEmpty) {
      return RoadSegment(
        index: 0,
        z1: 0,
        z2: segmentLength,
        y1: 0,
        y2: 0,
        curve: 0,
        environment: track.environment,
        timeOfDay: track.timeOfDay,
      );
    }
    final idx = ((positionZ / segmentLength).floor() % segments.length + segments.length) % segments.length;
    return segments[idx];
  }

  void render3D(
    Canvas canvas, {
    required Size screenSize,
    required double playerZ,
    required double playerX,
    required double cameraHeight,
    required double cameraDepth,
  }) {
    if (segments.isEmpty) return;

    final startSegment = findSegment(playerZ);
    final startIdx = startSegment.index;
    final percent = (playerZ % segmentLength) / segmentLength;

    final cameraX = playerX * roadWidth;
    final cameraZ = playerZ - (cameraDepth * segmentLength);
    // Smooth continuous camera elevation interpolated across segment
    final playerY = startSegment.p1.worldY + (startSegment.p2.worldY - startSegment.p1.worldY) * percent;
    final cameraY = cameraHeight + playerY;

    double dx = -(startSegment.curve * percent);
    double x = 0.0;

    // 1. First Pass: Project all visible segments ahead
    for (int n = 0; n < drawDistance; n++) {
      final segIdx = (startIdx + n) % segments.length;
      final segment = segments[segIdx];

      // Handle track loop worldZ wrap
      final loopedZ = segment.index < startIdx ? trackLength : 0.0;

      segment.p1.worldX = x;
      segment.p1.worldZ = (segment.index * segmentLength) + loopedZ;
      segment.p1.project(
        cameraX: cameraX,
        cameraY: cameraY,
        cameraZ: cameraZ,
        cameraDepth: cameraDepth,
        screenWidth: screenSize.width,
        screenHeight: screenSize.height,
        roadWidth: roadWidth,
      );

      segment.p2.worldX = x + dx;
      segment.p2.worldZ = ((segment.index + 1) * segmentLength) + loopedZ;
      segment.p2.project(
        cameraX: cameraX,
        cameraY: cameraY,
        cameraZ: cameraZ,
        cameraDepth: cameraDepth,
        screenWidth: screenSize.width,
        screenHeight: screenSize.height,
        roadWidth: roadWidth,
      );

      x += dx;
      dx += segment.curve;
    }

    // 2. Second Pass: Render Road Strips (Far to Near Painter's Algorithm)
    for (int n = drawDistance - 1; n >= 0; n--) {
      final segIdx = (startIdx + n) % segments.length;
      final segment = segments[segIdx];

      if (segment.p1.scale <= 0.0001 || segment.p2.scale <= 0.0001) continue;
      if (segment.p1.screenY > screenSize.height * 2.0) continue;

      segment.renderRoadStrip(canvas, screenSize);
    }

    // 3. Third Pass: Render Roadside Props & Scenery (Far to Near)
    for (int n = drawDistance - 1; n >= 0; n--) {
      final segIdx = (startIdx + n) % segments.length;
      final segment = segments[segIdx];

      if (segment.p1.scale <= 0.0001) continue;

      for (final prop in segment.props) {
        prop.render3D(
          canvas,
          screenX: segment.p1.screenX,
          screenY: segment.p1.screenY,
          scale: segment.p1.scale,
          roadWidthOnScreen: segment.p1.screenW,
          env: track.environment,
          timeOfDay: track.timeOfDay,
        );
      }
    }
  }
}
