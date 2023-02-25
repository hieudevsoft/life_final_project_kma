import 'package:flutter/material.dart';

class SingleRouteSizeBuilder extends PageRouteBuilder {
  SingleRouteSizeBuilder({
    required GlobalKey mtAppKey,
    required String routeName,
    Object? arguments,
  }) : super(
          settings: RouteSettings(),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            assert(mtAppKey.currentWidget != null && mtAppKey.currentWidget is MaterialApp);
            var routes = (mtAppKey.currentWidget as MaterialApp).routes;
            assert(routes!.containsKey(routeName));
            var currentRoute = routes![routeName]!(context);
            return currentRoute;
          },
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );
          },
        );
}
