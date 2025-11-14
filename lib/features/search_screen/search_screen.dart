import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart'
    hide Debounce;
import 'package:vietmap_map/components/debouncer_search.dart';
import 'package:vietmap_map/constants/events.dart';
import 'package:vietmap_map/di/app_context.dart';
import 'package:vietmap_map/features/search_screen/components/autocomplete_response_item.dart';
import 'package:vietmap_map/features/search_screen/components/item_with_entry_points.dart';
import 'package:vietmap_map/method_channel/vietmap_automotive_plugin.dart';
import 'package:vietmap_map/utils/location_util.dart';

import '../map_screen/bloc/map_bloc.dart';
import '../map_screen/bloc/map_event.dart';
import '../map_screen/bloc/map_state.dart';
import 'components/recent_search.dart';

class SearchScreen extends StatefulWidget {
  final LatLng? defaultLocation;
  const SearchScreen({super.key, this.defaultLocation});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final VietMapAutomotivePlugin _vietMapAutomotivePlugin =
      VietMapAutomotivePlugin.instance;
  final MethodChannel _methodChannel = AppContext.getSearchChannel();
  final FocusNode _focusNode = FocusNode();
  final Debounce _debounce = Debounce();
  final TextEditingController _searchController = TextEditingController();
  var currentLocation;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      _focusNode.requestFocus();
      _methodChannel.setMethodCallHandler(
        (call) async {
          switch (call.method) {
            case Events.closeSearch:
              _focusNode.unfocus();
              context.pop();
              break;
            case Events.queryTextUpdated:
              final query = call.arguments['query'] as String?;
              if (query != null && query.isNotEmpty && query.length >= 2) {
                _searchController.text = query;
                _debounce.run(() {
                  context.read<MapBloc>().add(MapEventSearchAddress(
                      address: query, focus: currentLocation));
                });
              }
              break;
            case Events.selectSearchResult:
              final refId = call.arguments['refId'] as String?;
              if (refId != null) {
                context
                    .read<MapBloc>()
                    .add(MapEventGetDetailAddressById(refId));
                _focusNode.unfocus();
                context.pop();
              }
              break;
            default:
          }
        },
      );
    });
    Geolocator.getCurrentPosition().then((value) {
      currentLocation = LatLng(value.latitude, value.longitude);
    }).catchError((error) {
      currentLocation = widget.defaultLocation;
      debugPrint('Error getting current position: $error');
    });
    context.read<MapBloc>().add(MapEventGetHistorySearch());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // await  _vietMapAutomotivePlugin.closeSearch();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                const SizedBox(height: 10),
                Hero(
                  tag: 'searchBar',
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width - 40,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        if (value.isNotEmpty && value.length >= 2) {
                          // _vietMapAutomotivePlugin.queryTextUpdated(
                          // query: value);
                          _debounce.run(() {
                            context.read<MapBloc>().add(MapEventSearchAddress(
                                address: value, focus: currentLocation));
                          });
                        }
                      },
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey)),
                          prefixIcon: InkWell(
                            onTap: () {
                              // _vietMapAutomotivePlugin.closeSearch();
                              context.pop();
                            },
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.black54,
                            ),
                          ),
                          hintText: 'Nhập từ khoá để tìm kiếm',
                          contentPadding: const EdgeInsets.only(top: 15),
                          hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.w400)),
                    ),
                  ),
                ),
                RecentSearchWidget(
                  controller: _searchController,
                  focusNode: _focusNode,
                ),
                BlocBuilder<MapBloc, MapState>(buildWhen: (previous, current) {
                  return current is MapStateSearchAddressSuccess ||
                      current is MapStateGetHistorySearchSuccess;
                }, builder: (_, state) {
                  if (state is MapStateSearchAddressSuccess) {
                    if (state.response.isEmpty) {
                      return const Center(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text('Không tìm thấy kết quả',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 17))),
                      );
                    }
                    return Expanded(
                      child: ListView.builder(
                          itemCount: state.response.length,
                          itemBuilder: (_, index) {
                            if (state.response[index].entryPoints?.isNotEmpty ??
                                false) {
                              return ItemWithEntryPoints(
                                model: state.response[index],
                              );
                            }
                            return AutocompleteResponseItem(
                              model: state.response[index],
                            );
                          }),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
