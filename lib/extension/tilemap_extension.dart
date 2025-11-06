import 'package:vietmap_map/features/map_screen/components/select_map_tiles_modal.dart';

extension TileMapExtension on MapTiles {
  String getMapTiles(String apiKey) {
    assert(apiKey.isNotEmpty);
    switch (this) {
      case MapTiles.vietmapVector:
        return "https://maps.vietmap.vn/maps/styles/tm/style.json?apikey=$apiKey";
      case MapTiles.vietmapDarkMap:
        return "https://maps.vietmap.vn/maps/styles/dm/style.json?apikey=$apiKey";
      case MapTiles.vietmapTileMap:
        return "https://maps.vietmap.vn/maps/styles/lm/style.json?apikey=$apiKey";
      case MapTiles.vietmapRasterLM:
        return "https://maps.vietmap.vn/maps/styles/lm/tiles.json?apikey=$apiKey";
      case MapTiles.vietmapRasterDM:
        return "https://maps.vietmap.vn/maps/styles/dm/tiles.json?apikey=$apiKey";

      case MapTiles.vietmapRasterTile:
        return "https://maps.vietmap.vn/maps/styles/tm/tiles.json?apikey=$apiKey";
    }
  }
}
