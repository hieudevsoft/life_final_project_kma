import 'package:flutter/foundation.dart';

class PlatformDetails {
  PlatformDetails._internal();
  static final _instance = PlatformDetails._internal();
  factory PlatformDetails() {
    return _instance;
  }

  bool get isMobile => TargetPlatform.values
      .where((element) => element == TargetPlatform.android || element == TargetPlatform.iOS)
      .contains(defaultTargetPlatform);

  bool get isDesktop => TargetPlatform.values
      .where((element) => element != TargetPlatform.iOS && element != TargetPlatform.android)
      .contains(defaultTargetPlatform);

  bool get isWeb => defaultTargetPlatform == kIsWeb;

  String getAsString() {
    if (isMobile) return 'Mobile';
    if (isDesktop) 'Desktop';
    return 'Web';
  }
}
