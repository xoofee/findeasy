import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/domain/entities/navigation_state.dart';
import 'package:findeasy/features/nav/domain/services/navigation_service.dart';
import 'package:findeasy/features/nav/presentation/providers/routing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_providers.g.dart';

final navigationServiceProvider = Provider<NavigationService>((ref) => NavigationService());

@riverpod
class NavigationProvider extends _$NavigationProvider {

  late NavigationService _navigationService;

  NavigationProvider() : super();

  @override
  NavigationState? build() {
    _navigationService = ref.read(navigationServiceProvider);
    
    final mapRoute = ref.watch(routeProvider);
    if (mapRoute == null) return null;
    return null;
  }

  void startNavigation(MapRoute mapRoute) {
    _navigationService.startNavigation(mapRoute);
  }

  void updateCurrentPoi(Poi poi) {

  }
}
