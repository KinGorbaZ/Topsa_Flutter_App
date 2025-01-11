// lib/screens/multiple_users_screen.dart

import 'package:flutter/material.dart';
import '../services/nearby_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            content: Text(AppLocalizations.of(context)!.initializationFailed),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _isInitialized = initialized;
        });
      }
    } catch (e) {
      debugPrint('Error initializing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: Colors.red,
          ),
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
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: Colors.red,
          ),
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
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isActive = false);
      }
    }
  }

  Future<void> _stop() async {
    try {
      await _nearbyService.stop();
      setState(() {
        _isActive = false;
        _connectionStates.clear();
      });
    } catch (e) {
      debugPrint('Error stopping: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connectToDevice(String deviceId) async {
    try {
      setState(() {
        _connectionStates[deviceId] = DeviceConnectionState.connecting;
      });

      await _nearbyService.connectToEndpoint(deviceId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _connectionStates[deviceId] = DeviceConnectionState.failed;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.connectionError}$e'),
            backgroundColor: Colors.red,
          ),
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
                child: Text(AppLocalizations.of(context)!.connect),
              )
            : const SizedBox.shrink();
    }
  }

  Widget _buildRoleSelection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.selectRole,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          onPressed: _startAsMain,
          child: Text(l10n.startAsMain),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          onPressed: _startAsClient,
          child: Text(l10n.startAsClient),
        ),
      ],
    );
  }

  Widget _buildDeviceList() {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<Discovery>>(
      stream: _nearbyService.deviceStream,
      builder: (context, discoverySnapshot) {
        return StreamBuilder<ConnectionStateUpdate>(
          stream: _nearbyService.connectionStateStream,
          builder: (context, connectionSnapshot) {
            if (!discoverySnapshot.hasData || discoverySnapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.device_unknown,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      _isMain ? l10n.noClientsFound : l10n.waitingForMain,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            // Update connection states from stream
            if (connectionSnapshot.hasData) {
              final update = connectionSnapshot.data!;
              _connectionStates[update.endpointId] = update.state;
            }

            return ListView.builder(
              itemCount: discoverySnapshot.data!.length,
              itemBuilder: (context, index) {
                final device = discoverySnapshot.data![index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.bluetooth,
                      color: _connectionStates[device.id] ==
                              DeviceConnectionState.connected
                          ? Colors.blue[700]
                          : Colors.grey,
                    ),
                    title: Text(device.name),
                    subtitle: Text(_getConnectionStateText(device.id, l10n)),
                    trailing: _buildConnectionButton(device.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _getConnectionStateText(
      String deviceId, AppLocalizations localizations) {
    final state =
        _connectionStates[deviceId] ?? DeviceConnectionState.disconnected;
    switch (state) {
      case DeviceConnectionState.connecting:
        return localizations.connecting;
      case DeviceConnectionState.connected:
        return localizations.connected;
      case DeviceConnectionState.failed:
        return localizations.connectionFailed;
      case DeviceConnectionState.disconnected:
        return localizations.disconnected;
    }
  }

  @override
  void dispose() {
    _nearbyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isMain ? l10n.mainDevice : l10n.clientDevice),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isActive) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.selectRole),
        ),
        body: Center(child: _buildRoleSelection(context)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isMain ? l10n.mainDevice : l10n.clientDevice),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _stop,
            tooltip: l10n.stop,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _isMain ? l10n.discoveringClients : l10n.searchingForMain,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildDeviceList()),
          ],
        ),
      ),
    );
  }
}
