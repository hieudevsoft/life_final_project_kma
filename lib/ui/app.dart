// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/event.dart';
import 'package:uvid/providers/auth.dart';
import 'package:uvid/ui/pages/auth/login_page.dart';
import 'package:uvid/ui/pages/home_page.dart';
import 'package:uvid/ui/widgets/loading.dart';
import 'package:uvid/utils/connectivity.dart';
import 'package:uvid/utils/routes.dart';
import 'package:uvid/utils/state_managment/contact_manager.dart';
import 'package:uvid/utils/state_managment/friend_manager.dart';
import 'package:uvid/utils/state_managment/home_manager.dart';
import 'package:uvid/utils/state_managment/notification_manager.dart';
import 'package:uvid/utils/state_managment/theme_manager.dart';
import 'package:provider/provider.dart';

final GlobalKey mtAppKey = GlobalKey();
DateTime get _now => DateTime.now();

class MyUvidApp extends StatefulWidget {
  const MyUvidApp({super.key});

  @override
  State<MyUvidApp> createState() => _MyUvidAppState();
}

class _MyUvidAppState extends State<MyUvidApp> {
  Widget? currentPage = null;
  late ThemeManager themeManager;
  late HomeManager homeManager;
  late ContactManager contactManager;
  late FriendManager friendManager;
  @override
  void initState() {
    super.initState();
    themeManager = ThemeManager();
    homeManager = HomeManager();
    contactManager = ContactManager();
    friendManager = FriendManager();

    LocalStorage().getIsDarkMode().then((value) => themeManager.toggleTheme(value));
    LocalStorage().getLanguage().then((value) => themeManager.toggleLocale(value));

    LocalStorage().getAudioMode().then((value) => homeManager.onChangeMuteAudio(value));
    LocalStorage().getVideoMode().then((value) => homeManager.onChangeMuteVideo(value));
    LocalStorage().getNotificationMode().then((value) => homeManager.onChangeMuteNotification(value));
    LocalStorage().getSearchContactsMode().then((value) => homeManager.onChangeSearchContactMode(value));

    AuthProviders().authStateChange.listen((user) {
      Future.delayed(
        const Duration(seconds: 1),
        () async {
          //FlutterNativeSplash.remove();
          final profile = await LocalStorage().getProfile();
          if (user == null || profile == null) {
            currentPage = LoginPage();
          } else {
            currentPage = HomePage();
          }
          setState(() {});
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider<Event?>(
      controller: EventController<Event?>(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            lazy: true,
            create: (context) {
              return themeManager;
            },
          ),
          ChangeNotifierProvider(
            lazy: true,
            create: (context) {
              return homeManager;
            },
          ),
          Provider(
            create: (context) {
              final customConnectivity = UvidAppConnectivity();
              customConnectivity.initialise();
              return customConnectivity;
            },
            dispose: (_, customConnectivity) {
              customConnectivity.disposeStream();
            },
          ),
          ChangeNotifierProvider(
            create: (context) => contactManager,
          ),
          ChangeNotifierProvider(
            create: (context) => friendManager,
          ),
          ChangeNotifierProvider(
            create: (context) => NotificationManager(),
          ),
        ],
        builder: (context, child) {
          return MaterialApp(
            key: mtAppKey,
            locale: context.select<ThemeManager, Locale>((themeManager) => themeManager.locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale != null) {
                if (supportedLocales.map((e) => e.languageCode).contains(locale.languageCode)) {
                  return locale;
                } else {
                  return Locale('en');
                }
              } else {
                return Locale('en');
              }
            },
            scrollBehavior: ScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.trackpad,
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
              },
            ),
            theme: ThemeManager().light,
            darkTheme: ThemeManager().dark,
            themeMode: context.select<ThemeManager, ThemeMode>((themeManager) => themeManager.themeMode),
            debugShowCheckedModeBanner: kDebugMode,
            routes: AppRoutesDirect.getAppRoutes(),
            home: currentPage ?? fullScreenLoadingWidget(context),
          );
        },
      ),
    );
  }
}
