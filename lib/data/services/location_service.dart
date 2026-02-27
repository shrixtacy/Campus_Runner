import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;
  String? _activeTaskId;

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<bool> checkLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final serviceEnabled = await checkLocationServiceEnabled();
      if (!serviceEnabled) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  void startLocationTracking(String taskId) {
    if (_positionStream != null) {
      stopLocationTracking();
    }

    _activeTaskId = taskId;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        timeLimit: Duration(seconds: 10),
      ),
    ).listen((Position position) {
      _updateTaskLocation(taskId, position);
    });
  }

  Future<void> _updateTaskLocation(String taskId, Position position) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'runnerLatitude': position.latitude,
        'runnerLongitude': position.longitude,
        'locationLastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      return;
    }
  }

  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _activeTaskId = null;
  }

  bool get isTracking => _positionStream != null;
  String? get activeTaskId => _activeTaskId;

  Future<double> calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<bool> isNearLocation(
    double currentLat,
    double currentLon,
    double targetLat,
    double targetLon, {
    double radiusInMeters = 50,
  }) async {
    final distance = await calculateDistance(
      currentLat,
      currentLon,
      targetLat,
      targetLon,
    );
    return distance <= radiusInMeters;
  }
}
