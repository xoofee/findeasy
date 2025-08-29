/*



*/


class DevicePositionException implements Exception {
  final String message;
  DevicePositionException(this.message);
  
  @override
  String toString() => 'DevicePositionException: $message';
}

class DevicePositionPermissionException extends DevicePositionException {
  DevicePositionPermissionException(super.message);
  
  @override
  String toString() => 'DevicePositionPermissionException: $message';
}

class NoNearbyPlacesException implements Exception {
  final String message;
  final double radius;

  NoNearbyPlacesException(this.message, this.radius);
  
  @override
  String toString() => 'NoNearbyPlacesException: $message, radius: $radius';

}
