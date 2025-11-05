import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

class VietMapRoutingParamsImpl extends VietMapRoutingParams {
  String apiKey;
  String? apiVersion;
  LatLng? originPoint;
  String? originDescription;
  String? destinationDescription;
  LatLng? destinationPoint;
  MapNavigationViewController? navigationController;
  List<LatLng>? waypoints;

  VietMapRoutingParamsImpl({
    required this.apiKey,
    this.originDescription,
    this.navigationController,
    this.destinationDescription,
    required this.originPoint,
    required this.destinationPoint,
    super.vehicle,
    this.apiVersion = '1.1',
    super.optimize,
    this.waypoints,
  }) : super(
          points: waypoints ?? [],
        );

  @override
  toMap() {
    final map = super.toMap();
    map['api-version'] = apiVersion;
    return map;
  }
}
