// lib/screens/multiple_users_screen.dart
import 'package:flutter/material.dart';
import '../services/nearby_service.dart';
import '../l10n/app_localizations.dart';

class MultipleUsersScreen extends StatefulWidget {
  const MultipleUsersScreen({Key? key}) : super(key: key);

  @override
  State<MultipleUsersScreen> createState() => _MultipleUsersScreenState();
}

class _MultipleUsersScreenState extends State<MultipleUsersScreen> {
  late NearbyService _nearbyService;
  bool _isInitialized = false;
  bool _isMain = false;
  bool _isActive = false;
  Map<String, DeviceConnectionState> _connectionStates = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      String deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      _nearbyService = NearbyService('Device-$deviceId');
      bool initialized = await _nearbyService.initialize();

      if (!initialized && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).initializationFailed),
            backgroundColor: Colors.red,
          ),
        );
      }

      _nearbyService.connectionStateStream.listen((stateUpdate) {
        if (mounted) {
          setState(() {
            _connectionStates[stateUpdate.endpointId] = stateUpdate.state;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = initialized;
        });
      }
    } catch (e) {
      debugPrint('Error initializing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _startAsMain() async {
    try {
      setState(() {
        _isMain = true;
        _isActive = true;
      });
      await _nearbyService.startAsMain();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isActive = false);
      }
    }
  }

  Future<void> _startAsClient() async {
    try {
      setState(() {
        _isMain = false;
        _isActive = true;
      });
      await _nearbyService.startAsClient();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isActive = false);
      }
    }
  }

  Future<void> _stop() async {
    try {
      setState(() => _isActive = false);
      await _nearbyService.stop();
      setState(() {
        _connectionStates.clear();
      });
    } catch (e) {
      debugPrint('Error stopping: $e');
    }
  }

  Future<void> _connectToDevice(String deviceId) async {
    try {
      await _nearbyService.connectToEndpoint(deviceId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildConnectionButton(String deviceId) {
    final state =
        _connectionStates[deviceId] ?? DeviceConnectionState.disconnected;

    switch (state) {
      case DeviceConnectionState.connecting:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case DeviceConnectionState.connected:
        return Icon(Icons.check_circle, color: Colors.green[700]);
      case DeviceConnectionState.failed:
        return Icon(Icons.error, color: Colors.red[700]);
      case DeviceConnectionState.disconnected:
        return _isMain
            ? ElevatedButton(
                onPressed: () => _connectToDevice(deviceId),
                child: const Text('Connect'),
              )
            : const SizedBox.shrink();
    }
  }

  Widget _buildRoleSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Select Role',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _startAsMain,
          child: const Text('Start as Main Device'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _startAsClient,
          child: const Text('Start as Client Device'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nearbyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Multiple Users')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('Multiple Users')),
        body: Center(child: _buildRoleSelection()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isMain ? 'Main Device' : 'Client Device'),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _stop,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _isMain ? 'Discovering Clients...' : 'Waiting for Main Device...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<Discovery>>(
                stream: _nearbyService.deviceStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No nearby devices found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final device = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.devices),
                          title: Text(device.name),
                          subtitle: Text(device.id),
                          trailing: _buildConnectionButton(device.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
