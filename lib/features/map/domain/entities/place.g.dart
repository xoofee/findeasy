// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Place _$PlaceFromJson(Map<String, dynamic> json) => Place(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      location: const LatLngJsonConverter()
          .fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'location': const LatLngJsonConverter().toJson(instance.location),
    };
