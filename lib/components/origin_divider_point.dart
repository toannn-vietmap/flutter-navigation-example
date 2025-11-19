import 'package:flutter/material.dart';
import 'package:vietmap_map/constants/colors.dart';

class OriginDividerPoint extends StatelessWidget {
  const OriginDividerPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: vietmapColor, blurRadius: 8, spreadRadius: 1)
        ],
      ),
      child: const Icon(
        Icons.circle,
        size: 12,
        color: vietmapColor,
      ),
    );
  }
}
