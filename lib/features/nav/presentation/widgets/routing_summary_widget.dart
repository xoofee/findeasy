import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:findeasy/features/nav/presentation/providers/routing_providers.dart';



class RoutingSummaryWidget extends ConsumerWidget {
  const RoutingSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(routeProvider);
    return const Placeholder();
  }
}