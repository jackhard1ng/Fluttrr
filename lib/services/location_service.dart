import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Location data model
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        country: json['country'] as String?,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : null,
      );
}

/// Location service for handling geolocation
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LocationData? _currentLocation;
  StreamSubscription<Position>? _locationSubscription;
  final _locationController = StreamController<LocationData>.broadcast();
  bool _isDisposed = false;

  /// Stream of location updates
  Stream<LocationData> get locationStream => _locationController.stream;

  /// Current location
  LocationData? get currentLocation => _currentLocation;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permission
  Future<LocationPermission> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Check if permission is granted
  Future<bool> hasPermission() async {
    final permission = await checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Get current location
  Future<LocationData?> getCurrentLocation({
    bool includeAddress = false,
  }) async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      final permission = await checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      var location = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (includeAddress) {
        location = await _addAddressToLocation(location);
      }

      _currentLocation = location;

      // Cache location
      await _cacheLocation(location);

      return location;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return await _getCachedLocation();
    }
  }

  /// Get last known location
  Future<LocationData?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
      return await _getCachedLocation();
    } catch (e) {
      debugPrint('Error getting last known location: $e');
      return await _getCachedLocation();
    }
  }

  /// Start listening to location updates
  Future<void> startLocationUpdates({
    int distanceFilter = 100,
    Duration? interval,
  }) async {
    final permission = await checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('Location permission denied');
      return;
    }

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
    );

    // Cancel existing subscription before creating a new one
    await _locationSubscription?.cancel();

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) async {
        // Guard against processing after disposal
        if (_isDisposed || _locationController.isClosed) return;

        final location = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _currentLocation = location;
        if (!_locationController.isClosed) {
          _locationController.add(location);
        }
        // Only cache if not disposed
        if (!_isDisposed) {
          await _cacheLocation(location);
        }
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
        // Guard against cleanup after disposal
        if (_isDisposed) return;
        // Clean up subscription on error
        _locationSubscription?.cancel();
        _locationSubscription = null;
      },
      cancelOnError: false,
    );
  }

  /// Stop listening to location updates
  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Get address from coordinates
  Future<LocationData?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return LocationData(
          latitude: latitude,
          longitude: longitude,
          address: _formatAddress(place),
          city: place.locality,
          state: place.administrativeArea,
          country: place.country,
        );
      }
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
    }
    return null;
  }

  /// Get coordinates from address
  Future<LocationData?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        return LocationData(
          latitude: location.latitude,
          longitude: location.longitude,
          address: address,
        );
      }
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
    }
    return null;
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate distance in a readable format (miles)
  String formatDistance(double distanceInMeters) {
    final miles = distanceInMeters / 1609.344;
    if (miles < 0.1) {
      final feet = (distanceInMeters * 3.28084).round();
      return '$feet ft';
    } else if (miles < 10) {
      return '${miles.toStringAsFixed(1)} mi';
    } else {
      return '${miles.round()} mi';
    }
  }

  /// Calculate bearing between two points
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Add address information to location
  Future<LocationData> _addAddressToLocation(LocationData location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return LocationData(
          latitude: location.latitude,
          longitude: location.longitude,
          address: _formatAddress(place),
          city: place.locality,
          state: place.administrativeArea,
          country: place.country,
          timestamp: location.timestamp,
        );
      }
    } catch (e) {
      debugPrint('Error adding address to location: $e');
    }
    return location;
  }

  /// Format address from placemark
  String _formatAddress(Placemark place) {
    final parts = <String?>[
      place.street,
      place.locality,
      place.administrativeArea,
      place.postalCode,
      place.country,
    ].where((part) => part != null && part.isNotEmpty).cast<String>().toList();

    return parts.join(', ');
  }

  /// Cache location to shared preferences
  Future<void> _cacheLocation(LocationData location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cached_latitude', location.latitude);
      await prefs.setDouble('cached_longitude', location.longitude);
      final city = location.city;
      if (city != null) {
        await prefs.setString('cached_city', city);
      }
    } catch (e) {
      debugPrint('Error caching location: $e');
    }
  }

  /// Get cached location from shared preferences
  Future<LocationData?> _getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble('cached_latitude');
      final longitude = prefs.getDouble('cached_longitude');
      final city = prefs.getString('cached_city');

      if (latitude != null && longitude != null) {
        return LocationData(
          latitude: latitude,
          longitude: longitude,
          city: city,
        );
      }
    } catch (e) {
      debugPrint('Error getting cached location: $e');
    }
    return null;
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (for permission settings)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Dispose of the service
  void dispose() {
    _isDisposed = true;
    stopLocationUpdates();
    if (!_locationController.isClosed) {
      _locationController.close();
    }
  }
}
