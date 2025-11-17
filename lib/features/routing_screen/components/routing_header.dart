import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/features/routing_screen/components/vehicle_button.dart';
import 'package:vietmap_map/features/routing_screen/models/routing_header_model.dart';

import '../../../constants/colors.dart';
import '../../../constants/route.dart';
import '../bloc/bloc.dart';

class RoutingHeader extends StatelessWidget {
  const RoutingHeader({
    super.key,
    required this.onOriginTapCallback,
    required this.onDestinationTapCallback,
    required this.onBackButtonTapCallback,
    this.currentLocation,
  });

  final VoidCallback onOriginTapCallback;
  final VoidCallback onDestinationTapCallback;
  final VoidCallback onBackButtonTapCallback;
  final LatLng? currentLocation;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutingBloc, RoutingState>(
      builder: (context, state) => Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'backButton',
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                          onTap: () {
                            onBackButtonTapCallback();
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
                  _buildHorizontalDivider(),
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
                                  context.pushNamed(
                                      Routes.modifiedAddressScreen,
                                      extra: {
                                        'sourceDescription': state
                                            .routingParams?.originPoint?.description,
                                        'sourcePoint':
                                            state.routingParams?.originPoint,
                                        'destinationDescription': state
                                            .routingParams
                                            ?.destinationPoint?.description,
                                        'destinationPoint': state
                                            .routingParams?.destinationPoint,
                                      });
                                },
                                child: const Icon(Icons.add_circle_rounded,
                                    color: Colors.grey),
                              ),
                            )
                          : const SizedBox.shrink(),
                      Center(
                        child: InkWell(
                          onTap: () {
                            context
                                .read<RoutingBloc>()
                                .add(RoutingEventReverseDirection());
                          },
                          child: const Icon(Icons.swap_vert_rounded,
                              color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            BlocBuilder<RoutingBloc, RoutingState>(builder: (_, state) {
              return Hero(
                tag: 'actionButton',
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.from(VehicleType.values.map((e) =>
                        VehicleButton(
                            estimatedTime: state
                                        .routingModel?.paths?.first.time ==
                                    null
                                ? null
                                : '${(state.routingModel!.paths!.first.time! / 60000).round()} phút',
                            vehicleType: e,
                            currentVehicleType:
                                state.routingParams?.vehicle ?? VehicleType.car,
                            onPressed: () {
                              context.read<RoutingBloc>().add(
                                  RoutingEventUpdateRouteParams(
                                      vehicleType: e));
                            })))),
              );
            }),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }

  _buildSearchBar(BuildContext context) {
    return BlocBuilder<RoutingBloc, RoutingState>(
      builder: (_, state) => Column(
        children: [
          Hero(
            tag: 'searchBarOrigin',
            child: Container(
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
                      onTap: () {
                        onOriginTapCallback();
                        var data = RoutingHeaderModel(
                          isFromOrigin: true,
                          addressText: state.routingParams?.originPoint?.description,
                          defaultLocation: currentLocation,
                          isFromModifiedAddressScreen: false
                        );
                        context.pushNamed(
                          Routes.searchAddressForRoutingScreen,
                          extra: data,
                        );
                      },
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(left: 10, top: -5),
                            hintText: state.routingParams?.originPoint?.description ??
                                'Vị trí của bạn',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Hero(
            tag: 'searchBarDestination',
            child: Container(
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
                      onTap: () {
                        onDestinationTapCallback();
                        var data = RoutingHeaderModel(
                          isFromOrigin: false,
                          addressText:
                              state.routingParams?.destinationPoint?.description,
                          defaultLocation: currentLocation,
                          isFromModifiedAddressScreen: false,
                        );
                        context.pushNamed(
                          Routes.searchAddressForRoutingScreen,
                          extra: data,
                        );
                      },
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(left: 10, top: -5),
                            hintText:
                                state.routingParams?.destinationPoint?.description ??
                                    'Chọn điểm đến',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildHorizontalDivider() {
    return Column(
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
        const Icon(
          Icons.location_on_outlined,
          size: 20,
          color: Colors.red,
        )
      ],
    );
  }
}
