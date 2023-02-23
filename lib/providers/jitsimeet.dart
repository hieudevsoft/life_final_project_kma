import 'package:flutter/material.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:uvid/domain/models/custom_jitsi_config_options.dart';
import 'package:uvid/providers/auth.dart';
import 'package:uvid/providers/firestore.dart';

class JitsiMeetProviders {
  JitsiMeetProviders._();
  static get _instance => JitsiMeetProviders._();
  factory JitsiMeetProviders() {
    return _instance;
  }

  final FirestoreProviders _firestoreMethods = FirestoreProviders();

  void createMeeting({
    required CustomJitsiConfigOptions customJitsiConfigOptions,
    required VoidCallback onRoomIdNotSetup,
  }) async {
    try {
      Map<FeatureFlagEnum, bool> featureFlag = Map<FeatureFlagEnum, bool>();
      FeatureFlagEnum.values.forEach((element) {
        print(element);
        featureFlag.putIfAbsent(element, () => true);
      });

      String? name = customJitsiConfigOptions.userDisplayName;
      if (name == null || name.isEmpty) {
        name = "Life account-${DateTime.now().second}";
      }

      if (customJitsiConfigOptions.room.isEmpty) {
        onRoomIdNotSetup();
        return;
      }

      String? userAuthencation = customJitsiConfigOptions.userAuthencation;
      var options = JitsiMeetingOptions(room: customJitsiConfigOptions.room)
        ..subject = customJitsiConfigOptions.subject
        ..userDisplayName = name
        ..userEmail = userAuthencation
        ..userAvatarURL = customJitsiConfigOptions.userAvatarURL
        ..videoMuted = customJitsiConfigOptions.videoMuted
        ..audioMuted = customJitsiConfigOptions.audioMuted
        ..audioOnly = customJitsiConfigOptions.audioOnly
        ..serverURL = customJitsiConfigOptions.serverURL
        ..token = customJitsiConfigOptions.token
        ..featureFlags = featureFlag;
      _firestoreMethods.addToMeetingHistory(customJitsiConfigOptions.room);
      await JitsiMeet.joinMeeting(options);
    } catch (error) {
      print("error: $error");
    }
  }
}
