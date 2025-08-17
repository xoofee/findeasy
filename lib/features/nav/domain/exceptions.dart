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
