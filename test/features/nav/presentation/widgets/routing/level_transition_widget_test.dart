import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/widgets/routing/level_transition_widget.dart';
import 'package:findeasy/features/nav/presentation/providers/routing_providers.dart';
import 'package:latlong2/latlong.dart' as latlong2;

void main() {
  group('LevelTransitionWidget Tests', () {
    late ProviderContainer container;
    late Poi startPoi;
    late Poi endPoi;
    late Level level1;
    late Level level2;

    setUp(() {
      container = ProviderContainer();
      
      // Create test levels
      level1 = Level(1.0); // F2
      level2 = Level(2.0); // F3
      
      // Create test POIs
      startPoi = Poi(
        id: 1,
        name: 'Start POI',
        type: PoiType.unknown,
        position: const latlong2.LatLng(0, 0),
        center: const latlong2.LatLng(0, 0),
        level: level1,
        isGraphNode: true,
      );
      
      endPoi = Poi(
        id: 2,
        name: 'End POI',
        type: PoiType.unknown,
        position: const latlong2.LatLng(0, 0),
        center: const latlong2.LatLng(0, 0),
        level: level2,
        isGraphNode: true,
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('shows single level when no level change', (WidgetTester tester) async {
      // Create a route with same level
      final route = MapRoute(
        path: [1, 2],
        geometry: [],
        distance: 100.0,
        instructions: [],
        startPoi: startPoi,
        endPoi: startPoi, // Same POI, same level
        startLevel: level1,
        endLevel: level1,
      );

      // Override the provider
      container.updateOverrides([
        routeBetweenPoisProvider.overrideWithValue(route),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: Scaffold(
              body: LevelTransitionWidget(),
            ),
          ),
        ),
      );

      // Should show single level
      expect(find.text('F2'), findsOneWidget);
      expect(find.text('Floor'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });

    testWidgets('shows two levels with arrow when level change', (WidgetTester tester) async {
      // Create a route with different levels
      final route = MapRoute(
        path: [1, 2],
        geometry: [],
        distance: 100.0,
        instructions: [],
        startPoi: startPoi,
        endPoi: endPoi,
        startLevel: level1,
        endLevel: level2,
      );

      // Override the provider
      container.updateOverrides([
        routeBetweenPoisProvider.overrideWithValue(route),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: Scaffold(
              body: LevelTransitionWidget(),
            ),
          ),
        ),
      );

      // Should show both levels with arrow
      expect(find.text('F3'), findsOneWidget); // Higher level on top
      expect(find.text('F2'), findsOneWidget); // Lower level on bottom
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('shows nothing when no route', (WidgetTester tester) async {
      // No route override, so provider returns null
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: Scaffold(
              body: LevelTransitionWidget(),
            ),
          ),
        ),
      );

      // Should show nothing
      expect(find.byType(LevelTransitionWidget), findsOneWidget);
      expect(find.text('F2'), findsNothing);
      expect(find.text('F3'), findsNothing);
    });
  });
}
