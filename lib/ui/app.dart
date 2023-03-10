import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/providers/auth.dart';
import 'package:uvid/ui/pages/auth/login_page.dart';
import 'package:uvid/ui/pages/home_page.dart';
import 'package:uvid/ui/pages/phone_verify_page.dart';
import 'package:uvid/ui/screens/friend_screen.dart';
import 'package:uvid/ui/screens/schedule_calendar_screen.dart';
import 'package:uvid/ui/screens/video_call_screen.dart';
import 'package:uvid/ui/widgets/loading.dart';
import 'package:uvid/utils/connectivity.dart';
import 'package:uvid/utils/notifications.dart';
import 'package:uvid/utils/routes.dart';
import 'package:uvid/utils/state_managment/contact_manager.dart';
import 'package:uvid/utils/state_managment/friend_manager.dart';
import 'package:uvid/utils/state_managment/home_manager.dart';
import 'package:uvid/utils/state_managment/theme_manager.dart';
import 'package:provider/provider.dart';

final GlobalKey mtAppKey = GlobalKey();

class MyUvidApp extends StatefulWidget {
  const MyUvidApp({super.key});

  @override
  State<MyUvidApp> createState() => _MyUvidAppState();
}

class _MyUvidAppState extends State<MyUvidApp> {
  Widget? currentPage = null;
  late ThemeManager themeManager;
  late HomeManager homeManager;
  @override
  void initState() {
    super.initState();
    AuthProviders().authStateChange.listen((user) {
      Future.delayed(
        const Duration(seconds: 1),
        () async {
          //FlutterNativeSplash.remove();
          final profile = await LocalStorage().getProfile();
          if (user == null || profile == null) {
            currentPage = LoginPage();
          } else if (profile != null) {
            currentPage = HomePage();
          }
          setState(() {});
        },
      );
    });
    themeManager = ThemeManager();
    LocalStorage().getIsDarkMode().then((value) => themeManager.toggleTheme(value));
    LocalStorage().getLanguage().then((value) => themeManager.toggleLocale(value));

    homeManager = HomeManager();
    LocalStorage().getAudioMode().then((value) => homeManager.onChangeMuteAudio(value));
    LocalStorage().getVideoMode().then((value) => homeManager.onChangeMuteVideo(value));
    LocalStorage().getNotificationMode().then((value) => homeManager.onChangeMuteNotification(value));
    LocalStorage().getSearchContactsMode().then((value) => homeManager.onChangeSearchContactMode(value));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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
          create: (context) => ContactManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => FriendManager(),
        ),
      ],
      builder: (context, child) {
        return CalendarControllerProvider(
          controller: EventController(),
          child: MaterialApp(
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
            theme: ThemeManager().light,
            darkTheme: ThemeManager().dark,
            themeMode: context.select<ThemeManager, ThemeMode>((themeManager) => themeManager.themeMode),
            debugShowCheckedModeBanner: kDebugMode,
            routes: AppRoutesDirect.getAppRoutes(),
            home: currentPage ?? fullScreenLoadingWidget(context),
          ),
        );
      },
    );
  }
}
