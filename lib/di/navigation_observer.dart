import 'package:flutter/material.dart';

class AppNavigation extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    
    super.didPush(route, previousRoute);

    debugPrint('Navigated to ${route.settings.name}');
  }
}
