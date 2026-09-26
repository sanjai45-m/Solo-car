import 'package:flutter/material.dart';
import '../../models/race_model.dart';
import 'roadside_prop.dart';

class ProjectedPoint {
  double worldX = 0;
  double worldY = 0;
  double worldZ = 0;

  double screenX = 0;
  double screenY = 0;
  double screenW = 0;
  double scale = 0;

  void project({
    required double cameraX,
    required double cameraY,
    required double cameraZ,
    required double cameraDepth,
    required double screenWidth,
    required double screenHeight,
    required double roadWidth,
  }) {
    final relZ = worldZ - cameraZ;
    if (relZ <= 0.1) {
      scale = 0;
      screenX = screenWidth / 2;
      screenY = screenHeight * 1.5;
      screenW = 0;
      return;
    }

    scale = cameraDepth / relZ;
    screenX = (screenWidth / 2) + (scale * (worldX - cameraX) * (screenWidth / 2));
    // Horizon at 40% of screen height for dramatic hill-climb perspective
    screenY = (screenHeight * 0.40) - (scale * (worldY - cameraY) * (screenHeight / 2));
    screenW = scale * roadWidth * (screenWidth / 2);
  }
}

class RoadSegment {
  final int index;
  final ProjectedPoint p1 = ProjectedPoint();
  final ProjectedPoint p2 = ProjectedPoint();

  double curve;
  double clip = 0.0;
  final EnvironmentType environment;
  final TimeOfDayType timeOfDay;
  final List<RoadsideProp> props;
  final bool isFinishLine;
  final bool isCheckpoint;

  RoadSegment({
    required this.index,
    required double z1,
    required double z2,
    required double y1,
    required double y2,
    required this.curve,
    required this.environment,
    required this.timeOfDay,
    this.props = const [],
    this.isFinishLine = false,
    this.isCheckpoint = false,
  }) {
    p1.worldZ = z1;
    p1.worldY = y1;
    p2.worldZ = z2;
    p2.worldY = y2;
  }

  void renderRoadStrip(Canvas canvas, Size screenSize) {
    // If segment is occluded behind a hill crest or invalid, skip
    if (p1.screenY <= p2.screenY) return;

    final isAlternate = (index % 6 < 3);

    // 1. Clear Textured Asphalt
    _renderAsphalt(canvas, isAlternate);

    // 2. 3D Elevated Red & White Curb Barriers with Concrete Sidewalls
    _render3DElevatedCurbs(canvas, isAlternate);

    // 3. Double Yellow Center Line (Solid)
    _renderDoubleYellowCenterLine(canvas);

    // 4. White Dashed Lane Dividers
    _renderLaneDividers(canvas, isAlternate);

    // 5. Finish Line
    if (isFinishLine) {
      _renderFinishBanner(canvas);
    }
  }

  void _renderAsphalt(Canvas canvas, bool isAlternate) {
    // Clean, crisp medium-dark highway asphalt
    final asphaltColor = isAlternate ? const Color(0xFF4E545E) : const Color(0xFF454B55);

    final path = Path()
      ..moveTo(p1.screenX - p1.screenW, p1.screenY)
      ..lineTo(p1.screenX + p1.screenW, p1.screenY)
      ..lineTo(p2.screenX + p2.screenW, p2.screenY)
      ..lineTo(p2.screenX - p2.screenW, p2.screenY)
      ..close();

    canvas.drawPath(path, Paint()..color = asphaltColor);
  }

  void _render3DElevatedCurbs(Canvas canvas, bool isAlternate) {
    final curbColor = isAlternate ? const Color(0xFFD32F2F) : const Color(0xFFFFFFFF);
    final curbW1 = p1.screenW * 0.10;
    final curbW2 = p2.screenW * 0.10;
    final curbH1 = p1.scale * 120.0;
    final curbH2 = p2.scale * 120.0;

    final topPaint = Paint()..color = curbColor;
    final sidePaint = Paint()..color = const Color(0xFFB0BEC5);

    // Left Curb Top Face
    final leftTop = Path()
      ..moveTo(p1.screenX - p1.screenW - curbW1, p1.screenY - curbH1)
      ..lineTo(p1.screenX - p1.screenW, p1.screenY - curbH1)
      ..lineTo(p2.screenX - p2.screenW, p2.screenY - curbH2)
      ..lineTo(p2.screenX - p2.screenW - curbW2, p2.screenY - curbH2)
      ..close();
    canvas.drawPath(leftTop, topPaint);

    // Left Curb Side Face (Vertical Concrete Wall)
    final leftSide = Path()
      ..moveTo(p1.screenX - p1.screenW, p1.screenY - curbH1)
      ..lineTo(p1.screenX - p1.screenW, p1.screenY)
      ..lineTo(p2.screenX - p2.screenW, p2.screenY)
      ..lineTo(p2.screenX - p2.screenW, p2.screenY - curbH2)
      ..close();
    canvas.drawPath(leftSide, sidePaint);

    // Right Curb Top Face
    final rightTop = Path()
      ..moveTo(p1.screenX + p1.screenW, p1.screenY - curbH1)
      ..lineTo(p1.screenX + p1.screenW + curbW1, p1.screenY - curbH1)
      ..lineTo(p2.screenX + p2.screenW + curbW2, p2.screenY - curbH2)
      ..lineTo(p2.screenX + p2.screenW, p2.screenY - curbH2)
      ..close();
    canvas.drawPath(rightTop, topPaint);

    // Right Curb Side Face (Vertical Concrete Wall)
    final rightSide = Path()
      ..moveTo(p1.screenX + p1.screenW, p1.screenY - curbH1)
      ..lineTo(p1.screenX + p1.screenW, p1.screenY)
      ..lineTo(p2.screenX + p2.screenW, p2.screenY)
      ..lineTo(p2.screenX + p2.screenW, p2.screenY - curbH2)
      ..close();
    canvas.drawPath(rightSide, sidePaint);
  }

  void _renderDoubleYellowCenterLine(Canvas canvas) {
    // Bright Double Yellow Centerlines (Matching Image 2)
    final yellowPaint = Paint()..color = const Color(0xFFFFD600);

    final lineW1 = p1.screenW * 0.015;
    final lineW2 = p2.screenW * 0.015;
    final gap1 = p1.screenW * 0.020;
    final gap2 = p2.screenW * 0.020;

    // Left Yellow Line
    final leftYPath = Path()
      ..moveTo(p1.screenX - gap1 - lineW1, p1.screenY)
      ..lineTo(p1.screenX - gap1, p1.screenY)
      ..lineTo(p2.screenX - gap2, p2.screenY)
      ..lineTo(p2.screenX - gap2 - lineW2, p2.screenY)
      ..close();
    canvas.drawPath(leftYPath, yellowPaint);

    // Right Yellow Line
    final rightYPath = Path()
      ..moveTo(p1.screenX + gap1, p1.screenY)
      ..lineTo(p1.screenX + gap1 + lineW1, p1.screenY)
      ..lineTo(p2.screenX + gap2 + lineW2, p2.screenY)
      ..lineTo(p2.screenX + gap2, p2.screenY)
      ..close();
    canvas.drawPath(rightYPath, yellowPaint);
  }

  void _renderLaneDividers(Canvas canvas, bool isAlternate) {
    if (!isAlternate) return; // Dashed lines alternate

    final whitePaint = Paint()..color = const Color(0xFFECEFF1);
    const laneOffset = 0.50; // White dashed lines in the middle of left & right carriageway

    final w1 = p1.screenW * 0.018;
    final w2 = p2.screenW * 0.018;

    // Left Carriage Lane Dash
    final xL1 = p1.screenX - (p1.screenW * laneOffset);
    final xL2 = p2.screenX - (p2.screenW * laneOffset);
    final dashL = Path()
      ..moveTo(xL1 - w1, p1.screenY)
      ..lineTo(xL1 + w1, p1.screenY)
      ..lineTo(xL2 + w2, p2.screenY)
      ..lineTo(xL2 - w2, p2.screenY)
      ..close();
    canvas.drawPath(dashL, whitePaint);

    // Right Carriage Lane Dash
    final xR1 = p1.screenX + (p1.screenW * laneOffset);
    final xR2 = p2.screenX + (p2.screenW * laneOffset);
    final dashR = Path()
      ..moveTo(xR1 - w1, p1.screenY)
      ..lineTo(xR1 + w1, p1.screenY)
      ..lineTo(xR2 + w2, p2.screenY)
      ..lineTo(xR2 - w2, p2.screenY)
      ..close();
    canvas.drawPath(dashR, whitePaint);
  }

  void _renderFinishBanner(Canvas canvas) {
    final path = Path()
      ..moveTo(p1.screenX - p1.screenW, p1.screenY)
      ..lineTo(p1.screenX + p1.screenW, p1.screenY)
      ..lineTo(p2.screenX + p2.screenW, p2.screenY)
      ..lineTo(p2.screenX - p2.screenW, p2.screenY)
      ..close();

    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12);
    canvas.drawPath(path, glowPaint);
  }
}
