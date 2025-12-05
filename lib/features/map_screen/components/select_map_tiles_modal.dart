import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../bloc/bloc.dart';
import 'tile_option_item.dart';

enum MapTiles {
  vietmapVector('Vector Default'),
  vietmapDarkMap('Vector Dark'),
  vietmapTileMap('Vector Light'),
  vietmapRasterLM('Raster Light'),
  vietmapRasterDM('Raster Dark'),
  vietmapRasterTile('Raster Default');

  final String value;
  const MapTiles(this.value);
}

class SelectMapTilesModal extends StatefulWidget {
  const SelectMapTilesModal({super.key});

  @override
  State<SelectMapTilesModal> createState() => _SelectMapTilesModalState();
}

class _SelectMapTilesModalState extends State<SelectMapTilesModal> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (_, state) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Loại bản đồ', style: TextStyle(fontSize: 16)),
              InkWell(
                onTap: () {
                  context.pop();
                },
                child: const Icon(Icons.close),
              )
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TileOptionItem(
                  mapType: MapTiles.vietmapVector,
                  currentMapType: state.mapTile,
                ),
                TileOptionItem(
                  mapType: MapTiles.vietmapDarkMap,
                  currentMapType: state.mapTile,
                ),
                TileOptionItem(
                  mapType: MapTiles.vietmapTileMap,
                  currentMapType: state.mapTile,
                ),
                TileOptionItem(
                  mapType: MapTiles.vietmapRasterLM,
                  currentMapType: state.mapTile,
                ),
                TileOptionItem(
                  mapType: MapTiles.vietmapRasterDM,
                  currentMapType: state.mapTile,
                ),
                TileOptionItem(
                  mapType: MapTiles.vietmapRasterTile,
                  currentMapType: state.mapTile,
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
