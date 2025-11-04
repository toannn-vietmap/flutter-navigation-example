import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

import '../../data/repository/vietmap_api_repository.dart';

class GetLocationFromLatLngUseCase
    extends UseCase<VietmapReverseModelV4, VietmapReverseParams> {
  final VietmapApiRepository repository;

  GetLocationFromLatLngUseCase(this.repository);
  @override
  Future<Either<Failure, VietmapReverseModelV4>> call(
      VietmapReverseParams params) {
    return repository.getLocationFromLatLng(params: params);
  }
}

class LocationPoint {
  final double lat;
  final double long;
  final int? category;
  LocationPoint({required this.lat, required this.long, this.category});
}
