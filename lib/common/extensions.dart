import 'package:flutter/material.dart';
import 'package:uvid/domain/models/audio_mode.dart';
import 'package:uvid/domain/models/language_type.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/domain/models/notification_mode.dart';
import 'package:uvid/domain/models/video_mode.dart';

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

  String typeAsString<T>(T type) {
    if (type is LanguageType) return languageTypeAsString(type);
    if (type is AudioMode) return audioModeAsString(type);
    if (type is VideoMode) return videoModeAsString(type);
    if (type is NotificationMode) return notificationModeAsString(type);
    if (type is bool) return type ? AppLocalizations.of(this)!.darkmode_on : AppLocalizations.of(this)!.darkmode_off;
    return "";
  }

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;
}
