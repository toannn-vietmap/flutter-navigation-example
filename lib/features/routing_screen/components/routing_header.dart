import 'package:flutter/material.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/features/routing_screen/components/routing_header_component.dart';
import 'package:vietmap_map/features/routing_screen/components/vehicle_button.dart';
import 'package:vietmap_map/features/routing_screen/components/modified_header_component.dart';

import '../bloc/bloc.dart';

class RoutingHeader extends StatefulWidget {
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
  State<RoutingHeader> createState() => _RoutingHeaderState();
}

class _RoutingHeaderState extends State<RoutingHeader> {
  bool isModifyingWaypoints = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoutingBloc, RoutingState>(
      listener: (context, state) {
        if (state is RoutingStateSubmitModifyWaypoints) {
          setState(() {
            isModifyingWaypoints = state.isModify;
          });
        }
      },
      child: Container(
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
            (isModifyingWaypoints)
                ? const ModifiedHeaderComponent()
                : RoutingHeaderComponent(
                    onOriginTapCallback: widget.onOriginTapCallback,
                    onDestinationTapCallback: widget.onDestinationTapCallback,
                    onBackButtonTapCallback: widget.onBackButtonTapCallback,
                    currentLocation: widget.currentLocation,
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
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
