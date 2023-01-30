import 'package:flutter/material.dart';
import 'package:uvid/domain/models/language_type.dart';
import 'package:uvid/utils/colors.dart';
import 'package:uvid/utils/fonts.dart';

class ThemeManager with ChangeNotifier {
  ThemeManager._internal();
  static final _instance = ThemeManager._internal();
  factory ThemeManager() {
    return _instance;
  }

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = Locale('vi');

  ThemeData get light => ThemeData.light().copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: primaryColor,
        colorScheme: ColorScheme.dark().copyWith(
          primary: primaryColor,
          onPrimary: onPrimaryColor,
          secondary: secondaryColor,
          onSecondary: onSecondaryColor,
          tertiary: tertiaryColor,
          onTertiary: onTertiaryColor,
          background: backgroundColor,
          onBackground: onBackgroundColor,
          error: errorColor,
          onError: onErrorColor,
        ),
        textTheme: TextTheme().copyWith(
          headline1: TextStyle(
            color: onPrimaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: fontQuickSand,
          ),
          bodyText1: TextStyle(
            color: onPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: fontQuickSand,
          ),
          subtitle1: TextStyle(
            color: onSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w200,
            fontFamily: fontQuickSand,
          ),
        ),
      );

  ThemeData get dark => ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: primaryColorDark,
        colorScheme: ColorScheme.dark().copyWith(
          primary: primaryColorDark,
          onPrimary: onPrimaryColorDark,
          secondary: secondaryColorDark,
          onSecondary: onSecondaryColorDark,
          tertiary: tertiaryColorDark,
          onTertiary: onTertiaryColorDark,
          background: backgroundColorDark,
          onBackground: onBackgroundColorDark,
          error: errorColor,
          onError: onErrorColor,
        ),
        textTheme: TextTheme().copyWith(
          headline1: TextStyle(
            color: onPrimaryColorDark,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: fontQuickSand,
          ),
          bodyText1: TextStyle(
            color: onPrimaryColorDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: fontQuickSand,
          ),
          subtitle1: TextStyle(
            color: onSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w200,
            fontFamily: fontQuickSand,
          ),
        ),
      );

  ThemeMode get themeMode => _themeMode;
  void toggleTheme(bool isDarkmode) {
    if (isDarkmode && themeMode == ThemeMode.dark) return;
    if (!isDarkmode && themeMode == ThemeMode.light) return;
    _themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Locale get locale => _locale;
  void toggleLocale(LanguageType type) {
    if (type == LanguageType.VI && locale.languageCode == 'vi') return;
    if (type == LanguageType.EN && locale.languageCode == 'en') return;

    if (locale.languageCode == 'vi') {
      _locale = Locale('en');
    } else {
      _locale = Locale('vi');
    }
    notifyListeners();
  }
}
