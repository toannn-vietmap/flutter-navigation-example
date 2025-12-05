import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:talker/talker.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart';
import 'package:vietmap_map/data/models/point_model.dart';
import 'package:vietmap_map/data/models/vietmap_place_model_impl.dart';
import 'package:vietmap_map/domain/repository/history_search_repositories.dart';
import 'package:vietmap_map/domain/usecase/add_history_search_usecase.dart';
import 'package:vietmap_map/extension/driving_profile_extension.dart';
import 'package:vietmap_map/extension/latlng_extension.dart';
import 'package:vietmap_map/features/routing_screen/bloc/routing_event.dart';
import 'package:vietmap_map/features/routing_screen/bloc/routing_state.dart';

import '../../../di/app_context.dart';
import '../../../domain/entities/vietmap_routing_params_impl.dart';

class RoutingBloc extends Bloc<RoutingEvent, RoutingState> {
  final talker = Talker();
  RoutingBloc() : super(RoutingStateInitial()) {
    on<RoutingEventGetDirection>(_onRoutingEventGetDirection);
    on<RoutingEventUpdateRouteParams>(_onRoutingEventUpdateRouteParams);
    on<RoutingEventClearDirection>(_onRoutingEventClearDirection);
    on<RoutingEventReverseDirection>(_onRoutingEventReverseDirection);
    on<RoutingEventNativeRouteBuilt>(_onRoutingEventNativeRouteBuilt);
    on<RoutingEventUpdateCurrentLocation>(_onRoutingEventUpdateCurrentLocation);
    on<RoutingEventAddWaypoint>(_onRoutingEventAddWaypoint);
    on<RoutingEventPickNewWaypoint>(_onRoutingEventPickNewWaypoint);
    on<RoutingEventRemoveWaypoint>(_onRoutingEventRemoveWaypoint);
    on<RoutingEventReorderWaypoint>(_onRoutingEventReorderWaypoint);
    on<RoutingEventSubmitModifyWaypoints>(_onRoutingEventSubmitModifyWaypoints);
  }

  _onRoutingEventSubmitModifyWaypoints(
      RoutingEventSubmitModifyWaypoints event, Emitter<RoutingState> emit) {
    emit(RoutingStateSubmitModifyWaypoints(
        isModify: event.isModify, state: state));
  }

  _onRoutingEventReorderWaypoint(
      RoutingEventReorderWaypoint event, Emitter<RoutingState> emit) async {
    var params = state.routingParams;

    if (params != null && params.waypoints != null) {
      if (event.newIndex > event.oldIndex) {
        params.waypoints!
            .insert(event.newIndex, params.waypoints![event.oldIndex]);
        params.waypoints!.removeAt(event.oldIndex);
      } else {
        var item = params.waypoints!.removeAt(event.oldIndex);
        params.waypoints!.insert(event.newIndex, item);
      }

      params.points = PointModel.toLatLngList(params.waypoints) ?? [];
      params.originPoint = params.waypoints?.first;
      params.destinationPoint = params.waypoints?.last;

      await params.navigationController?.buildRoute(
          waypoints: params.points,
          profile: params.vehicle.convertToDrivingProfile());
      emit(
        RoutingStateWaypointUpdated(state, params),
      );
    }
  }

  _onRoutingEventRemoveWaypoint(
      RoutingEventRemoveWaypoint event, Emitter<RoutingState> emit) async {
    var params = state.routingParams;
    if (params != null &&
        params.waypoints != null &&
        params.waypoints!.length > event.index) {
      params.waypoints!.removeAt(event.index);
      params.points = PointModel.toLatLngList(params.waypoints) ?? [];
      params.originPoint = params.waypoints?.first;
      params.destinationPoint = params.waypoints?.last;
      await params.navigationController?.buildRoute(
          waypoints: params.points,
          profile: params.vehicle.convertToDrivingProfile());
      emit(RoutingStateWaypointUpdated(state, params));
    }
  }

  _onRoutingEventPickNewWaypoint(
      RoutingEventPickNewWaypoint event, Emitter<RoutingState> emit) async {
    if (event.newPoint != null) {
      var params = state.routingParams;
      if (event.isExistedWaypoints != null &&
          event.isExistedWaypoints! &&
          event.indexWaypoint != null) {
        params?.waypoints?[event.indexWaypoint!] = event.newPoint!;
      } else {
        params?.waypoints?.add(event.newPoint!);
      }
      params?.originPoint = params.waypoints?.first;
      params?.destinationPoint = event.newPoint;
      params?.points = PointModel.toLatLngList(params.waypoints) ?? [];
      await params?.navigationController?.buildRoute(
          waypoints: params.points,
          profile: params.vehicle.convertToDrivingProfile());
      emit(
        RoutingStateWaypointUpdated(state, params),
      );
    }
  }

  _onRoutingEventAddWaypoint(
      RoutingEventAddWaypoint event, Emitter<RoutingState> emit) async {
    emit(RoutingStateLoading(state));
    EasyLoading.show();
    AddHistorySearchUseCase(HistorySearchRepositories()).call(event.newPoint!);
    Either<Failure, VietmapPlaceModel>? response;
    await Future.wait(
      [
        Vietmap.placeV4(event.newPoint!.refId!).then((value) {
          response = value;
        }),
        // _vietMapAutomotivePlugin.selectSearchResult(
        //   refId: event.model.refId ?? '',
        // ),
      ],
    );
    VietmapPlaceModelImpl? placeModel;
    await EasyLoading.dismiss();
    response?.fold((l) => null, (r) {
      placeModel = VietmapPlaceModelImpl.fromJson(r.toJson());
      placeModel?.newLocation = event.newPoint!.dataNew;
    });
    if (placeModel != null) {
      var newPoint = PointModel(
        description: placeModel!.getFullName(),
        location: LatLng(
          placeModel!.lat!.toDouble(),
          placeModel!.lng!.toDouble(),
        ),
      );
      var params = state.routingParams;
      if (event.isExistedWaypoints != null &&
          event.isExistedWaypoints! &&
          event.indexWaypoint != null) {
        params?.waypoints?[event.indexWaypoint!] = newPoint;
      } else {
        params?.waypoints?.add(newPoint);
      }
      params?.originPoint = params.waypoints?.first;
      params?.destinationPoint = newPoint;
      params?.points = PointModel.toLatLngList(params.waypoints) ?? [];
      await params?.navigationController?.buildRoute(
          waypoints: params.points,
          profile: params.vehicle.convertToDrivingProfile());
      emit(
        RoutingStateWaypointUpdated(state, params),
      );
    }
  }

  _onRoutingEventUpdateCurrentLocation(
      RoutingEventUpdateCurrentLocation event, Emitter<RoutingState> emit) {
    emit(RoutingStateUpdateCurrentLocation(state, event.currentLocation));
  }

  _onRoutingEventNativeRouteBuilt(
      RoutingEventNativeRouteBuilt event, Emitter<RoutingState> emit) {
    emit(RoutingStateNativeRouteBuilt(state, event.directionRoute));
  }

  _onRoutingEventReverseDirection(
      RoutingEventReverseDirection event, Emitter<RoutingState> emit) {
    var params = state.routingParams;
    if (params != null) {
      var temp = params.originPoint;
      var tempDes = params.originPoint?.description;
      params.originPoint = params.destinationPoint;
      params.originPoint?.description = params.destinationPoint?.description;
      params.destinationPoint = temp;
      params.destinationPoint?.description = tempDes;
      if (params.originPoint != null && params.destinationPoint != null) {
        // add(RoutingEventGetDirection(
        //     from: params.originPoint!, to: params.destinationPoint!));
        params.waypoints = [
          params.originPoint!,
          params.destinationPoint!,
        ];
        if (params.navigationController != null) {
          params.navigationController!.buildRoute(
              waypoints: PointModel.toLatLngList(params.waypoints!) ?? [],
              profile: params.vehicle.convertToDrivingProfile());
        }
      }
      emit(
        RoutingState(
            listPoint: <LatLng>[...(state.listPoint ?? [])],
            routingModel: VietMapRoutingModel.copyWith(state.routingModel),
            routingParams: params),
      );
    }
  }

  _onRoutingEventClearDirection(
      RoutingEventClearDirection event, Emitter<RoutingState> emit) {
    state.routingParams?.navigationController?.clearRoute();
    emit(RoutingStateInitial());
  }

  _onRoutingEventUpdateRouteParams(
      RoutingEventUpdateRouteParams event, Emitter<RoutingState> emit) async {
    emit(RoutingStateLoading(state));
    VietMapRoutingParamsImpl? params = state.routingParams ??
        VietMapRoutingParamsImpl(
          apiKey: AppContext.getVietmapAPIKey() ?? '',
          originPoint: null,
          destinationPoint: null,
        );
    params.vehicle = event.vehicleType ?? params.vehicle;
    params.destinationPoint = event.destinationPoint ?? params.destinationPoint;
    params.originPoint = event.originPoint ?? params.originPoint;
    params.navigationController =
        event.navigationController ?? params.navigationController;

    try {
      if (params.originPoint == null) {
        params.originPoint?.description = 'Vị trí của bạn';
        params.originPoint?.location =
            (await Geolocator.getCurrentPosition()).toLatLng();
      }
    } catch (e) {
      talker.handle(e.toString());
    }
    if (params.originPoint != null && params.destinationPoint != null) {
      params.waypoints = [
        params.originPoint!,
        ...params.waypoints?.sublist(1, (params.waypoints?.length ?? 2) - 1) ??
            [],
        params.destinationPoint!,
      ];
      params.points = PointModel.toLatLngList(params.waypoints) ?? [];
      emit(
        RoutingState(
          listPoint: params.points,
          routingModel: VietMapRoutingModel.copyWith(state.routingModel),
          routingParams: params,
        ),
      );
      // add(RoutingEventGetDirection(
      //     from: params.originPoint!, to: params.destinationPoint!));
      if (params.navigationController != null) {
        EasyLoading.show();
        Talker().debug(params.vehicle.convertToDrivingProfile());
        Talker().debug(
            ('${params.originPoint!.location.latitude}--o--${params.originPoint!.location.longitude}'));
        Talker().debug(
            ('${params.destinationPoint!.location.latitude}--d--${params.destinationPoint!.location.longitude}'));
        params.navigationController!.buildRoute(
          waypoints: params.points,
          profile: params.vehicle.convertToDrivingProfile(),
        );
      }
    }
  }

  _onRoutingEventGetDirection(
      RoutingEventGetDirection event, Emitter<RoutingState> emit) async {
    //RoutingStateGetDirectionSuccess

    emit(RoutingStateLoading(state));
    var routingParams = state.routingParams ??
        VietMapRoutingParamsImpl(
          originPoint: event.from,
          destinationPoint: event.to,
          apiKey: AppContext.getVietmapAPIKey() ?? '',
        );
    routingParams.originPoint = event.from;
    routingParams.destinationPoint = event.to;
    EasyLoading.show();
    var response = await Vietmap.routing(routingParams);
    EasyLoading.dismiss();
    response.fold(
        (l) => RoutingStateGetDirectionError(message: 'Error', state: state),
        (r) {
      if (r.paths?.isNotEmpty != true) {
        emit(RoutingStateGetDirectionError(message: 'Error', state: state));
      } else {
        var locs = VietmapPolylineDecoder.decodePolyline(r.paths!.first.points!)
            .map((e) {
          return LatLng(e.latitude, e.longitude);
        }).toList();
        emit(RoutingStateGetDirectionSuccess(state,
            response: r, listPoint: locs, routingParams: routingParams));
      }
    });
  }
}
