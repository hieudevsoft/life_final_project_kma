import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:toasta/toasta.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/providers/auth.dart';
import 'package:uvid/ui/pages/auth/login_page.dart';
import 'package:uvid/ui/pages/home_page.dart';
import 'package:uvid/ui/pages/phone_verify.dart';
import 'package:uvid/ui/widgets/loading.dart';
import 'package:uvid/utils/connectivity.dart';
import 'package:uvid/utils/home_manager.dart';
import 'package:uvid/utils/theme.dart';
import 'package:provider/provider.dart';

class MyUvidApp extends StatefulWidget {
  const MyUvidApp({super.key});

  @override
  State<MyUvidApp> createState() => _MyUvidAppState();
}

class _MyUvidAppState extends State<MyUvidApp> {
  Widget? currentPage = null;
  late ThemeManager themeManager;
  @override
  void initState() {
    super.initState();

    AuthProviders().authStateChange.listen((user) {
      Future.delayed(
        const Duration(seconds: 1),
        () {
          if (user == null) {
            currentPage = LoginPage();
          } else {
            currentPage = HomePage();
          }
          setState(() {});
        },
      );
    });

    themeManager = ThemeManager();
    LocalStorage().getIsDarkMode().then((value) => themeManager.toggleTheme(value));
    LocalStorage().getLanguage().then((value) => themeManager.toggleLocale(value));
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
            return HomeManager();
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
        )
      ],
      builder: (context, child) {
        return ToastaContainer(
          child: MaterialApp(
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
              routes: {
                '/login': (context) => const LoginPage(),
                '/home': (context) => const HomePage(),
                '/phone_verify': (context) => const PhoneVerifyPage(),
              },
              home: currentPage ?? fullScreenLoadingWidget(context)),
        );
      },
    );
  }
}
