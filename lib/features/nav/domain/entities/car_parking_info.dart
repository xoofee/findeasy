import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_parking_info.freezed.dart';
part 'car_parking_info.g.dart';

/// Represents information about where a user has parked their car
@freezed
class CarParkingInfo with _$CarParkingInfo {
  const factory CarParkingInfo({
    required int placeId,
    required double levelNumber,
    required String parkingSpaceName,
    required DateTime parkedAt,
  }) = _CarParkingInfo;

  factory CarParkingInfo.fromJson(Map<String, dynamic> json) => _$CarParkingInfoFromJson(json);
}
