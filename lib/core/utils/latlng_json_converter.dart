import 'package:latlong2/latlong.dart';
import 'package:json_annotation/json_annotation.dart';

class LatLngJsonConverter implements JsonConverter<LatLng, Map<String, dynamic>> {
  const LatLngJsonConverter();

  @override
  LatLng fromJson(Map<String, dynamic> json) =>
      LatLng(json['latitude'] as double, json['longitude'] as double);

  @override
  Map<String, dynamic> toJson(LatLng instance) =>
      {'latitude': instance.latitude, 'longitude': instance.longitude};
}
