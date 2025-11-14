import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/features/map_screen/maps_screen.dart';
import 'package:vietmap_map/features/pick_address_screen/pick_address_screen.dart';
import 'package:vietmap_map/features/routing_screen/models/routing_header_model.dart';
import 'package:vietmap_map/features/routing_screen/models/routing_params_model.dart';
import 'package:vietmap_map/features/routing_screen/routing_screen.dart';
import 'package:vietmap_map/features/search_screen/search_screen.dart';
import 'package:vietmap_map/features/routing_screen/search_address.dart';

class Routes {
  static const String mapScreen = '/mapScreen';
  static const String searchScreen = '/searchScreen';
  static const String routingScreen = '/routingScreen';
  static const String pickAddressScreen = '/pickAddressScreen';
  static const String searchAddressForRoutingScreen =
      '/searchAddressForRouting';
}

final route = GoRouter(
  initialLocation: Routes.mapScreen,
  routes: [
    GoRoute(
      path: Routes.mapScreen,
      builder: (context, state) => const MapScreen(),
      name: Routes.mapScreen,
    ),
    GoRoute(
      path: Routes.searchScreen,
      builder: (context, state) {
        var defaultLocation = state.extra as LatLng?;
        return SearchScreen(
          defaultLocation: defaultLocation,
        );
      },
      name: Routes.searchScreen,
    ),
    GoRoute(
      path: Routes.routingScreen,
      builder: (context, state) {
        var routingParams = state.extra as RoutingParamsModel?;
        return RoutingScreen(
          args: routingParams,
        );
      },
      name: Routes.routingScreen,
    ),
    GoRoute(
      path: Routes.pickAddressScreen,
      builder: (context, state) => const PickAddressScreen(),
      name: Routes.pickAddressScreen,
    ),
    GoRoute(
      path: Routes.searchAddressForRoutingScreen,
      builder: (context, state) {
        return SearchAddress(
          args: state.extra as RoutingHeaderModel?,
        );
      },
      name: Routes.searchAddressForRoutingScreen,
    ),
  ],
);
