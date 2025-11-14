import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_navigation/models/direction_route.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

class RoutingEvent {}

class RoutingEventGetDirection extends RoutingEvent {
  final LatLng from;
  final LatLng to;
  RoutingEventGetDirection({required this.from, required this.to});
}

class RoutingEventUpdateRouteParams extends RoutingEvent {
  final LatLng? originPoint;
  final LatLng? destinationPoint;
  final String? originDescription;
  final String? destinationDescription;
  final VehicleType? vehicleType;
  final MapNavigationViewController? navigationController;
  RoutingEventUpdateRouteParams({
    this.originPoint,
    this.destinationPoint,
    this.navigationController,
    this.vehicleType,
    this.originDescription,
    this.destinationDescription,
  });
}

class RoutingEventUpdateVehicleType extends RoutingEvent {
  final VehicleType vehicleType;
  RoutingEventUpdateVehicleType({required this.vehicleType});
}

class RoutingEventClearDirection extends RoutingEvent {}

class RoutingEventReverseDirection extends RoutingEvent {}

class RoutingEventNativeRouteBuilt extends RoutingEvent {
  final DirectionRoute directionRoute;
  RoutingEventNativeRouteBuilt({required this.directionRoute});
}

class RoutingEventUpdateCurrentLocation extends RoutingEvent {
  final LatLng currentLocation;
  RoutingEventUpdateCurrentLocation({required this.currentLocation});
}
