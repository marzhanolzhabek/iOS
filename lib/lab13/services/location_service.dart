
import 'package:geolocator/geolocator.dart';

class LocationServiceDisabled implements Exception {}

class LocationPermissionBlocked implements Exception {}

class LocationPermissionRejected implements Exception {}

class LocationService {
  Future<Position> fetchCurrentPosition() async {
    final enabled =
    await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      throw LocationServiceDisabled();
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionBlocked();
    }

    if (permission == LocationPermission.denied) {
      throw LocationPermissionRejected();
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }
}
