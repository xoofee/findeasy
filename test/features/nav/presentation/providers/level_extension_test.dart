import 'package:flutter_test/flutter_test.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/utils/level_extension.dart';

void main() {
  group('LevelExtension Tests', () {
    group('getDefaultLevel', () {
      test('should return smallest non-negative level when non-negative levels exist', () {
        // Arrange
        final levels = [
          Level(2.0),
          Level(1.0),
          Level(0.0),
          Level(-1.0),
          Level(-2.0),
        ];
        
        // Act
        final result = levels.getDefaultLevel();
        
        // Assert
        expect(result.value, equals(0.0));
      });
      
      test('should return smallest non-negative level when only non-negative levels exist', () {
        // Arrange
        final levels = [
          Level(5.0),
          Level(1.0),
          Level(3.0),
          Level(0.0),
        ];
        
        // Act
        final result = levels.getDefaultLevel();
        
        // Assert
        expect(result.value, equals(0.0));
      });
      
      test('should return largest negative level when only negative levels exist', () {
        // Arrange
        final levels = [
          Level(-5.0),
          Level(-1.0),
          Level(-3.0),
          Level(-10.0),
        ];
        
        // Act
        final result = levels.getDefaultLevel();
        
        // Assert
        expect(result.value, equals(-1.0));
      });
      
      test('should return smallest non-negative level when non-negative levels exist', () {
        // Arrange
        final levels = [
          Level(2.0),
          Level(1.0),
          Level(-1.0),
          Level(-2.0),
          Level(-5.0),
        ];
        
        // Act
        final result = levels.getDefaultLevel();
        
        // Assert
        expect(result.value, equals(1.0));
      });
      
      test('should return first level when only negative levels exist', () {
        // Arrange
        final levels = [
          Level(-5.0),
          Level(-1.0),
          Level(-3.0),
        ];
        
        // Act
        final result = levels.getDefaultLevel();
        
        // Assert
        expect(result.value, equals(-1.0));
      });
      
      test('should return single level when list has only one element', () {
        // Arrange
        final levels = [Level(1.0)];
        
        // Act
        final result = levels.getDefaultLevel();
        
        // Assert
        expect(result.value, equals(1.0));
      });
      
      test('should return single negative level when list has only one negative element', () {
        // Arrange
        final levels = [Level(-1.0)];
        
        // Act
        final result = levels.getDefaultLevel();
        
        // Assert
        expect(result.value, equals(-1.0));
      });
      
      test('should return single zero level when list has only zero', () {
        // Arrange
        final levels = [Level(0.0)];
        
        // Act
        final result = levels.getDefaultLevel();
        
        // Assert
        expect(result.value, equals(0.0));
      });
      
      test('should throw StateError when list is empty', () {
        // Arrange
        final levels = <Level>[];
        
        // Act & Assert
        expect(() => levels.getDefaultLevel(), throwsStateError);
      });
      
      test('should handle decimal values correctly', () {
        // Arrange
        final levels = [
          Level(1.5),
          Level(0.5),
          Level(-0.5),
          Level(-1.5),
        ];
        
        // Act
        final result = levels.getDefaultLevel();
        
        // Assert
        expect(result.value, equals(0.5));
      });
      
      test('should handle very small decimal values', () {
        // Arrange
        final levels = [
          Level(0.001),
          Level(0.0001),
          Level(-0.0001),
          Level(-0.001),
        ];
        
        // Act
        final result = levels.getDefaultLevel();
        
        // Assert
        expect(result.value, equals(0.0001));
      });
      
      test('should preserve original list order after calling getDefaultLevel', () {
        // Arrange
        final originalLevels = [
          Level(2.0),
          Level(1.0),
          Level(0.0),
          Level(-1.0),
        ];
        final levelsCopy = List<Level>.from(originalLevels);
        
        // Act
        levelsCopy.getDefaultLevel();
        
        // Assert
        expect(levelsCopy, equals(originalLevels));
      });
    });
  });
}
