import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

class VietmapReverseModelV4Impl extends VietmapReverseModelV4 {
  double? distanceFromCurrentLocation;

  VietmapReverseModelV4Impl({
    super.entryPoints,
    super.dataOld,
    super.dataNew,
    super.refId,
    super.distance,
    super.categories,
    super.boundaries,
    super.lat,
    super.lng,
    super.address,
    super.name,
    super.display,
    this.distanceFromCurrentLocation,
  });

  factory VietmapReverseModelV4Impl.fromVietmapReverseModelV4(
      VietmapReverseModelV4 model) {
    return VietmapReverseModelV4Impl(
      entryPoints: model.entryPoints,
      dataOld: model.dataOld,
      dataNew: model.dataNew,
      refId: model.refId,
      distance: model.distance,
      categories: model.categories,
      boundaries: model.boundaries,
      lat: model.lat,
      lng: model.lng,
      address: model.address,
      name: model.name,
      display: model.display,
    );
  }

  VietmapPlaceModel toVietmapPlaceModel() {
    return VietmapPlaceModel(
      lat: lat,
      lng: lng,
      address: address,
      name: name,
      display: display,
    );
  }

  factory VietmapReverseModelV4Impl.fromJson(Map<String, dynamic> json) {
    return VietmapReverseModelV4Impl(
      lat: json['lat'],
      lng: json['lng'],
      refId: json['ref_id'],
      distance: json['distance'],
      address: json['address'],
      name: json['name'],
      display: json['display'],
      categories: json['categories'] != null
          ? List<String?>.from(json['categories'])
          : [],
      boundaries: json['boundaries'] != null
          ? List<VietmapBoundaries?>.from(
              json['boundaries'].map((x) => VietmapBoundaries.fromJson(x)))
          : [],
      entryPoints: json['entry_points'] != null
          ? List<VietmapEntryPointModel?>.from(json['entry_points']
              .map((x) => VietmapEntryPointModel.fromJson(x)))
          : [],
      dataOld: json['data_old'] != null
          ? VietmapReverseModelV4.fromJson(json['data_old'])
          : null,
      dataNew: json['data_new'] != null
          ? VietmapReverseModelV4.fromJson(json['data_new'])
          : null,
    );
  }
}
