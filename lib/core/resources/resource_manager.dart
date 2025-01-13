// lib/core/resources/resource_manager.dart

import 'dart:async';

class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();
  factory ResourceManager() => _instance;

  ResourceManager._internal();

  final _cache = <String, _WeakResource>{};
  final _expirationTimes = <String, DateTime>{};
  Timer? _cleanupTimer;

  void cacheResource(String key, dynamic resource, {Duration? expiration}) {
    _cache[key] = _WeakResource(resource);

    if (expiration != null) {
      _expirationTimes[key] = DateTime.now().add(expiration);
    }

    _startCleanupTimer();
  }

  T? getResource<T>(String key) {
    final resource = _cache[key]?.resource;

    if (resource != null) {
      if (_isExpired(key)) {
        _removeResource(key);
        return null;
      }
      return resource as T?;
    }

    return null;
  }

  void removeResource(String key) {
    _removeResource(key);
  }

  bool _isExpired(String key) {
    final expirationTime = _expirationTimes[key];
    if (expirationTime == null) return false;
    return DateTime.now().isAfter(expirationTime);
  }

  void _removeResource(String key) {
    _cache.remove(key);
    _expirationTimes.remove(key);
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanup();
    });
  }

  void _cleanup() {
    final keysToRemove = <String>[];

    _cache.forEach((key, resource) {
      if (resource.resource == null || _isExpired(key)) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _removeResource(key);
    }

    if (_cache.isEmpty) {
      _cleanupTimer?.cancel();
      _cleanupTimer = null;
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
    _expirationTimes.clear();
  }
}

class _WeakResource {
  final WeakReference<dynamic> _reference;

  _WeakResource(dynamic resource) : _reference = WeakReference(resource);

  dynamic get resource => _reference.target;
}
