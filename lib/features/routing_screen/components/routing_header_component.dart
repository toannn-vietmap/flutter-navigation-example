import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/constants/colors.dart';
import 'package:vietmap_map/constants/route.dart';
import 'package:vietmap_map/features/routing_screen/bloc/bloc.dart';
import 'package:vietmap_map/features/routing_screen/models/routing_header_model.dart';

class RoutingHeaderComponent extends StatefulWidget {
  final VoidCallback onOriginTapCallback;
  final VoidCallback onDestinationTapCallback;
  final VoidCallback onBackButtonTapCallback;
  final LatLng? currentLocation;
  const RoutingHeaderComponent({
    super.key,
    required this.onOriginTapCallback,
    required this.onDestinationTapCallback,
    required this.onBackButtonTapCallback,
    this.currentLocation,
  });

  @override
  State<RoutingHeaderComponent> createState() => _RoutingHeaderComponentState();
}

class _RoutingHeaderComponentState extends State<RoutingHeaderComponent> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutingBloc, RoutingState>(
      builder: (context, state) => SizedBox(
        height: (state.routingParams?.waypoints?.length ?? 0) > 2 ? 150 : 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'backButton',
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                    onTap: () {
                      widget.onBackButtonTapCallback();
                      context
                          .read<RoutingBloc>()
                          .add(RoutingEventClearDirection());
                      context.pop();
                    },
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 5),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: vietmapColor, blurRadius: 10)
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
                if ((state.routingParams?.waypoints?.length ?? 0) > 2) ...[
                  const SizedBox(height: 7),
                  const Icon(Icons.circle, size: 4),
                  const SizedBox(height: 7),
                  const Icon(Icons.circle, size: 4),
                  const SizedBox(height: 7),
                  const Icon(Icons.circle, size: 4),
                  const SizedBox(height: 7),
                ],
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Colors.red,
                )
              ],
            ),
            const SizedBox(width: 10),
            _buildSearchBar(context),
            const SizedBox(width: 5),
            Column(
              mainAxisAlignment: (state.listPoint?.length ?? 0) >= 2
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                (state.listPoint?.length ?? 0) >= 2
                    ? Center(
                        child: InkWell(
                          onTap: () {
                            context.read<RoutingBloc>().add(
                                RoutingEventSubmitModifyWaypoints(
                                    isModify: true));
                          },
                          child: const Icon(Icons.add_circle_rounded,
                              color: Colors.grey),
                        ),
                      )
                    : const SizedBox.shrink(),
                (state.routingParams?.waypoints?.length ?? 0) == 2
                    ? Center(
                        child: InkWell(
                          onTap: () {
                            context
                                .read<RoutingBloc>()
                                .add(RoutingEventReverseDirection());
                          },
                          child: const Icon(Icons.swap_vert_rounded,
                              color: Colors.grey),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            )
          ],
        ),
      ),
    );
  }

  _searchBarItem({
    required String hintText,
    required VoidCallback onTap,
    required String heroTag,
    bool isBetweenItem = false,
  }) {
    return Hero(
      tag: heroTag,
      child: Container(
        margin: isBetweenItem ? const EdgeInsets.symmetric(vertical: 5) : null,
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.7,
        height: 45,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 0.5)),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    hintText,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildSearchBar(BuildContext context) {
    return BlocBuilder<RoutingBloc, RoutingState>(
      builder: (_, state) => Column(
        children: [
          _searchBarItem(
            onTap: () {
              widget.onOriginTapCallback();
              var data = RoutingHeaderModel(
                  isFromOrigin: true,
                  addressText:
                      state.routingParams?.waypoints?.first.description,
                  defaultLocation: widget.currentLocation,
                  isEditingWaypoints: false);
              context.pushNamed(
                Routes.searchAddressForRoutingScreen,
                extra: data,
              );
            },
            heroTag: 'searchBarOrigin',
            hintText: state.routingParams?.waypoints?.first.description ??
                'Vị trí của bạn',
          ),
          (state.routingParams?.waypoints?.length ?? 0) > 2
              ? state.routingParams?.waypoints?.length == 3
                  ? _searchBarItem(
                      hintText:
                          state.routingParams?.waypoints?[1].description ??
                              'Chọn điểm trung gian',
                      onTap: () {
                        context.read<RoutingBloc>().add(
                            RoutingEventSubmitModifyWaypoints(isModify: true));
                      },
                      heroTag: 'searchBarWaypoint',
                      isBetweenItem: true)
                  : _searchBarItem(
                      hintText:
                          '${state.routingParams!.waypoints!.length - 2} điểm dừng',
                      onTap: () {
                        context.read<RoutingBloc>().add(
                            RoutingEventSubmitModifyWaypoints(isModify: true));
                      },
                      heroTag: 'searchBarWaypoint',
                      isBetweenItem: true)
              : const SizedBox(height: 10),
          _searchBarItem(
            hintText: state.routingParams?.waypoints?.last.description ??
                'Chọn điểm đến',
            onTap: () {
              widget.onDestinationTapCallback();
              var data = RoutingHeaderModel(
                isFromOrigin: false,
                addressText: state.routingParams?.waypoints?.last.description,
                defaultLocation: widget.currentLocation,
                isEditingWaypoints: false,
              );
              context.pushNamed(
                Routes.searchAddressForRoutingScreen,
                extra: data,
              );
            },
            heroTag: 'searchBarDestination',
          ),
        ],
      ),
    );
  }
}
