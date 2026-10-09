import 'package:flutter/widgets.dart';

/// Reports page navigation as screen views.
///
/// Only [PageRoute]s count as screens: pushing or closing a dialog, bottom
/// sheet or popup menu reports nothing. Routes without a
/// [RouteSettings.name] are skipped, since their path would be meaningless.
class RybbitRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  /// Creates an observer that calls [onScreenView] with the route name
  /// whenever [isEnabled] returns true.
  RybbitRouteObserver({
    required bool Function() isEnabled,
    required void Function(String name) onScreenView,
  }) : _isEnabled = isEnabled,
       _onScreenView = onScreenView;

  final bool Function() _isEnabled;
  final void Function(String name) _onScreenView;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _track(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Closing a dialog or bottom sheet doesn't change the screen.
    if (route is PageRoute && previousRoute != null) _track(previousRoute);
  }

  void _track(Route<dynamic> route) {
    if (route is! PageRoute || !_isEnabled()) return;
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    _onScreenView(name);
  }
}
