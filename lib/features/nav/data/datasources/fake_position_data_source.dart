import 'package:findeasy/features/nav/data/datasources/device_position_data_source.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class FakePositionDataSource implements DevicePositionDataSource {
  @override
  Future<latlong2.LatLng> getCurrentPosition() async {
    return latlong2.LatLng(103.92936406404, 1.30704350174);
  }
}