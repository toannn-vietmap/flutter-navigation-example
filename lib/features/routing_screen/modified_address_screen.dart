import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/constants/colors.dart';
import 'package:vietmap_map/constants/route.dart';
import 'package:vietmap_map/di/app_context.dart';
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
  late VietmapController _vietmapController;

  MyLocationRenderMode myLocationRenderMode = MyLocationRenderMode.compass;

  RoutingBloc get routingBloc => BlocProvider.of<RoutingBloc>(context);

  @override
  void initState() {
    super.initState();
  }

  double _calculateContainerHeight(RoutingState state) {
    final itemCount = (state.routingParams?.waypoints?.length ?? 0) + 1;
    const double itemHeight = 30.0; // Chiều cao mỗi item
    const double verticalPadding = 5.0; // Padding trên dưới mỗi item
    
    // Tính chiều cao cần thiết cho số item hiện tại
    final double neededHeight = itemCount * (itemHeight + verticalPadding);
    
    // Giới hạn tối đa 4 items (nếu nhiều hơn sẽ scroll)
    const double maxHeight = 15.0 + (4 * (40.0 + 10.0)); // ~230
    
    return neededHeight > maxHeight ? maxHeight : neededHeight;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoutingBloc, RoutingState>(
      listener: (context, state) {},
      builder: (context, state) {
        return PopScope(
          child: Scaffold(
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    height: _calculateContainerHeight(state),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'backButton',
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                                onTap: () {
                                  context.pop();
                                },
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Guide Vertical
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: vietmapColor, blurRadius: 10)
                                  ]),
                              child: const Icon(
                                Icons.circle,
                                size: 10,
                                color: vietmapColor,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Icon(Icons.circle, size: 4),
                            const SizedBox(height: 7),
                            const Icon(Icons.circle, size: 4),
                            const SizedBox(height: 7),
                            const Icon(Icons.circle, size: 4),
                            const SizedBox(height: 7),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: Colors.red,
                            )
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ReorderableListView.builder(
                            itemCount:
                                (state.routingParams?.waypoints?.length ?? 0) +
                                    1,
                            itemBuilder: (context, index) {
                              var waypoint = index >
                                      state.routingParams!.waypoints!.length - 1
                                  ? null
                                  : state.routingParams!.waypoints![index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                key: ValueKey('waypoint$index'),
                                child: _searchItem(
                                  hintText: waypoint?.description ??
                                      'Chọn thêm điểm dừng',
                                  onTap: () {
                                    context.pushNamed(
                                      Routes.searchAddressForRoutingScreen,
                                      extra: RoutingHeaderModel(
                                        isFromOrigin: false,
                                        isFromModifiedAddressScreen: true,
                                        defaultLocation: state.routingParams
                                            ?.waypoints?.first.location,
                                      ),
                                    );
                                  },
                                  onClear: () {
                                    context.read<RoutingBloc>().add(
                                        RoutingEventRemoveWaypoint(
                                            index: index));
                                  },
                                  index: index,
                                ),
                              );
                            },
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            onReorder: (oldIndex, newIndex) {
                              debugPrint(
                                  'Old index: $oldIndex - New index: $newIndex');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        VietmapGL(
                          myLocationEnabled: true,
                          myLocationTrackingMode:
                              MyLocationTrackingMode.trackingCompass,
                          myLocationRenderMode: myLocationRenderMode,
                          trackCameraPosition: true,
                          compassViewMargins: Point(
                              10, MediaQuery.sizeOf(context).height * 0.27),
                          // minMaxZoomPreference: const MinMaxZoomPreference(0, 18),
                          styleString: AppContext.getVietmapMapStyleUrl() ?? "",
                          onMapCreated: (controller) {
                            _vietmapController = controller;
                          },
                          initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  state.routingParams?.originPoint?.location
                                          .latitude ??
                                      10.776889,
                                  state.routingParams?.originPoint?.location
                                          .longitude ??
                                      106.660172),
                              zoom: 14),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchItem({
    required String hintText,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required int index,
  }) {
    return Hero(
      tag: 'searchBar$index',
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 30,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 0.5)),
            child: InkWell(
              onTap: onTap,
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10, top: -20),
                    hintText: hintText,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Center(
            child: InkWell(
              onTap: () {
                context.read<RoutingBloc>().add(RoutingEventReverseDirection());
              },
              child: const Icon(Icons.close_rounded, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
