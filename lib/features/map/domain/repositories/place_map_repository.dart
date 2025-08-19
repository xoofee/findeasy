import 'package:easyroute/easyroute.dart';

abstract class PlaceMapRepository {
  Future<MapResult> getMap(int placeId);
}
