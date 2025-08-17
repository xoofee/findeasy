import 'package:easyroute/easyroute.dart';

/// Service interface for parsing map files into PlaceMap objects
abstract class MapParserService {
  /// Parse a .osm.gz file into a PlaceMap object
  /// 
  /// [filePath] - Path to the .osm.gz file
  /// [placeId] - ID of the place for identification
  /// 
  /// Returns a PlaceMap object with all parsed data
  Future<PlaceMap> parseOsmGzFile(String filePath, int placeId);
  
  /// Check if a file is a valid .osm.gz file
  /// 
  /// [filePath] - Path to the file to validate
  /// 
  /// Returns true if the file is valid, false otherwise
  Future<bool> isValidOsmGzFile(String filePath);
  
  /// Get basic information about a .osm.gz file without full parsing
  /// 
  /// [filePath] - Path to the .osm.gz file
  /// 
  /// Returns basic metadata about the file
  Future<Map<String, dynamic>> getFileMetadata(String filePath);
}
