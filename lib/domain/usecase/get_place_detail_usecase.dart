import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/data/models/vietmap_place_model.dart';

import '../../data/repository/vietmap_api_repository.dart';

class GetPlaceDetailUseCase extends UseCase<VietmapPlaceModelImpl, String> {
  final VietmapApiRepository repository;

  GetPlaceDetailUseCase(this.repository);
  @override
  Future<Either<Failure, VietmapPlaceModelImpl>> call(String params) {
    return repository.getPlaceDetail(params);
  }
}
