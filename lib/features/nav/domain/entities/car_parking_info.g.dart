// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_parking_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CarParkingInfoImpl _$$CarParkingInfoImplFromJson(Map<String, dynamic> json) =>
    _$CarParkingInfoImpl(
      placeId: (json['placeId'] as num).toInt(),
      levelNumber: (json['levelNumber'] as num).toDouble(),
      parkingSpaceName: json['parkingSpaceName'] as String,
      parkedAt: DateTime.parse(json['parkedAt'] as String),
    );

Map<String, dynamic> _$$CarParkingInfoImplToJson(
        _$CarParkingInfoImpl instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'levelNumber': instance.levelNumber,
      'parkingSpaceName': instance.parkingSpaceName,
      'parkedAt': instance.parkedAt.toIso8601String(),
    };
