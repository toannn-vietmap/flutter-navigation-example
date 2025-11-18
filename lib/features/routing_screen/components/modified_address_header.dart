import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vietmap_map/constants/colors.dart';
import 'package:vietmap_map/constants/route.dart';
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
  RoutingBloc get routingBloc => BlocProvider.of<RoutingBloc>(context);

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
    return Column(
      children: [
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
                    context.read<RoutingBloc>().add(
                        RoutingEventSubmitModifyWaypoints(isModify: false));
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
                  context
                      .read<RoutingBloc>()
                      .add(RoutingEventSubmitModifyWaypoints(isModify: false));
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        // Address list
        BlocBuilder<RoutingBloc, RoutingState>(
          builder: (context, state) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            height: _calculateContainerHeight(state),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ReorderableListView.builder(
              itemCount: (state.routingParams?.waypoints?.length ?? 0) + 1,
              itemBuilder: (context, index) {
                var waypoint =
                    index > state.routingParams!.waypoints!.length - 1
                        ? null
                        : state.routingParams!.waypoints![index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  key: ValueKey('waypoint$index'),
                  child: _searchItem(
                    prefixChar: String.fromCharCode(65 + index),
                    hintText: waypoint?.description ?? 'Chọn thêm điểm dừng',
                    onTap: () {
                      context.pushNamed(
                        Routes.searchAddressForRoutingScreen,
                        extra: RoutingHeaderModel(
                          isFromOrigin: false,
                          isEditingWaypoints: true,
                          defaultLocation:
                              state.routingParams?.waypoints?.first.location,
                          indexWaypoint: waypoint != null ? index : null,
                        ),
                      );
                    },
                    onDelete: () {
                      if (state.routingParams?.waypoints?.length == 2) {
                        context.pop();
                        return;
                      }
                      context
                          .read<RoutingBloc>()
                          .add(RoutingEventRemoveWaypoint(index: index));
                    },
                    isEndItem: index == state.routingParams!.waypoints!.length,
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
        ),
      ],
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
          Expanded(
            child: Container(
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
          ),
          const SizedBox(width: 5),
          isEndItem
              ? const SizedBox(width: 25)
              : InkWell(
                  onTap: onDelete,
                  child: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
        ],
      ),
    );
  }
}
