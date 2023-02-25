import 'package:flutter/material.dart';

class TwoRouteSlideBuilder extends PageRouteBuilder {
  TwoRouteSlideBuilder({
    required GlobalKey mtAppKey,
    required String enterRoute,
    required String exitRoute,
    Object? arguments,
  }) : super(
          settings: RouteSettings(),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            assert(mtAppKey.currentWidget != null && mtAppKey.currentWidget is MaterialApp);
            final routes = (mtAppKey.currentWidget as MaterialApp).routes;
            assert(routes!.containsKey(enterRoute));
            final currentRoute = routes![enterRoute]!(context);
            return currentRoute;
          },
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final routes = (mtAppKey.currentWidget as MaterialApp).routes;
            assert(routes!.containsKey(exitRoute));
            final exitPage = routes![exitRoute]!(context);
            return Stack(
              fit: StackFit.expand,
              children: [
                SlideTransition(
                  position: Tween(
                    begin: Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
                SlideTransition(
                  position: Tween(
                    begin: Offset.zero,
                    end: Offset(1, 0),
                  ).animate(animation),
                  child: exitPage,
                ),
              ],
            );
          },
        );
}
