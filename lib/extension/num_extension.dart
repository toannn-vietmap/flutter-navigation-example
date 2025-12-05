extension NumExtension on num? {
  String distanceToString() {
    if (this == null) return '';
    if (this! < 1000) {
      return '${this!.toStringAsFixed(0)} m';
    } else {
      return '${(this! / 1000).toStringAsFixed(1)} km';
    }
  }

  String convertSecondsToString() {
    if (this == null) return '';
    var seconds = this! / 1000;
    if (seconds < 60) {
      return '${(seconds).toStringAsFixed(0)} giây';
    } else if (seconds < 3600) {
      return '${(seconds / 60).toStringAsFixed(0)} phút';
    } else if (seconds < 86400) {
      return '${(seconds / 3600).toStringAsFixed(0)} giờ, ${(seconds % 3600 / 60).toStringAsFixed(0)} phút';
    } else {
      return '${(seconds / 86400).toStringAsFixed(0)} ngày, ${(seconds % 86400 / 3600).toStringAsFixed(0)} giờ, ${(seconds % 3600 / 60).toStringAsFixed(0)} phút';
    }
  }

  String convertNativeResponseSecondsToString() {
    if (this == null) return '';

    final d = Duration(seconds: this!.round());
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    final parts = <String>[];

    if (days > 0) {
      parts.add('$days ngày');
    }
    if (hours > 0) {
      parts.add('$hours giờ');
    }
    if (minutes > 0) {
      parts.add('$minutes phút');
    }

    if (parts.isEmpty) {
      parts.add('$seconds giây');
    }

    return parts.join(' ');
  }

  String convertSecondsToMinutes() {
    if (this == null) return '';

    if (this! < 60) {
      return '${this!.round()} giây';
    }

    var duration = Duration(seconds: this!.round());
    return '${duration.inMinutes} phút';
  }
}
