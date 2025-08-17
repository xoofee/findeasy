/*

The Repository layer should only re-map if it combines multiple sources and needs to normalize errors.
Otherwise → let exceptions bubble up.

*/

import 'package:latlong2/latlong.dart' as latlong2;
import 'package:findeasy/features/nav/data/datasources/device_position_data_source.dart';

class DevicePositionRepository {
  DevicePositionDataSource devicePositionSource;

  DevicePositionRepository({required this.devicePositionSource});

  Future<latlong2.LatLng> getCurrentPosition() async {
    return await devicePositionSource.getCurrentPosition();
  }
}
