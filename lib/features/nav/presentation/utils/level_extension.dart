import 'package:easyroute/easyroute.dart';

extension LevellListExtension on List<Level> {
  Level getDefaultLevel() {
    final sortedLevels = List<Level>.from(this)..sort();
    
    // Find the smallest non-negative floor (>= 0)
    final nonNegativeLevels = sortedLevels.where((level) => level.value >= 0).toList();
    if (nonNegativeLevels.isNotEmpty) {
      return nonNegativeLevels.first; // First after sorting is the smallest
    }
    
    // If no non-negative floors, find the largest negative floor (< 0)
    final negativeLevels = sortedLevels.where((level) => level.value < 0).toList();
    if (negativeLevels.isNotEmpty) {
      return negativeLevels.last; // Last after sorting is the largest
    }
    
    // Fallback: return the first level if list is not empty
    return isNotEmpty ? first : throw StateError('No levels available');
  }
  
}

extension LevelExtension on Level {
  String get displayName {
    if (value >= 0) return 'F${value.toInt()+1}';
    return 'B${value.toInt().abs()}'; // e.g., -1 for basement
  }
}
