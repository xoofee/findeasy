import 'package:findeasy/features/map/domain/entities/place.dart';
import 'package:latlong2/latlong.dart' as latlong2;

abstract class PlacesDataSource {
  /// return a list of places that are within the radius of the center, ordered by distance from the center
  Future<List<Place>> getPlaces(latlong2.LatLng center, {double maxDistance = 500.0, int limit = 10});

  // not used for now
  // Future<List<Place>> getAllPlaces();
  // Future<Place> getPlaceById(String placeId);
  // Future<Place> createPlace(Place place);
  // Future<Place> updatePlace(Place place);
  // Future<void> deletePlace(String placeId);
}
