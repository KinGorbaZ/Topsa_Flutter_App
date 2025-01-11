// lib/screens/multiple_users_screen.dart
import 'package:flutter/material.dart';
import '../services/nearby_service.dart';

class MultipleUsersScreen extends StatefulWidget {
  const MultipleUsersScreen({Key? key}) : super(key: key);

  @override
  State<MultipleUsersScreen> createState() => _MultipleUsersScreenState();
}

class _MultipleUsersScreenState extends State<MultipleUsersScreen> {
  late NearbyService _nearbyService;
  final TextEditingController _nameController = TextEditingController();
  bool _isInitialized = false;
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _nearbyService = NearbyService(_nameController.text);
      bool initialized = await _nearbyService.initialize();

      if (!initialized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Failed to initialize Nearby service. Please check permissions.')),
          );
        }
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
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _startDiscovery() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isDiscovering = true);
    await _nearbyService.startAdvertising();
    await _nearbyService.startDiscovery();
  }

  Future<void> _stopDiscovery() async {
    setState(() => _isDiscovering = false);
    await _nearbyService.stopDiscovery();
    await _nearbyService.stopAdvertising();
  }

  @override
  void dispose() {
    _nearbyService.dispose();
    _nameController.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
              enabled: !_isDiscovering,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isDiscovering ? _stopDiscovery : _startDiscovery,
              icon: Icon(_isDiscovering ? Icons.stop : Icons.search),
              label:
                  Text(_isDiscovering ? 'Stop Discovery' : 'Start Discovery'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<Discovery>>(
                stream: _nearbyService.deviceStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No nearby users found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final device = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(device.name),
                          subtitle: Text(device.id),
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
