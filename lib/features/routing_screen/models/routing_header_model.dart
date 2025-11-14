import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

class RoutingHeaderModel {
  final bool isFromOrigin;
  final String? addressText;
  final LatLng? defaultLocation;

  RoutingHeaderModel(
      {required this.isFromOrigin, this.addressText, this.defaultLocation});

  factory RoutingHeaderModel.fromJson(Map<String, dynamic> json) {
    return RoutingHeaderModel(
      isFromOrigin: json['isFromOrigin'],
      addressText: json['addressText'],
      defaultLocation: json['defaultLocation'] != null
          ? LatLng(
              json['defaultLocation']['latitude'],
              json['defaultLocation']['longitude'],
            )
          : null,
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
    };
  }
}
