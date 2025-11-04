import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

class VietmapPlaceModelImpl extends VietmapPlaceModel {
  VietmapPlaceModelImpl({
    String? display,
    String? name,
    double? lat,
    double? lng,
    String? address,
    String? hsNum,
    String? street,
    int? cityId,
    String? city,
    int? districtId,
    String? district,
    int? wardId,
    String? ward,
  });

  VietmapPlaceModelImpl.fromJson(Map<String, dynamic> json) {
    display = json['display'];
    name = json['name'];
    hsNum = json['hs_num'];
    street = json['street'];
    address = json['address'];
    cityId = json['city_id'];
    city = json['city'];
    districtId = json['district_id'];
    district = json['district'];
    wardId = json['ward_id'];
    ward = json['ward'];
    lat = json['lat'];
    lng = json['lng'];
  }

  String? getFullAddress() {
    if (address != null && address!.isNotEmpty) {
      return address;
    }
    if (display != null && display!.isNotEmpty) {
      return display;
    }
    return name;
  }
}
