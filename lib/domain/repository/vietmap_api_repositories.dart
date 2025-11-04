import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/data/models/vietmap_place_model.dart';
import 'package:vietmap_map/data/repository/vietmap_api_repository.dart';
import 'package:vietmap_map/domain/entities/vietmap_routing_params_impl.dart';

class VietmapApiRepositories extends VietmapApiRepository {
  static final VietmapApiRepositories _instance =
      VietmapApiRepositories._internal();

  VietmapApiRepositories._internal();

  factory VietmapApiRepositories() {
    return _instance;
  }

  @override
  Future<Either<Failure, VietMapRoutingModel>> findRoute(
      VietMapRoutingParamsImpl params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<VietmapReverseModelV4>>> getLocationFromCategory(
      {required VietmapReverseParams params}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, VietmapReverseModelV4>> getLocationFromLatLng(
      {VietmapReverseParams? params}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, VietmapPlaceModelImpl>> getPlaceDetail(
      String placeId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<VietmapAutocompleteModelV4>>> searchLocation(
      VietmapAutocompleteParamsV4 params) {
    throw UnimplementedError();
  }
}
