import 'package:geolocator/geolocator.dart';

Future<bool> checkAndRequestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("⚠️ Người dùng đã từ chối quyền truy cập vị trí.");
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("❌ Quyền truy cập vị trí bị từ chối vĩnh viễn.");
    return false;
  }

  print("✅ Quyền truy cập vị trí được cấp.");
  return true;
}
