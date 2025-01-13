// lib/game_engine/sync_manager.dart

import 'dart:async';

class DeviceSyncManager {
  final String deviceId;
  bool isMainDevice;
  final List<String> connectedDevices = [];
  final Duration _connectionTimeout = const Duration(seconds: 5);
  final Map<String, DateTime> _lastPingTimes = {};
  Timer? _healthCheckTimer;

  DeviceSyncManager({
    required this.deviceId,
    this.isMainDevice = false,
  });

  void addDevice(String deviceId) {
    if (!connectedDevices.contains(deviceId)) {
      connectedDevices.add(deviceId);
      _lastPingTimes[deviceId] = DateTime.now();
    }
  }

  void removeDevice(String deviceId) {
    connectedDevices.remove(deviceId);
    _lastPingTimes.remove(deviceId);
  }

  bool isConnected(String deviceId) {
    return connectedDevices.contains(deviceId);
  }

  void setMainDevice(bool isMain) {
    isMainDevice = isMain;
  }

  void startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final devicesToRemove = <String>[];

      for (var deviceId in connectedDevices) {
        final lastPing = _lastPingTimes[deviceId];
        if (lastPing != null && now.difference(lastPing) > _connectionTimeout) {
          devicesToRemove.add(deviceId);
        }
      }

      for (var deviceId in devicesToRemove) {
        removeDevice(deviceId);
      }
    });
  }

  void updatePing(String deviceId) {
    if (connectedDevices.contains(deviceId)) {
      _lastPingTimes[deviceId] = DateTime.now();
    }
  }

  void dispose() {
    _healthCheckTimer?.cancel();
    connectedDevices.clear();
    _lastPingTimes.clear();
  }
}
