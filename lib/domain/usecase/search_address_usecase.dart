import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import '/data/repository/vietmap_api_repository.dart';

class SearchAddressUseCase extends UseCase<List<VietmapAutocompleteModelV4>,
    VietmapAutocompleteParamsV4> {
  final VietmapApiRepository repository;

  SearchAddressUseCase(this.repository);
  @override
  Future<Either<Failure, List<VietmapAutocompleteModelV4>>> call(
      VietmapAutocompleteParamsV4 params) {
    return repository.searchLocation(params);
  }
}
