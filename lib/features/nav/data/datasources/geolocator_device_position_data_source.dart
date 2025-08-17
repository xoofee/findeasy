/*

The DataSource layer is where external errors (Geolocator’s own exceptions) should be mapped into domain exceptions.

*/

import 'package:findeasy/features/nav/data/datasources/device_position_data_source.dart';
import 'package:findeasy/features/nav/domain/exceptions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong2;


class GeolocatorDevicePositionDataSource implements DevicePositionDataSource {
  @override
  Future<latlong2.LatLng> getCurrentPosition() async {

    // return generateFakeGpsPosition(longitude: 103.92936406404, latitude: 1.30704350174);

    // Check location permission
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      // Handle permission denial
      throw DevicePositionPermissionException('Location permission denied');
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the case when permission is permanently denied
      throw DevicePositionPermissionException('Location permission permanently denied');
    }

    // Get the current position with high accuracy
    Position position = await Geolocator.getCurrentPosition( );
    
    return latlong2.LatLng(position.latitude, position.longitude);
  }
}