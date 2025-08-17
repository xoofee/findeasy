class PlacesException implements Exception {
  final String message;
  PlacesException(this.message);

  @override
  String toString() => 'PlacesException: $message';
}