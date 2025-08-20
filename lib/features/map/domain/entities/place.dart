import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:findeasy/core/utils/latlng_json_converter.dart';

part 'place.freezed.dart';
part 'place.g.dart';

@freezed
class Place with _$Place {
  const factory Place({
    required int id,
    required String name,
    required String address,
    @LatLngJsonConverter() required latlong2.LatLng location,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}
