import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toasta/toasta.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/domain/models/language_type.dart';
import 'package:uvid/exceptions/cancel_sign_in.dart';
import 'package:uvid/exceptions/google_sign_in.dart';
import 'package:uvid/providers/auth.dart';
import 'package:uvid/ui/widgets/elevated_button.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/ui/widgets/popup_menu.dart';
import 'package:uvid/utils/home_manager.dart';
import 'package:uvid/utils/theme.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final AnimationController _controller;

  bool _isSignInAvailable = true;
  late AuthProviders authProviders;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    authProviders = AuthProviders();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkmode = context.select<ThemeManager, bool>(((themeManager) => themeManager.themeMode == ThemeMode.dark));
    return Scaffold(
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildRowLanguageOptionSetting(context),
                    _buildRowDarkModeOptionSetting(context, isDarkmode),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.5,
                child: Lottie.asset(
                  'assets/images/video_conference.json',
                  controller: _controller,
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.contain,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..repeat(
                          min: 0,
                          max: 1,
                          reverse: true,
                          period: Duration(milliseconds: composition.duration.inMilliseconds ~/ 2));
                  },
                ),
              ),
              Text(
                AppLocalizations.of(context)!.start_or_join_a_metting,
                style: context.textTheme.headline1,
                textAlign: TextAlign.center,
              ),
              gapV24,
              Icon(
                context.watch<HomeManager>().statusInternet.contains('Online') ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                color: context.watch<HomeManager>().statusInternet.contains('Online')
                    ? isDarkmode
                        ? Colors.green.shade500
                        : Colors.white
                    : context.colorScheme.error,
                size: 36,
              ),
              gapV4,
              Text(
                context.watch<HomeManager>().statusInternet,
                style: context.textTheme.bodyText1?.copyWith(
                  color: context.watch<HomeManager>().statusInternet.contains('Online')
                      ? isDarkmode
                          ? Colors.green.shade500
                          : Colors.white
                      : context.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              gapV24,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: MyElevatedButton(
                  backgroundColor: context.colorScheme.background,
                  isEnabled: _isSignInAvailable,
                  onPressed: () async {
                    try {
                      setState(() {
                        _isSignInAvailable = false;
                      });
                      final isSignInWithGoogleSucessfully = await authProviders.signInWithGoogleSuccessfully();
                      if (isSignInWithGoogleSucessfully) {
                        context.read<HomeManager>().onPageChanged(0);
                        Toasta(context).toast(
                          Toast(
                            darkMode: false,
                            height: 60,
                            borderRadius: BorderRadius.circular(12),
                            duration: Duration(seconds: 2),
                            subtitle: AppLocalizations.of(context)!.welcome,
                            fadeInSubtitle: true,
                            status: ToastStatus.success,
                          ),
                        );
                      } else {
                        Toasta(context).toast(
                          Toast(
                            darkMode: false,
                            height: 60,
                            borderRadius: BorderRadius.circular(12),
                            duration: Duration(seconds: 2),
                            title: APP_NAME,
                            subtitle: 'Failure',
                            onExit: () {
                              setState(() {
                                _isSignInAvailable = true;
                              });
                            },
                            fadeInSubtitle: true,
                            status: ToastStatus.failed,
                          ),
                        );
                      }
                    } on GoogleSignInException catch (e) {
                      Toasta(context).toast(
                        Toast(
                          darkMode: false,
                          height: 60,
                          borderRadius: BorderRadius.circular(12),
                          duration: Duration(seconds: 2),
                          title: APP_NAME,
                          subtitle: e.toString(),
                          onExit: () {
                            setState(() {
                              _isSignInAvailable = true;
                            });
                          },
                          fadeInSubtitle: true,
                          status: ToastStatus.failed,
                        ),
                      );
                    } on CancelSignInException catch (_) {
                      setState(() {
                        _isSignInAvailable = true;
                      });
                    } on Exception {
                      Toasta(context).toast(
                        Toast(
                          darkMode: false,
                          height: 60,
                          borderRadius: BorderRadius.circular(12),
                          duration: Duration(seconds: 2),
                          subtitle: AppLocalizations.of(context)!.some_thing_went_wrong,
                          onExit: () {
                            setState(() {
                              _isSignInAvailable = true;
                            });
                          },
                          fadeInSubtitle: true,
                          status: ToastStatus.failed,
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        width: 32,
                      ),
                      gapH8,
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.google_sigin_in,
                          style: context.textTheme.bodyText1?.copyWith(
                            color: context.colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 48,
                ),
                child: MyElevatedButton(
                  backgroundColor: context.colorScheme.tertiary,
                  isEnabled: _isSignInAvailable,
                  onPressed: () {
                    Navigator.pushNamed(context, "/phone_verify");
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/ic_phone.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        width: 32,
                      ),
                      gapH8,
                      Expanded(
                        flex: 1,
                        child: Text(
                          AppLocalizations.of(context)!.phone_sigin_in,
                          style: context.textTheme.bodyText1?.copyWith(
                            color: context.colorScheme.onTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                ),
                child: MyElevatedButton(
                  backgroundColor: context.colorScheme.secondary,
                  isEnabled: _isSignInAvailable,
                  onPressed: () {
                    //TODO login with biometrics
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/ic_biometrics.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        width: 32,
                      ),
                      gapH8,
                      Expanded(
                        flex: 1,
                        child: Text(
                          "Login with Biometrics",
                          style: context.textTheme.bodyText1?.copyWith(
                            color: context.colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildRowLanguageOptionSetting(BuildContext context) {
  final isVietnamese = context.select<ThemeManager, bool>(((themeManager) => themeManager.locale.languageCode == 'vi'));
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        isVietnamese ? 'assets/images/ic_vi.png' : 'assets/images/ic_en.png',
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        isAntiAlias: false,
      ),
      gapH8,
      Text(
        isVietnamese ? AppLocalizations.of(context)!.vi : AppLocalizations.of(context)!.en,
        style: context.textTheme.subtitle1?.copyWith(
          fontSize: 16,
          color: context.colorScheme.onPrimary,
          fontWeight: FontWeight.w900,
        ),
        textAlign: TextAlign.start,
      ),
      UvidPopupMenu<LanguageType>(
        values: LanguageType.values,
        initialValue: context.read<ThemeManager>().locale.languageCode == 'vi' ? LanguageType.VI : LanguageType.EN,
        onUvidPopupSelected: (type) {
          context.read<ThemeManager>().toggleLocale(type);
        },
        dropdownColor: context.colorScheme.onPrimary,
      )
    ],
  );
}

Widget _buildRowDarkModeOptionSetting(BuildContext context, bool isDarkmode) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        isDarkmode ? 'assets/images/ic_dark_mode.png' : 'assets/images/ic_light_mode.png',
        height: 24,
        fit: BoxFit.cover,
        isAntiAlias: false,
      ),
      gapH8,
      Text(
        isDarkmode ? AppLocalizations.of(context)!.dark_mode : AppLocalizations.of(context)!.light_mode,
        style: context.textTheme.subtitle1?.copyWith(
          fontSize: 16,
          color: context.colorScheme.onPrimary,
          fontWeight: FontWeight.w900,
        ),
        textAlign: TextAlign.start,
      ),
      UvidPopupMenu<bool>(
        values: [true, false],
        initialValue: isDarkmode,
        onUvidPopupSelected: (type) {
          context.read<ThemeManager>().toggleTheme(type);
        },
        dropdownColor: context.colorScheme.onPrimary,
      )
    ],
  );
}
