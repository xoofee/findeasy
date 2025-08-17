import 'package:latlong2/latlong.dart' as latlong2;

abstract class DevicePositionDataSource {
  Future<latlong2.LatLng> getCurrentPosition();
}

