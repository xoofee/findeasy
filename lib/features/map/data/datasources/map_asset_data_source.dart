import 'dart:io';
import 'dart:typed_data';
import 'package:findeasy/features/map/data/datasources/map_data_source.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Data source for loading map data from assets (offline testing)
class MapAssetDataSource implements MapDataSource {
  static const String _assetPath = 'assets/maps/happy_coast.osm.gz';
  static const String _fileName = 'happy_coast.osm.gz';
  
  @override
  Future<String> downloadMap(int placeId) async {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path, _fileName));

      // check if file exists
      if (await tempFile.exists()) {
        return tempFile.path;
      }

      // Get the asset file as bytes
      final ByteData data = await rootBundle.load(_assetPath);

      await tempFile.writeAsBytes(data.buffer.asUint8List());
      return tempFile.path;
  }
  
  @override
  Future<(int, DateTime)> getPlaceMapInfo(int placeId) async {
    return (0, DateTime(2025, 1, 1));
  }
  
}
