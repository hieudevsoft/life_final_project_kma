import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvid/common/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/audio_mode.dart';
import 'package:uvid/domain/models/contact_model.dart';
import 'package:uvid/domain/models/custom_jitsi_config_options.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/domain/models/video_mode.dart';
import 'package:uvid/providers/jitsimeet.dart';
import 'package:uvid/ui/app.dart';
import 'package:uvid/ui/screens/contact_screen.dart';
import 'package:uvid/ui/screens/history_meeting_screen.dart';
import 'package:uvid/ui/screens/setting_screen.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/ui/widgets/page_animation/single_route_scale_builder.dart';
import 'package:uvid/ui/widgets/painter/custom_shape_painter.dart';
import 'package:uvid/utils/routes.dart';
import 'package:uvid/utils/state_managment/friend_manager.dart';
import 'package:uvid/utils/state_managment/home_manager.dart';
import 'package:uvid/utils/utils.dart';

import '../../utils/notifications.dart';
import '../screens/meeting_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  final pages = [
    const MeetingScreen(),
    const ContactScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      lowerBound: 0.3,
      upperBound: 1,
    );
    _scaleAnimation = CurvedAnimation(parent: _scaleAnimationController, curve: Curves.fastOutSlowIn);
    _scaleAnimationController.repeat(reverse: true);
    context.read<FriendManager>()
      ..trackCall(
        onCalling: (profile) {
          _buildDialogPhoneCall(profile, context);
        },
        onCallingCancelled: () {
          if (isThereCurrentDialogShowing(context)) {
            Navigator.pop(context);
          }
        },
        onAcceptCalling: (meetingId) {
          if (isThereCurrentDialogShowing(context)) {
            Navigator.pop(context);
          }
          joinMeeting(context, meetingId, false);
        },
      )
      ..trackOnReceivedCalling(
        () {
          _buildDialogWaitingPhoneCall();
        },
        () {
          if (isThereCurrentDialogShowing(context)) {
            Navigator.pop(context);
          }
        },
      );
    NotificationManager().checkedAllowed(() {
      NotificationManager().showDialogRequestPermission(context);
    });
    NotificationManager().notificationStream.listen((notification) {
      if (Platform.isIOS) {
        NotificationManager().decreaseBadgeNotification();
      }
      if (notification.channelKey == NotificationManager.basicNotificationChannelKey) {
        // Navigator.push(
        //   context,
        //   SingleRouteScaleBuilder(mtAppKey: mtAppKey, routeName: AppRoutesDirect.notification.route),
        // );
      } else {
        Navigator.push(
          context,
          SingleRouteScaleBuilder(mtAppKey: mtAppKey, routeName: AppRoutesDirect.scheduleCalendar.route),
        );
      }
    });
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.tertiary,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          context.read<HomeManager>().page == 0
              ? AppLocalizations.of(context)!.meet_and_chat_title
              : context.read<HomeManager>().page == 1
                  ? AppLocalizations.of(context)!.contacts
                  : AppLocalizations.of(context)!.settings,
          style: context.textTheme.bodyText1?.copyWith(
            color: context.colorScheme.onTertiary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.colorScheme.tertiary,
        foregroundColor: context.colorScheme.onTertiary,
      ),
      body: IndexedStack(
        children: pages,
        index: context.watch<HomeManager>().page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: context.colorScheme.tertiary,
        selectedItemColor: context.colorScheme.onTertiary,
        elevation: 10,
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 16,
        showUnselectedLabels: false,
        onTap: context.read<HomeManager>().onPageChanged,
        currentIndex: context.watch<HomeManager>().page,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.video_call_rounded,
            ),
            label: AppLocalizations.of(context)!.meet_and_chat,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.contacts_rounded,
            ),
            label: AppLocalizations.of(context)!.contacts,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_rounded,
            ),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }

  _buildDialogPhoneCall(Profile profile, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.phone_enabled_rounded),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        iconColor: context.colorScheme.onPrimary,
        backgroundColor: context.colorScheme.primary,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: profile.photoUrl == null
                    ? Image.asset(
                        'assets/ic_launcher.png',
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      )
                    : profile.avatarUrlIsLink
                        ? Image.network(
                            profile.photoUrl!,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                          )
                        : Image.memory(
                            base64Decode(profile.photoUrl!),
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                          ),
              ),
            ),
            Text(
              '${profile.name == null ? 'No name' : profile.name}',
              style: context.textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${profile.email == null ? profile.phoneNumber : profile.email}',
              style: context.textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            ScaleTransition(
              scale: _scaleAnimation,
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                splashColor: getEndColorCute(3),
                elevation: 12,
                mini: true,
                child: Icon(Icons.phone_disabled_rounded),
                onPressed: () {
                  context.read<FriendManager>().cancelCalling();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildDialogWaitingPhoneCall() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      useSafeArea: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.phone_enabled_rounded),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        iconColor: Colors.white,
        backgroundColor: Colors.black.withOpacity(0.5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: context.watch<FriendManager>().waittingsCalling.map((e) {
            final index = Random().nextInt(100);
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            getStartColorCute(index),
                            getEndColorCute(index),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: getStartColorCute(index),
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      top: 0,
                      child: CustomPaint(
                        size: Size(100, 100),
                        painter: CustomCardShapePainter(
                          20,
                          getStartColorCute(index),
                          getEndColorCute(index),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          gapH8,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: e.urlLinkImage == null
                                ? Image.asset(
                                    'assets/ic_launcher.png',
                                    height: 64,
                                    width: 64,
                                    fit: BoxFit.cover,
                                  )
                                : e.urlLinkImage!.contains('http')
                                    ? Image.network(
                                        e.urlLinkImage!,
                                        fit: BoxFit.cover,
                                        height: 64,
                                        width: 64,
                                      )
                                    : Image.memory(
                                        base64Decode(e.urlLinkImage!),
                                        fit: BoxFit.cover,
                                        height: 64,
                                        width: 64,
                                      ),
                          ),
                          gapH16,
                          Text(
                            e.name.toString(),
                            style: context.textTheme.bodyText1?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            e.description.toString(),
                            style: context.textTheme.bodyText1?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white70.withOpacity(0.5),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                heroTag: null,
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                splashColor: getEndColorCute(index),
                                elevation: 12,
                                mini: true,
                                child: Icon(Icons.phone_disabled_rounded),
                                onPressed: () {
                                  if (e.keyId != null) {
                                    context.read<FriendManager>().removingCall(e.keyId!, () {
                                      if (isThereCurrentDialogShowing(context)) {
                                        Navigator.pop(context);
                                      }
                                    });
                                  }
                                },
                              ),
                              gapH8,
                              FloatingActionButton(
                                heroTag: null,
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.white,
                                splashColor: getEndColorCute(index),
                                elevation: 12,
                                mini: true,
                                child: Icon(Icons.phone_enabled),
                                onPressed: () {
                                  if (e.keyId != null) {
                                    context.read<FriendManager>().acceptCalling(e.keyId!, (meetingId) {
                                      joinMeeting(context, meetingId, true);
                                    });
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

isThereCurrentDialogShowing(BuildContext context) => ModalRoute.of(context)?.isCurrent != true;

joinMeeting(BuildContext context, String meetingId, bool isOwner) async {
  final profile = await LocalStorage().getProfile();
  final audioIsMute = await LocalStorage().getAudioMode() == AudioMode.OFF;
  final videoIsMute = await LocalStorage().getVideoMode() == VideoMode.OFF;
  final userDisplayName = profile?.name == null
      ? profile?.phoneNumber == null
          ? ''
          : profile!.phoneNumber
      : profile!.email;
  String avatarProfile = '';
  if (profile != null) {
    avatarProfile = profile.avatarUrlIsLink ? profile.photoUrl ?? '' : '';
  }

  final CustomJitsiConfigOptions jitsiConfigOptions = CustomJitsiConfigOptions(
    room: meetingId,
    audioMuted: audioIsMute,
    videoMuted: videoIsMute,
    userDisplayName: userDisplayName,
    userAvatarURL: avatarProfile,
    userAuthencation: profile?.email ?? profile?.phoneNumber,
  );
  JitsiMeetProviders().createMeeting(
    customJitsiConfigOptions: jitsiConfigOptions,
    isOwnerRoom: isOwner,
    onRoomIdNotSetup: () {
      Utils().showToast(
        AppLocalizations.of(context)!.room_id_must_not_empty,
        backgroundColor: Colors.redAccent.shade200,
      );
    },
    onError: () {
      Utils().showToast(
        AppLocalizations.of(context)!.some_thing_went_wrong,
        backgroundColor: Colors.redAccent.shade200,
      );
    },
  );
}
