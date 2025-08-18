abstract class MapDataSource {
  
  Future<(int, DateTime)> getPlaceMapInfo(int placeId);

  Future<String> downloadMap(int placeId);

}