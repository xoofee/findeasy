/*

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/widgets/level_selection_widget.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LevelSelectionWidget Integration Tests', () {
    // Fake level data for testing
    final List<Level> fakeLevels = [
      Level(-3.0), // Basement 3
      Level(-2.0), // Basement 2
      Level(-1.0), // Basement 1
      Level(0.0),  // Ground Floor
      Level(1.0),  // Level 1
      Level(2.0),  // Level 2
      Level(3.0),  // Level 3
      Level(4.0),  // Level 4
      Level(5.0),  // Level 5
      Level(6.0),  // Level 6
      Level(7.0),  // Level 7
      Level(8.0),  // Level 8
    ];

    // Note: We're using the real providers with overrides instead of mock providers

    testWidgets('should display level selection widget with fake data', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override the providers with our fake data
            currentLevelProvider.overrideWith((ref) => CurrentLevelController(ref)..state = Level(0.0)),
            availableLevelsProvider.overrideWith((ref) => fakeLevels),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: LevelSelectionWidget(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      while (true) {
        await tester.pump(const Duration(milliseconds: 100)); // Pump frames periodically
        await Future.delayed(const Duration(milliseconds: 100)); // Small delay to avoid blocking
      }
    });

    testWidgets('should handle scrolling with many levels', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentLevelProvider.overrideWith((ref) => CurrentLevelController(ref)..state = Level(0.0)),
            availableLevelsProvider.overrideWith((ref) => fakeLevels),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: LevelSelectionWidget(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the scrollable area
      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);

      // Test scrolling down
      await tester.drag(scrollable, const Offset(0, -100));
      await tester.pumpAndSettle();

      // Test scrolling up
      await tester.drag(scrollable, const Offset(0, 100));
      await tester.pumpAndSettle();
    });

    testWidgets('should display correct level labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentLevelProvider.overrideWith((ref) => CurrentLevelController(ref)..state = Level(0.0)),
            availableLevelsProvider.overrideWith((ref) => fakeLevels),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: LevelSelectionWidget(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify ground floor is displayed as 'G'
      expect(find.text('G'), findsOneWidget);
      
      // Verify positive levels are displayed as numbers
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      
      // Verify negative levels are displayed as numbers
      expect(find.text('-1'), findsOneWidget);
      expect(find.text('-2'), findsOneWidget);
    });

    testWidgets('should maintain compact dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentLevelProvider.overrideWith((ref) => CurrentLevelController(ref)..state = Level(0.0)),
            availableLevelsProvider.overrideWith((ref) => fakeLevels),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: LevelSelectionWidget(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the main container
      final container = find.byType(Container).first;
      final RenderBox renderBox = tester.renderObject(container);
      
      // Verify the widget maintains compact dimensions
      // Width should be around 60px + margins + padding
      expect(renderBox.size.width, lessThan(100));
      
      // Height should be constrained (max 200px, min 120px)
      expect(renderBox.size.height, greaterThan(100));
      expect(renderBox.size.height, lessThan(250));
    });

    testWidgets('should handle empty levels gracefully', (WidgetTester tester) async {
      // Test with empty levels list
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentLevelProvider.overrideWith((ref) => CurrentLevelController(ref)..state = Level(0.0)),
            availableLevelsProvider.overrideWith((ref) => <Level>[]),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: LevelSelectionWidget(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Widget should handle empty state gracefully
      // Either show nothing or show a placeholder
      expect(find.byType(LevelSelectionWidget), findsOneWidget);
    });

    testWidgets('should handle single level', (WidgetTester tester) async {
      // Test with single level
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentLevelProvider.overrideWith((ref) => CurrentLevelController(ref)..state = Level(1.0)),
            availableLevelsProvider.overrideWith((ref) => [Level(1.0)]),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: LevelSelectionWidget(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display the single level
      expect(find.text('1'), findsOneWidget);
    });
  });
}

*/