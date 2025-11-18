import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

class RoutingHeaderModel {
  final bool isFromOrigin;
  final bool isEditingWaypoints;
  final int? indexWaypoint;
  final String? addressText;
  final LatLng? defaultLocation;

  RoutingHeaderModel({
    required this.isFromOrigin,
    required this.isEditingWaypoints,
    this.addressText,
    this.defaultLocation,
    this.indexWaypoint,
  });

  factory RoutingHeaderModel.fromJson(Map<String, dynamic> json) {
    return RoutingHeaderModel(
      isFromOrigin: json['isFromOrigin'],
      isEditingWaypoints: json['isEditingWaypoints'],
      addressText: json['addressText'],
      defaultLocation: json['defaultLocation'] != null
          ? LatLng(
              json['defaultLocation']['latitude'],
              json['defaultLocation']['longitude'],
            )
          : null,
      indexWaypoint: json['indexWaypoint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFromOrigin': isFromOrigin,
      'addressText': addressText,
      'defaultLocation': defaultLocation != null
          ? {
              'latitude': defaultLocation!.latitude,
              'longitude': defaultLocation!.longitude,
            }
          : null,
      'isEditingWaypoints': isEditingWaypoints,
      'indexWaypoint': indexWaypoint,
    };
  }
}
