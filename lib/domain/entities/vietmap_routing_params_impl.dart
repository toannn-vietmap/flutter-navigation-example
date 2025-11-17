import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/data/models/point_model.dart';

class VietMapRoutingParamsImpl extends VietMapRoutingParams {
  String apiKey;
  String? apiVersion;
  PointModel? originPoint;
  PointModel? destinationPoint;
  MapNavigationViewController? navigationController;
  List<PointModel>? waypoints;

  VietMapRoutingParamsImpl({
    required this.apiKey,
    this.navigationController,
    required this.originPoint,
    required this.destinationPoint,
    super.vehicle,
    this.apiVersion = '1.1',
    super.optimize,
    this.waypoints,
  }) : super(
          points: PointModel.toLatLngList(waypoints) ?? [],
        );

  @override
  toMap() {
    final map = super.toMap();
    map['api-version'] = apiVersion;
    return map;
  }

  VietMapRoutingParamsImpl copyWith(VietMapRoutingParamsImpl params) {
    return VietMapRoutingParamsImpl(
      apiKey: apiKey,
      apiVersion: apiVersion,
      originPoint: params.originPoint ?? originPoint,
      destinationPoint: params.destinationPoint ?? destinationPoint,
      vehicle: params.vehicle,
      optimize: params.optimize,
      navigationController: params.navigationController ?? navigationController,
      waypoints: params.waypoints ?? waypoints,
    );
  }
}
