import 'dart:convert';
import 'dart:io';
import 'package:findeasy/features/map/data/datasources/places_data_source.dart';
import 'package:findeasy/features/map/domain/entities/place.dart';
import 'package:findeasy/features/map/domain/exceptions.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:findeasy/core/constants/app_constants.dart';
import 'package:easyroute/easyroute.dart';

class PlacesRepository {
  final PlacesDataSource placesDataSource;

  PlacesRepository({
    required this.placesDataSource,
  });

  Future<List<Place>> getPlaces(latlong2.LatLng center, {double maxDistance = 500.0, int limit = 10}) async {
    return await placesDataSource.getPlaces(center, maxDistance: maxDistance, limit: limit);
  }

}