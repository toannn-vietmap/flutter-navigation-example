import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/domain/entities/vietmap_routing_params_impl.dart';

import '../../data/repository/vietmap_api_repository.dart';

class GetDirectionUseCase
    extends UseCase<VietMapRoutingModel, VietMapRoutingParamsImpl> {
  final VietmapApiRepository repository;

  GetDirectionUseCase(this.repository);
  @override
  Future<Either<Failure, VietMapRoutingModel>> call(
      VietMapRoutingParamsImpl params) {
    return repository.findRoute(params);
  }
}
