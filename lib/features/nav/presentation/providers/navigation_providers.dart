import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/domain/entities/navigation_state.dart';
import 'package:findeasy/features/nav/domain/services/navigation_service.dart';
import 'package:findeasy/features/nav/presentation/providers/routing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


// final navigationServiceProvider = Provider<NavigationService>((ref) {
//   final mapRoute = ref.watch(routeProvider);
//   if (mapRoute == null) {
//   return NavigationService(mapRoute: mapRoute);
// });

// @riverpod
// class NavigationProvider extends _$NavigationProvider {
//   NavigationProvider() : super();

//   @override
//   NavigationState build() {
//     return NavigationState();
//   }

//   void updateCurrentPoi(Poi poi) {

//   }
// }
