import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:findeasy/features/nav/presentation/providers/routing_providers.dart';

class RoutingSummaryWidget extends ConsumerWidget {
  const RoutingSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeProvider);
    if (route == null) return const SizedBox.shrink();

    final walkSpeedMetersPerMinute = 70.0; // Average adult indoor walking speed: 1.2–1.5 m/s (≈ 4.3–5.4 km/h). TODO: get from settings

    return Container(
      margin: const EdgeInsets.all(16.0),
      height: 56.0, // Slightly higher than the 48px button
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Row(
          children: [
            // Distance info
            Expanded(
              child: _buildCompactInfoCard(
                icon: Icons.straighten,
                value: '${route.distance.round()}',
                unit: '米',
                color: Colors.blue[600]!,
              ),
            ),
            
            const SizedBox(width: 8.0),
            
            // Time info
            Expanded(
              child: _buildCompactInfoCard(
                icon: Icons.access_time,
                value: '${(route.distance / walkSpeedMetersPerMinute).round()}',
                unit: '分鐘',
                color: Colors.blue[600]!,
              ),
            ),
            
            const SizedBox(width: 16.0),
            
            // Start navigation button
            SizedBox(
              height: 48.0,
              child: ElevatedButton(
                onPressed: () {
                  // ref.read(navigationControllerProvider.notifier).startNavigation(route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.navigation, size: 20.0),
                    const SizedBox(width: 8.0),
                    Text(
                      '開始導航',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfoCard({
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      height: 48.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        // color: color.withOpacity(0.1),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        // border: Border.all(
        //   color: color.withOpacity(0.2),
        //   width: 1.0,
        // ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 20.0,
          ),
          const SizedBox(width: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 2.0),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12.0,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}