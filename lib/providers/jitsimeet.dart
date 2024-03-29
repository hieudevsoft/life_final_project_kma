import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:path/path.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:uvid/common/constants.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/custom_jitsi_config_options.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/providers/auth.dart';
import 'package:uvid/providers/firestore.dart';

class JitsiMeetProviders {
  JitsiMeetProviders._() {
    _initData();
  }
  static get _instance => JitsiMeetProviders._();
  factory JitsiMeetProviders() {
    return _instance;
  }
  Profile? _profile = null;
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();
  var currentTime = getTimeNowInWholeMilliseconds();
  String? _deviceId = null;
  _initData() async {
    _profile = await LocalStorage().getProfile();
    _deviceId = await PlatformDeviceId.getDeviceId;
  }

  void createMeeting({
    required CustomJitsiConfigOptions customJitsiConfigOptions,
    required VoidCallback onRoomIdNotSetup,
    required VoidCallback onError,
    bool isOwnerRoom = true,
  }) async {
    try {
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
        ..serverURL = serverUrl
        ..videoMuted = customJitsiConfigOptions.videoMuted
        ..audioMuted = customJitsiConfigOptions.audioMuted
        ..audioOnly = customJitsiConfigOptions.audioOnly;
      if (customJitsiConfigOptions.serverURL != null && customJitsiConfigOptions.serverURL!.isNotEmpty) {
        options.serverURL = customJitsiConfigOptions.serverURL!;
      }
      if (customJitsiConfigOptions.token != null && customJitsiConfigOptions.token!.isNotEmpty) {
        options.token = customJitsiConfigOptions.serverURL!;
      }
      currentTime = getTimeNowInWholeMilliseconds();
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(
          onConferenceJoined: (message) {
            debugPrint("${options.room} onConferenceJoined: $message");
            if (isOwnerRoom) {
              _ref.child(MEETING_COOLECTION).child(customJitsiConfigOptions.room).child('owner').set({
                "id": _profile == null ? _deviceId : _profile!.uniqueId,
                "name": customJitsiConfigOptions.userDisplayName,
                "avatar": customJitsiConfigOptions.userAvatarURL,
                "description": customJitsiConfigOptions.subject,
                "created_at": currentTime,
                "exited_at": 0,
              });
            } else {
              _ref
                  .child(MEETING_COOLECTION)
                  .child(customJitsiConfigOptions.room)
                  .child('members')
                  .child(_profile == null ? 'Life-guess-$_deviceId}' : _profile!.uniqueId!)
                  .set({
                "name": customJitsiConfigOptions.userDisplayName,
                "avatar": customJitsiConfigOptions.userAvatarURL,
                "joined_at": currentTime,
                "exited_at": 0,
              });
            }
          },
          onPictureInPictureTerminated: (message) {
            debugPrint("${options.room} onPictureInPictureTerminated: $message");
            updateExitRoom(isOwnerRoom, customJitsiConfigOptions.room);
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} onConferenceTerminated: $message");
            updateExitRoom(isOwnerRoom, customJitsiConfigOptions.room);
          },
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} onConferenceWillJoin: $message");
          },
          onPictureInPictureWillEnter: (message) {
            debugPrint("${options.room} onPictureInPictureWillEnter: $message");
          },
        ),
      );
    } catch (error) {
      onError.call();
    }
  }

  void updateExitRoom(bool isOwnerRoom, String room) {
    if (isOwnerRoom) {
      _ref.child(MEETING_COOLECTION).child(room).child('owner').update({
        "exited_at": getTimeNowInWholeMilliseconds(),
      });
    } else {
      _ref
          .child(MEETING_COOLECTION)
          .child(room)
          .child('members')
          .child(_profile == null ? 'Life-guess-$_deviceId}' : _profile!.uniqueId!)
          .update({
        "exited_at": getTimeNowInWholeMilliseconds(),
      });
    }
  }
}
