import 'package:flutter/material.dart';

class DestinationDividerPoint extends StatelessWidget {
  const DestinationDividerPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
      ),
      child: const Icon(
        Icons.location_on,
        size: 22,
        color: Colors.red,
      ),
    );
  }
}
