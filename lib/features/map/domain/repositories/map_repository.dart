import 'package:easyroute/easyroute.dart';

abstract class MapRepository {
  Future<(PlaceMap, PoiManager)> getMap(int placeId);
}
