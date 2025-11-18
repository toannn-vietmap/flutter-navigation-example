import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_navigation/models/direction_route.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/data/models/point_model.dart';

class RoutingEvent {}

class RoutingEventGetDirection extends RoutingEvent {
  final PointModel from;
  final PointModel to;
  RoutingEventGetDirection({required this.from, required this.to});
}

class RoutingEventUpdateRouteParams extends RoutingEvent {
  // final LatLng? originPoint;
  // final LatLng? destinationPoint;
  // final String? originDescription;
  // final String? destinationDescription;
  final PointModel? originPoint;
  final PointModel? destinationPoint;
  final VehicleType? vehicleType;
  final MapNavigationViewController? navigationController;
  RoutingEventUpdateRouteParams({
    this.originPoint,
    this.destinationPoint,
    this.navigationController,
    this.vehicleType,
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

class RoutingEventAddWaypoint extends RoutingEvent {
  final VietmapAutocompleteModelV4? newPoint;
  // use for case change address of existed waypoint
  final bool? isExistedWaypoints;
  // required if isExistedWaypoints is true
  final int? indexWaypoint;
  RoutingEventAddWaypoint(
      {this.newPoint, this.isExistedWaypoints, this.indexWaypoint});
}

class RoutingEventRemoveWaypoint extends RoutingEvent {
  final int index;
  RoutingEventRemoveWaypoint({required this.index});
}

class RoutingEventReorderWaypoint extends RoutingEvent {
  final int oldIndex;
  final int newIndex;
  RoutingEventReorderWaypoint({required this.oldIndex, required this.newIndex});
}

class RoutingEventPickNewWaypoint extends RoutingEvent {
  final PointModel? newPoint;
  // use for case change address of existed waypoint
  final bool? isExistedWaypoints;
  // required if isExistedWaypoints is true
  final int? indexWaypoint;
  RoutingEventPickNewWaypoint(
      {this.newPoint, this.isExistedWaypoints, this.indexWaypoint});
}

class RoutingEventSubmitModifyWaypoints extends RoutingEvent {
  final bool isModify;
  RoutingEventSubmitModifyWaypoints({required this.isModify});
}
