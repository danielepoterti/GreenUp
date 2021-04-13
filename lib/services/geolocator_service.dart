import 'package:geolocator/geolocator.dart';
//mport 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';

class GeolocatorService {
  static Future<PermissionStatus> getPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    //LocationData _locationData;
    Location location = new Location();

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }
    return await location.hasPermission();
  }

  static Future<Position> getLocation() async {
    return getPermission().then((result) async {
      if (result == PermissionStatus.granted) {
        return await Geolocator.getCurrentPosition();
      } else
        return null;
    });
  }
}
