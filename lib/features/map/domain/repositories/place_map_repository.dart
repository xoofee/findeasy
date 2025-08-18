import 'package:easyroute/easyroute.dart';

abstract class PlaceMapRepository {
  Future<(PlaceMap, PoiManager)> getMap(int placeId);
}
