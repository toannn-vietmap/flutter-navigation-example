import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_map/components/permission_location_widget.dart';
import 'package:vietmap_map/features/map_screen/maps_screen.dart';
import 'package:vietmap_map/features/pick_address_screen/pick_address_screen.dart';
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
  static const String requestLocationPermissionScreen =
      '/requestLocationPermissionScreen';
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
      builder: (context, state) => const SearchScreen(),
      name: Routes.searchScreen,
    ),
    GoRoute(
      path: Routes.routingScreen,
      builder: (context, state) => const RoutingScreen(),
      name: Routes.routingScreen,
    ),
    GoRoute(
      path: Routes.pickAddressScreen,
      builder: (context, state) => const PickAddressScreen(),
      name: Routes.pickAddressScreen,
    ),
    GoRoute(
      path: Routes.searchAddressForRoutingScreen,
      builder: (context, state) => const SearchAddress(),
      name: Routes.searchAddressForRoutingScreen,
    ),
    GoRoute(
      path: Routes.requestLocationPermissionScreen,
      builder: (context, state) => PermissionLocationWidget(
        pathRiderect: state.pathParameters['pathRiderect'],
      ),
      name: Routes.requestLocationPermissionScreen,
    ),
  ],
  redirect: (context, state) async {
    debugPrint('Checking location permission for route:');
    bool hasPermission = false;
    await Geolocator.checkPermission().then((permission) {
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        hasPermission = false;
      } else {
        hasPermission = true;
      }
    });
    return hasPermission
        ? null
        : '${Routes.requestLocationPermissionScreen}?pathRiderect=${state.name}';
  },
);
