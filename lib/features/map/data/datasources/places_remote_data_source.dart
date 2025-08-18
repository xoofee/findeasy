/*

PlacesRemoteDataSource (compared to RemotePlacesDataSource) keeps feature name first (Places) → easier to find when browsing code, since everything related to Places is grouped.

*/

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:findeasy/core/constants/app_constants.dart';
import 'package:findeasy/features/map/data/datasources/places_data_source.dart';
import 'package:findeasy/features/map/domain/entities/place.dart';
import 'package:findeasy/features/map/domain/exceptions.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PlacesRemoteDataSource implements PlacesDataSource{
  final Dio _dio;
  final String _baseUrl; 

  PlacesRemoteDataSource({required Dio dio, required String baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  // Get nearby places
  @override
  Future<List<Place>> getPlaces(latlong2.LatLng center, {double maxDistance = 500.0, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/places_near',
        queryParameters: {
          'lat': center.latitude,
          'lon': center.longitude,
          'max_distance': maxDistance,
        },
      );
      List<Place> places = [];
      for (var place in response.data) {
        places.add(Place.fromJson(place));
      }
      return places;
    } catch (e) {
      throw PlacesException("Failed to load nearby places");
    }
  }

  // Get all places
  // Future<List<Place>> getAllPlaces() async {
  //   try {
  //     final response = await _dio.get('$_baseUrl/places/');
  //     List<Place> places = [];
  //     for (var place in response.data) {
  //       places.add(Place.fromJson(place));
  //     }
  //     return places;
  //   } catch (e) {
  //     throw Exception("Failed to load places");
  //   }
  // }

  // Create a new place
  // Future<Place> createPlace(Place place) async {
  //   try {
  //     final response = await _dio.post(
  //       '$_baseUrl/places/',
  //       data: json.encode(place.toJson()),
  //     );
  //     return Place.fromJson(response.data);
  //   } catch (e) {
  //     throw PlacesException("Failed to create place");
  //   }
  // }

  // Get a place by ID
  // Future<Place> getPlaceById(String placeId) async {
  //   try {
  //     final response = await _dio.get('$_baseUrl/places/$placeId');
  //     return Place.fromJson(response.data);
  //   } catch (e) {
  //     throw Exception("Failed to load place");
  //   }
  // }

  // Delete a place by ID
  // Future<void> deletePlace(String placeId) async {
  //   try {
  //     await _dio.delete('$_baseUrl/places/$placeId');
  //   } catch (e) {
  //     throw Exception("Failed to delete place");
  //   }
  // }


}
