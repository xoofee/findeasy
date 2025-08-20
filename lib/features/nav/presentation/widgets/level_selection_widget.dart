import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';

/// Compact widget for selecting different building levels
/// Shows max 4 floors at once, scrollable if more floors exist
class LevelSelectionWidget extends ConsumerWidget {
  const LevelSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLevel = ref.watch(currentLevelProvider);
    final availableLevels = ref.watch(availableLevelsProvider);
    
    if (availableLevels.isEmpty || currentLevel == null) {
      return const SizedBox.shrink();
    }

    // Sort levels to ensure proper ordering
    final sortedLevels = List<Level>.from(availableLevels)..sort((a, b) => b.compareTo(a));

    // print(sortedLevels);
    
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          maxHeight: 200, // Limit height to show max ~4 floors
          minHeight: 120, // Minimum height for better UX
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sortedLevels.map((level) => _buildLevelItem(
              level: level,
              isSelected: level == currentLevel,
              onTap: () => _selectLevel(ref, level),
            )).toList(),
          ),
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
        width: 60, // Fixed width for compact design
        height: 40, // Fixed height for each level item
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            _getLevelDisplayName(level),
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

  String _getLevelDisplayName(Level level) {
    if (level.value == 0) return 'G';
    if (level.value > 0) return '${level.value.toInt()}';
    return '${level.value.toInt()}'; // e.g., -1 for basement
  }

  void _selectLevel(WidgetRef ref, Level level) {
    ref.read(currentLevelProvider.notifier).state = level;
  }
}