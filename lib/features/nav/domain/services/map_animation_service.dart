
abstract class MapAnimationService {

  void animateTo(double lat, double lon, {double? zoom, double? rotation, Duration duration = const Duration(seconds: 1)});
}
