import 'package:geolocator/geolocator.dart';

class LocationUtils {
  static Future<bool> checkLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
    }
    return true;
  }
}
