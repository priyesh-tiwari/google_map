import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_model.dart';

enum LocationPermissionStatus { granted, denied, permanentlyDenied, restricted }

class LocationViewModel extends ChangeNotifier {
  LocationModel? _currentLocation;
  final List<LocationModel> _locationHistory = [];
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.denied;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Position>? _positionStreamSubscription;

  LocationModel? get currentLocation => _currentLocation;
  List<LocationModel> get locationHistory => List.unmodifiable(_locationHistory);
  LocationPermissionStatus get permissionStatus => _permissionStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await checkAndRequestPermissions();
    if (_permissionStatus == LocationPermissionStatus.granted) {
      await getCurrentLocation();
      startLocationUpdates();
    }
  }

  Future<void> checkAndRequestPermissions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _permissionStatus = LocationPermissionStatus.denied;
        _errorMessage = 'Location permission denied';
      } else if (permission == LocationPermission.deniedForever) {
        _permissionStatus = LocationPermissionStatus.permanentlyDenied;
        _errorMessage = 'Location permission permanently denied. Please enable in settings.';
      } else {
        _permissionStatus = LocationPermissionStatus.granted;
      }
    } catch (e) {
      _errorMessage = 'Error checking permissions: $e';
      _permissionStatus = LocationPermissionStatus.denied;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    if (_permissionStatus != LocationPermissionStatus.granted) {
      _errorMessage = 'Location permission not granted';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _updateLocationFromPosition(position);
    } catch (e) {
      _errorMessage = 'Error getting location: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void startLocationUpdates() {
    if (_permissionStatus != LocationPermissionStatus.granted) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _updateLocationFromPosition(position);
      },
      onError: (error) {
        _errorMessage = 'Location update error: $error';
        notifyListeners();
      },
    );
  }

  Future<void> _updateLocationFromPosition(Position position) async {
    try {
      // Get address details from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark? place = placemarks.isNotEmpty ? placemarks.first : null;

      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        city: place?.locality ?? place?.subLocality,
        state: place?.administrativeArea,
        postalCode: place?.postalCode,
        timestamp: DateTime.now(),
      );

      _currentLocation = location;
      _locationHistory.insert(0, location);
      
      // Keep only last 50 locations
      if (_locationHistory.length > 50) {
        _locationHistory.removeLast();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error getting address: $e';
      notifyListeners();
    }
  }

  Future<void> openSettings() async {
    await Geolocator.openLocationSettings();
  }

  void clearHistory() {
    _locationHistory.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}