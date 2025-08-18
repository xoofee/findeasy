import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';

/// Widget for selecting different building levels
class LevelSelectionWidget extends ConsumerWidget {
  const LevelSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLevel = ref.watch(currentLevelProvider);
    final availableLevels = ref.watch(availableLevelsProvider);
    
    if (availableLevels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: () => _goToNextLevel(ref, availableLevels),
            tooltip: 'Next Level',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getLevelDisplayName(currentLevel),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => _goToPreviousLevel(ref, availableLevels),
            tooltip: 'Previous Level',
          ),
        ],
      ),
    );
  }

  void _goToNextLevel(WidgetRef ref, List<Level> availableLevels) {
    final currentLevel = ref.read(currentLevelProvider);
    final currentIndex = availableLevels.indexOf(currentLevel);
    if (currentIndex < availableLevels.length - 1) {
      ref.read(currentLevelProvider.notifier).state = availableLevels[currentIndex + 1];
    }
  }

  void _goToPreviousLevel(WidgetRef ref, List<Level> availableLevels) {
    final currentLevel = ref.read(currentLevelProvider);
    final currentIndex = availableLevels.indexOf(currentLevel);
    if (currentIndex > 0) {
      ref.read(currentLevelProvider.notifier).state = availableLevels[currentIndex - 1];
    }
  }

  String _getLevelDisplayName(Level level) {
    if (level.value == 0) return 'Ground Floor';
    if (level.value > 0) return 'Level ${level.value.toInt()}';
    return 'Level ${level.value.toInt()}'; // e.g., Level -1 for basement
  }
}