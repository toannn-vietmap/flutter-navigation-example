import 'package:flutter/material.dart';
import 'package:vietmap_map/constants/colors.dart';

class ModifiedHeaderItem extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isEndItem;
  final String heroTag;
  final String? prefixChar;
  const ModifiedHeaderItem({
    super.key,
    required this.hintText,
    required this.onTap,
    this.onDelete,
    this.isEndItem = false,
    required this.heroTag,
    this.prefixChar,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isEndItem
              ? const SizedBox(
                  width: 20,
                )
              : prefixChar != null
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: Text(
                        prefixChar!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox(
                      width: 20,
                    ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 40,
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
