import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uvid/domain/models/audio_mode.dart';
import 'package:uvid/domain/models/contact_mode.dart';
import 'package:uvid/domain/models/language_type.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/domain/models/notification_mode.dart';
import 'package:uvid/domain/models/video_mode.dart';
import 'package:uvid/utils/colors.dart';

extension ExtensionsContext on BuildContext {
  String languageTypeAsString(LanguageType languageType) {
    switch (languageType) {
      case LanguageType.VI:
        return AppLocalizations.of(this)!.vi;
      case LanguageType.EN:
        return AppLocalizations.of(this)!.en;
    }
  }

  String audioModeAsString(AudioMode audioMode) {
    switch (audioMode) {
      case AudioMode.ON:
        return AppLocalizations.of(this)!.on;
      case AudioMode.OFF:
        return AppLocalizations.of(this)!.off;
    }
  }

  String videoModeAsString(VideoMode videoMode) {
    switch (videoMode) {
      case VideoMode.ON:
        return AppLocalizations.of(this)!.on;
      case VideoMode.OFF:
        return AppLocalizations.of(this)!.off;
    }
  }

  String notificationModeAsString(NotificationMode notificationMode) {
    switch (notificationMode) {
      case NotificationMode.ON:
        return AppLocalizations.of(this)!.on;
      case NotificationMode.OFF:
        return AppLocalizations.of(this)!.off;
    }
  }

  String searchContactModeAsString(ContactMode contaceMode) {
    switch (contaceMode) {
      case ContactMode.NAME:
        return AppLocalizations.of(this)!.name;
      case ContactMode.EMAIL:
        return "Email";
      case ContactMode.PHONE:
        return AppLocalizations.of(this)!.phone_number;
    }
  }

  String typeAsString<T>(T type) {
    if (type is LanguageType) return languageTypeAsString(type);
    if (type is AudioMode) return audioModeAsString(type);
    if (type is VideoMode) return videoModeAsString(type);
    if (type is NotificationMode) return notificationModeAsString(type);
    if (type is ContactMode) return searchContactModeAsString(type);
    if (type is bool) return type ? AppLocalizations.of(this)!.darkmode_on : AppLocalizations.of(this)!.darkmode_off;
    return "";
  }

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;
}

String getCustomUniqueId() {
  const String pushChars = '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz';
  int lastPushTime = 0;
  List lastRandChars = [];
  int now = DateTime.now().millisecondsSinceEpoch;
  bool duplicateTime = (now == lastPushTime);
  lastPushTime = now;
  List timeStampChars = List<String>.filled(8, '0');
  for (int i = 7; i >= 0; i--) {
    timeStampChars[i] = pushChars[now % 64];
    now = (now / 64).floor();
  }
  if (now != 0) {
    print("Id should be unique");
  }
  String uniqueId = timeStampChars.join('');
  if (!duplicateTime) {
    for (int i = 0; i < 12; i++) {
      lastRandChars.add((Random().nextDouble() * 64).floor());
    }
  } else {
    int i = 0;
    for (int i = 11; i >= 0 && lastRandChars[i] == 63; i--) {
      lastRandChars[i] = 0;
    }
    lastRandChars[i]++;
  }
  for (int i = 0; i < 12; i++) {
    uniqueId += pushChars[lastRandChars[i]];
  }
  return uniqueId;
}

final Map<Color, Color> mapStartEndColorCute = {
  Color(0xff6DC8F3): Color(0xff73A1F9),
  Color(0xffFFB157): Color(0xffFFA057),
  Color(0xffFF5B95): Color(0xffF8556D),
  Color(0xffD76EF5): Color(0xff8F7AFE),
  Color(0xff42E695): Color(0xff3BB2B8)
};

Color getStartColorCute(int index) {
  return mapStartEndColorCute.entries.toList()[index % mapStartEndColorCute.length].key;
}

Color getEndColorCute(int index) {
  return mapStartEndColorCute.entries.toList()[index % mapStartEndColorCute.length].value;
}

int getTimeNowInWholeMilliseconds() {
  return DateTime.now().millisecondsSinceEpoch;
}

DateTime millisecondsToDateTime(int milliseconds) {
  return DateTime.fromMillisecondsSinceEpoch(milliseconds);
}

String getStringDateFromDateTime(DateTime dateTime, String pattern) {
  return DateFormat(pattern).format(dateTime);
}

enum TimeStampFormat { parse_12, parse_24 }

extension NavigationExtension on State {
  void pushRoute(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
}

extension NavigatorExtention on BuildContext {
  Future<T?> pushRoute<T>(Widget page) => Navigator.of(this).push<T>(MaterialPageRoute(builder: (context) => page));

  void pop([dynamic value]) => Navigator.of(this).pop(value);

  void showSnackBarWithText(String text) => ScaffoldMessenger.of(this)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

extension DateUtils on DateTime {
  String get weekdayToFullString {
    switch (weekday) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "Error";
    }
  }

  String get weekdayToAbbreviatedString {
    switch (weekday) {
      case DateTime.monday:
        return "M";
      case DateTime.tuesday:
        return "T";
      case DateTime.wednesday:
        return "W";
      case DateTime.thursday:
        return "T";
      case DateTime.friday:
        return "F";
      case DateTime.saturday:
        return "S";
      case DateTime.sunday:
        return "S";
      default:
        return "Err";
    }
  }

  int get totalMinutes => hour * 60 + minute;

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) =>
      DateTime(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        minute ?? this.minute,
        second ?? this.second,
        millisecond ?? this.millisecond,
        microsecond ?? this.microsecond,
      );

  String dateToStringWithFormat({String format = 'y-M-d'}) {
    return DateFormat(format).format(this);
  }

  DateTime stringToDateWithFormat({
    required String format,
    required String dateString,
  }) =>
      DateFormat(format).parse(dateString);

  String getTimeInFormat(TimeStampFormat format) =>
      DateFormat('h:mm${format == TimeStampFormat.parse_12 ? " a" : ""}').format(this).toUpperCase();

  bool compareWithoutTime(DateTime date) => day == date.day && month == date.month && year == date.year;

  bool compareTime(DateTime date) => hour == date.hour && minute == date.minute && second == date.second;
}

extension ColorExtension on Color {
  Color get accentColor =>
      (blue / 2 >= 255 / 2 || red / 2 >= 255 / 2 || green / 2 >= 255 / 2) ? AppColors.black : AppColors.white;
}

extension StringExt on String {
  String get capitalized => toBeginningOfSentenceCase(this) ?? "";
}
