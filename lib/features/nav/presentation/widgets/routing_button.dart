import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:findeasy/features/nav/presentation/providers/map_providers.dart';


/*
TODO: implement the following logic in the mode transition
/// - Without start/destination: RoutingButton() - opens route planning page
/// - With destination: RoutingButton(destination: poi) - opens route planning page with 
pre-selected destination
/// - With start point: RoutingButton(startPoint: poi) - opens route planning page with 
pre-selected start point
/// 
/// This allows users to jump directly to routing with either start or destination selected,
/// useful for both "到這去" (Go Here) and "從這里出發" (Depart from Here) functionality.
class RoutingButton extends StatelessWidget {

*/

/// Button widget for switching to routing mode
/// 
/// This button toggles the navigation mode from home to routing,
/// allowing users to plan routes without navigating to a separate page.
class RoutingButton extends ConsumerWidget {

  const RoutingButton({
    super.key,

  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return 
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Switch to routing mode instead of navigating to a separate page
                  ref.read(navigationModeProvider.notifier).state = AppNavigationMode.routing;
                },
                child: const Column(
                  children: [
                     Center(
                       child: SizedBox(
                         width: 32,
                         height: 24,
                         child: Icon(
                           Icons.turn_sharp_right,
                           color: Colors.orange,
                           size: 26,
                         ),
                       ),
                     ),
                    // const SizedBox(height: 0),
                     Text(
                      '路線',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        );
  }
}