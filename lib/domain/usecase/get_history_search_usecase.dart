import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

import '../../data/repository/history_search_repository.dart';

class GetHistorySearchUseCase
    extends UseCase<List<VietmapAutocompleteModelV4>, NoParams> {
  final HistorySearchRepository historySearchRepository;

  GetHistorySearchUseCase(this.historySearchRepository);
  @override
  Future<Either<Failure, List<VietmapAutocompleteModelV4>>> call(
      NoParams params) async {
    return Future.value(historySearchRepository.getHistorySearch());
  }
}
