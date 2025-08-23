
import 'package:findeasy/features/map/data/datasources/places_data_source.dart';
import 'package:findeasy/features/map/domain/entities/place.dart';
import 'package:latlong2/latlong.dart' as latlong2;


class PlacesFakeDataSource implements PlacesDataSource{


  // Get nearby places
  @override
  Future<List<Place>> getPlaces(latlong2.LatLng center, {double maxDistance = 500.0, int limit = 10}) async {

    return [
      Place(id: 0, name: "歡樂海岸", address: "SZ", location: const latlong2.LatLng(22.527104, 113.985433)),
      Place(id: 1, name: "Mall B", address: "456 Main St", location: const latlong2.LatLng(1.308, 103.930)),
    ];
  }

}
