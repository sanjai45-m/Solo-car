import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/apex_racing_game.dart';
import '../../models/power_up_model.dart';
import 'drift_score_popup.dart';
import 'heat_level_badge.dart';
import 'minimap_widget.dart';
import 'mobile_controls_overlay.dart';
import 'nitro_gauge.dart';
import 'power_up_button.dart';
import 'race_position_badge.dart';
import 'tachometer_speedometer.dart';

class RacingHudOverlay extends StatefulWidget {
  final ApexRacingGame game;
  final VoidCallback onPause;

  const RacingHudOverlay({
    super.key,
    required this.game,
    required this.onPause,
  });

  @override
  State<RacingHudOverlay> createState() => _RacingHudOverlayState();
}

class _RacingHudOverlayState extends State<RacingHudOverlay> {
  int _position = 1;
  int _totalRacers = 6;
  double _speedKmH = 0.0;
  double _rpmRatio = 0.0;
  double _nitroPercent = 1.0;
  double _trackProgress = 0.0;
  int _currentLap = 1;
  int _totalLaps = 2;
  int _countdown = -1;
  String? _alertMessage;

  double _driftPoints = 0.0;
  double _driftMultiplier = 1.0;
  bool _isDrifting = false;

  PowerUpType? _currentPowerUp;
  int _heatLevel = 1;

  @override
  void initState() {
    super.initState();
    _bindGameEvents();
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    final phase = WidgetsBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(fn);
        }
      });
    } else {
      setState(fn);
    }
  }

  void _bindGameEvents() {
    widget.game.onPositionUpdate = (pos, total) {
      if (_position != pos || _totalRacers != total) {
        _safeSetState(() {
          _position = pos;
          _totalRacers = total;
        });
      }
    };

    widget.game.onSpeedUpdate = (speed, rpm) {
      if ((_speedKmH - speed).abs() >= 1.0 || (_rpmRatio - rpm).abs() >= 0.02) {
        _safeSetState(() {
          _speedKmH = speed;
          _rpmRatio = rpm;
        });
      }
    };

    widget.game.onNitroUpdate = (nitro) {
      if ((_nitroPercent - nitro).abs() >= 0.015) {
        _safeSetState(() => _nitroPercent = nitro);
      }
    };

    widget.game.onLapUpdate = (progress, lap, totalLaps) {
      if (_currentLap != lap || (_trackProgress - progress).abs() >= 0.005) {
        _safeSetState(() {
          _trackProgress = progress;
          _currentLap = lap;
          _totalLaps = totalLaps;
        });
      }
    };

    widget.game.onCountdown = (count) {
      _safeSetState(() => _countdown = count);
      if (count == 0) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (_countdown == 0) {
            _safeSetState(() => _countdown = -1);
          }
        });
      }
    };

    widget.game.onAlertMessage = (msg, bonus) {
      _safeSetState(() => _alertMessage = msg);
      Future.delayed(const Duration(milliseconds: 1600), () {
        _safeSetState(() => _alertMessage = null);
      });
    };

    widget.game.onDriftUpdate = (points, mult, drifting) {
      if (_isDrifting != drifting || (_driftPoints - points).abs() > 10 || _driftMultiplier != mult) {
        _safeSetState(() {
          _driftPoints = points;
          _driftMultiplier = mult;
          _isDrifting = drifting;
        });
      }
    };

    widget.game.onPowerUpUpdate = (powerUp) {
      _safeSetState(() => _currentPowerUp = powerUp);
    };

    widget.game.onHeatUpdate = (heat) {
      if (_heatLevel != heat) {
        _safeSetState(() => _heatLevel = heat);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Top Left: Race Position & Lap Counter
        Positioned(
          top: 16,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RacePositionBadge(
                position: _position,
                totalRacers: _totalRacers,
                currentLap: _currentLap,
                totalLaps: _totalLaps,
                trackProgress: _trackProgress,
              ),
              const SizedBox(height: 8),
              // Heat Level Badge
              HeatLevelBadge(heatLevel: _heatLevel),
            ],
          ),
        ),

        // 2. Top Right: Mini Radar & Pause Button
        Positioned(
          top: 16,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MinimapWidget(game: widget.game),
              const SizedBox(width: 12),
              // Pause Button
              IconButton(
                icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 38),
                onPressed: widget.onPause,
              ),
            ],
          ),
        ),

        // 3. Center Screen: Countdown / Alerts / Drift Combo Popups
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Countdown Display
              if (_countdown > 0)
                Text(
                  '$_countdown',
                  style: GoogleFonts.orbitron(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFD600),
                    shadows: [
                      const Shadow(
                        color: Color(0xFFFF6D00),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                )
              else if (_countdown == 0)
                Text(
                  'GO!',
                  style: GoogleFonts.orbitron(
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF00E676),
                    shadows: [
                      const Shadow(
                        color: Color(0xFF00E676),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                ),

              // Drift & Alert Message
              DriftScorePopup(
                driftPoints: _driftPoints,
                multiplier: _driftMultiplier,
                isDrifting: _isDrifting,
                alertMessage: _alertMessage,
              ),
            ],
          ),
        ),

        // 4. Combat Power-Up Trigger Button (Placed conveniently above touch brake or on right side)
        Positioned(
          right: 24,
          bottom: 110,
          child: PowerUpButton(
            powerUp: _currentPowerUp,
            onActivate: () {
              widget.game.activatePowerUp();
            },
          ),
        ),

        // 5. Bottom Center: Nitro Gauge & Speedometer
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  NitroGauge(nitroPercent: _nitroPercent),
                  const SizedBox(width: 16),
                  TachometerSpeedometer(
                    speedKmH: _speedKmH,
                    rpmRatio: _rpmRatio,
                  ),
                ],
              ),
            ),
          ),
        ),

        // 6. Mobile Touch Controls (Always available on screen)
        MobileControlsOverlay(game: widget.game),
      ],
    );
  }
}
