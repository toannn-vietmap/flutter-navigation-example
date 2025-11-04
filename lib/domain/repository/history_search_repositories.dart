import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

import 'package:vietmap_map/data/repository/history_search_repository.dart';

class HistorySearchRepositories implements HistorySearchRepository {
  @override
  Future<Either<Failure, bool>> addHistorySearch(
      VietmapAutocompleteModelV4 recentSearch) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<VietmapAutocompleteModelV4>>> getHistorySearch() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> removeAllHistorySearch() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> removeHistorySearch(
      VietmapAutocompleteModelV4 model) {
    throw UnimplementedError();
  }
}
