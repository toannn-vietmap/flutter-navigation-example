import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';

class PointModel {
  LatLng location;
  String? description;

  PointModel({
    required this.location,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'description': description,
    };
  }

  factory PointModel.fromJson(Map<String, dynamic> json) {
    return PointModel(
      location: LatLng(
        json['location']['latitude'],
        json['location']['longitude'],
      ),
      description: json['description'],
    );
  }

  static List<LatLng>? toLatLngList(List<PointModel>? points) {
    return points?.map((point) => point.location).toList();
  }

  LatLng toLatLng() {
    return location;
  }
}
