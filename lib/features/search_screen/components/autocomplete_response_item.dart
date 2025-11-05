import 'package:flutter/material.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/features/map_screen/bloc/bloc.dart';

class AutocompleteResponseItem extends StatelessWidget {
  const AutocompleteResponseItem({super.key, required this.model});
  final VietmapAutocompleteModelV4 model;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<MapBloc>().add(MapEventGetDetailAddress(model));
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.pop(context);
      },
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.location_pin, color: Colors.black54),
          const SizedBox(width: 5),
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(model.name ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.address ?? ''),
                  model.dataNew != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Text(
                            'Mới: ${model.dataNew!.address}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        )
                      : const SizedBox.shrink(),
                  const Divider()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
