import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

import '../../data/repository/history_search_repository.dart';

class AddHistorySearchUseCase
    extends UseCase<bool, VietmapAutocompleteModelV4> {
  final HistorySearchRepository historySearchRepository;

  AddHistorySearchUseCase(this.historySearchRepository);

  @override
  Future<Either<Failure, bool>> call(VietmapAutocompleteModelV4 params) {
    return Future.value(historySearchRepository.addHistorySearch(params));
  }
}
