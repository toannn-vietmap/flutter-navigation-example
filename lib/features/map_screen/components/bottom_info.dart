import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_map/components/map_action_button.dart';
import 'package:vietmap_map/components/permission_location_widget.dart';
import 'package:vietmap_map/features/map_screen/bloc/map_bloc.dart';
import 'package:vietmap_map/utils/location_util.dart';

import '../../../constants/colors.dart';
import '../../../constants/route.dart';
import '../../routing_screen/models/routing_params_model.dart';
import '../bloc/map_state.dart';

class BottomSheetInfo extends StatefulWidget {
  const BottomSheetInfo(
      {super.key,
      required this.onClose,
      required this.onCreateRouteCallback,
      required this.onStartNavigationCallback});
  final VoidCallback onClose;
  final VoidCallback onCreateRouteCallback;
  final VoidCallback onStartNavigationCallback;

  @override
  State<StatefulWidget> createState() => _BottomSheetInfo();
}

class _BottomSheetInfo extends State<BottomSheetInfo>
    with WidgetsBindingObserver {
  dynamic _locationResponse;
  VoidCallback? _actionCallback;
  bool _isStartNavigation = false;
  bool _isWaitingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isWaitingPermission) {
      final hasPermission = await LocationUtil.checkLocationPermission();
      if (hasPermission && _locationResponse != null && context.mounted) {
        _navigateToRouting(
            _locationResponse, _actionCallback!, _isStartNavigation);
        _clearPendingData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) {
        return current is MapStateGetPlaceDetailSuccess ||
            current is MapStateGetLocationFromCoordinateSuccess;
      },
      builder: (_, state) {
        if (state is MapStateGetPlaceDetailSuccess) {
          return Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '${state.response.hsNum ?? ''}, ${state.response.street ?? ''}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${state.response.ward ?? ''}, ${state.response.district ?? ''}, ${state.response.city ?? ''}',
                  style: const TextStyle(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // const Spacer(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    MapActionButton(
                        onPressed: () async {
                          await _handleNavigateWithPermission(
                            context,
                            state.response,
                            widget.onCreateRouteCallback,
                            false,
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.directions, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Chỉ đường')
                          ],
                        )),
                    const SizedBox(width: 10),
                    MapActionButtonOutline(
                        onPressed: () async {
                          await _handleNavigateWithPermission(
                            context,
                            state.response,
                            widget.onStartNavigationCallback,
                            true,
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.navigation_sharp, color: vietmapColor),
                            SizedBox(width: 5),
                            Text('Bắt đầu',
                                style: TextStyle(color: vietmapColor)),
                          ],
                        ))
                  ],
                )
              ],
            ),
          );
        }
        if (state is MapStateGetLocationFromCoordinateSuccess) {
          return Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    state.response.name ?? '',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                Text(state.response.address ?? '',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text(
                  'Mới: ${state.response.dataNew?.address ?? ''}',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  'Khoảng cách: ${state.response.distanceFromCurrentLocation?.toStringAsFixed(2) ?? 0} km',
                  style: const TextStyle(fontSize: 16),
                  maxLines: 2,
                ),
                Row(
                  children: [
                    MapActionButton(
                        onPressed: () async {
                          await _handleNavigateWithPermission(
                            context,
                            state.response,
                            widget.onCreateRouteCallback,
                            false,
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.directions, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Chỉ đường')
                          ],
                        )),
                    const SizedBox(width: 10),
                    MapActionButtonOutline(
                        onPressed: () async {
                          await _handleNavigateWithPermission(
                            context,
                            state.response,
                            widget.onStartNavigationCallback,
                            true,
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.navigation_sharp, color: vietmapColor),
                            SizedBox(width: 5),
                            Text('Bắt đầu',
                                style: TextStyle(color: vietmapColor)),
                          ],
                        ))
                  ],
                )
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _clearPendingData() {
    _locationResponse = null;
    _actionCallback = null;
    _isStartNavigation = false;
    _isWaitingPermission = false;
  }

  Future<void> _handleNavigateWithPermission(
    BuildContext context,
    dynamic response,
    VoidCallback onCreateRouteCallback,
    bool isNavigation,
  ) async {
    final hasPermission = await LocationUtil.checkLocationPermission();

    if (!context.mounted) return;

    if (hasPermission) {
      _navigateToRouting(response, onCreateRouteCallback, isNavigation);
      return;
    }

    _locationResponse = response;
    _actionCallback = onCreateRouteCallback;
    _isStartNavigation = isNavigation;
    _isWaitingPermission = true;

    await showDialog<bool>(
      context: context,
      builder: (_) => PermissionLocationDialog(
        onPermissionGranted: () {
          _navigateToRouting(response, onCreateRouteCallback, isNavigation);
          _clearPendingData();
        },
      ),
    );
  }

  void _navigateToRouting(
    dynamic response,
    VoidCallback onCreateRouteCallback,
    bool isNavigation,
  ) {
    onCreateRouteCallback();
    EasyLoading.show();
    context.pushNamed(
      Routes.routingScreen,
      extra: RoutingParamsModel.fromVietmapModel(response, isNavigation),
    );
  }
}
