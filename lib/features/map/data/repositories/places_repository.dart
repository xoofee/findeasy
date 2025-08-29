import 'package:findeasy/features/map/data/datasources/places_data_source.dart';
import 'package:findeasy/features/map/domain/entities/place.dart';
import 'package:findeasy/features/nav/domain/exceptions.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class PlacesRepository {
  final PlacesDataSource placesDataSource;

  PlacesRepository({
    required this.placesDataSource,
  });

  Future<List<Place>> getPlaces(latlong2.LatLng center, {double maxDistance = 500.0, int limit = 10}) async {
    return await placesDataSource.getPlaces(center, maxDistance: maxDistance, limit: limit);
  }

  Future<Place> getNearestPlace(latlong2.LatLng center, {double maxDistance = 500.0, int limit = 10}) async {
    final places = await getPlaces(center, maxDistance: maxDistance, limit: limit);
    if (places.isEmpty) {
      throw NoNearbyPlacesException("No nearby places found", maxDistance);
    }
    return places.first;
  }

}
