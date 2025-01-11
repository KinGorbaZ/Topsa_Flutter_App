import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class NearbyService {
  final Nearby _nearby = Nearby();
  static const String SERVICE_ID = "com.topsa.topsa_flutter_app";

  final StreamController<List<Discovery>> _devicesController =
      StreamController<List<Discovery>>.broadcast();
  Stream<List<Discovery>> get deviceStream => _devicesController.stream;

  final String userName;
  final List<Discovery> _discoveredDevices = [];
  bool _isDiscovering = false;
  bool _isAdvertising = false;

  NearbyService(this.userName);

  Future<bool> initialize() async {
    try {
      debugPrint('Checking permissions...');
      if (!await _checkPermissions()) {
        debugPrint('Failed to get permissions');
        return false;
      }
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

      // Location services
      if (!await _nearby.checkLocationEnabled()) {
        var locationEnabled = await _nearby.enableLocationServices();
        if (!locationEnabled) {
          debugPrint('Location services not enabled');
          return false;
        }
      }

      // Bluetooth permissions with proper error handling
      Map<Permission, PermissionStatus> bluetoothPermissions = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ].request();

      bool allGranted =
          bluetoothPermissions.values.every((status) => status.isGranted);
      if (!allGranted) {
        debugPrint('Some Bluetooth permissions were denied');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  Future<void> startAdvertising() async {
    if (_isAdvertising) return;

    try {
      debugPrint('Starting advertising as: $userName');
      _isAdvertising = true;

      bool? advertiseResult = await _nearby.startAdvertising(
        userName,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: SERVICE_ID,
      );

      if (advertiseResult == false) {
        debugPrint('Failed to start advertising');
        _isAdvertising = false;
      }
    } catch (e) {
      debugPrint('Error starting advertising: $e');
      _isAdvertising = false;
    }
  }

  Future<void> startDiscovery() async {
    if (_isDiscovering) return;

    try {
      debugPrint('Starting discovery...');
      _isDiscovering = true;
      _discoveredDevices.clear();
      _devicesController.add(_discoveredDevices);

      bool? discoveryResult = await _nearby.startDiscovery(
        userName,
        Strategy.P2P_CLUSTER,
        onEndpointFound: (id, userName, serviceId) {
          debugPrint('Found endpoint: $userName ($id)');
          final discovery = Discovery(id: id, name: userName);
          if (!_discoveredDevices.any((device) => device.id == id)) {
            _discoveredDevices.add(discovery);
            _devicesController.add(_discoveredDevices);
          }
        },
        onEndpointLost: (id) {
          debugPrint('Lost endpoint: $id');
          _discoveredDevices.removeWhere((device) => device.id == id);
          _devicesController.add(_discoveredDevices);
        },
        serviceId: SERVICE_ID,
      );

      if (discoveryResult == false) {
        debugPrint('Failed to start discovery');
        _isDiscovering = false;
      }
    } catch (e) {
      debugPrint('Error starting discovery: $e');
      _isDiscovering = false;
    }
  }

  void _onConnectionInitiated(
      String endpointId, ConnectionInfo connectionInfo) {
    debugPrint('Connection initiated by: ${connectionInfo.endpointName}');
    _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: (endpointId, payload) {
        debugPrint('Received payload from: $endpointId');
      },
      onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {
        debugPrint(
            'Payload transfer update from $endpointId: ${payloadTransferUpdate.status}');
      },
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    debugPrint('Connection result: $endpointId, status: $status');
  }

  void _onDisconnected(String endpointId) {
    debugPrint('Disconnected: $endpointId');
  }

  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;
    debugPrint('Stopping discovery...');
    _isDiscovering = false;
    await _nearby.stopDiscovery();
  }

  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;
    debugPrint('Stopping advertising...');
    _isAdvertising = false;
    await _nearby.stopAdvertising();
  }

  void dispose() {
    debugPrint('Disposing Nearby service');
    stopDiscovery();
    stopAdvertising();
    _devicesController.close();
  }
}

class Discovery {
  final String id;
  final String name;

  Discovery({required this.id, required this.name});
}
