import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/data/models/vietmap_place_model.dart';

import '../../domain/entities/vietmap_routing_params_impl.dart';

abstract class VietmapApiRepository {
  Future<Either<Failure, VietmapReverseModelV4>> getLocationFromLatLng({
    VietmapReverseParams? params,
  });

  Future<Either<Failure, List<VietmapAutocompleteModelV4>>> searchLocation(
      VietmapAutocompleteParamsV4 params);

  Future<Either<Failure, VietmapPlaceModelImpl>> getPlaceDetail(String placeId);

  Future<Either<Failure, VietMapRoutingModel>> findRoute(
      VietMapRoutingParamsImpl params);

  Future<Either<Failure, List<VietmapReverseModelV4>>> getLocationFromCategory(
      {required VietmapReverseParams params});
}
