import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:toasta/toasta.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/providers/auth.dart';
import 'package:uvid/ui/pages/auth/login_page.dart';
import 'package:uvid/ui/pages/home_page.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/ui/widgets/loading.dart';
import 'package:uvid/utils/connectivity.dart';
import 'package:uvid/utils/home_manager.dart';
import 'package:uvid/utils/theme.dart';
import 'package:provider/provider.dart';

class MyUvidApp extends StatelessWidget {
  const MyUvidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: true,
          create: (context) => ThemeManager(),
        ),
        ChangeNotifierProvider(
          lazy: true,
          create: (context) => HomeManager(),
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
              },
              home: StreamBuilder(
                stream: AuthProviders().authStateChange,
                builder: (context, snapshot) {
                  print(snapshot.data);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return fullScreenLoadingWidget(context);
                  }
                  if (snapshot.hasData) {
                    return HomePage();
                  }
                  return LoginPage();
                },
              )),
        );
      },
    );
  }
}
