import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

import '../../data/repository/vietmap_api_repository.dart';

class GetLocationFromCategoryUseCase
    extends UseCase<List<VietmapReverseModelV4>, VietmapReverseParams> {
  final VietmapApiRepository repository;

  GetLocationFromCategoryUseCase(this.repository);
  @override
  Future<Either<Failure, List<VietmapReverseModelV4>>> call(
      VietmapReverseParams params) {
    return repository.getLocationFromCategory(params: params);
  }
}
