import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vietmap_map/data/models/vietmap_reverse_model_v4_impl.dart';

import 'package:vietmap_map/domain/repository/history_search_repositories.dart';
import 'package:vietmap_map/domain/usecase/add_history_search_usecase.dart';
import 'package:vietmap_map/method_channel/vietmap_automotive_plugin.dart';
import '../../../domain/usecase/get_history_search_usecase.dart';
import 'map_event.dart';
import 'map_state.dart';
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final VietMapAutomotivePlugin _vietMapAutomotivePlugin =
      VietMapAutomotivePlugin.instance;
  MapBloc() : super(const MapStateInitial()) {
    on<MapEventSearchAddress>(_onMapEventSearchAddress);
    on<MapEventGetDetailAddress>(_onMapEventGetDetailAddress);
    on<MapEventGetDetailAddressById>(_onMapEventGetDetailAddressById);
    on<MapEventGetEntryPointDetailAddress>(
        _onMapEventGetEntryPointDetailAddress);

    on<MapEventGetDirection>(_onMapEventGetDirection);
    on<MapEventGetAddressFromCoordinate>(_onMapEventGetAddressFromCoordinate);
    on<MapEventOnUserLongTapOnMap>(_onMapEventOnUserLongTapOnMap);
    on<MapEventGetHistorySearch>(_onMapEventGetHistorySearch);
    on<MapEventGetAddressFromCategory>(_onMapEventGetAddressFromCategory);
    on<MapEventShowPlaceDetail>(_onMapEventShowPlaceDetail);
    on<MapEventUserClickOnMapPoint>(_onMapEventUserClickOnMapPoint);
    on<MapEventChangeMapTiles>(_onMapEventChangeMapTiles);
  }

  _onMapEventChangeMapTiles(
      MapEventChangeMapTiles event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    emit(MapStateChangeMapTilesSuccess(event.mapType, state));
  }

  _onMapEventUserClickOnMapPoint(
      MapEventUserClickOnMapPoint event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    // num? distanceToLocation;

    await Future.wait(
      [
        // _vietMapAutomotivePlugin
        //     .getDistanceToLocation(
        //   location:
        //       LatLng(event.coordinate.latitude, event.coordinate.longitude),
        // )
        //     .then(
        //   (result) {
        //     distanceToLocation = result;
        //   },
        // ),
        // if (event.isSendingEvent)
        //   _vietMapAutomotivePlugin.addMarkers(
        //     markers: [
        //       VietmapMarkerModel(
        //         lat: event.coordinate.latitude,
        //         lng: event.coordinate.longitude,
        //         title: event.placeName,
        //         snippet: event.placeShortName,
        //       )
        //     ],
        //   )
      ],
    );
    VietmapReverseModelV4Impl r = VietmapReverseModelV4Impl(
      lat: event.coordinate.latitude,
      lng: event.coordinate.longitude,
      address: event.placeName,
      name: event.placeShortName,
      // distanceFromCurrentLocation: distanceToLocation?.toDouble() ?? 0.0,
    );
    emit(MapStateGetLocationFromCoordinateSuccess(r, state));
  }

  _onMapEventShowPlaceDetail(
      MapEventShowPlaceDetail event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    var reverseModel = VietmapReverseModelV4Impl(
      lat: event.model.lat ?? 0,
      lng: event.model.lng ?? 0,
      address: event.model.address ?? '',
      name: event.model.name ?? '',
    );
    emit(MapStateGetLocationFromCoordinateSuccess(reverseModel, state));
  }

  _onMapEventGetAddressFromCategory(
      MapEventGetAddressFromCategory event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();

    // var response =
    //     await GetLocationFromCategoryUseCase(VietmapApiRepositories()).call(
    //         LocationPoint(
    //             lat: event.latLng?.latitude ?? 0,
    //             long: event.latLng?.longitude ?? 0,
    //             category: event.categoryCode));
    var response = await Vietmap.autocompleteV4(
      VietmapAutocompleteParamsV4(
        text: event.name ?? '',
        circleRadius: 5000,
        cats: '${[event.categoryCode]}',
        focusLocation: event.latLng,
      ),
    );
    var places = <VietmapAutocompleteModelV4>[];
    response.fold((l) => emit(MapStateSearchAddressError('Error', state)), (r) {
      places = r;
    });
    var placeDetails = await _getPlaceDetail(places);
    emit(MapStateGetCategoryAddressSuccess(placeDetails, state));
    EasyLoading.dismiss();
  }

  Future<List<VietmapPlaceModel?>> _getPlaceDetail(
      List<VietmapAutocompleteModelV4> places) async {
    final result = await Future.wait(
      places.map((e) async {
        try {
          var detailResponse = await Vietmap.placeV4(e.refId!);
          return detailResponse.fold((error) => null, (place) => place);
        } catch (ex) {
          return null;
        }
      }),
    );

    return result.whereType<VietmapPlaceModel>().toList();
  }

  _onMapEventGetHistorySearch(
      MapEventGetHistorySearch event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response = await GetHistorySearchUseCase(HistorySearchRepositories())
        .call(NoParams());
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateGetHistorySearchError('Error', state)),
        (r) => emit(MapStateGetHistorySearchSuccess(r, state)));
  }

  _onMapEventOnUserLongTapOnMap(
      MapEventOnUserLongTapOnMap event, Emitter<MapState> emit) async {
    add(MapEventGetAddressFromCoordinate(coordinate: event.coordinate));
  }

  _onMapEventGetAddressFromCoordinate(
      MapEventGetAddressFromCoordinate event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response = await Vietmap.reverseV4(VietmapReverseParams(
        latLng: LatLng(event.coordinate.latitude, event.coordinate.longitude)));
    EasyLoading.dismiss();
    response.fold(
        (l) => emit(MapStateGetLocationFromCoordinateError('Error', state)),
        (r) async {
      var reverseModel = VietmapReverseModelV4Impl.fromVietmapReverseModelV4(r);
      emit(MapStateGetLocationFromCoordinateSuccess(reverseModel, state));

      // await _vietMapAutomotivePlugin.addMarkers(
      //   markers: [
      //     VietmapMarkerModel(
      //       lat: event.coordinate.latitude,
      //       lng: event.coordinate.longitude,
      //       title: r.name,
      //       snippet: r.address,
      //     )
      //   ],
      // );
    });
  }

  _onMapEventGetDirection(
      MapEventGetDirection event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response = await Vietmap.routing(VietMapRoutingParams(
      points: [event.from, event.to],
    ));
    response.fold((l) => MapStateGetDirectionError('Error', state), (r) {
      var locs = VietmapPolylineDecoder.decodePolyline(r.paths!.first.points!)
          .map((e) {
        return LatLng(e.latitude, e.longitude);
      }).toList();
      emit(MapStateGetDirectionSuccess(r, locs, state));
    });
    EasyLoading.dismiss();
  }

  _onMapEventGetEntryPointDetailAddress(
      MapEventGetEntryPointDetailAddress event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response = await Vietmap.placeV4(event.refId);
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateGetPlaceDetailError('Error', state)),
        (r) {
      emit(MapStateGetPlaceDetailSuccess(r, state));
    });
  }

  _onMapEventGetDetailAddress(
      MapEventGetDetailAddress event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    AddHistorySearchUseCase(HistorySearchRepositories()).call(event.model);
    var response;
    await Future.wait(
      [
        Vietmap.placeV4(event.model.refId!).then((value) {
          response = value;
        }),
        // _vietMapAutomotivePlugin.selectSearchResult(
        //   refId: event.model.refId ?? '',
        // ),
      ],
    );
    await EasyLoading.dismiss();
    response.fold((l) => emit(MapStateGetPlaceDetailError('Error', state)),
        (r) {
      emit(MapStateGetPlaceDetailSuccess(r, state));
    });
  }

  _onMapEventGetDetailAddressById(
      MapEventGetDetailAddressById event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response = await Vietmap.placeV4(event.refId);
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateGetPlaceDetailError('Error', state)),
        (r) {
      emit(MapStateGetPlaceDetailSuccess(r, state));
    });
  }

  _onMapEventSearchAddress(
      MapEventSearchAddress event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response = await Vietmap.geoCodeV4(
      VietmapAutocompleteParamsV4(
        text: event.address,
        displayType: AutocompleteDisplayEnum.bothOldAndNew,
      ),
    );
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateSearchAddressError('Error', state)),
        (r) => emit(MapStateSearchAddressSuccess(r, state)));
  }
}
