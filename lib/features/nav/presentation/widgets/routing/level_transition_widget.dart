import 'package:findeasy/features/nav/presentation/utils/level_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/routing_providers.dart';
import 'package:findeasy/features/nav/presentation/providers/map_providers.dart';

/// Widget that shows level transition information when routing between POIs
/// Shows one level if start and end are on same floor, or two levels with arrow if different floors
class LevelTransitionWidget extends ConsumerWidget {
  const LevelTransitionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeProvider);
    final currentLevel = ref.watch(currentLevelProvider);
    
    // Only show when there's a route
    if (route == null) {
      return const SizedBox.shrink();
    }

    final startLevel = route.originLevel;
    final endLevel = route.destinationLevel;
    final hasLevelChange = route.hasLevelChange;
    final goesUp = startLevel.value < endLevel.value;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(8),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.1),
      //       blurRadius: 4,
      //       offset: const Offset(0, 1),
      //     ),
      //   ],
      // ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 200,
          minHeight: 60,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasLevelChange) ...[
              // Show higher level on top, lower level on bottom
              _buildLevelItem(
                level: goesUp ? endLevel : startLevel,
                isSelected: (goesUp ? endLevel : startLevel) == currentLevel,
                onTap: () => _selectLevel(ref, goesUp ? endLevel : startLevel),
              ),
              // Arrow between levels
              SizedBox(
                width: 30,
                height: 20,
                child: Icon(
                  goesUp? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              // Show lower level on bottom
              _buildLevelItem(
                level: goesUp ? startLevel : endLevel,
                isSelected: (goesUp ? startLevel : endLevel) == currentLevel,
                onTap: () => _selectLevel(ref, goesUp ? startLevel : endLevel),
              ),
            ] else ...[
              // Show single level if no level change
              _buildLevelItem(
                level: startLevel,
                isSelected: startLevel == currentLevel,
                onTap: () => _selectLevel(ref, startLevel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLevelItem({
    required Level level,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            level.displayName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _selectLevel(WidgetRef ref, Level level) {
    ref.read(currentLevelProvider.notifier).setLevel(level);
  }
}
