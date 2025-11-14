import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

import '../components/select_map_tiles_modal.dart';

class MapEvent {}

class MapEventSearchAddress extends MapEvent {
  final String address;
  final LatLng? focus;
  MapEventSearchAddress({required this.address, this.focus});
}

class MapEventGetDetailAddress extends MapEvent {
  final VietmapAutocompleteModelV4 model;

  MapEventGetDetailAddress(this.model);
}

class MapEventGetDetailAddressById extends MapEvent {
  final String refId;

  MapEventGetDetailAddressById(this.refId);
}

class MapEventGetEntryPointDetailAddress extends MapEvent {
  final String refId;

  MapEventGetEntryPointDetailAddress(this.refId);
}

class MapEventGetDirection extends MapEvent {
  final LatLng from;
  final LatLng to;
  MapEventGetDirection({required this.from, required this.to});
}

class MapEventGetAddressFromCoordinate extends MapEvent {
  final LatLng coordinate;
  MapEventGetAddressFromCoordinate({required this.coordinate});
}

class MapEventOnUserLongTapOnMap extends MapEvent {
  final LatLng coordinate;

  MapEventOnUserLongTapOnMap(this.coordinate);
}

class MapEventGetHistorySearch extends MapEvent {}

class MapEventGetAddressFromCategory extends MapEvent {
  final int categoryCode;
  final LatLng? latLng;
  final String? name;
  MapEventGetAddressFromCategory({
    this.latLng,
    required this.categoryCode,
    this.name,
  });
}

class MapEventShowPlaceDetail extends MapEvent {
  final VietmapPlaceModel model;

  MapEventShowPlaceDetail(this.model);
}

class MapEventUserClickOnMapPoint extends MapEvent {
  final String placeName;
  final LatLng coordinate;
  final String placeShortName;
  final bool isSendingEvent;

  MapEventUserClickOnMapPoint({
    required this.placeName,
    required this.placeShortName,
    required this.coordinate,
    this.isSendingEvent = true,
  });
}

class MapEventChangeMapTiles extends MapEvent {
  final MapTiles mapType;

  MapEventChangeMapTiles(this.mapType);
}

class MapEventReceiveCreateRoute extends MapEvent {}

class MapEventRequestPermissionLocation extends MapEvent {
  final VietmapModel response;
  final bool isStartNavigation;
  MapEventRequestPermissionLocation(
      {required this.response, this.isStartNavigation = false});
}
