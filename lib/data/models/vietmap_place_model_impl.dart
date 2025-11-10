import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

class VietmapPlaceModelImpl extends VietmapPlaceModel {
  VietmapAutocompleteModel? newLocation;

  VietmapPlaceModelImpl({
    super.display,
    super.name,
    super.lat,
    super.lng,
    super.address,
    super.hsNum,
    super.street,
    super.cityId,
    super.city,
    super.districtId,
    super.district,
    super.wardId,
    super.ward,
    this.newLocation,
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
    newLocation = json['new_location'] != null
        ? VietmapAutocompleteModel.fromJson(json['new_location'])
        : null;
  }

  String? getFullWithoutName() {
    var data = [hsNum, street, ward, district, city];
    return data
        .where((element) => element != null && element.isNotEmpty)
        .join(', ');
  }

  String? getFullName() {
    if (name != null && name!.isNotEmpty) {
      return name;
    }
    if (address != null && address!.isNotEmpty) {
      return address;
    }
    return '';
  }
}
