import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_flutter_navigation/models/direction_route.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';
import 'package:vietmap_map/constants/colors.dart';
import 'package:vietmap_map/constants/route.dart';
import 'package:vietmap_map/data/models/point_model.dart';
import 'package:vietmap_map/di/app_context.dart';
import 'package:vietmap_map/extension/driving_profile_extension.dart';
import 'package:vietmap_map/features/routing_screen/bloc/bloc.dart';
import 'package:vietmap_map/features/routing_screen/models/routing_header_model.dart';

class ModifiedAddressScreen extends StatefulWidget {
  const ModifiedAddressScreen({
    super.key,
  });

  @override
  State<ModifiedAddressScreen> createState() => _ModifiedAddressScreen();
}

class _ModifiedAddressScreen extends State<ModifiedAddressScreen> {
  MyLocationRenderMode myLocationRenderMode = MyLocationRenderMode.compass;

  RoutingBloc get routingBloc => BlocProvider.of<RoutingBloc>(context);

  MapNavigationViewController? _navigationController;
  late MapOptions _navigationOption;
  final _vietmapPlugin = VietMapNavigationPlugin();

  Future<void> initialize() async {
    if (!mounted) return;

    _navigationOption = _vietmapPlugin.getDefaultOptions();
    _navigationOption.simulateRoute = false;
    _navigationOption.isCustomizeUI = true;
    _navigationOption.apiKey = AppContext.getVietmapAPIKey() ?? "";
    _navigationOption.mapStyle = AppContext.getVietmapMapStyleUrl() ?? "";
    _navigationOption.padding = const EdgeInsets.all(100);

    _vietmapPlugin.setDefaultOptions(_navigationOption);
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  double _calculateContainerHeight(RoutingState state) {
    final itemCount = (state.routingParams?.waypoints?.length ?? 0) + 1;
    const double itemHeight = 35.0;
    const double verticalPadding = 5.0;

    // calculate total height needed
    final double neededHeight = itemCount * (itemHeight + verticalPadding);

    // set a maximum height to avoid overflow
    const double maxHeight = 15.0 + (4 * (35.0 + 10.0)); // ~230

    return neededHeight > maxHeight ? maxHeight : neededHeight;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top bar with back button and done button
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.2),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Hero(
                      tag: 'backButton',
                      child: InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    const Text(
                      'Chỉnh sửa điểm dừng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Xong',
                        style: TextStyle(
                          color: vietmapColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<RoutingBloc, RoutingState>(
                // Header
                builder: (context, state) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  height: _calculateContainerHeight(state),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: ReorderableListView.builder(
                          itemCount:
                              (state.routingParams?.waypoints?.length ?? 0) + 1,
                          itemBuilder: (context, index) {
                            var waypoint = index >
                                    state.routingParams!.waypoints!.length - 1
                                ? null
                                : state.routingParams!.waypoints![index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              key: ValueKey('waypoint$index'),
                              child: _searchItem(
                                prefixChar: String.fromCharCode(65 + index),
                                hintText: waypoint?.description ??
                                    'Chọn thêm điểm dừng',
                                onTap: () {
                                  context.pushNamed(
                                    Routes.searchAddressForRoutingScreen,
                                    extra: RoutingHeaderModel(
                                      isFromOrigin: false,
                                      isEditingWaypoints: true,
                                      defaultLocation: state.routingParams
                                          ?.waypoints?.first.location,
                                      indexWaypoint:
                                          waypoint != null ? index : null,
                                    ),
                                  );
                                },
                                onDelete: () {
                                  if (state.routingParams?.waypoints?.length ==
                                      2) {
                                    context.pop();
                                    return;
                                  }
                                  context.read<RoutingBloc>().add(
                                      RoutingEventRemoveWaypoint(index: index));
                                },
                                isEndItem: index ==
                                    state.routingParams!.waypoints!.length,
                                heroTag: 'searchBar$index',
                              ),
                            );
                          },
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          onReorder: (oldIndex, newIndex) {
                            context.read<RoutingBloc>().add(
                                  RoutingEventReorderWaypoint(
                                    oldIndex: oldIndex,
                                    newIndex: newIndex,
                                  ),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<RoutingBloc, RoutingState>(
                builder: (context, state) => Expanded(
                  child: Stack(
                    children: [
                      NavigationView(
                        mapOptions: _navigationOption,
                        onNewRouteSelected: (DirectionRoute p0) {
                          routingBloc.add(
                              RoutingEventNativeRouteBuilt(directionRoute: p0));
                        },
                        onMapRendered: () async {
                          if (!mounted) return;
                          EasyLoading.show();
                          await _navigationController!.buildRoute(
                            waypoints: PointModel.toLatLngList(
                                    state.routingParams?.waypoints) ??
                                [],
                            profile: state.routingParams?.vehicle
                                    .convertToDrivingProfile() ??
                                DrivingProfile.drivingTraffic,
                          );
                          EasyLoading.dismiss();
                        },
                        onMapCreated: (p0) async {
                          _navigationController = p0;
                          routingBloc.add(RoutingEventUpdateRouteParams(
                              navigationController: _navigationController));
                        },
                        onRouteBuilt: (DirectionRoute p0) {
                          routingBloc.add(
                              RoutingEventNativeRouteBuilt(directionRoute: p0));
                          setState(() {
                            EasyLoading.dismiss();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchItem({
    required String hintText,
    required VoidCallback onTap,
    required VoidCallback onDelete,
    required bool isEndItem,
    required String heroTag,
    required String prefixChar,
  }) {
    return Hero(
      tag: heroTag,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isEndItem
              ? const SizedBox(
                  width: 20,
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Text(
                    prefixChar,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
          const SizedBox(width: 10),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 35,
            decoration: isEndItem
                ? BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: vietmapColor,
                        width: 1,
                        style: BorderStyle.solid),
                  )
                : BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 0.5)),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    if (isEndItem)
                      const Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: vietmapColor,
                      ),
                    if (isEndItem) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hintText,
                        style: TextStyle(
                          color: isEndItem ? vietmapColor : Colors.grey,
                          fontSize: 14,
                          fontWeight:
                              isEndItem ? FontWeight.w500 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isEndItem) const SizedBox(width: 4),
                    if (!isEndItem)
                      const Icon(
                        Icons.drag_handle_rounded,
                        size: 15,
                        color: Colors.grey,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          isEndItem
              ? const SizedBox.shrink()
              : Center(
                  child: InkWell(
                    onTap: onDelete,
                    child: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ),
        ],
      ),
    );
  }
}
