import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SystemMenuButton extends ConsumerWidget {
  const SystemMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

      // Three-dot system menu button
    return PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: Colors.grey[600],
          size: 24,
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        onSelected: (String value) {
          // Handle menu item selection
          switch (value) {
            case 'clear_place':
              // TODO: Show saved searches
              ref.read(currentPlaceProvider.notifier).state = null;
              break;
            case 'refresh_position':
              refreshDevicePosition(ref);
              break;
            case 'clear_history':
              // TODO: Clear search history
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'clear_place',
            child: Row(
              children: [
                Icon(Icons.bookmark, size: 20),
                SizedBox(width: 12),
                Text('move to a new place'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'refresh_position',
            child: Row(
              children: [
                Icon(Icons.settings, size: 20),
                SizedBox(width: 12),
                Text('refresh position'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'clear_history',
            child: Row(
              children: [
                Icon(Icons.clear_all, size: 20),
                SizedBox(width: 12),
                Text('清除歷史'),
              ],
            ),
          ),
        ],
      );

    return const Placeholder();
  }
}