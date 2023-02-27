// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:uvid/ui/pages/auth/login_page.dart';
import 'package:uvid/ui/pages/home_page.dart';
import 'package:uvid/ui/pages/phone_verify_page.dart';
import 'package:uvid/ui/screens/friend_screen.dart';
import 'package:uvid/ui/screens/join_screen.dart';
import 'package:uvid/ui/screens/notification_screen.dart';
import 'package:uvid/ui/screens/schedule_calendar_screen.dart';
import 'package:uvid/ui/screens/video_call_screen.dart';

abstract class AppRoutesDirect {
  AppRoutesDirect._();
  static final Route login = Route(route: '/login', build: (ctx) => const LoginPage());
  static final Route home = Route(route: '/home', build: (ctx) => const HomePage());
  static final Route phonevify = Route(route: '/phone_verify', build: (ctx) => const PhoneVerifyPage());
  static final Route scheduleCalendar = Route(route: '/schedule_calendar', build: (ctx) => const ScheduleCalendarScreen());
  static final Route videoCall = Route(route: '/video_call', build: (ctx) => const VideoCallScreen());
  static final Route friend = Route(route: '/friend', build: (ctx) => const FriendScreen());
  static final Route notification = Route(route: '/notification', build: (ctx) => const NotificationScreen());
  static final Route joinScreen = Route(route: '/join_screen', build: (ctx) => const JoinScreen());

  static get _routes => [
        login,
        home,
        phonevify,
        scheduleCalendar,
        videoCall,
        friend,
        notification,
        joinScreen,
      ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    final Map<String, Widget Function(BuildContext)> routes = {};
    _routes.forEach((route) {
      routes.putIfAbsent(route.route, () => route.build);
    });
    return routes;
  }
}

class Route {
  String route;
  Widget Function(BuildContext) build;
  Route({
    required this.route,
    required this.build,
  });
}
