/*

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/widgets/level_selection_widget.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';

void main() {

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

  runApp(
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

}

*/