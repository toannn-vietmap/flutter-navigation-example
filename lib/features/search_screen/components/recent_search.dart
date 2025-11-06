import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_map/features/map_screen/bloc/map_bloc.dart';
import 'package:vietmap_map/features/map_screen/bloc/map_state.dart';
import '../../map_screen/bloc/map_event.dart';

class RecentSearchWidget extends StatelessWidget {
  const RecentSearchWidget(
      {super.key, required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
        buildWhen: (previous, current) =>
            current is MapStateGetHistorySearchSuccess ||
            current is MapStateSearchAddressSuccess,
        builder: (_, state) {
          if (state is MapStateGetHistorySearchSuccess) {
            return Expanded(
              child: ListView.builder(
                itemBuilder: ((context, index) {
                  return InkWell(
                    onTap: () {
                      context
                          .read<MapBloc>()
                          .add(MapEventGetDetailAddress(state.response[index]));
                      FocusScope.of(context).requestFocus(FocusNode());
                      context.pop();
                    },
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.history, color: Colors.black54),
                        const SizedBox(width: 5),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(state.response[index].name ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(state.response[index].address ?? ''),
                                state.response[index].dataNew != null
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: Text(
                                          'Mới: ${state.response[index].dataNew!.display}',
                                          style: const TextStyle(
                                              color: Colors.blue),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                const Divider()
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            focusNode.requestFocus();
                            controller.text = state.response[index].name ?? '';
                            context.read<MapBloc>().add(MapEventSearchAddress(
                                address: state.response[index].name ?? ''));
                          },
                          child: const Icon(Icons.arrow_outward_rounded,
                              color: Colors.black54),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  );
                }),
                itemCount: state.response.length,
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }
}
