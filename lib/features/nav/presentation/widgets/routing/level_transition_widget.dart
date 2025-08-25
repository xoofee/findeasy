import 'package:findeasy/features/nav/presentation/utils/level_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/routing_providers.dart';

/// Widget that shows level transition information when routing between POIs
/// Shows one level if start and end are on same floor, or two levels with arrow if different floors
class LevelTransitionWidget extends ConsumerWidget {
  const LevelTransitionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeBetweenPoisProvider);
    
    // Only show when there's a route
    if (route == null) {
      return const SizedBox.shrink();
    }

    final startLevel = route.startLevel;
    final endLevel = route.endLevel;
    final hasLevelChange = route.hasLevelChange;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
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
                level: startLevel.value > endLevel.value ? startLevel : endLevel,
                isSelected: false,
                label: startLevel.value > endLevel.value ? 'From' : 'To',
              ),
              // Arrow between levels
              Container(
                width: 30,
                height: 20,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              // Show lower level on bottom
              _buildLevelItem(
                level: startLevel.value > endLevel.value ? endLevel : startLevel,
                isSelected: false,
                label: startLevel.value > endLevel.value ? 'To' : 'From',
              ),
            ] else ...[
              // Show single level if no level change
              _buildLevelItem(
                level: startLevel,
                isSelected: false,
                label: 'Floor',
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
    required String label,
  }) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            level.displayName,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
