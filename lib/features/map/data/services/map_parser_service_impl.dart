import 'dart:io';
import 'package:archive/archive.dart';
import 'package:easyroute/easyroute.dart';
import 'package:path/path.dart' as path;
import 'map_parser_service.dart';

/// Implementation of MapParserService using the easyroute library
class MapParserServiceImpl implements MapParserService {
  
  @override
  Future<PlaceMap> parseOsmGzFile(String filePath, int placeId) async {
    try {
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Map file not found: $filePath');
      }

      // Validate file
      if (!await isValidOsmGzFile(filePath)) {
        throw Exception('Invalid .osm.gz file: $filePath');
      }

      // Extract .gz file to get .osm content
      final osmContent = await _extractGzFile(filePath);
      
      // Parse OSM content using easyroute library
      final rawMap = await _parseOsmContent(osmContent);
      
      // Build PlaceMap from RawMap
      final (placeMap, _) = buildPlaceMap(rawMap);
      
      // Update placeMap with the actual placeId
      placeMap.id = placeId;
      
      return placeMap;
      
    } catch (e) {
      throw Exception('Failed to parse .osm.gz file: $e');
    }
  }

  @override
  Future<bool> isValidOsmGzFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      
      // Check file extension
      if (!path.extension(filePath).toLowerCase().contains('.gz')) {
        return false;
      }
      
      // Check if it's a valid gzip file by trying to read the header
      final bytes = await file.openRead(0, 10).first;
      return bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
      
    } catch (e) {
      return false;
    }
  }

  // @override
  // Future<Map<String, dynamic>> getFileMetadata(String filePath) async {
  //   try {
  //     final file = File(filePath);
  //     if (!await file.exists()) {
  //       throw Exception('File not found: $filePath');
  //     }

  //     final stats = await file.stat();
      
  //     return {
  //       'fileSize': stats.size,
  //       'lastModified': stats.modified,
  //       'isValidGz': await isValidOsmGzFile(filePath),
  //       'fileName': path.basename(filePath),
  //       'filePath': filePath,
  //     };
      
  //   } catch (e) {
  //     throw Exception('Failed to get file metadata: $e');
  //   }
  // }

  // /// Extract .gz file and return the decompressed content
  // Future<String> _extractGzFile(String gzFilePath) async {
  //   final file = File(gzFilePath);
  //   final bytes = await file.readAsBytes();
    
  //   // Decompress gzip
  //   final archive = GZipDecoder().decodeBytes(bytes);
    
  //   // Convert to string (assuming it's UTF-8 encoded XML)
  //   return String.fromCharCodes(archive);
  // }

  /// Parse OSM XML content using easyroute library
  Future<RawMap> _parseOsmContent(String osmXmlContent) async {
    // Create a temporary file with the XML content
    final tempDir = Directory.systemTemp;
    final tempFile = File(path.join(tempDir.path, 'temp_osm_${DateTime.now().millisecondsSinceEpoch}.xml'));
    
    try {
      await tempFile.writeAsString(osmXmlContent);
      
      // Use easyroute's OSM parser
      final rawMap = await loadOsmMap(tempFile.path);
      
      return rawMap;
      
    } finally {
      // Clean up temporary file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}
