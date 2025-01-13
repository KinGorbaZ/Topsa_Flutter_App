// lib/core/monitoring/performance_monitor.dart

import 'dart:collection';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;

  PerformanceMonitor._internal();

  final _measurements = <String, Queue<_PerformanceMeasurement>>{};
  static const _maxMeasurements = 100;

  void recordOperation(String name, Duration duration) {
    _measurements.putIfAbsent(name, () => Queue<_PerformanceMeasurement>())
      ..addLast(_PerformanceMeasurement(duration));

    _cleanOldMeasurements(name);
  }

  Map<String, Duration> getAverages() {
    final averages = <String, Duration>{};

    _measurements.forEach((name, measurements) {
      if (measurements.isNotEmpty) {
        final total = measurements.fold<Duration>(
          Duration.zero,
          (sum, measurement) => sum + measurement.duration,
        );
        averages[name] = Duration(
          microseconds: total.inMicroseconds ~/ measurements.length,
        );
      }
    });

    return averages;
  }

  void _cleanOldMeasurements(String name) {
    final list = _measurements[name];
    if (list != null && list.length > _maxMeasurements) {
      list.removeFirst();
    }
  }

  void reset() {
    _measurements.clear();
  }
}

class _PerformanceMeasurement {
  final Duration duration;
  final DateTime timestamp;

  _PerformanceMeasurement(this.duration) : timestamp = DateTime.now();
}
