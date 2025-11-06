class RoutingHeaderModel {
  final bool isFromOrigin;
  final String? addressText;

  RoutingHeaderModel({required this.isFromOrigin, this.addressText});

  factory RoutingHeaderModel.fromJson(Map<String, dynamic> json) {
    return RoutingHeaderModel(
      isFromOrigin: json['isFromOrigin'],
      addressText: json['addressText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFromOrigin': isFromOrigin,
      'addressText': addressText,
    };
  }
}
