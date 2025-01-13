// lib/game_engine/timing_controller.dart
class TimingController {
  final Stopwatch _stopwatch = Stopwatch();
  Duration _targetDuration = Duration.zero;
  final List<Duration> _recentMeasurements = [];
  static const _maxMeasurements = 10;

  void start() {
    _stopwatch.start();
  }

  void stop() {
    _stopwatch.stop();
  }

  void reset() {
    _stopwatch.reset();
  }

  Duration getElapsedTime() {
    return _stopwatch.elapsed;
  }

  void recordMeasurement(Duration actual, Duration target) {
    _recentMeasurements.add(actual - target);
    if (_recentMeasurements.length > _maxMeasurements) {
      _recentMeasurements.removeAt(0);
    }
  }

  Duration getAverageLatency() {
    if (_recentMeasurements.isEmpty) return Duration.zero;
    final total = _recentMeasurements.fold(
      Duration.zero,
      (prev, curr) => prev + curr,
    );
    return Duration(
        microseconds: total.inMicroseconds ~/ _recentMeasurements.length);
  }

  void setTargetDuration(Duration duration) {
    _targetDuration = duration;
  }

  bool isTargetReached() {
    final compensatedTime = _stopwatch.elapsed - getAverageLatency();
    return compensatedTime >= _targetDuration;
  }
}
