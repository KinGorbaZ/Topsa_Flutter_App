// lib/game_engine/event_system.dart

import 'dart:async';

/// Defines all possible game events
enum GameEvent {
  // Game flow events
  gameStart,
  gameStop,
  gamePause,
  gameResume,

  // Target events
  targetAppeared,
  targetHit,
  targetMissed,

  // Score events
  scoreUpdate,

  // System events
  error,

  // Multiplayer events
  playerJoined,
  playerLeft
}

/// Basic event data structure for adding extra information to events
class GameEventData {
  final GameEvent event;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  GameEventData({
    required this.event,
    this.data = const {},
  }) : timestamp = DateTime.now();
}

/// Manages game events and their distribution throughout the application
class GameEventSystem {
  // Broadcast stream controller for game events
  final _eventController = StreamController<GameEventData>.broadcast();

  // Event history for debugging and state recovery
  final List<GameEventData> _eventHistory = [];
  static const int _maxHistorySize = 100;

  // Public stream getter
  Stream<GameEventData> get eventStream => _eventController.stream;

  /// Emits an event with optional data
  void emitEvent(GameEvent event, [Map<String, dynamic> data = const {}]) {
    try {
      final eventData = GameEventData(
        event: event,
        data: data,
      );

      // Add to history
      _addToHistory(eventData);

      // Emit the event
      _eventController.add(eventData);
    } catch (e) {
      // If there's an error emitting the event, emit an error event
      final errorData = GameEventData(
        event: GameEvent.error,
        data: {'error': e.toString()},
      );
      _eventController.add(errorData);
    }
  }

  /// Adds event to history, maintaining maximum size
  void _addToHistory(GameEventData eventData) {
    _eventHistory.add(eventData);
    if (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeAt(0);
    }
  }

  /// Returns a list of recent events
  List<GameEventData> getRecentEvents() {
    return List.unmodifiable(_eventHistory);
  }

  /// Returns a stream of specific event types
  Stream<GameEventData> filterEvents(GameEvent eventType) {
    return eventStream.where((eventData) => eventData.event == eventType);
  }

  /// Cleans up resources
  void dispose() {
    _eventController.close();
    _eventHistory.clear();
  }
}
