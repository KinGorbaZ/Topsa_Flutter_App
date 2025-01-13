// lib/game_engine/game_state.dart
import 'package:flutter/foundation.dart';

enum GameState { idle, preparing, running, paused, finished }

enum ExerciseType { reactionColor, reactionSound, movement }

class GameStateManager extends ChangeNotifier {
  GameState _currentState = GameState.idle;
  ExerciseType _exerciseType = ExerciseType.reactionColor;
  int _score = 0;
  Duration _reactionTime = Duration.zero;

  GameState get currentState => _currentState;
  ExerciseType get exerciseType => _exerciseType;
  int get score => _score;
  Duration get reactionTime => _reactionTime;

  bool _canTransitionTo(GameState newState) {
    switch (_currentState) {
      case GameState.idle:
        return newState == GameState.preparing;
      case GameState.preparing:
        return newState == GameState.running || newState == GameState.idle;
      case GameState.running:
        return newState == GameState.paused || newState == GameState.finished;
      case GameState.paused:
        return newState == GameState.running || newState == GameState.finished;
      case GameState.finished:
        return newState == GameState.idle;
    }
  }

  void setState(GameState newState) {
    if (!_canTransitionTo(newState)) {
      throw StateError(
          'Invalid state transition from $_currentState to $newState');
    }
    _currentState = newState;
    notifyListeners();
  }

  void setExerciseType(ExerciseType type) {
    _exerciseType = type;
    notifyListeners();
  }

  void updateScore(int points) {
    if (points < -100 || points > 100) {
      // Reasonable limits
      throw RangeError('Score update out of valid range');
    }
    _score += points;
    notifyListeners();
  }

  void setReactionTime(Duration time) {
    _reactionTime = time;
    notifyListeners();
  }

  void reset() {
    _currentState = GameState.idle;
    _score = 0;
    _reactionTime = Duration.zero;
    notifyListeners();
  }
}
