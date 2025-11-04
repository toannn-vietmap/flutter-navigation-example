import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

class VietMapRoutingParamsImpl extends VietMapRoutingParams {
  String apiKey;
  String? apiVersion;
  LatLng? originPoint;
  String? originDescription;
  String? destinationDescription;
  LatLng? destinationPoint;
  VehicleType vehicleType;
  MapNavigationViewController? navigationController;
  List<LatLng>? waypoints;

  VietMapRoutingParamsImpl({
    required this.apiKey,
    this.originDescription,
    this.navigationController,
    this.destinationDescription,
    required this.originPoint,
    required this.destinationPoint,
    this.vehicleType = VehicleType.car,
    this.apiVersion = '1.1',
    bool optimize = false,
    this.waypoints,
  }) : super(
          points: waypoints ?? [originPoint!, destinationPoint!],
          vehicle: vehicleType,
          optimize: optimize,
        );

  @override
  toMap() {
    final map = super.toMap();
    map['api-version'] = apiVersion;
    return map;
  }
}
