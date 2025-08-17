import 'package:findeasy/features/map/data/datasources/places_remote_data_source.dart';
import 'package:findeasy/features/map/domain/entities/place.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class PlacesRepository {
  final PlacesRemoteDataSource remoteDataSource;

  PlacesRepository({required this.remoteDataSource});

  Future<List<Place>> getPlaces(latlong2.LatLng center, {double maxDistance = 500.0, int limit = 10}) async {
    return await remoteDataSource.getPlaces(center, maxDistance: maxDistance, limit: limit);
  }
}