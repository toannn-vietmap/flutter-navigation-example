import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_map/features/routing_screen/bloc/bloc.dart';

import '../map_screen/bloc/map_bloc.dart';
import '../map_screen/bloc/map_event.dart';
import '../map_screen/bloc/map_state.dart';
import 'components/search_address_header.dart';
import 'models/routing_header_model.dart';

class SearchAddress extends StatefulWidget {
  final RoutingHeaderModel? args;
  const SearchAddress({super.key, this.args});

  @override
  State<SearchAddress> createState() => _SearchAddressState();
}

class _SearchAddressState extends State<SearchAddress> {
  bool isSearchFromOrigin = true;
  String? addressText = '';
  @override
  void initState() {
    debugPrint(
        'SearchAddress initState called: ${widget.args?.defaultLocation}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var args = widget.args;
      if (args != null) {
        setState(() {
          isSearchFromOrigin = args.isFromOrigin;
          addressText = args.addressText;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        body: Column(children: [
          SearchAddressHeader(
            isSearchFromOrigin: isSearchFromOrigin,
            addressText: addressText,
            defaultLocation: widget.args?.defaultLocation,
            isFromModifiedAddressScreen:
                widget.args?.isFromModifiedAddressScreen ?? false,
          ),
          BlocBuilder<MapBloc, MapState>(buildWhen: (previous, current) {
            if (current is MapStateSearchAddressSuccess) {
              return true;
            }
            return false;
          }, builder: (_, state) {
            if (state is MapStateSearchAddressSuccess) {
              return Expanded(
                child: ListView.builder(
                    itemCount: state.response.length,
                    itemBuilder: (_, index) {
                      return InkWell(
                        onTap: () {
                          if (widget.args != null &&
                              widget.args!.isFromModifiedAddressScreen) {
                            context.read<RoutingBloc>().add(
                                RoutingEventAddWaypoint(
                                    newPoint: state.response[index]));
                          } else {
                            context.read<MapBloc>().add(
                                MapEventGetDetailAddress(
                                    state.response[index]));
                          }
                          FocusScope.of(context).requestFocus(FocusNode());
                          context.pop();
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            const Icon(Icons.location_pin,
                                color: Colors.black54),
                            const SizedBox(width: 5),
                            Expanded(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(state.response[index].name ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(state.response[index].address ?? ''),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: Text(
                                          'Mới: ${state.response[index].dataNew?.address ?? (state.response[index].address ?? '')}',
                                          style: const TextStyle(
                                              color: Colors.blue)),
                                    ),
                                    const Divider()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              );
            } else {
              return const SizedBox.shrink();
            }
          })
        ]),
      ),
    );
  }
}
