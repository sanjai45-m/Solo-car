import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/apex_racing_game.dart';
import '../models/car_model.dart';
import '../models/multiplayer_room.dart';
import '../models/race_model.dart';
import '../services/audio_service.dart';
import '../services/game_controller.dart';
import '../widgets/dialogs/pause_dialog.dart';
import '../widgets/dialogs/race_finish_dialog.dart';
import '../widgets/hud/racing_hud_overlay.dart';
import 'garage_screen.dart';

class RaceGameScreen extends StatefulWidget {
  final GameController gameController;
  final CarModel carModel;
  final RaceTrack track;
  final List<MultiplayerPlayerSlot>? multiplayerOpponents;

  const RaceGameScreen({
    super.key,
    required this.gameController,
    required this.carModel,
    required this.track,
    this.multiplayerOpponents,
  });

  @override
  State<RaceGameScreen> createState() => _RaceGameScreenState();
}

class _RaceGameScreenState extends State<RaceGameScreen> {
  late ApexRacingGame _game;
  bool _isPaused = false;
  bool _isFinished = false;

  int _finishPosition = 1;
  int _finishTimeMs = 0;
  int _earnedCash = 0;

  @override
  void initState() {
    super.initState();
    AudioService().playRaceMusic();
    _initGame();
  }

  @override
  void dispose() {
    AudioService().playMenuMusic();
    super.dispose();
  }

  void _initGame() {
    _isPaused = false;
    _isFinished = false;

    _game = ApexRacingGame(
      carModel: widget.carModel,
      track: widget.track,
      multiplayerOpponents: widget.multiplayerOpponents,
      onPauseRequest: _togglePause,
      onRaceFinish: (pos, timeMs, cash) {
        if (!mounted || _isFinished) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isFinished) {
            setState(() {
              _isFinished = true;
              _finishPosition = pos;
              _finishTimeMs = timeMs;
              _earnedCash = cash;
            });

            AudioService().playFinishCheer();
            widget.gameController.recordRaceResult(
              track: widget.track,
              finishPosition: pos,
              raceTimeMs: timeMs,
              earnedCash: cash,
              driftScore: _game.playerCar.driftScore.toInt(),
            );
          }
        });
      },
    );
  }

  void _togglePause() {
    if (_isFinished) return;
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _game.pauseEngine();
      } else {
        _game.resumeEngine();
      }
    });
  }

  void _restartRace() {
    setState(() {
      _initGame();
    });
  }

  void _nextRace() {
    final allTracks = RaceTrack.defaultTracks;
    final currentIdx = allTracks.indexWhere((t) => t.id == widget.track.id);
    if (currentIdx != -1 && currentIdx + 1 < allTracks.length) {
      final next = allTracks[currentIdx + 1];
      widget.gameController.selectTrack(next);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RaceGameScreen(
            gameController: widget.gameController,
            carModel: widget.gameController.currentCar,
            track: next,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Flame Game Engine Canvas
          GameWidget<ApexRacingGame>(
            game: _game,
          ),

          // 2. Active Racing HUD Overlay
          if (!_isFinished)
            RacingHudOverlay(
              game: _game,
              onPause: _togglePause,
            ),

          // 3. Pause Modal Dialog
          if (_isPaused && !_isFinished)
            PauseDialog(
              onResume: _togglePause,
              onRestart: _restartRace,
              onQuit: () => Navigator.pop(context),
            ),

          // 4. Race Finish / Victory Podium Dialog
          if (_isFinished)
            RaceFinishDialog(
              track: widget.track,
              finishPosition: _finishPosition,
              raceTimeMs: _finishTimeMs,
              earnedCash: _earnedCash,
              driftScore: _game.playerCar.driftScore,
              onNextRace: _nextRace,
              onRetry: _restartRace,
              onGarage: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GarageScreen(gameController: widget.gameController),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
