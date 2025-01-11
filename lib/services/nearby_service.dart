// lib/services/nearby_service.dart
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class ConnectionStateUpdate {
  final String endpointId;
  final DeviceConnectionState state;

  ConnectionStateUpdate(this.endpointId, this.state);
}

class NearbyService {
  final Nearby _nearby = Nearby();
  static const String SERVICE_ID = "com.topsa.topsa_flutter_app";
  final Set<String> _connectedEndpoints = {};
  bool _isReconnecting = false;
  // Added connection tracking map
  final Map<String, DeviceConnectionState> _connectionStates = {};

  final StreamController<List<Discovery>> _devicesController =
      StreamController<List<Discovery>>.broadcast();
  final StreamController<ConnectionStateUpdate> _connectionStateController =
      StreamController<ConnectionStateUpdate>.broadcast();

  Stream<List<Discovery>> get deviceStream => _devicesController.stream;
  Stream<ConnectionStateUpdate> get connectionStateStream =>
      _connectionStateController.stream;

  final String userName;
  final List<Discovery> _discoveredDevices = [];
  bool _isMain = false;
  bool _isActive = false;

  NearbyService(this.userName);

  Future<bool> initialize() async {
    try {
      debugPrint('Checking permissions...');

      // Check and request required permissions
      if (!await _checkPermissions()) {
        debugPrint('Failed to get permissions');
        return false;
      }

      // Reset states
      _isMain = false;
      _isActive = false;
      _discoveredDevices.clear();
      _connectionStates.clear();

      return true;
    } catch (e) {
      debugPrint('Error initializing Nearby Service: $e');
      return false;
    }
  }

  Future<bool> _checkPermissions() async {
    try {
      // Location permissions
      var locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) {
        debugPrint('Location permission denied');
        return false;
      }

      // Check if location services are enabled
      if (!await _nearby.checkLocationEnabled()) {
        var locationEnabled = await _nearby.enableLocationServices();
        if (!locationEnabled) {
          debugPrint('Location services not enabled');
          return false;
        }
      }

      // Bluetooth permissions
      var bluetoothScan = await Permission.bluetoothScan.request();
      var bluetoothConnect = await Permission.bluetoothConnect.request();
      var bluetoothAdvertise = await Permission.bluetoothAdvertise.request();

      // Check all Bluetooth permissions
      if (!bluetoothScan.isGranted ||
          !bluetoothConnect.isGranted ||
          !bluetoothAdvertise.isGranted) {
        debugPrint('Bluetooth permissions denied');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  Future<void> startAdvertising() async {
    if (!_isActive) return;

    try {
      debugPrint('Starting advertising as: $userName');

      bool? advertiseResult = await _nearby.startAdvertising(
        userName,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: SERVICE_ID,
      );

      if (advertiseResult == false) {
        _isActive = false;
        throw Exception('Failed to start advertising');
      }
    } catch (e) {
      debugPrint('Error in advertising: $e');
      _isActive = false;
      rethrow;
    }
  }

  Future<void> stopAdvertising() async {
    try {
      debugPrint('Stopping advertising...');
      await _nearby.stopAdvertising();
    } catch (e) {
      debugPrint('Error stopping advertising: $e');
      rethrow;
    }
  }

  Future<void> startAsMain() async {
    if (_isActive) return;

    _isMain = true;
    _isActive = true;

    try {
      // Start advertising first so clients can discover
      await startAdvertising();
      // Then start discovery to find clients
      await startDiscovery();
    } catch (e) {
      _isActive = false;
      rethrow;
    }
  }

  Future<void> startAsClient() async {
    if (_isActive) return;

    _isMain = false;
    _isActive = true;

    try {
      // Start advertising so main can discover
      await startAdvertising();
      // Also start discovery to find main device
      await startDiscovery();
    } catch (e) {
      _isActive = false;
      rethrow;
    }
  }

  Future<void> startDiscovery() async {
    try {
      debugPrint('Starting discovery as: $userName (isMain: $_isMain)');
      // Don't clear discovered devices if we're already connected to some
      if (_connectedEndpoints.isEmpty) {
        _discoveredDevices.clear();
        _devicesController.add(_discoveredDevices);
      }

      bool? discoveryResult = await _nearby.startDiscovery(
        userName,
        Strategy.P2P_CLUSTER,
        onEndpointFound: (id, name, serviceId) {
          debugPrint('Found endpoint: $name ($id)');
          // Only add if not already connected
          if (!_connectedEndpoints.contains(id)) {
            final discovery = Discovery(id: id, name: name);
            if (!_discoveredDevices.any((device) => device.id == id)) {
              _discoveredDevices.add(discovery);
              _devicesController.add(_discoveredDevices);
              _updateConnectionState(id, DeviceConnectionState.disconnected);
            }
          }
        },
        onEndpointLost: (id) async {
          debugPrint('Lost endpoint: $id');
          // Only remove if not connected
          if (!_connectedEndpoints.contains(id)) {
            _discoveredDevices.removeWhere((device) => device.id == id);
            _devicesController.add(_discoveredDevices);
            _updateConnectionState(id!, DeviceConnectionState.disconnected);
          }
        },
        serviceId: SERVICE_ID,
      );

      if (discoveryResult != true) {
        throw Exception('Failed to start discovery');
      }
    } catch (e) {
      debugPrint('Error in discovery: $e');
      rethrow;
    }
  }

  void _updateConnectionState(String endpointId, DeviceConnectionState state) {
    _connectionStates[endpointId] = state;
    _connectionStateController.add(ConnectionStateUpdate(endpointId, state));
  }

  Future<void> connectToEndpoint(String endpointId) async {
    if (!_isActive || _isReconnecting) return;

    try {
      _updateConnectionState(endpointId, DeviceConnectionState.connecting);

      bool? connectionResult = await Future.any([
        _nearby.requestConnection(
          userName,
          endpointId,
          onConnectionInitiated: _onConnectionInitiated,
          onConnectionResult: _onConnectionResult,
          onDisconnected: _onDisconnected,
        ),
        Future.delayed(const Duration(seconds: 10)).then(
            (_) => throw TimeoutException('Connection request timed out')),
      ]);

      if (connectionResult != true) {
        throw Exception('Connection request failed');
      }
    } catch (e) {
      _updateConnectionState(endpointId, DeviceConnectionState.failed);
      rethrow;
    }
  }

  void _onConnectionInitiated(
      String endpointId, ConnectionInfo connectionInfo) {
    debugPrint('Connection initiated: ${connectionInfo.endpointName}');

    _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: (endpointId, payload) {
        debugPrint('Received payload from: $endpointId');
      },
      onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {
        debugPrint('Transfer update: ${payloadTransferUpdate.status}');
      },
    ).catchError((e) {
      debugPrint('Error accepting connection: $e');
      _updateConnectionState(endpointId, DeviceConnectionState.failed);
      _connectedEndpoints.remove(endpointId);
    });
  }

  void _onConnectionResult(String endpointId, Status status) {
    debugPrint('Connection result: $endpointId - $status');

    if (status == Status.CONNECTED) {
      _connectedEndpoints.add(endpointId);
      _updateConnectionState(endpointId, DeviceConnectionState.connected);
    } else {
      _connectedEndpoints.remove(endpointId);
      _updateConnectionState(endpointId, DeviceConnectionState.failed);
    }
  }

  void _onDisconnected(String endpointId) {
    debugPrint('Disconnected: $endpointId');
    _connectedEndpoints.remove(endpointId);
    _updateConnectionState(endpointId, DeviceConnectionState.disconnected);
  }

  Future<void> stop() async {
    if (!_isActive) return;

    _isActive = false;
    _isReconnecting = false;

    try {
      await stopDiscovery();
      await stopAdvertising();
      _discoveredDevices.clear();
      _devicesController.add(_discoveredDevices);
      _connectionStates.clear();
      _connectedEndpoints.clear();
    } catch (e) {
      debugPrint('Error stopping service: $e');
      rethrow;
    }
  }

  Future<void> stopDiscovery() async {
    if (!_isMain) return;

    try {
      debugPrint('Stopping discovery...');
      await _nearby.stopDiscovery();
    } catch (e) {
      debugPrint('Error stopping discovery: $e');
      rethrow;
    }
  }

  void dispose() {
    stop();
    _devicesController.close();
    _connectionStateController.close();
  }
}

class Discovery {
  final String id;
  final String name;

  Discovery({required this.id, required this.name});
}

enum DeviceConnectionState {
  disconnected,
  connecting,
  connected,
  failed,
}
