import 'package:latlong2/latlong.dart' as latlong2;
import 'package:json_annotation/json_annotation.dart';
import 'package:findeasy/core/utils/latlng_json_converter.dart';

part 'place.g.dart';

@JsonSerializable()
class Place {
  final int id;
  final String name;
  final String address;

  @LatLngJsonConverter()
  final latlong2.LatLng location;

  Place({required this.id, required this.name, required this.address, required this.location});

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
  
  Map<String, dynamic> toJson() => _$PlaceToJson(this);
}
