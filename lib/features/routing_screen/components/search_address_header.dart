import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_flutter_navigation/models/marker_widget.dart';
import 'package:vietmap_map/data/models/point_model.dart';

import '../../../constants/route.dart';
import '../../../core/debounce.dart';
import '../../../domain/entities/vietmap_picker_data.dart';
import '../../map_screen/bloc/map_bloc.dart';
import '../../map_screen/bloc/map_event.dart';
import '../bloc/bloc.dart';

class SearchAddressHeader extends StatefulWidget {
  const SearchAddressHeader({
    super.key,
    required this.isSearchFromOrigin,
    this.addressText,
    this.isEditingWaypoints = false,
    this.defaultLocation,
    this.indexWaypoint,
  });
  final bool isSearchFromOrigin;
  final bool isEditingWaypoints;
  final String? addressText;
  final LatLng? defaultLocation;
  final int? indexWaypoint;
  @override
  State<SearchAddressHeader> createState() => _SearchAddressHeaderState();
}

class _SearchAddressHeaderState extends State<SearchAddressHeader> {
  final FocusNode _focusNode = FocusNode();

  final Debounce _debounce = Debounce();
  final TextEditingController _controller = TextEditingController();
  LatLng? currentPosition;
  @override
  void initState() {
    Geolocator.getCurrentPosition().then((value) {
      currentPosition = LatLng(value.latitude, value.longitude);
    }).catchError((error) {
      currentPosition = widget.defaultLocation;
      debugPrint('Error getting current position: $error');
    });
    if (widget.addressText != null &&
        widget.addressText != 'Vị trí của bạn' &&
        widget.addressText != 'Vị trí ghim') {
      _controller.text = widget.addressText!;
      context
          .read<MapBloc>()
          .add(MapEventSearchAddress(address: widget.addressText!));
    }
    Future.delayed(const Duration(milliseconds: 400)).then((value) {
      _focusNode.requestFocus();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: widget.isSearchFromOrigin
                    ? 'searchBarOrigin'
                    : 'searchBarDestination',
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
                    controller: _controller,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _debounce.run(() {
                          context.read<MapBloc>().add(
                                MapEventSearchAddress(
                                    address: value, focus: currentPosition),
                              );
                        });
                        setState(() {});
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
                            context.pop();
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.black54,
                          ),
                        ),
                        suffixIcon: _controller.text.isEmpty
                            ? const SizedBox.shrink()
                            : InkWell(
                                onTap: () {
                                  setState(() {
                                    _controller.clear();
                                  });
                                },
                                child: const Icon(
                                  Icons.clear_rounded,
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
            ],
          ),
          const Divider(),
          Hero(
            tag: 'actionButton',
            child: TextButton(
                onPressed: () async {
                  var location =
                      await context.pushNamed(Routes.pickAddressScreen);
                  if (location != null) {
                    location = location as VietMapPickerData;
                    if (!context.mounted) return;
                    if (widget.isEditingWaypoints) {
                      context
                          .read<RoutingBloc>()
                          .add(RoutingEventPickNewWaypoint(
                            newPoint: PointModel(
                                location: location.latLng,
                                description:
                                    location.displayText ?? 'Vị trí ghim'),
                            indexWaypoint: widget.indexWaypoint,
                            isExistedWaypoints: widget.indexWaypoint != null,
                          ));
                    } else {
                      context
                          .read<RoutingBloc>()
                          .add(RoutingEventUpdateRouteParams(
                            originPoint: widget.isSearchFromOrigin
                                ? PointModel(
                                    location: location.latLng,
                                    description:
                                        location.displayText ?? 'Vị trí ghim')
                                : null,
                            destinationPoint: !widget.isSearchFromOrigin
                                ? PointModel(
                                    location: location.latLng,
                                    description:
                                        location.displayText ?? 'Vị trí ghim')
                                : null,
                          ));
                    }
                    context.pop();
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: Colors.grey),
                    SizedBox(width: 10),
                    Text('Chọn trên bản đồ',
                        style: TextStyle(color: Colors.grey)),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
