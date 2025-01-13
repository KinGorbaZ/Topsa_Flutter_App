// lib/games/color_reaction_game.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameErrorHandler extends StatelessWidget {
  final Widget child;

  const GameErrorHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          // Return to menu after error
          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });

          return Material(
            child: Center(
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.yellow, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.error ?? 'Error',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Returning to menu...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          );
        };

        return child;
      },
    );
  }
}

enum GameEndCondition { time, score }

class GameSettings {
  List<Color> colors;
  GameEndCondition endCondition;
  int targetValue;

  GameSettings({
    required this.colors,
    required this.endCondition,
    required this.targetValue,
  });
}

class ColorReactionGame extends StatefulWidget {
  const ColorReactionGame({Key? key}) : super(key: key);

  @override
  State<ColorReactionGame> createState() => _ColorReactionGameState();
}

class _ColorReactionGameState extends State<ColorReactionGame> {
  bool _isPlaying = false;
  bool _showTarget = false;
  bool _isSettingUp = true;
  bool _isCountingDown = false;
  Color _currentColor = Colors.black;
  int _score = 0;
  int _countdown = 5;
  Timer? _gameTimer;
  Timer? _countdownTimer;
  Timer? _gameTimeTimer;
  int _elapsed = 0;
  String? _feedbackText;

  final Random _random = Random();
  late GameSettings _gameSettings;

  // Default colors
  final List<Color> _defaultColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    _gameSettings = GameSettings(
      colors: List.from(_defaultColors),
      endCondition: GameEndCondition.score,
      targetValue: 10,
    );
  }

  void _startCountdown() {
    setState(() {
      _isSettingUp = false;
      _isCountingDown = true;
      _countdown = 5;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _startGame();
      }
    });
  }

  void _startGame() {
    _gameTimer?.cancel();
    _gameTimeTimer?.cancel();

    setState(() {
      _isCountingDown = false;
      _isPlaying = true;
      _score = 0;
      _elapsed = 0;
      // Show first color immediately after countdown
      _showTarget = true;
      _currentColor =
          _gameSettings.colors[_random.nextInt(_gameSettings.colors.length)];
      _feedbackText = null;
    });

    if (_gameSettings.endCondition == GameEndCondition.time) {
      // Start timer that counts total game time
      _gameTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsed++;
          if (_elapsed >= _gameSettings.targetValue) {
            _endGame();
            timer.cancel();
          }
        });
      });

      // Schedule first black screen after initial color
      Future.delayed(const Duration(seconds: 2), () {
        if (_isPlaying) {
          _scheduleNextTarget();
        }
      });
    } else {
      // Schedule first black screen after initial color
      Future.delayed(const Duration(seconds: 2), () {
        if (_isPlaying) {
          _scheduleNextTarget();
        }
      });
    }
  }

  void _scheduleNextTarget() {
    _gameTimer?.cancel();

    if (!mounted || !_isPlaying) return;

    setState(() {
      _showTarget = false;
      _currentColor = Colors.black;
    });

    _gameTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showTarget = true;
          _currentColor = _gameSettings
              .colors[_random.nextInt(_gameSettings.colors.length)];
        });

        // Schedule next black screen
        Future.delayed(const Duration(seconds: 3), () {
          if (_isPlaying) {
            _scheduleNextTarget();
          }
        });
      }
    });
  }

  void _handleTap() {
    if (!_isPlaying) return;

    // Only handle taps for score mode
    if (_gameSettings.endCondition == GameEndCondition.score) {
      if (_showTarget) {
        setState(() {
          _score++;
          _feedbackText = AppLocalizations.of(context)!.hit;
          if (_score >= _gameSettings.targetValue) {
            _endGame();
            return;
          }
        });
        // Clear feedback text after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _feedbackText = null;
            });
          }
        });
        _scheduleNextTarget();
      } else {
        setState(() {
          _score = max(0, _score - 1);
          _feedbackText = AppLocalizations.of(context)!.miss;
        });
        // Clear feedback text after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _feedbackText = null;
            });
          }
        });
      }
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _gameTimeTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _showTarget = false;
      _currentColor = Colors.black;
    });
    _showGameResults();
  }

  void _showGameResults() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.gameOver),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Final Score: $_score'),
              if (_gameSettings.endCondition == GameEndCondition.time)
                Text('Time: $_elapsed seconds'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isSettingUp = true;
                  _initializeSettings();
                });
              },
              child: Text(l10n.playAgain),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorItem(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_gameSettings.colors.length > 1) {
            _gameSettings.colors.remove(color);
          }
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddColorButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Pick a color',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: Colors.primaries.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (!_gameSettings.colors.contains(color)) {
                                _gameSettings.colors.add(color);
                              }
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: Colors.blue, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.blue,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildSettingsScreen() {
    final orientation = MediaQuery.of(context).orientation;

    return SafeArea(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout(),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGameModeSection(),
        const SizedBox(height: 30),
        _buildColorSection(),
        const SizedBox(height: 40),
        _buildStartButton(),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildGameModeSection(),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildColorSection(),
              const SizedBox(height: 20),
              _buildStartButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameModeSection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            l10n.gameMode,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButton<GameEndCondition>(
            value: _gameSettings.endCondition,
            dropdownColor: Colors.white,
            items: GameEndCondition.values.map((GameEndCondition condition) {
              return DropdownMenuItem<GameEndCondition>(
                value: condition,
                child: Text(
                  condition == GameEndCondition.time
                      ? l10n.timeLimit
                      : l10n.scoreTarget,
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            onChanged: (GameEndCondition? newValue) {
              if (newValue != null) {
                setState(() {
                  _gameSettings.endCondition = newValue;
                  _gameSettings.targetValue =
                      newValue == GameEndCondition.time ? 30 : 10;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: _gameSettings.endCondition == GameEndCondition.time
                  ? l10n.timeLimitSeconds
                  : l10n.targetScore,
              labelStyle: const TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(color: Colors.black),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              int? newValue = int.tryParse(value);
              if (newValue != null && newValue > 0) {
                setState(() {
                  _gameSettings.targetValue = newValue;
                });
              }
            },
            controller: TextEditingController(
                text: _gameSettings.targetValue.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            l10n.gameColors,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            l10n.tapToRemove,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ..._gameSettings.colors.map((color) => _buildColorItem(color)),
              _buildAddColorButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    final l10n = AppLocalizations.of(context)!;

    return ElevatedButton(
      onPressed: _gameSettings.colors.isNotEmpty ? _startCountdown : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        backgroundColor: Colors.blue,
      ),
      child: Text(
        l10n.startGame,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _gameTimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenHeight * 0.4;

    return GameErrorHandler(
      child: Scaffold(
        body: GestureDetector(
          onTap: _handleTap,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _currentColor,
                ),
                child: Center(
                  child: _isSettingUp
                      ? _buildSettingsScreen()
                      : _isCountingDown
                          ? FittedBox(
                              fit: BoxFit.contain,
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  '$_countdown',
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                ),
              ),
              if (_feedbackText != null &&
                  _gameSettings.endCondition == GameEndCondition.score)
                Center(
                  child: Text(
                    _feedbackText!,
                    style: TextStyle(
                      fontSize: screenHeight * 0.15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(5.0, 5.0),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
