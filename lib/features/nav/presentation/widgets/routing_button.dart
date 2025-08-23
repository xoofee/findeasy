import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:findeasy/features/nav/presentation/widgets/car_parking_dialog.dart';
import 'package:findeasy/features/nav/presentation/providers/car_parking_providers.dart';
import 'package:findeasy/features/nav/presentation/pages/routing_page.dart';

class RoutingButton extends StatelessWidget {

  
  const RoutingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RoutingPage(),
                    ),
                  );
                },
                child: const Column(
                  children: [
                     Center(
                       child: SizedBox(
                         width: 32,
                         height: 24,
                         child: Icon(
                           Icons.route,
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