import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/core/failures/cache_failure.dart';
import 'package:vietmap_map/data/repository/history_search_repository.dart';

class HistorySearchRepositories implements HistorySearchRepository {
  static const String _keyHistorySearch = 'history_search';
  static const int _maxHistoryItems = 20;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<Either<Failure, bool>> addHistorySearch(
      VietmapAutocompleteModelV4 recentSearch) async {
    try {
      final prefs = await _prefs;
      final history = await _getHistoryList(prefs);

      history.removeWhere((item) => item.refId == recentSearch.refId);

      history.insert(0, recentSearch);

      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      final jsonList = history.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList(_keyHistorySearch, jsonList);

      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VietmapAutocompleteModelV4>>>
      getHistorySearch() async {
    try {
      final prefs = await _prefs;
      final history = await _getHistoryList(prefs);
      return Right(history);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeAllHistorySearch() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_keyHistorySearch);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeHistorySearch(
      VietmapAutocompleteModelV4 model) async {
    try {
      final prefs = await _prefs;
      final history = await _getHistoryList(prefs);

      history.removeWhere((item) => item.refId == model.refId);

      final jsonList = history.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList(_keyHistorySearch, jsonList);

      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<List<VietmapAutocompleteModelV4>> _getHistoryList(
      SharedPreferences prefs) async {
    final jsonList = prefs.getStringList(_keyHistorySearch) ?? [];
    return jsonList
        .map((jsonStr) =>
            VietmapAutocompleteModelV4.fromJson(json.decode(jsonStr)))
        .toList();
  }
}
