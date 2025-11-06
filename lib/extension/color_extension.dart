import 'package:flutter/widgets.dart';

extension ColorOpacityToAlpha on Color {
  Color withOpacityValue(double opacity) {
    return withAlpha((opacity * 255).round());
  }
}