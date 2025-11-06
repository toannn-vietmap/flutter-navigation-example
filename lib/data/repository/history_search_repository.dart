import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

abstract class HistorySearchRepository {
  Future<Either<Failure, List<VietmapAutocompleteModelV4>>> getHistorySearch();
  Future<Either<Failure, bool>> addHistorySearch(
      VietmapAutocompleteModelV4 recentSearch);
  Future<Either<Failure, bool>> removeHistorySearch(
      VietmapAutocompleteModelV4 model);
  Future<Either<Failure, bool>> removeAllHistorySearch();
}
